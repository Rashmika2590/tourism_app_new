import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class FavouriteApiService {
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

  // ====== ADD FAVOURITE ======
  static Future<Map<String, dynamic>> addFavourite({
    required String userId,
    required int hotelId,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/favourite/");
        final body = jsonEncode({"user_id": userId, "hotel_id": hotelId});

        print("Adding favourite for hotel: $hotelId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("Add favourite response: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          throw Exception("Failed to add favourite: ${response.body}");
        }
      },
    );
  }

  // ====== REMOVE FAVOURITE ======
  static Future<bool> removeFavourite(int favouriteId) async {
    return await _makeAuthenticatedRequest<bool>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/favourite/$favouriteId");

        print("Removing favourite ID: $favouriteId");
        final response = await http.delete(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Remove favourite response: ${response.statusCode}");
        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception("Failed to remove favourite: ${response.body}");
        }
      },
    );
  }
}
