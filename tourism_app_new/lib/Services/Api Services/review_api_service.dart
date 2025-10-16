import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/models/review_model.dart';

class ReviewService {
  static const String baseUrl =
      "https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com";
  static final AuthService _authService = AuthService();

  // ====== TOKEN HANDLING ======
  static Future<String?> _getValidToken() async {
    try {
      final token = await _authService.getValidToken();
      print("Retrieved token: ${token != null ? 'SUCCESS' : 'NULL'}");
      return token;
    } catch (e) {
      print("Error getting valid token: $e");
      return null;
    }
  }

  // ====== GENERIC AUTH REQUEST ======
  static Future<T> _makeAuthenticatedRequest<T>({
    required Future<T> Function(String token) requestFunction,
    int maxRetries = 1,
  }) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Authentication failed - no valid token available");
    }

    try {
      T response = await requestFunction(token);

      // Only retry for http.Response
      if (response is http.Response) {
        print("Response status: ${response.statusCode}");
        if (response.statusCode == 401 && maxRetries > 0) {
          print("Token expired, refreshing and retrying...");
          try {
            token = await _authService.getFreshToken();
            if (token == null) {
              throw Exception(
                "Authentication failed - could not refresh token",
              );
            }
            print("Successfully refreshed token");
            response = await requestFunction(token);
            print(
              "Retry response status: ${(response as http.Response).statusCode}",
            );
          } catch (refreshError) {
            print("Token refresh failed: $refreshError");
            throw Exception(
              "Authentication failed - token refresh error: $refreshError",
            );
          }
        }
      }

      return response;
    } catch (e) {
      print("Request failed: $e");
      rethrow;
    }
  }

  // ====== ADD REVIEW ======
  static Future<Review> addReview({
    required int hotelId,
    required int rating,
    required String comment,
    List<http.MultipartFile>? imageFiles,
  }) async {
    return await _makeAuthenticatedRequest<Review>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/review/");

        // Create multipart request
        var request = http.MultipartRequest('POST', uri);

        // Add headers
        request.headers['Authorization'] = 'Bearer $token';

        // Create review data JSON
        final reviewData = {
          'hotel_id': hotelId,
          'rating': rating,
          'comment': comment,
        };

        // Add review data as form field
        request.fields['review_data'] = jsonEncode(reviewData);

        // Add image files if any
        if (imageFiles != null && imageFiles.isNotEmpty) {
          request.files.addAll(imageFiles);
        }

        print("Adding review for hotel: $hotelId, rating: $rating");

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print("Add review response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = jsonDecode(response.body);
          return Review.fromJson(jsonData);
        } else {
          print("Add Review Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to add review: ${response.body}");
        }
      },
    );
  }

  // ====== GET REVIEWS FOR HOTEL ======
  static Future<List<Review>> getReviewsForHotel(int hotelId) async {
    return await _makeAuthenticatedRequest<List<Review>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/review/?hotel_id=$hotelId");

        print("Getting reviews for hotel: $hotelId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get reviews response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData is List) {
            return jsonData
                .map((reviewJson) => Review.fromJson(reviewJson))
                .toList();
          } else {
            throw Exception("Invalid response format for reviews");
          }
        } else {
          print("Get Reviews Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get reviews: ${response.body}");
        }
      },
    );
  }

  // ====== HELPER METHOD TO CREATE MULTIPART FILE ======
  static http.MultipartFile createMultipartFile(
    String fieldName,
    List<int> fileBytes, {
    required String filename,
    String? contentType,
  }) {
    return http.MultipartFile.fromBytes(
      fieldName,
      fileBytes,
      filename: filename,
      contentType: contentType != null ? MediaType.parse(contentType) : null,
    );
  }
}
