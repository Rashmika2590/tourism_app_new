import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com';

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

  // ====== GENERIC AUTH REQUEST ======

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
