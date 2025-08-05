import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferecesUtil {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  // Token methods
  static Future<void> setToken(String token) async {
    await _sharedPreferences?.setString('token', token);
  }

  static String? getToken() {
    return _sharedPreferences?.getString('token');
  }

  // Token expiry methods
  static Future<void> setTokenExpiry(String expiryTime) async {
    await _sharedPreferences?.setString('token_expiry', expiryTime);
  }

  static String? getTokenExpiry() {
    return _sharedPreferences?.getString('token_expiry');
  }

  // Refresh token methods (for future use if you implement refresh tokens)
  static Future<void> setRefreshToken(String refreshToken) async {
    await _sharedPreferences?.setString('refreshToken', refreshToken);
  }

  static String? getRefreshToken() {
    return _sharedPreferences?.getString('refreshToken');
  }

  // Boolean methods
  static Future<void> setBool(String key, bool value) async {
    await _sharedPreferences?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _sharedPreferences?.getBool(key);
  }

  // String methods
  static Future<void> setString(String key, String value) async {
    await _sharedPreferences?.setString(key, value);
  }

  static String? getString(String key) {
    return _sharedPreferences?.getString(key);
  }

  // Clear methods
  static Future<void> clearAll() async {
    await _sharedPreferences?.clear();
  }

  static Future<void> remove(String key) async {
    await _sharedPreferences?.remove(key);
  }
}
