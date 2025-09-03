// Services/Api Services/Authentication/booking_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Models/booking_model.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class BookingApiService {
  static const String baseUrl =
      "https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com";
  static const String bookingEndpoint = "/booking/";
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

  // ====== CREATE BOOKING ======
  static Future<BookingResponse> createBooking(BookingRequest booking) async {
    return await _makeAuthenticatedRequest<BookingResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl$bookingEndpoint");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(booking.toJson()),
        );

        print("Create booking response: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return BookingResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception("Failed to create booking: ${response.body}");
        }
      },
    );
  }

  // ====== GET BOOKING BY ID ======
  static Future<BookingResponse> getBookingById(int bookingId) async {
    return await _makeAuthenticatedRequest<BookingResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl$bookingEndpoint$bookingId/");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get booking response: ${response.statusCode}");
        if (response.statusCode == 200) {
          return BookingResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception("Failed to get booking: ${response.body}");
        }
      },
    );
  }

  // ====== UPDATE BOOKING STATUS ======
  static Future<BookingResponse> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    return await _makeAuthenticatedRequest<BookingResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl$bookingEndpoint$bookingId/");
        final response = await http.patch(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"status": status}),
        );

        print("Update booking response: ${response.statusCode}");
        if (response.statusCode == 200) {
          return BookingResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception("Failed to update booking: ${response.body}");
        }
      },
    );
  }
}
