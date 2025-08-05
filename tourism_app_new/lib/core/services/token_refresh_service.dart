import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/core/utils/shared_preferences.dart';

class TokenRefreshService {
  static const String baseUrl = 'https://uexplus128-001-site1.otempurl.com/api';

  static Future<bool> refreshToken() async {
    final refreshToken = SharedPreferecesUtil.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/Auth/refresh-token'), // ✅ Backend should provide this
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['token'];
      final newRefreshToken = data['refreshToken'];

      await SharedPreferecesUtil.setToken(newToken);
      await SharedPreferecesUtil.setRefreshToken(newRefreshToken);
      return true;
    } else {
      return false;
    }
  }
}
