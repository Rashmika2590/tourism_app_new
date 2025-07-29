import 'dart:ui';

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
  final LatLng _center = const LatLng(6.9271, 79.8612); // Colombo coordinates

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Google Map
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.isExpanded ? 0 : 16),
              bottomRight: Radius.circular(widget.isExpanded ? 0 : 16),
            ),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // We'll use custom button
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

          // Expand/Collapse Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: widget.onToggle,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[600],
              child: AnimatedRotation(
                duration: Duration(milliseconds: 300),
                turns: widget.isExpanded ? 0.5 : 0,
                child: Icon(Icons.expand_less, size: 24),
              ),
            ),
          ),

          // Close button when expanded
          if (widget.isExpanded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
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
    );
  }
}
