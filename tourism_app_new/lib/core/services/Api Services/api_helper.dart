import 'package:http/http.dart' as http;
import 'package:tourism_app_new/core/services/Authentication/auth_service..dart';
import 'package:tourism_app_new/core/services/token_refresh_service.dart';

class ApiHelper {
  static const String baseUrl =
      'https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com';
  static final AuthService _authService = AuthService();

  /// Ensure token is valid before making request
  static Future<T> makeAuthenticatedRequest<T>({
    required Future<T> Function(String token) requestFunction,
    int maxRetries = 1,
  }) async {
    String? token = await _authService.getValidToken();
    if (token == null) {
      throw Exception("No valid token available");
    }

    T response = await requestFunction(token);

    if (response is http.Response &&
        response.statusCode == 401 &&
        maxRetries > 0) {
      // Try refresh with backend token endpoint if available
      bool refreshed = await TokenRefreshService.refreshToken();
      token =
          refreshed
              ? _authService.getCurrentUser()?.getIdToken() as String?
              : await _authService.getFreshToken();

      if (token == null) {
        throw Exception("Authentication failed - could not refresh token");
      }

      response = await requestFunction(token);
    }

    return response;
  }
}
