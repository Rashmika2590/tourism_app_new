import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/property_details_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tourism_app_new/widgets/property_card.dart'; // Import PropertyCard

class PropertyListPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int adultCount;
  final int childrenCount;
  final String checkInDate;
  final String checkInTime;
  final String checkOutDate;
  final String checkOutTime;

  const PropertyListPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.adultCount,
    required this.childrenCount,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
  });

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<List<Property>> _properties;

  @override
  void initState() {
    super.initState();
    _properties = _fetchProperties();
  }

  Future<List<Property>> _fetchProperties() async {
    try {
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: DateTime.parse(widget.checkInDate),
        checkInTime: widget.checkInTime,
        checkOutDate: DateTime.parse(widget.checkOutDate),
        coTime: widget.checkOutTime,
        latitude: widget.latitude,
        longitude: widget.longitude,
        maxDistanceKm: 50, // Default search radius
        adultCount: widget.adultCount,
        childrenCount: widget.childrenCount,
      );

      if (!availability.hasAvailableRooms()) {
        return [];
      }

      final List<Future<Hotel>> futureHotels = availability.hotelIds
          .map((id) => HotelApiService.getHotelById(id))
          .toList();

      final hotels = await Future.wait(futureHotels);

      return hotels.map((hotel) => _mapHotelToProperty(hotel)).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load properties: $e')),
      );
      return [];
    }
  }

  Property _mapHotelToProperty(Hotel hotel) {
    return Property(
      id: hotel.id.toString(),
      propertyName: hotel.name,
      address: Address(
        no: '',
        street: hotel.address,
        city: hotel.state,
        province: '',
        country: '',
        postalCode: hotel.postalCode,
        latitude: hotel.latitude,
        longitude: hotel.longitude,
      ),
      propertyImage: PropertyImage(
        primaryImageUrl: hotel.images.isNotEmpty ? hotel.images.first : '',
        secondaryImages: hotel.images.length > 1 ? hotel.images.sublist(1) : [],
      ),
      rating: Rating(
        userId: '',
        rating: hotel.rating ?? 0.0,
        comment: '',
      ),
      propertyType: 1,
      availability: 1,
      allowShortStays: hotel.enableShortStay,
      allowLongStays: hotel.enableLongStay,
      userRole: 0,
      numOfHours: 0,
      guestStayType: 1,
      guestCapacities: [],
      packages: [],
    );
  }

  void _onMapCreated(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Properties')),
      body: FutureBuilder<List<Property>>(
        future: _properties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data!;
          if (properties.isEmpty) {
            return const Center(child: Text('No properties found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: 12.0,
                    ),
                    markers: properties
                        .map(
                          (p) => Marker(
                            markerId: MarkerId(p.id),
                            position: LatLng(
                              p.address.latitude,
                              p.address.longitude,
                            ),
                            infoWindow: InfoWindow(title: p.propertyName),
                          ),
                        )
                        .toSet(),
                  ),
                ),
                ListView.builder(
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
                            builder: (context) => PropertyDetailsPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
