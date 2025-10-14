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

  // Location-based search properties
  double? _searchLatitude;
  double? _searchLongitude;
  double _searchRadius = 20.0;
  String _searchLocationName = '';
  bool _useCurrentLocation = true;

  // Guest booking properties
  bool _isBookingForSomeoneElse = false;
  String _guestName = '';
  String _guestEmail = '';
  String _guestPhone = '';
  String _relationshipToUser = '';
  String _specialRequest = '';

  // Getters for existing properties
  DateTime get checkInDate => _checkInDate;
  TimeOfDay get checkInTime => _checkInTime;
  int get duration => _duration;
  int get adults => _adults;
  int get children => _children;
  String get state => _state;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Getters for location properties
  double? get searchLatitude => _searchLatitude;
  double? get searchLongitude => _searchLongitude;
  double get searchRadius => _searchRadius;
  String get searchLocationName => _searchLocationName;
  bool get useCurrentLocation => _useCurrentLocation;
  bool get hasSearchLocation =>
      _searchLatitude != null && _searchLongitude != null;

  // Getters for guest booking
  bool get isBookingForSomeoneElse => _isBookingForSomeoneElse;
  String get guestName => _guestName;
  String get guestEmail => _guestEmail;
  String get guestPhone => _guestPhone;
  String get relationshipToUser => _relationshipToUser;
  String get specialRequest => _specialRequest;

  // Setters for existing properties
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

  // Setters for location properties
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

  // Setters for guest booking
  void setBookingForSomeoneElse(bool value) {
    _isBookingForSomeoneElse = value;
    if (!value) {
      _guestName = '';
      _guestEmail = '';
      _guestPhone = '';
      _relationshipToUser = '';
    }
    notifyListeners();
  }

  void setGuestDetails({
    required String name,
    required String email,
    required String phone,
    required String relationship,
  }) {
    _guestName = name;
    _guestEmail = email;
    _guestPhone = phone;
    _relationshipToUser = relationship;
    notifyListeners();
  }

  void setSpecialRequest(String request) {
    _specialRequest = request;
    notifyListeners();
  }

  // Helper methods
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
    _isBookingForSomeoneElse = false;
    _guestName = '';
    _guestEmail = '';
    _guestPhone = '';
    _relationshipToUser = '';
    _specialRequest = '';
    notifyListeners();
  }
}
