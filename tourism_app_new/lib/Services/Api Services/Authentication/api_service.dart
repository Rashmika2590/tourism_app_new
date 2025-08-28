import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class ApiService {
  static const String baseUrl =
      'https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com';
  static final AuthService _authService = AuthService();

  // ====== DEBUG UTILITIES ======
  // static Future<void> debugToken() async {
  //   try {
  //     String? token = await _getValidToken();
  //     print(
  //       "Current token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}",
  //     );
  //     print("Token length: ${token?.length ?? 0}");

  //     if (token != null) {
  //       // Test token with a simple endpoint
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/hotel/'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $token',
  //         },
  //       );

  //       print("Test request status: ${response.statusCode}");
  //       if (response.statusCode != 200) {
  //         print("Test request body: ${response.body}");
  //       }
  //     }
  //   } catch (e) {
  //     print("Debug token error: $e");
  //   }
  // }

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

      // Token refresh logic for http.Response only
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

  // ====== USER AUTH APIS ======
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = "user",
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/');

      final requestBody = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "role": role,
        "is_verified": false,
        "created_time": DateTime.now().toIso8601String(),
        "updated_time": DateTime.now().toIso8601String(),
        "updated_by": '',
      };

      print("Registering user with email: $email");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Registration response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Registration Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print("Registration exception: $e");
      rethrow;
    }
  }
}
