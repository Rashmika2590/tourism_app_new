import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class RoomApiService {
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

  // ====== CREATE ROOM ======
  static Future<Map<String, dynamic>> createRoom({
    required int hotelId,
    required String name,
    required String type,
    required double price,
    required int maxOccupancy,
    required List<String> amenities,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/");
        final body = jsonEncode({
          "hotel_id": hotelId,
          "name": name,
          "type": type,
          "price": price,
          "max_occupancy": maxOccupancy,
          "amenities": amenities,
        });

        print("Creating room for hotel: $hotelId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("Room creation response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            "Room Creation Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to create room: ${response.body}");
        }
      },
    );
  }

  // ====== GET ROOMS BY HOTEL ID ======
  static Future<List<Room>> getRoomsByHotelId(int hotelId) async {
    return await _makeAuthenticatedRequest<List<Room>>(
      requestFunction: (token) async {
        final uri = Uri.parse(
          "$baseUrl/hotel/$hotelId/rooms",
        ); // adjust if endpoint differs
        print("Getting rooms for hotel ID: $hotelId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get rooms response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((room) => Room.fromJson(room)).toList();
        } else {
          print("Get Rooms Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get rooms: ${response.body}");
        }
      },
    );
  }

  // ====== GET ROOM BY ID ======
  static Future<Room> getRoomById(int roomId) async {
    return await _makeAuthenticatedRequest<Room>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/$roomId");
        print("Getting room details for ID: $roomId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get room response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          return Room.fromJson(jsonDecode(response.body));
        } else {
          print("Get Room Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get room details: ${response.body}");
        }
      },
    );
  }
}
