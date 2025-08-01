import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExpandableMapWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const ExpandableMapWidget({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  _ExpandableMapWidgetState createState() => _ExpandableMapWidgetState();
}

class _ExpandableMapWidgetState extends State<ExpandableMapWidget> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(6.9271, 79.8612); // Colombo

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height:
                    widget.isExpanded ? 500 : 250, // <-- Increased height here
                child: Stack(
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
                          shadows: [
                            const BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _center,
                              zoom: 15.0,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            markers: {
                              Marker(
                                markerId: MarkerId('property_location'),
                                position: _center,
                                infoWindow: InfoWindow(
                                  title: 'Property Location',
                                  snippet: 'Luxury Villa in Colombo',
                                ),
                              ),
                            },
                          ),
                        ),
                      ),
                    ),

                    // Toggle button inside the map container at bottom-right
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onToggle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
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
                                color: Color(0xFF00215A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isExpanded ? 'Hide map' : 'View map',
                                style: const TextStyle(
                                  color: Color(0xFF00215A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: widget.isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(
                                  Icons.expand_less,
                                  color: Color(0xFF00215A),
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
                        left: 16,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: widget.onToggle,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[600],
                          child: Icon(Icons.close),
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
