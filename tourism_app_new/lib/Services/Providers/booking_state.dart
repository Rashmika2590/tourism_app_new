import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/booking_model.dart';

class BookingState extends ChangeNotifier {
  // --- Booking fields ---
  int roomId = 0;
  DateTime checkInDate = DateTime.now();
  TimeOfDay checkInTime = TimeOfDay.now();
  int duration = 1; // in hours
  int adults = 1;
  int children = 0;
  String locationName = '';
  double? latitude;
  double? longitude;
  String specialRequest = '';
  double price = 0.0;
  String paymentMethod = 'Card'; // default payment method

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

  void setLocation(String name, double? lat, double? lng) {
    locationName = name;
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }

  void setLocationName(String name) {
    locationName = name;
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

  // --- Reset all values (optional) ---
  void resetBooking() {
    roomId = 0;
    checkInDate = DateTime.now();
    checkInTime = TimeOfDay.now();
    duration = 1;
    adults = 1;
    children = 0;
    locationName = '';
    latitude = null;
    longitude = null;
    specialRequest = '';
    price = 0.0;
    paymentMethod = 'Card';
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
