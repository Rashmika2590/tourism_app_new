import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferecesUtil {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> setToken(String token) async {
    await _sharedPreferences!.setString('token', token);
  }

  static String? getToken() {
    return _sharedPreferences!.getString('token');
  }
}
