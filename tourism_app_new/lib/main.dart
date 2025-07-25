import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourism_app_new/core/utils/shared_preferences.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: AppRoutes.property_details,
      routes: AppRoutes.routes,
    );
  }
}
