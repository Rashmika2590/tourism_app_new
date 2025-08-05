import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism_app_new/core/services/Authentication/trac_registration_status.dart';
import 'package:tourism_app_new/core/utils/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _keepSignedInKey = 'keep_signed_in';

  // Register with email & password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _saveTokenWithExpiry(user);

        // Mark user as registered and set auto-login for first-time users
        await UserStateManager.markUserAsRegistered(email);
        await _setKeepSignedIn(true); // Auto-login for new users

        debugPrint("New user registered: $email");
        debugPrint("Auto-login enabled for new user");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registration failed: ${e.message}");
      return null;
    }
  }

  // Login with email & password
  Future<User?> loginWithEmailPassword(
    String email,
    String password, {
    bool keepSignedIn = false,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _saveTokenWithExpiry(user);

        // Check if this is the same user who registered on this device
        bool isRegisteredUser =
            await UserStateManager.isLoginWithRegisteredEmail(email);

        if (isRegisteredUser) {
          // This is a returning user who registered on this device
          await _setKeepSignedIn(keepSignedIn);
          debugPrint(
            "Returning registered user login: $email, keepSignedIn: $keepSignedIn",
          );
        } else {
          // This is a user logging in who didn't register on this device
          await _setKeepSignedIn(keepSignedIn);
          debugPrint(
            "External user login: $email, keepSignedIn: $keepSignedIn",
          );
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login failed: ${e.message}");
      return null;
    }
  }

  // Anonymous Sign-In
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        await _saveTokenWithExpiry(user);
        await _setKeepSignedIn(true); // Anonymous users stay logged in
        debugPrint("Anonymous sign in - auto-login enabled");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Anonymous Sign-In failed: ${e.message}");
      return null;
    }
  }

  // Enhanced logout with user state management
  Future<void> signOut({bool clearKeepSignedIn = true}) async {
    try {
      await _auth.signOut();

      if (clearKeepSignedIn) {
        await _setKeepSignedIn(false);
        // Don't clear registration status - user is still registered
        // Just clear the keep signed in preference
      }

      await SharedPreferecesUtil.clearAll();
      debugPrint("User signed out, keepSignedIn cleared: $clearKeepSignedIn");
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }

  // Check if user should be automatically logged in
  Future<bool> shouldAutoLogin() async {
    final keepSignedIn = await _getKeepSignedIn();
    final currentUser = _auth.currentUser;
    final hasRegistered = await UserStateManager.hasUserRegistered();

    debugPrint(
      "Auto-login check: keepSignedIn=$keepSignedIn, hasUser=${currentUser != null}, hasRegistered=$hasRegistered",
    );

    return keepSignedIn && currentUser != null;
  }

  // Get fresh token - this automatically refreshes if needed
  Future<String?> getFreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken(true); // force refresh
      await _saveTokenWithExpiry(user);
      return token;
    } catch (e) {
      debugPrint("Error getting fresh token: $e");
      return null;
    }
  }

  // Check if token needs refresh
  Future<bool> isTokenExpired() async {
    final expiryTimeStr = await SharedPreferecesUtil.getTokenExpiry();
    if (expiryTimeStr == null) return true;

    final expiryTime = DateTime.tryParse(expiryTimeStr);
    if (expiryTime == null) return true;

    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);
    return timeUntilExpiry.inMinutes < 5;
  }

  // Auto-refresh token if needed
  Future<String?> getValidToken() async {
    final currentToken = SharedPreferecesUtil.getToken();

    if (currentToken == null || await isTokenExpired()) {
      debugPrint("Token expired or missing, refreshing...");
      return await getFreshToken();
    }

    return currentToken;
  }

  // Save token with expiry time
  Future<void> _saveTokenWithExpiry(User user) async {
    final token = await user.getIdToken(true);
    await SharedPreferecesUtil.setToken(token!);

    final expiryTime = DateTime.now().add(Duration(hours: 1));
    await SharedPreferecesUtil.setTokenExpiry(expiryTime.toIso8601String());

    debugPrint("Token saved with expiry: ${expiryTime.toIso8601String()}");
  }

  // Keep signed in preference methods
  Future<void> _setKeepSignedIn(bool value) async {
    await SharedPreferecesUtil.setBool(_keepSignedInKey, value);
  }

  Future<bool> _getKeepSignedIn() async {
    return SharedPreferecesUtil.getBool(_keepSignedInKey) ?? false;
  }

  // Get currently signed-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user registration status for debugging
  Future<Map<String, dynamic>> getUserAuthStatus() async {
    final userStatus = await UserStateManager.getUserStatus();
    final keepSignedIn = await _getKeepSignedIn();
    final currentUser = getCurrentUser();

    return {
      ...userStatus,
      'keepSignedIn': keepSignedIn,
      'firebaseUser': currentUser?.email,
      'shouldAutoLogin': await shouldAutoLogin(),
    };
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in: ${user.email} (${user.uid})');
      }
    });
  }
}
