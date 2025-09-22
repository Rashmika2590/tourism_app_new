// services/location_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// A service class for handling location-related functionalities.
class LocationService {
  /// Converts a location name (e.g., "Colombo") into geographical coordinates.
  ///
  /// Throws an exception if the location cannot be found.
  static Future<LatLng> getCoordinatesFromLocationName(
      String locationName) async {
    try {
      final locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      } else {
        throw Exception('Location not found.');
      }
    } catch (e) {
      throw Exception('Failed to get coordinates from location name: $e');
    }
  }

  /// Checks and requests location permissions.
  ///
  /// Returns `true` if permissions are granted, otherwise `false`.
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't request permission.
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied.
      return false;
    }

    return true;
  }


  /// Fetches the current geographical position of the device.
  ///
  /// Throws an exception if location services are disabled or permissions are denied.
  static Future<Position> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) {
      throw Exception('Location permissions are denied.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Converts a [Position] object to a user-friendly [Placemark].
  ///
  /// Returns the first placemark found for the given coordinates.
  /// Throws an exception if no placemark is found.
  static Future<Placemark> getPlacemarkFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      } else {
        throw Exception('No placemark found for the current location.');
      }
    } catch (e) {
      throw Exception('Failed to get placemark: $e');
    }
  }
}
