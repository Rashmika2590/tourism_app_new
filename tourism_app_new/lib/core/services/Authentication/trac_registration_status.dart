import 'package:tourism_app_new/core/utils/shared_preferences.dart';

class UserStateManager {
  // Keys for storing user state
  static const String _isFirstTimeUserKey = 'is_first_time_user';
  static const String _userRegistrationStatusKey = 'user_registration_status';
  static const String _hasCompletedOnboardingKey = 'completed_onboarding';
  static const String _userEmailKey = 'user_email';

  // Check if this is a completely new user (never opened the app)
  static Future<bool> isFirstTimeAppUser() async {
    return SharedPreferecesUtil.getBool(_isFirstTimeUserKey) ?? true;
  }

  // Mark that user has opened the app for the first time
  static Future<void> markAppAsUsed() async {
    await SharedPreferecesUtil.setBool(_isFirstTimeUserKey, false);
  }

  // Check if user has registered an account
  static Future<bool> hasUserRegistered() async {
    return SharedPreferecesUtil.getBool(_userRegistrationStatusKey) ?? false;
  }

  // Mark user as registered
  static Future<void> markUserAsRegistered(String email) async {
    await SharedPreferecesUtil.setBool(_userRegistrationStatusKey, true);
    await SharedPreferecesUtil.setString(_userEmailKey, email);
  }

  // Check if user completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    return SharedPreferecesUtil.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  // Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    await SharedPreferecesUtil.setBool(_hasCompletedOnboardingKey, true);
  }

  // Get registered user email
  static Future<String?> getRegisteredUserEmail() async {
    return SharedPreferecesUtil.getString(_userEmailKey);
  }

  // Check if user is logging in with same email they registered with
  static Future<bool> isLoginWithRegisteredEmail(String loginEmail) async {
    final registeredEmail = await getRegisteredUserEmail();
    return registeredEmail != null &&
        registeredEmail.toLowerCase() == loginEmail.toLowerCase();
  }

  // Clear all user data (for logout)
  static Future<void> clearUserData() async {
    await SharedPreferecesUtil.remove(_userRegistrationStatusKey);
    await SharedPreferecesUtil.remove(_userEmailKey);
    await SharedPreferecesUtil.remove(_hasCompletedOnboardingKey);
    // Keep _isFirstTimeUserKey so we know app has been used before
  }

  // Get user registration status info
  static Future<Map<String, dynamic>> getUserStatus() async {
    return {
      'isFirstTimeAppUser': await isFirstTimeAppUser(),
      'hasRegistered': await hasUserRegistered(),
      'hasCompletedOnboarding': await hasCompletedOnboarding(),
      'registeredEmail': await getRegisteredUserEmail(),
    };
  }
}
