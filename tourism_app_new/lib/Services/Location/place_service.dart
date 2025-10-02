import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _apiKey = 'AIzaSyC3d7coKXELrnxFCwCJ2ku2bhqnNpEo7';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Method to find nearest places
  static Future<List<Place>> findNearbyPlaces(
    double latitude,
    double longitude,
    String
    type, // e.g., 'gas_station', 'hospital', 'restaurant', 'train_station'
    int radius,
  ) async {
    final String url =
        '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<Place> places = [];

          for (var result in data['results']) {
            // Calculate distance
            double distance = await _calculateDistance(
              latitude,
              longitude,
              result['geometry']['location']['lat'],
              result['geometry']['location']['lng'],
            );

            places.add(
              Place(name: result['name'], distance: distance, type: type),
            );
          }

          // Sort by distance and return the closest one
          places.sort((a, b) => a.distance.compareTo(b.distance));
          return places;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching places: $e');
      return [];
    }
  }

  // Calculate distance using Haversine formula
  static Future<double> _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
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

    return earthRadius * c; // distance in kilometers
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}

class Place {
  final String name;
  final double distance;
  final String type;

  Place({required this.name, required this.distance, required this.type});

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
