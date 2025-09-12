// services/location_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Convert location name to coordinates
  static Future<LatLng> getCoordinatesFromLocation(String locationName) async {
    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
      throw Exception('Location not found');
    } catch (e) {
      // Fallback to current location if location name conversion fails
      return await getCurrentLocation();
    }
  }

  // Get current device location
  static Future<LatLng> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Fallback to a default location (Colombo)
      return const LatLng(6.9271, 79.8612);
    }
  }

  // Get location coordinates based on provided location or current location
  static Future<LatLng> getLocationCoordinates(String? locationName) async {
    if (locationName != null && locationName.isNotEmpty) {
      return await getCoordinatesFromLocation(locationName);
    } else {
      return await getCurrentLocation();
    }
  }
}
