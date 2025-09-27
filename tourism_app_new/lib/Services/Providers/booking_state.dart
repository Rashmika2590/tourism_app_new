import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tourism_app_new/models/booking_model.dart';
import 'package:tourism_app_new/widgets/filtering%20option.dart';

class BookingState extends ChangeNotifier {
  // --- Booking fields ---
  int roomId = 0;
  DateTime checkInDate = DateTime.now();
  TimeOfDay checkInTime = TimeOfDay.now();
  int duration = 1; // in hours
  int adults = 1;
  int children = 0;
  String state = '';
  String specialRequest = '';
  double price = 0.0;
  String paymentMethod = 'Card'; // default payment method

  // --- Search and Filter fields ---
  double? latitude;
  double? longitude;
  double radiusKm = 10.0; // Default radius
  FilterOptions filterOptions = FilterOptions();

  // --- Computed property for checkout ---
  DateTime get checkOutDate {
    final checkInDateTime = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
      checkInTime.hour,
      checkInTime.minute,
    );
    return checkInDateTime.add(Duration(hours: duration));
  }

  // --- Setters with notifyListeners() ---
  void setRoomId(int id) {
    roomId = id;
    notifyListeners();
  }

  void setCheckInDate(DateTime date) {
    checkInDate = date;
    notifyListeners();
  }

  void setCheckInTime(TimeOfDay time) {
    checkInTime = time;
    notifyListeners();
  }

  void setDuration(int d) {
    duration = d;
    notifyListeners();
  }

  void setGuests({required int adultCount, required int childrenCount}) {
    adults = adultCount;
    children = childrenCount;
    notifyListeners();
  }

  void setState(String s) {
    state = s;
    notifyListeners();
  }

  void setSpecialRequest(String s) {
    specialRequest = s;
    notifyListeners();
  }

  void setPrice(double p) {
    price = p;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void setLocation({double? lat, double? lon, double? radius}) {
    if (lat != null) latitude = lat;
    if (lon != null) longitude = lon;
    if (radius != null) radiusKm = radius;
    notifyListeners();
  }

  void setFilterOptions(FilterOptions options) {
    filterOptions = options;
    if (options.maxDistance != null) {
      radiusKm = options.maxDistance!;
    }
    notifyListeners();
  }

  Future<void> fetchInitialLocation() async {
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setLocation(lat: position.latitude, lon: position.longitude);
      } else {
        print("Location permission denied");
      }
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  // --- Reset all values (optional) ---
  void resetBooking() {
    roomId = 0;
    checkInDate = DateTime.now();
    checkInTime = TimeOfDay.now();
    duration = 1;
    adults = 1;
    children = 0;
    state = '';
    specialRequest = '';
    price = 0.0;
    paymentMethod = 'Card';
    filterOptions = FilterOptions();
    radiusKm = 10.0;
    // Do not reset location
    notifyListeners();
  }

  // --- Convert current state to BookingRequest for API ---
  BookingRequest toBookingRequest() {
    final checkInDateTime = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
      checkInTime.hour,
      checkInTime.minute,
    );

    final checkOutDateTime = checkInDateTime.add(Duration(hours: duration));

    return BookingRequest(
      roomId: roomId,
      ciDate: "${checkInDateTime.toLocal()}".split(' ')[0],
      ciTime:
          "${checkInDateTime.hour.toString().padLeft(2, '0')}:${checkInDateTime.minute.toString().padLeft(2, '0')}",
      coDate: "${checkOutDateTime.toLocal()}".split(' ')[0],
      coTime:
          "${checkOutDateTime.hour.toString().padLeft(2, '0')}:${checkOutDateTime.minute.toString().padLeft(2, '0')}",
      adultCount: adults,
      childrenCount: children,
      specialRequest: specialRequest,
      price: price,
      paymentMethod: paymentMethod,
      bookingTime: DateTime.now().toIso8601String(),
    );
  }
}