import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_app_new/models/user_model.dart';

class SharedPrefUser {
  static const String _userKey = 'user_data';

  // Save user object
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
  }

  // Get user object
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;
    return User.fromJson(jsonDecode(jsonString));
  }

  // Check if user exists
  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  // Clear user
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
