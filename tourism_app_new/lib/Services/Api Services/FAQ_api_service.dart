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

  // ====== GET USER REACTION FOR FAQ ======
  static Future<UserReaction?> getUserReaction(int faqId) async {
    try {
      return await _makeAuthenticatedRequest<UserReaction?>(
        requestFunction: (token) async {
          final uri = Uri.parse("$baseUrl/faq/$faqId/user_reaction");

          print("Getting user reaction for FAQ: $faqId");

          final response = await http.get(
            uri,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          );

          print("Get user reaction response status: ${response.statusCode}");

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            return UserReaction.fromJson(jsonData);
          } else if (response.statusCode == 404) {
            // User hasn't reacted to this FAQ yet
            print("No reaction found for FAQ: $faqId");
            return null;
          } else {
            print(
              "Get user reaction Error: ${response.statusCode} - ${response.body}",
            );
            throw Exception("Failed to get user reaction: ${response.body}");
          }
        },
      );
    } catch (e) {
      print("Error getting user reaction: $e");
      return null;
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

  // ====== DELETE REACTION FROM FAQ ======
  static Future<void> deleteReaction(int faqId) async {
    return await _makeAuthenticatedRequest<void>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/$faqId/reaction");

        print("Deleting reaction for FAQ: $faqId");

        final response = await http.delete(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Delete reaction response status: ${response.statusCode}");
        if (response.statusCode == 200 ||
            response.statusCode == 204 ||
            response.statusCode == 204) {
          print("Reaction deleted successfully");
          return;
        } else {
          print(
            "Delete reaction Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to delete reaction: ${response.body}");
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

// ====== NEW MODEL FOR USER REACTION ======
class UserReaction {
  final int id;
  final int faqId;
  final String userId;
  final bool reacted;
  final bool isLike;
  final DateTime createdDate;

  UserReaction({
    required this.id,
    required this.faqId,
    required this.userId,
    required this.reacted,
    required this.isLike,
    required this.createdDate,
  });

  factory UserReaction.fromJson(Map<String, dynamic> json) {
    return UserReaction(
      id: json['id'] ?? 0,
      faqId: json['faq_id'] ?? 0,
      userId: json['user_id'] ?? '',
      reacted: json['reacted'] ?? false,
      isLike: json['is_like'] ?? false,
      createdDate: DateTime.parse(json['created_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faq_id': faqId,
      'user_id': userId,
      'reacted': reacted,
      'is_like': isLike,
      'created_date': createdDate.toIso8601String(),
    };
  }
}
