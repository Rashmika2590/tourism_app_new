import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class FAQApiService {
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

  // ====== GET FAQs FOR HOTEL ======
  static Future<List<FAQ>> getFAQs(int hotelId) async {
    return await _makeAuthenticatedRequest<List<FAQ>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/?hotel_id=$hotelId");
        print("Getting FAQs for hotel: $hotelId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get FAQs response: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((item) => FAQ.fromJson(item)).toList();
        } else {
          throw Exception("Failed to load FAQs: ${response.body}");
        }
      },
    );
  }

  // ====== CREATE FAQ ======
  static Future<FAQ> createFAQ({
    required int hotelId,
    required String question,
  }) async {
    return await _makeAuthenticatedRequest<FAQ>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/");
        final body = jsonEncode({
          "hotel_id": hotelId,
          "created_date": DateTime.now().toIso8601String(),
          "updated_date": DateTime.now().toIso8601String(),
          "question": question,
        });

        print("Creating FAQ for hotel: $hotelId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("Create FAQ response: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return FAQ.fromJson(json.decode(response.body));
        } else {
          throw Exception("Failed to create FAQ: ${response.body}");
        }
      },
    );
  }

  // ====== REACT TO FAQ ======
  static Future<bool> reactToFAQ({
    required int faqId,
    required bool isLike,
  }) async {
    return await _makeAuthenticatedRequest<bool>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/$faqId/reaction");
        final body = jsonEncode({
          "is_like": isLike,
          "created_date": DateTime.now().toIso8601String(),
        });

        print("Reacting to FAQ: $faqId with ${isLike ? 'like' : 'dislike'}");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("React to FAQ response: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          throw Exception("Failed to react to FAQ: ${response.body}");
        }
      },
    );
  }

  // ====== GET FAQ BY ID ======
  static Future<FAQ> getFAQById(int faqId) async {
    return await _makeAuthenticatedRequest<FAQ>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/faq/$faqId");
        print("Getting FAQ by ID: $faqId");

        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Get FAQ by ID response: ${response.statusCode}");
        if (response.statusCode == 200) {
          return FAQ.fromJson(json.decode(response.body));
        } else {
          throw Exception("Failed to load FAQ: ${response.body}");
        }
      },
    );
  }
}

// FAQ Model
class FAQ {
  final int id;
  final int hotelId;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String question;
  final String? answer;
  int likes;
  int dislikes;
  bool? userReaction; // true for like, false for dislike, null for no reaction

  FAQ({
    required this.id,
    required this.hotelId,
    required this.createdDate,
    required this.updatedDate,
    required this.question,
    this.answer,
    this.likes = 0,
    this.dislikes = 0,
    this.userReaction,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      createdDate: DateTime.parse(
        json['created_date'] ?? DateTime.now().toIso8601String(),
      ),
      updatedDate: DateTime.parse(
        json['updated_date'] ?? DateTime.now().toIso8601String(),
      ),
      question: json['question'] ?? '',
      answer: json['answer'],
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      userReaction: json['user_reaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'created_date': createdDate.toIso8601String(),
      'updated_date': updatedDate.toIso8601String(),
      'question': question,
      'answer': answer,
      'likes': likes,
      'dislikes': dislikes,
      'user_reaction': userReaction,
    };
  }
}
