// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/core/utils/shared_preferences.dart';
import 'package:tourism_app_new/models/property_model.dart';

class ApiService {
  static const String baseUrl = 'https://uexplus128-001-site1.otempurl.com/api';

  static Future<List<Property>> filterProperties(
    Map<String, dynamic> filters, {
    required String city,
  }) async {
    final token = await SharedPreferecesUtil.getToken();
    if (token == null) {
      throw Exception("Authentication token is missing.");
    }

    // Include city in filters
    filters['city'] = city;

    final response = await http.post(
      Uri.parse('$baseUrl/Property/filtered-properties'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(filters),
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

  // Function to fetch property details by ID
  static Future<Map<String, dynamic>> fetchPropertyById(
    String propertyId,
  ) async {
    try {
      // Retrieve token from SharedPreferences
      final token = await SharedPreferecesUtil.getToken();
      print(token);
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Property/$propertyId'),
        headers: {'Authorization': 'Bearer $token'},
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

  // Function to fetch package list by property ID
  static Future<List<Map<String, dynamic>>> fetchPackagesByPropertyId(
    String propertyId,
  ) async {
    try {
      final token = await SharedPreferecesUtil.getToken();
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Package/by-property/$propertyId'),
        headers: {'Authorization': 'Bearer $token'},
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

  // Function to fetch package details by ID
  static Future<Map<String, dynamic>> fetchPackageById(String packageId) async {
    try {
      // Retrieve token from SharedPreferences
      final token = await SharedPreferecesUtil.getToken();
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Package/$packageId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the decoded JSON response
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
    final token = await SharedPreferecesUtil.getToken();
    if (token == null) {
      throw Exception("Authentication token is missing.");
    }

    final response = await http.post(
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
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to submit rating: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Function to fetch property ratings by property ID
  static Future<List<Map<String, dynamic>>> fetchPropertyRatings(
    String propertyId,
  ) async {
    try {
      final token = await SharedPreferecesUtil.getToken();
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/PropertyRating/$propertyId'),
        headers: {'Authorization': 'Bearer $token'},
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
