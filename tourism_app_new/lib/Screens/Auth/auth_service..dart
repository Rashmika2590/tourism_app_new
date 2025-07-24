import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism_app_new/core/utils/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with email & password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        _printFirebaseToken(user);
        debugPrint("register  via email & passowrd");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registration failed: ${e.message}");
      return null;
    }
  }

  // Login with email & password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        _printFirebaseToken(user);
        debugPrint("sign in email & passowrd");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login failed: ${e.message}");
      return null;
    }
  }

  // Google Sign-In
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // User canceled sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     User? user = userCredential.user;
  //     if (user != null) {
  //       _printFirebaseToken(user);
  //       debugPrint("sign in google");
  //     }
  //     return user;
  //   } catch (e) {
  //     debugPrint("Google Sign-In failed: $e");
  //     return null;
  //   }
  // }

  // Anonymous Sign-In
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      if (user != null) {
        _printFirebaseToken(user);
        debugPrint("sign in anonymously");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Anonymous Sign-In failed: ${e.message}");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      //await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }

  // Print Firebase Token in Terminal
  Future<void> _printFirebaseToken(User user) async {
    String? token = await user.getIdToken(true);
    await SharedPreferecesUtil.setToken(token!);
    print(token);
  }

  // Get currently signed-in user

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
