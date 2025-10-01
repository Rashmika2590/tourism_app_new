// Services/room_availability_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/models/availability_model.dart';

class RoomAvailabilityService {
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

      // Only retry for http.Response
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
            print("Successfully refreshed token");
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

  // ====== GET ROOM AVAILABILITY ======
  static Future<RoomAvailability> getRoomAvailability(
    RoomAvailabilityParams params,
  ) async {
    return await _makeAuthenticatedRequest<RoomAvailability>(
      requestFunction: (token) async {
        final queryParams = params.toQueryParams();
        final uri = Uri.parse(
          "$baseUrl/availability/",
        ).replace(queryParameters: queryParams);

        print("Getting room availability with params: $queryParams");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Room availability response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          return RoomAvailability.fromJson(jsonData);
        } else {
          print(
            "Room Availability Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to get room availability: ${response.body}");
        }
      },
    );
  }

  // ====== HELPER METHODS ======
  static Future<RoomAvailability> searchAvailability({
    required DateTime checkInDate,
    required String checkInTime,
    required DateTime checkOutDate,
    required String checkOutTime,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
    int? adultCount,
    int? childrenCount,
  }) async {
    final params = RoomAvailabilityParams(
      ciDate: _formatDate(checkInDate),
      ciTime: checkInTime,
      coDate: _formatDate(checkOutDate),
      coTime: checkOutTime,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
      adultCount: adultCount,
      childrenCount: childrenCount,
    );

    return await getRoomAvailability(params);
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
