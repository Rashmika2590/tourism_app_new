// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/forgot_password.dart';
import 'package:tourism_app_new/Screens/Auth/register.dart';
import 'package:tourism_app_new/Screens/notification.dart';
import 'package:tourism_app_new/Screens/profile/pfofile_setting.dart';
import 'package:tourism_app_new/Screens/property_list_page.dart';
import '../Screens/home_page.dart';
import '../Screens/Auth/login.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String propertylist = '/property_list';
  static const String notification = '/notification';

  static const String profile_settings = '/Profile_settings';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    login: (context) => LoginScreen(),
    register: (context) => RegistrationScreen(),
    forgotPassword: (context) => ForgotPasswordPage(),

    propertylist: (context) => PropertyListPage(city: ''),
    notification: (context) => NotificationsScreen(),

    profile_settings: (context) => ProfileSettingsPage(),
  };
}
