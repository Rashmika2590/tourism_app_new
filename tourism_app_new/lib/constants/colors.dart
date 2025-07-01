import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0066CC);
  static const Color accent = Color(0xFFFF9900);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF333333);
  static const Color buttonColor = Colors.orange;
  static const Color buttonText = Colors.white;
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 1, 181, 163),
      Color(0xFF00C2AE),
      Color(0xFF005C53),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 1.0, 1.0],
  );

  // Add more gradients as needed
}
