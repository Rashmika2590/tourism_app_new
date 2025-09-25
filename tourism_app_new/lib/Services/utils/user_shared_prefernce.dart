import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_app_new/models/user_model.dart';

class SharedPrefUser {
  static const String _userKey =
      'user_data'; // Fixed the key name - removed asterisks

  // Save user object
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(user.toJson());
      await prefs.setString(_userKey, jsonString);
      print('User data saved successfully: ${user.email}');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Get user object
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userKey);

      if (jsonString == null) {
        print('No user data found in SharedPreferences');
        return null;
      }

      final userData = User.fromJson(jsonDecode(jsonString));
      print('User data loaded successfully: ${userData.email}');
      return userData;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  // Check if user exists
  static Future<bool> hasUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey);
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Clear user
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}
