import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/property_details_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tourism_app_new/widgets/hotel_card.dart';

class PropertyListPage extends StatefulWidget {
  final String city;
  final double? latitude;
  final double? longitude;
  final double? radius;

  const PropertyListPage({
    super.key,
    required this.city,
    this.latitude,
    this.longitude,
    this.radius,
  });

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<List<Hotel>> _filteredHotels;
  LatLng? _targetLocation;

  @override
  void initState() {
    super.initState();
    _filteredHotels = _fetchHotels();
    _loadLocation();
  }

  Future<List<Hotel>> _fetchHotels() async {
    try {
      if (widget.latitude != null &&
          widget.longitude != null &&
          widget.radius != null) {
        return await HotelApiService.searchHotels(
          latitude: widget.latitude,
          longitude: widget.longitude,
          radiusKm: widget.radius,
        );
      } else {
        return await HotelApiService.searchHotels(state: widget.city);
      }
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load hotels: $e')),
      );
      return [];
    }
  }

  Future<void> _loadLocation() async {
    try {
      if (widget.latitude != null && widget.longitude != null) {
        setState(() {
          _targetLocation = LatLng(widget.latitude!, widget.longitude!);
        });
        return;
      } else {
        List<Location> locations = await locationFromAddress(widget.city);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          setState(() {
            _targetLocation = LatLng(loc.latitude, loc.longitude);
          });
        }
      }
    } catch (e) {
      print('Error finding location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found for "${widget.city}"')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.city == "Nearby"
        ? "Nearby Properties"
        : 'Properties in ${widget.city}';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: FutureBuilder<List<Hotel>>(
        future: _filteredHotels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return const Center(child: Text('No properties found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_targetLocation != null)
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _targetLocation!,
                        zoom: 12.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("searchCity"),
                          position: _targetLocation!,
                          infoWindow: InfoWindow(title: widget.city),
                        ),
                        ...hotels.map((hotel) => Marker(
                              markerId: MarkerId(hotel.id.toString()),
                              position: LatLng(hotel.latitude, hotel.longitude),
                              infoWindow: InfoWindow(title: hotel.name),
                            )),
                      },
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return HotelCard(
                        hotel: hotel,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PropertyDetailsPage(hotelId: hotel.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}