import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_app_new/models/user_model.dart';
import 'package:tourism_app_new/Services/Authentication/trac_registration_status.dart';
import 'package:tourism_app_new/Services/utils/shared_preferences.dart';
import 'package:tourism_app_new/Services/utils/user_shared_prefernce.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _keepSignedInKey = 'keep_signed_in';

  // Utility: decode and print JWT info
  void _debugPrintTokenInfo(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT format');
        return;
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      debugPrint("======= JWT TOKEN =======");
      debugPrint("Token (length ${token.length}):");
      debugPrint(token);
      debugPrint("------- Decoded Payload -------");
      debugPrint(payload);
      debugPrint("===============================");
    } catch (e) {
      debugPrint("Error decoding token: $e");
    }
  }

  // Register with email & password
  Future<firebase_auth.User?> registerWithEmailPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'No Name',
          email: firebaseUser.email!,
          phone: firebaseUser.phoneNumber ?? 'No Phone',
          password: '', // Password should not be stored here
          createdTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedTime: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
          updatedBy: 'self',
        );
        await SharedPrefUser.saveUser(user);
        await _saveTokenWithExpiry(firebaseUser);
        await UserStateManager.markUserAsRegistered(email);
        await _setKeepSignedIn(true);
        debugPrint("New user registered: $email");
        debugPrint("Auto-login enabled for new user");
      }
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registration failed: ${e.message}");
      return null;
    }
  }

  // Login with email & password
  Future<firebase_auth.User?> loginWithEmailPassword(
    String email,
    String password, {
    bool keepSignedIn = false,
  }) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create a User model object
        final user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'No Name',
          email: firebaseUser.email!,
          phone: firebaseUser.phoneNumber ?? 'No Phone',
          password: '', // Password should not be stored here
          createdTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedTime: firebase_auth.FirebaseAuth.instance.currentUser?.metadata.lastSignInTime ?? DateTime.now(),
          updatedBy: 'self',
        );

        // Save the user model to shared preferences
        await SharedPrefUser.saveUser(user);

        await _saveTokenWithExpiry(firebaseUser);
        bool isRegisteredUser =
            await UserStateManager.isLoginWithRegisteredEmail(email);

        await _setKeepSignedIn(keepSignedIn);
        if (isRegisteredUser) {
          debugPrint(
            "Returning registered user login: $email, keepSignedIn: $keepSignedIn",
          );
        } else {
          debugPrint(
            "External user login: $email, keepSignedIn: $keepSignedIn",
          );
        }
      }
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login failed: ${e.message}");
      return null;
    }
  }

  // Anonymous Sign-In
  Future<firebase_auth.User?> signInAnonymously() async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInAnonymously();
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Anonymous',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          password: '',
          createdTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedTime: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
          updatedBy: 'self',
        );
        await SharedPrefUser.saveUser(user);
        await _saveTokenWithExpiry(firebaseUser);
        await _setKeepSignedIn(true);
        debugPrint("Anonymous sign in - auto-login enabled");
      }
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Anonymous Sign-In failed: ${e.message}");
      return null;
    }
  }

  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'No Name',
          email: firebaseUser.email!,
          phone: firebaseUser.phoneNumber ?? 'No Phone',
          password: '', // Password should not be stored here
          createdTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedTime: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
          updatedBy: 'self',
        );
        await SharedPrefUser.saveUser(user);
        await _saveTokenWithExpiry(firebaseUser);

        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _setKeepSignedIn(true);
          await UserStateManager.markUserAsRegistered(firebaseUser.email!);
          debugPrint("New Google user registered: ${firebaseUser.email}");
        } else {
          await _setKeepSignedIn(true);
          debugPrint("Existing Google user login: ${firebaseUser.email}");
        }
      }

      return firebaseUser;
    } catch (e) {
      debugPrint("Google Sign-In failed: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut({bool clearKeepSignedIn = true}) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      if (clearKeepSignedIn) {
        await _setKeepSignedIn(false);
      }

      await SharedPreferecesUtil.clearAll();
      debugPrint("User signed out, keepSignedIn cleared: $clearKeepSignedIn");
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
    await SharedPrefUser.clearUser();
  }

  // Auto-login check
  Future<bool> shouldAutoLogin() async {
    final keepSignedIn = await _getKeepSignedIn();
    final currentUser = _auth.currentUser;
    final hasRegistered = await UserStateManager.hasUserRegistered();

    debugPrint(
      "Auto-login check: keepSignedIn=$keepSignedIn, hasUser=${currentUser != null}, hasRegistered=$hasRegistered",
    );

    return keepSignedIn && currentUser != null;
  }

  // Get fresh token
  Future<String?> getFreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken(true);
      if (token != null) {
        _debugPrintTokenInfo(token);
      }
      await _saveTokenWithExpiry(user);
      return token;
    } catch (e) {
      debugPrint("Error getting fresh token: $e");
      return null;
    }
  }

  // Check expiry
  Future<bool> isTokenExpired() async {
    final expiryTimeStr = await SharedPreferecesUtil.getTokenExpiry();
    if (expiryTimeStr == null) return true;

    final expiryTime = DateTime.tryParse(expiryTimeStr);
    if (expiryTime == null) return true;

    final now = DateTime.now();
    return expiryTime.isBefore(now.add(const Duration(minutes: 5)));
  }

  // Ensure valid token
  Future<String?> getValidToken() async {
    final currentToken = SharedPreferecesUtil.getToken();

    if (currentToken == null || await isTokenExpired()) {
      debugPrint("Token expired or missing, refreshing...");
      return await getFreshToken();
    }
    _debugPrintTokenInfo(currentToken);
    return currentToken;
  }

  // Save token + expiry
  Future<void> _saveTokenWithExpiry(firebase_auth.User user) async {
    final token = await user.getIdToken(true);
    if (token == null) return;
    await SharedPreferecesUtil.setToken(token);

    final expiryTime = DateTime.now().add(const Duration(hours: 1));
    await SharedPreferecesUtil.setTokenExpiry(expiryTime.toIso8601String());

    debugPrint("Token saved with expiry: ${expiryTime.toIso8601String()}");
    _debugPrintTokenInfo(token);
  }

  // Keep signed-in flag
  Future<void> _setKeepSignedIn(bool value) async {
    await SharedPreferecesUtil.setBool(_keepSignedInKey, value);
  }

  Future<bool> _getKeepSignedIn() async {
    return SharedPreferecesUtil.getBool(_keepSignedInKey) ?? false;
  }

  // Current user
  firebase_auth.User? getCurrentUser() => _auth.currentUser;

  // Debug auth status
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

  // Init auth state listener
  Future<void> initializeAuth() async {
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in: ${user.email} (${user.uid})');
      }
    });
  }
}
