// Services/booking_calendar_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class BookingCalendarService {
  static const String baseUrl =
      "https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com";
  static final AuthService _authService = AuthService();

  // ====== TOKEN HANDLING ======
  static Future<String?> _getValidToken() async {
    try {
      final token = await _authService.getValidToken();
      print("Retrieved token: ${token != null ? 'SUCCESS' : 'NULL'}");
      return token;
    } catch (e) {
      print("Error getting valid token: $e");
      return null;
    }
  }

  // ====== GENERIC AUTH REQUEST ======
  static Future<T> _makeAuthenticatedRequest<T>({
    required Future<T> Function(String token) requestFunction,
    int maxRetries = 1,
  }) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Authentication failed - no valid token available");
    }

    try {
      T response = await requestFunction(token);

      if (response is http.Response) {
        print("Response status: ${response.statusCode}");
        if (response.statusCode == 401 && maxRetries > 0) {
          print("Token expired, refreshing and retrying...");
          try {
            token = await _authService.getFreshToken();
            if (token == null) {
              throw Exception(
                "Authentication failed - could not refresh token",
              );
            }
            response = await requestFunction(token);
            print(
              "Retry response status: ${(response as http.Response).statusCode}",
            );
          } catch (refreshError) {
            print("Token refresh failed: $refreshError");
            throw Exception(
              "Authentication failed - token refresh error: $refreshError",
            );
          }
        }
      }
      return response;
    } catch (e) {
      print("Request failed: $e");
      rethrow;
    }
  }

  // ====== GET FUTURE BOOKINGS ======
  static Future<List<BookingCalendarItem>> getFutureBookings(
    int hotelId,
  ) async {
    return await _makeAuthenticatedRequest<List<BookingCalendarItem>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/booking/$hotelId/future_bookings");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Future bookings response: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          return jsonData
              .map((json) => BookingCalendarItem.fromJson(json))
              .toList();
        } else {
          throw Exception("Failed to get future bookings: ${response.body}");
        }
      },
    );
  }

  // ====== GET HOTEL ROOMS ======
  static Future<List<HotelRoom>> getHotelRooms(int hotelId) async {
    return await _makeAuthenticatedRequest<List<HotelRoom>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/hotel/$hotelId/rooms");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Hotel rooms response: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          return jsonData.map((json) => HotelRoom.fromJson(json)).toList();
        } else {
          throw Exception("Failed to get hotel rooms: ${response.body}");
        }
      },
    );
  }

  // ====== GET CALENDAR DATA ======
  static Future<HotelCalendarData> getCalendarData(int hotelId) async {
    final bookings = await getFutureBookings(hotelId);
    final rooms = await getHotelRooms(hotelId);
    return HotelCalendarData(bookings: bookings, rooms: rooms);
  }
}

// ====== MODELS ======

class BookingCalendarItem {
  final int id;
  final int roomId;
  final String status;
  final String ciDate;
  final String ciTime;
  final String coDate;
  final String coTime;
  final int adultCount;
  final int childrenCount;
  final double price;
  final String paymentMethod;
  final String bookingTime;

  BookingCalendarItem({
    required this.id,
    required this.roomId,
    required this.status,
    required this.ciDate,
    required this.ciTime,
    required this.coDate,
    required this.coTime,
    required this.adultCount,
    required this.childrenCount,
    required this.price,
    required this.paymentMethod,
    required this.bookingTime,
  });

  factory BookingCalendarItem.fromJson(Map<String, dynamic> json) {
    return BookingCalendarItem(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      status: json['status'] ?? 'pending',
      ciDate: json['ci_date'] ?? '',
      ciTime: json['ci_time'] ?? '',
      coDate: json['co_date'] ?? '',
      coTime: json['co_time'] ?? '',
      adultCount: json['adult_count'] ?? 0,
      childrenCount: json['children_count'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      bookingTime: json['booking_time'] ?? '',
    );
  }

  DateTime get checkInDateTime {
    return DateTime.parse('$ciDate $ciTime');
  }

  DateTime get checkOutDateTime {
    return DateTime.parse('$coDate $coTime');
  }

  // Check if this booking overlaps with a given date range
  bool overlaps(DateTime startDate, DateTime endDate) {
    final bookingStart = checkInDateTime;
    final bookingEnd = checkOutDateTime;
    return bookingStart.isBefore(endDate) && bookingEnd.isAfter(startDate);
  }

  // Check if a specific time falls within this booking
  bool containsTime(DateTime checkTime) {
    final bookingStart = checkInDateTime;
    final bookingEnd = checkOutDateTime;
    return checkTime.isAfter(bookingStart) && checkTime.isBefore(bookingEnd) ||
        checkTime.isAtSameMomentAs(bookingStart) ||
        checkTime.isAtSameMomentAs(bookingEnd);
  }

  // Get duration in hours
  int getDurationInHours() {
    return checkOutDateTime.difference(checkInDateTime).inHours;
  }
}

class HotelRoom {
  final int id;
  final int hotelId;
  final String type;
  final String name;
  final String price;
  final int maxOccupancy;
  final List<String> amenities;
  final bool freeCancellation;

  HotelRoom({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.name,
    required this.price,
    required this.maxOccupancy,
    required this.amenities,
    required this.freeCancellation,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      maxOccupancy: json['max_occupancy'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      freeCancellation: json['free_cancellation'] ?? false,
    );
  }
}

class HotelCalendarData {
  final List<BookingCalendarItem> bookings;
  final List<HotelRoom> rooms;

  HotelCalendarData({required this.bookings, required this.rooms});

  // Get all bookings for a specific room
  List<BookingCalendarItem> getBookingsForRoom(int roomId) {
    return bookings.where((b) => b.roomId == roomId).toList();
  }

  // Check if a room is available for a date range
  bool isRoomAvailable(int roomId, DateTime checkIn, DateTime checkOut) {
    final roomBookings = getBookingsForRoom(roomId);
    for (var booking in roomBookings) {
      if (booking.overlaps(checkIn, checkOut)) {
        return false;
      }
    }
    return true;
  }

  // Get available rooms for a date range
  List<HotelRoom> getAvailableRooms(DateTime checkIn, DateTime checkOut) {
    return rooms
        .where((room) => isRoomAvailable(room.id, checkIn, checkOut))
        .toList();
  }

  // Get unavailable rooms for a date range
  List<HotelRoom> getUnavailableRooms(DateTime checkIn, DateTime checkOut) {
    return rooms
        .where((room) => !isRoomAvailable(room.id, checkIn, checkOut))
        .toList();
  }

  // Get bookings for a specific date
  List<BookingCalendarItem> getBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return bookings.where((b) => b.overlaps(startOfDay, endOfDay)).toList();
  }

  // Get room availability status for calendar view
  Map<int, List<DateRange>> getRoomBookingRanges() {
    Map<int, List<DateRange>> roomRanges = {};

    for (var room in rooms) {
      roomRanges[room.id] = [];
    }

    for (var booking in bookings) {
      if (roomRanges.containsKey(booking.roomId)) {
        roomRanges[booking.roomId]!.add(
          DateRange(
            start: booking.checkInDateTime,
            end: booking.checkOutDateTime,
            bookingId: booking.id,
          ),
        );
      }
    }

    return roomRanges;
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;
  final int bookingId;

  DateRange({required this.start, required this.end, required this.bookingId});

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }
}
