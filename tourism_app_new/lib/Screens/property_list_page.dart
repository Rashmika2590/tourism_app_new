import 'package:flutter/material.dart';
import 'package:tourism_app_new/widgets/post_searching_dropdowns.dart';
import 'package:tourism_app_new/core/services/api_service.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tourism_app_new/widgets/property_card.dart'; // Import PropertyCard

class PropertyListPage extends StatefulWidget {
  final String city;

  const PropertyListPage({super.key, required this.city});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<List<Property>> _filteredProperties;
  LatLng? _targetLocation;

  @override
  void initState() {
    super.initState();
    _filteredProperties = fetchFilteredPropertiesByCity(widget.city);
    _loadLocationFromCity();
  }

  Future<void> _loadLocationFromCity() async {
    try {
      List<Location> locations = await locationFromAddress(widget.city);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _targetLocation = LatLng(loc.latitude, loc.longitude);
        });
      }
    } catch (e) {
      print('Error finding location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found for "${widget.city}"')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  Future<List<Property>> fetchFilteredPropertiesByCity(String city) async {
    try {
      final normalizedCity = city.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final allProperties = await ApiService.filterProperties({}, city: city);

      for (var p in allProperties) {
        print("🔍 Property: ${p.propertyName} | City: ${p.address.city}");
      }

      return allProperties
          .where((p) => (p.address.city).toLowerCase().contains(normalizedCity))
          .toList();
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Properties in ${widget.city}')),
      body: FutureBuilder<List<Property>>(
        future: _filteredProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data!;
          print("🧱 UI Rendering ${properties.length} property cards");

          if (properties.isEmpty) {
            return const Center(child: Text('No properties found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🗺️ Google Map
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
                // 🔽 Property Cards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
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
                              builder: (context) => HotelBookingScreen(),
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
