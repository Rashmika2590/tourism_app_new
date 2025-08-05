import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/core/services/Authentication/auth_service..dart';
import 'package:tourism_app_new/core/services/Authentication/trac_registration_status.dart';
import 'package:tourism_app_new/routs.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  int _stage = 0;
  String _statusMessage = "Initializing...";

  late AnimationController _imageController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _logoController;
  late Animation<double> _logoScale;

  late AnimationController _waveController;

  final AuthService _authService = AuthService();

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
    Offset(0, -1.5),
    Offset(1.5, 0),
    Offset(-1.5, 0),
    Offset(0, 1.5),
    Offset(0, -1.5),
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

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
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

    await Future.delayed(const Duration(milliseconds: 1000));
    _initializeAppLogic(); // Start routing logic
  }

  Future<void> _initializeAppLogic() async {
    try {
      setState(() => _statusMessage = "Checking user status...");

      await _authService.initializeAuth();
      final userStatus = await _authService.getUserAuthStatus();

      print("=== USER STATUS DEBUG ===");
      print("First time app user: ${userStatus['isFirstTimeAppUser']}");
      print("Has registered: ${userStatus['hasRegistered']}");
      print("Keep signed in: ${userStatus['keepSignedIn']}");
      print("Firebase user: ${userStatus['firebaseUser']}");
      print("Should auto login: ${userStatus['shouldAutoLogin']}");
      print("========================");

      setState(() => _statusMessage = "Preparing your experience...");
      await Future.delayed(Duration(seconds: 2));

      await _routeUser(userStatus);
    } catch (e) {
      print("Error during app initialization: $e");
      setState(() => _statusMessage = "Something went wrong...");
      await Future.delayed(Duration(seconds: 1));
      _navigateToLogin();
    }
  }

  Future<void> _routeUser(Map<String, dynamic> userStatus) async {
    final isFirstTimeAppUser = userStatus['isFirstTimeAppUser'] as bool;
    final hasRegistered = userStatus['hasRegistered'] as bool;
    final shouldAutoLogin = userStatus['shouldAutoLogin'] as bool;
    final firebaseUser = userStatus['firebaseUser'] as String?;

    if (isFirstTimeAppUser) {
      await UserStateManager.markAppAsUsed();
      setState(() => _statusMessage = "Welcome!");
      await Future.delayed(Duration(milliseconds: 500));
      _navigateToOnboardingOrLogin();
    } else if (shouldAutoLogin && firebaseUser != null) {
      setState(() => _statusMessage = "Welcome back!");
      await Future.delayed(Duration(milliseconds: 500));
      String? validToken = await _authService.getValidToken();
      if (validToken != null) {
        _navigateToHome();
      } else {
        print("Token validation failed, redirecting to login");
        _navigateToLogin();
      }
    } else if (hasRegistered) {
      setState(() => _statusMessage = "Please sign in...");
      await Future.delayed(Duration(milliseconds: 500));
      _navigateToLogin();
    } else {
      setState(() => _statusMessage = "Let's get started...");
      await Future.delayed(Duration(milliseconds: 500));
      _navigateToLogin();
    }
  }

  void _navigateToOnboardingOrLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
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

          if (_stage >= 6)
            Center(
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo/crabigo_logo.png', height: 100),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        _statusMessage,
                        key: ValueKey(_statusMessage),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_stage >= 7)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Stack(
                  children: [
                    ClipPath(
                      clipper: WaveClipper(_waveController.value, offset: 40),
                      child: Container(
                        color: const Color(0xFFFFA726),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    ClipPath(
                      clipper: WaveClipper(_waveController.value, offset: 0),
                      child: Container(
                        color: const Color(0xFF00B894),
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

// WaveClipper remains the same
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
