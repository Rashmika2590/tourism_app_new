import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <-- ADD THIS IMPORT
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/Services/utils/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tourism_app_new/routs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferecesUtil.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // <-- WRAP MaterialApp with this
      create:
          (context) => BookingState(), // Create your state management instance
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: AppRoutes.splachscreen,
        routes: AppRoutes.routes,
      ),
    );
  }
}
