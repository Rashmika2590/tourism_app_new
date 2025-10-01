import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism_app_new/Screens/property_details_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:tourism_app_new/widgets/property_card.dart';

class PropertyListPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const PropertyListPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late final Future<List<Property>> _propertiesFuture;
  late final LatLng _targetLocation;

  @override
  void initState() {
    super.initState();
    _targetLocation = LatLng(widget.latitude, widget.longitude);
    _propertiesFuture =
        _fetchPropertiesByLocation(widget.latitude, widget.longitude);
  }

  // Fetch properties based on location
  Future<List<Property>> _fetchPropertiesByLocation(
    double lat,
    double lng,
  ) async {
    try {
      // Step 1: Get availability based on location
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: DateTime.now(),
        checkInTime: "14:00", // Example check-in time
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
        checkOutTime: "12:00", // Example check-out time
        latitude: lat,
        longitude: lng,
        maxDistanceKm: 10, // Search within a 10km radius
      );

      if (!availability.hasAvailableRooms()) {
        return []; // No rooms available
      }

      // Step 2: Fetch details for each available hotel
      final hotelIds = availability.hotelIds;
      final properties = await HotelApiService.getHotelsByIds(hotelIds);

      return properties;
    } catch (e) {
      debugPrint('Error fetching properties by location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load properties: $e')),
      );
      return [];
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Properties near ${widget.locationName}')),
      body: FutureBuilder<List<Property>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data;
          if (properties == null || properties.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Google Map
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _targetLocation,
                      zoom: 12.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("searchLocation"),
                        position: _targetLocation,
                        infoWindow: InfoWindow(title: widget.locationName),
                      ),
                      // Add markers for each property
                      ...properties.map(
                        (p) => Marker(
                          markerId: MarkerId(p.id),
                          position: LatLng(
                            p.address.latitude,
                            p.address.longitude,
                          ),
                          infoWindow: InfoWindow(title: p.propertyName),
                        ),
                      ),
                    },
                    myLocationEnabled: true,
                  ),
                ),
                // Property Cards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return PropertyCard(
                        property: property,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PropertyDetailsPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}