import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/login.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  int _stage = 0;

  late AnimationController _imageController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _logoController;
  late Animation<double> _logoScale;

  late AnimationController _waveController;

  final List<String> _images = [
    'assets/logo/animate1.png',
    'assets/logo/animate2.png',
    'assets/logo/animate3.png',
    'assets/logo/animate4.png',
  ];

  final List<Color> _bgColors = [
    Color(0xFFFFF4E5),
    Color(0xFFE3F2FD),
    Color(0xFFFFEBEE),
    Color(0xFFE8F5E9),
    Color(0xFFFFFDE7),
  ];

  final List<Offset> _startOffsets = [
    Offset(0, -1.5), // top
    Offset(1.5, 0), // right
    Offset(-1.5, 0), // left
    Offset(0, 1.5), // bottom
    Offset(0, -1.5), // top again
  ];

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startSequence();
  }

  void _startSequence() async {
    for (int i = 0; i < _images.length; i++) {
      _slideAnimation = Tween<Offset>(
        begin: _startOffsets[i],
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _imageController, curve: Curves.easeOutBack),
      );

      setState(() => _stage = i + 1);
      _imageController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    setState(() => _stage = 6);
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() => _stage = 7);
    _waveController.forward();

    await Future.delayed(const Duration(milliseconds: 1600));
    _navigateNext();
  }

  void _navigateNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _logoController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Directional animated image backgrounds
          if (_stage >= 1 && _stage <= 5)
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              color: _bgColors[_stage - 1],
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(_images[_stage - 1], height: 180),
                  ),
                ),
              ),
            ),

          // Logo appears in stage 6 and continues through stage 7
          if (_stage >= 6)
            Center(
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset('assets/logo/crabigo_logo.png', height: 100),
              ),
            ),

          // Dual wave effect in stage 7
          if (_stage >= 7)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Bottom orange wave
                    ClipPath(
                      clipper: WaveClipper(_waveController.value, offset: 40),
                      child: Container(
                        color: const Color(0xFFFFA726), // Orange
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Top green wave
                    ClipPath(
                      clipper: WaveClipper(_waveController.value, offset: 0),
                      child: Container(
                        color: const Color(0xFF00B894), // Green
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ✅ Updated to support offset for layered waves
class WaveClipper extends CustomClipper<Path> {
  final double progress;
  final double offset;

  WaveClipper(this.progress, {this.offset = 0});

  @override
  Path getClip(Size size) {
    final path = Path();

    double height = size.height * (1 - progress) + offset;

    path.lineTo(0, height);
    path.quadraticBezierTo(
      size.width * 0.25,
      height - 30,
      size.width * 0.5,
      height,
    );
    path.quadraticBezierTo(size.width * 0.75, height + 30, size.width, height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.offset != offset;
}
