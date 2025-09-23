import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/models/faq_model.dart';

class FAQService {
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

  // ====== CREATE FAQ ======
  static Future<CreateFAQResponse> createFAQ(CreateFAQRequest request) async {
    return await _makeAuthenticatedRequest<CreateFAQResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/");

        print("Creating FAQ for hotel: ${request.hotelId}");

        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(request.toJson()),
        );

        print("Create FAQ response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = jsonDecode(response.body);
          return CreateFAQResponse.fromJson(jsonData);
        } else {
          print("Create FAQ Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to create FAQ: ${response.body}");
        }
      },
    );
  }

  // ====== ADD REACTION TO FAQ ======
  static Future<FAQReactionResponse> addReaction(
    int faqId,
    FAQReactionRequest request,
  ) async {
    return await _makeAuthenticatedRequest<FAQReactionResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/$faqId/reaction");

        print("Adding reaction to FAQ: $faqId, isLike: ${request.isLike}");

        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(request.toJson()),
        );

        print("Add reaction response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = jsonDecode(response.body);
          return FAQReactionResponse.fromJson(jsonData);
        } else {
          print(
            "Add reaction Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to add reaction: ${response.body}");
        }
      },
    );
  }

  // ====== GET FAQS FOR HOTEL ======
  static Future<FAQResponse> getFAQsForHotel(int hotelId) async {
    return await _makeAuthenticatedRequest<FAQResponse>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/hotel/$hotelId/");

        print("Getting FAQs for hotel: $hotelId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get FAQs response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          return FAQResponse.fromJson(jsonData);
        } else {
          print("Get FAQs Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get FAQs: ${response.body}");
        }
      },
    );
  }

  // ====== HELPER METHODS ======
  static Future<CreateFAQResponse> createFAQForHotel({
    required int hotelId,
    required String question,
  }) async {
    final now = DateTime.now();
    final request = CreateFAQRequest(
      hotelId: hotelId,
      question: question,
      createdDate: now,
      updatedDate: now,
    );

    return await createFAQ(request);
  }

  static Future<FAQReactionResponse> likeFAQ(int faqId) async {
    final request = FAQReactionRequest(
      isLike: true,
      createdDate: DateTime.now(),
    );

    return await addReaction(faqId, request);
  }

  static Future<FAQReactionResponse> dislikeFAQ(int faqId) async {
    final request = FAQReactionRequest(
      isLike: false,
      createdDate: DateTime.now(),
    );

    return await addReaction(faqId, request);
  }
}
