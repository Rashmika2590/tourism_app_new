// nearest_places_widget.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:tourism_app_new/Services/Location/place_service.dart';
import 'package:tourism_app_new/constants/colors.dart';

class NearestPlacesWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearestPlacesWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<NearestPlacesWidget> createState() => _NearestPlacesWidgetState();
}

class _NearestPlacesWidgetState extends State<NearestPlacesWidget> {
  final Map<String, Place?> _nearestPlaces = {
    'gas_station': null,
    'hospital': null,
    'restaurant': null,
    'train_station': null,
  };

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAllNearestPlaces();
  }

  Future<void> _fetchAllNearestPlaces() async {
    try {
      // Define place types with their search radius
      final placeTypes = [
        {'type': 'gas_station', 'radius': 5000},
        {'type': 'hospital', 'radius': 5000},
        {'type': 'restaurant', 'radius': 3000},
        {'type': 'train_station', 'radius': 10000},
      ];

      // Fetch all places in parallel
      final List<Future<List<Place>>> futures =
          placeTypes.map((placeType) {
            return _findNearbyPlaces(
              widget.latitude,
              widget.longitude,
              placeType['type'] as String,
              placeType['radius'] as int,
            );
          }).toList();

      final results = await Future.wait(futures);

      setState(() {
        _nearestPlaces['gas_station'] =
            results[0].isNotEmpty ? results[0].first : null;
        _nearestPlaces['hospital'] =
            results[1].isNotEmpty ? results[1].first : null;
        _nearestPlaces['restaurant'] =
            results[2].isNotEmpty ? results[2].first : null;
        _nearestPlaces['train_station'] =
            results[3].isNotEmpty ? results[3].first : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching nearest places: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<List<Place>> _findNearbyPlaces(
    double latitude,
    double longitude,
    String type,
    int radius,
  ) async {
    const String apiKey = 'AIzaSyC3d7coKXELrnxFCwCJ2ku2bhqnNpEo7-s';
    const String baseUrl = 'https://maps.googleapis.com/maps/api/place';

    final String url =
        '$baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<Place> places = [];

          for (var result in data['results']) {
            double distance = _calculateDistance(
              latitude,
              longitude,
              result['geometry']['location']['lat'],
              result['geometry']['location']['lng'],
            );

            places.add(
              Place(
                name: result['name'],
                distance: distance,
                type: type,
                //address: result['vicinity'] ?? 'Address not available',
              ),
            );
          }

          // Sort by distance and return the closest one
          places.sort((a, b) => a.distance.compareTo(b.distance));
          return places;
        } else {
          print('Places API error: ${data['status']} for type: $type');
        }
      }
      return [];
    } catch (e) {
      print('Error fetching $type places: $e');
      return [];
    }
  }

  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const double earthRadius = 6371; // kilometers

    double dLat = _toRadians(endLat - startLat);
    double dLng = _toRadians(endLng - startLng);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void _onRetry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _fetchAllNearestPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearest Public Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          _buildLoadingWidget()
        else if (_hasError)
          _buildErrorWidget()
        else
          _buildFacilitiesGrid(),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Finding nearest facilities...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 40),
          const SizedBox(height: 12),
          const Text(
            'Failed to load nearby facilities',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFacilityItem(
                Icons.local_gas_station,
                'Petrol Station',
                _nearestPlaces['gas_station']?.formattedDistance ?? 'Not found',
                _nearestPlaces['gas_station']?.name,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFacilityItem(
                Icons.local_hospital_outlined,
                'Hospital',
                _nearestPlaces['hospital']?.formattedDistance ?? 'Not found',
                _nearestPlaces['hospital']?.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFacilityItem(
                Icons.restaurant,
                'Restaurant',
                _nearestPlaces['restaurant']?.formattedDistance ?? 'Not found',
                _nearestPlaces['restaurant']?.name,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFacilityItem(
                Icons.train,
                'Train Station',
                _nearestPlaces['train_station']?.formattedDistance ??
                    'Not found',
                _nearestPlaces['train_station']?.name,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityItem(
    IconData icon,
    String title,
    String distance,
    String? placeName,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Single Icon aligned with both Type + Distance
              Padding(
                padding: const EdgeInsets.only(top: 10), // fine-tune alignment
                child: Icon(icon, size: 32, color: AppColors.mainGreen),
              ),

              const SizedBox(width: 12),

              // Type + Distance stacked
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distance,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (placeName != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                placeName!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
