// expandable_map_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism_app_new/Services/Location/location_service.dart';
import 'package:tourism_app_new/constants/colors.dart';

class ExpandableMapWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? location;

  const ExpandableMapWidget({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.location,
  }) : super(key: key);

  @override
  _ExpandableMapWidgetState createState() => _ExpandableMapWidgetState();
}

class _ExpandableMapWidgetState extends State<ExpandableMapWidget> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(6.9271, 79.8612); // Default to Colombo
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LatLng coordinates;
      String locationName;

      if (widget.location != null && widget.location!.isNotEmpty) {
        // If a location name is provided, geocode it
        coordinates = await LocationService.getCoordinatesFromLocationName(
          widget.location!,
        );
        locationName = widget.location!;
      } else {
        // Otherwise, get the user's current location
        final position = await LocationService.getCurrentPosition();
        coordinates = LatLng(position.latitude, position.longitude);
        // Get a user-friendly name for the current location
        final placemark = await LocationService.getPlacemarkFromPosition(
          position,
        );
        locationName =
            placemark.locality ??
            placemark.administrativeArea ??
            'Current Location';
      }

      setState(() {
        _center = coordinates;
        _markers.clear(); // Clear old markers
        _markers.add(
          Marker(
            markerId: const MarkerId('property_location'),
            position: _center,
            infoWindow: InfoWindow(
              title: locationName,
              snippet: 'Property is located here',
            ),
          ),
        );
        _isLoading = false;
      });

      // Animate camera to the new location if the controller is ready
      mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 15.0));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally, show a snackbar or a message on the map
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading map: $e')));
      print('Error loading location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // If we already have the location, move the camera
    if (!_isLoading) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_center, 15.0));
    }
  }

  @override
  void didUpdateWidget(ExpandableMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload location if it changed
    if (oldWidget.location != widget.location) {
      _loadLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: widget.isExpanded ? 650 : 180,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: widget.isExpanded ? 600 : 150,
                child: Stack(
                  clipBehavior:
                      Clip.none, // 👈 allow button to overflow outside
                  children: [
                    // Map container
                    Positioned.fill(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child:
                              _isLoading
                                  ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                  : GoogleMap(
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: CameraPosition(
                                      target: _center,
                                      zoom: 15.0,
                                    ),
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled:
                                        true, // 👈 disable native zoom buttons
                                    zoomGesturesEnabled: true,
                                    scrollGesturesEnabled: true,
                                    rotateGesturesEnabled: true,
                                    tiltGesturesEnabled: true,
                                    gestureRecognizers:
                                        <Factory<OneSequenceGestureRecognizer>>{
                                          Factory<OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer(),
                                          ),
                                        },
                                    markers: _markers,
                                  ),
                        ),
                      ),
                    ),

                    // Toggle button - half inside, half outside
                    Positioned(
                      bottom: -20, // 👈 push down so half is outside
                      //left: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onToggle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map,
                                size: 17,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isExpanded ? 'Hide map' : 'View map',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: widget.isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.expand_more,
                                  color: Colors.grey[800],
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Close button (when expanded)
                    if (widget.isExpanded)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: widget.onToggle,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[600],
                          child: const Icon(Icons.close),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
