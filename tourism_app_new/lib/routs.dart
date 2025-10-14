import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/forgot_password.dart';
import 'package:tourism_app_new/Screens/Auth/register.dart';
import 'package:tourism_app_new/Screens/notification.dart';
import 'package:tourism_app_new/Screens/profile/favourits_list.dart';
import 'package:tourism_app_new/Screens/profile/pfofile_setting.dart';
import 'package:tourism_app_new/Screens/splash_screen.dart';
import 'package:tourism_app_new/Screens/testing/Booking/user_booking_list.dart';
import 'package:tourism_app_new/Screens/testing/hotel_create.dart';
import 'package:tourism_app_new/Screens/testing/hotel_search_page.dart';
import 'package:tourism_app_new/Services/Authentication/debug_user_status.dart';
import '../Screens/home_page.dart';
import '../Screens/Auth/login.dart';

class AppRoutes {
  static const String splachscreen = '/splachscreen';

  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String propertylist = '/property_list';
  static const String property_details = '/property_details';
  static const String components = '/post_searching_dropdowns';
  static const String notification = '/notification';

  static const String profile_settings = '/Profile_settings';
  static const String favourites = '/favourites';
  static const String user_bookings = '/user-bookings';

  static const String debug = '/debug';

  static const String hotelcreation = '/create-hotel';
  static const String hotelsearch = '/hotel-search';
  static const String hoteldetails = '/hotel_details';

  static Map<String, WidgetBuilder> routes = {
    splachscreen: (context) => AnimatedSplashScreen(),

    home: (context) => HomePage(),
    login: (context) => LoginScreen(),
    register: (context) => RegistrationScreen(),
    forgotPassword: (context) => ForgotPasswordPage(),

    //propertylist: (context) => PropertyListPage(city: ''),
    notification: (context) => NotificationsScreen(),

    //components: (context) => HotelBookingScreen(),
    profile_settings: (context) => ProfileSettingsPage(),
    favourites: (context) => FavouriteHotelsPage(),
    user_bookings: (context) => UserBookingsScreen(),
    debug: (context) => DebugUserStatusScreen(),

    hotelcreation: (context) => HotelCreationScreen(),
    hotelsearch: (context) => HotelSearchScreen(),
    //hoteldetails: (context) => EnhancedHotelDetailsScreen(,),
  };
}
