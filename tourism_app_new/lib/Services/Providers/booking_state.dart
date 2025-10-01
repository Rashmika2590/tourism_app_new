// Services/Providers/booking_state.dart - Enhanced with search location context
import 'package:flutter/material.dart';

class BookingState extends ChangeNotifier {
  // Existing booking properties
  DateTime _checkInDate = DateTime.now();
  TimeOfDay _checkInTime = TimeOfDay.now();
  int _duration = 1;
  int _adults = 1;
  int _children = 0;
  String _state = '';
  double? _latitude;
  double? _longitude;

  // New location-based search properties
  double? _searchLatitude;
  double? _searchLongitude;
  double _searchRadius = 20.0; // Default radius in km
  String _searchLocationName = '';
  bool _useCurrentLocation = true;

  // Getters for existing properties
  DateTime get checkInDate => _checkInDate;
  TimeOfDay get checkInTime => _checkInTime;
  int get duration => _duration;
  int get adults => _adults;
  int get children => _children;
  String get state => _state;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Getters for new location properties
  double? get searchLatitude => _searchLatitude;
  double? get searchLongitude => _searchLongitude;
  double get searchRadius => _searchRadius;
  String get searchLocationName => _searchLocationName;
  bool get useCurrentLocation => _useCurrentLocation;

  // Check if search location is set
  bool get hasSearchLocation =>
      _searchLatitude != null && _searchLongitude != null;

  // Existing setters
  void setCheckInDate(DateTime date) {
    _checkInDate = date;
    notifyListeners();
  }

  void setCheckInTime(TimeOfDay time) {
    _checkInTime = time;
    notifyListeners();
  }

  void setDuration(int duration) {
    _duration = duration;
    notifyListeners();
  }

  void setGuests({required int adultCount, required int childrenCount}) {
    _adults = adultCount;
    _children = childrenCount;
    notifyListeners();
  }

  void setState(String state) {
    _state = state;
    notifyListeners();
  }

  // New location-based setters
  void setSearchLocation({
    required double latitude,
    required double longitude,
    String locationName = '',
    bool useCurrentLocation = false,
  }) {
    _searchLatitude = latitude;
    _searchLongitude = longitude;
    _searchLocationName = locationName;
    _useCurrentLocation = useCurrentLocation;
    notifyListeners();
  }

  void setSearchRadius(double radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  void setUseCurrentLocation(bool useCurrentLocation) {
    _useCurrentLocation = useCurrentLocation;
    notifyListeners();
  }

  void clearSearchLocation() {
    _searchLatitude = null;
    _searchLongitude = null;
    _searchLocationName = '';
    _useCurrentLocation = true;
    notifyListeners();
  }

  void setCoordinates(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  // Helper method to get search location display name
  String getSearchLocationDisplayName() {
    if (_searchLocationName.isNotEmpty) {
      return _searchLocationName;
    } else if (_useCurrentLocation) {
      return 'Current Location';
    } else if (hasSearchLocation) {
      return 'Selected Location';
    } else {
      return 'No Location Set';
    }
  }

  // Method to copy current search context (useful for passing to result screens)
  Map<String, dynamic> getSearchContext() {
    return {
      'latitude': _searchLatitude,
      'longitude': _searchLongitude,
      'radius': _searchRadius,
      'locationName': getSearchLocationDisplayName(),
      'useCurrentLocation': _useCurrentLocation,
      'checkInDate': _checkInDate,
      'checkInTime': _checkInTime,
      'duration': _duration,
      'adults': _adults,
      'children': _children,
    };
  }

  // Reset all booking data
  void reset() {
    _checkInDate = DateTime.now();
    _checkInTime = TimeOfDay.now();
    _duration = 1;
    _adults = 1;
    _children = 0;
    _state = '';
    _searchLatitude = null;
    _searchLongitude = null;
    _searchRadius = 20.0;
    _searchLocationName = '';
    _useCurrentLocation = true;
    notifyListeners();
  }
}
