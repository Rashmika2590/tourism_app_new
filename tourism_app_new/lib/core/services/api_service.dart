import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/models/property_model.dart';
import 'package:tourism_app_new/core/services/Authentication/auth_service..dart';

class ApiService {
  static const String baseUrl = 'https://uexplus128-001-site1.otempurl.com/api';
  static final AuthService _authService = AuthService();

  // Enhanced method to get valid token with automatic refresh
  static Future<String?> _getValidToken() async {
    return await _authService.getValidToken();
  }

  // Generic method to make authenticated requests with auto-retry on token expiry
  static Future<http.Response> _makeAuthenticatedRequest({
    required Future<http.Response> Function(String token) requestFunction,
    int maxRetries = 1,
  }) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Authentication failed - no valid token available");
    }

    http.Response response = await requestFunction(token);

    // If we get 401 (Unauthorized), try to refresh token and retry
    if (response.statusCode == 401 && maxRetries > 0) {
      print("Token expired, refreshing and retrying...");
      token = await _authService.getFreshToken();
      if (token == null) {
        throw Exception("Authentication failed - could not refresh token");
      }
      response = await requestFunction(token);
    }

    return response;
  }

  static Future<List<Property>> filterProperties(
    Map<String, dynamic> filters, {
    required String city,
  }) async {
    // Include city in filters
    filters['city'] = city;

    final response = await _makeAuthenticatedRequest(
      requestFunction:
          (token) => http.post(
            Uri.parse('$baseUrl/Property/filtered-properties'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(filters),
          ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        return (data['items'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
      } else {
        throw Exception("Unexpected response format: $data");
      }
    } else {
      throw Exception(
        'Failed to filter properties: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> fetchPropertyById(
    String propertyId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        requestFunction:
            (token) => http.get(
              Uri.parse('$baseUrl/Property/$propertyId'),
              headers: {'Authorization': 'Bearer $token'},
            ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to fetch property: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch property: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPackagesByPropertyId(
    String propertyId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        requestFunction:
            (token) => http.get(
              Uri.parse('$baseUrl/Package/by-property/$propertyId'),
              headers: {'Authorization': 'Bearer $token'},
            ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to fetch packages: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching packages: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchPackageById(String packageId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        requestFunction:
            (token) => http.get(
              Uri.parse('$baseUrl/Package/$packageId'),
              headers: {'Authorization': 'Bearer $token'},
            ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to fetch package: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch package: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> submitPropertyRating({
    required String propertyId,
    required int rating,
    required String comment,
  }) async {
    final response = await _makeAuthenticatedRequest(
      requestFunction:
          (token) => http.post(
            Uri.parse('$baseUrl/PropertyRating'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "propertyId": propertyId,
              "rating": rating,
              "comment": comment,
            }),
          ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to submit rating: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPropertyRatings(
    String propertyId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        requestFunction:
            (token) => http.get(
              Uri.parse('$baseUrl/PropertyRating/$propertyId'),
              headers: {'Authorization': 'Bearer $token'},
            ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to fetch ratings: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching ratings: $e');
    }
  }
}
