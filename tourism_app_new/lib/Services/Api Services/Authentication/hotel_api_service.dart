import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class HotelApiService {
  static const String baseUrl =
      'https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com';
  static final AuthService _authService = AuthService();
  static final ImagePicker _imagePicker = ImagePicker();

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
      // Token refresh logic for http.Response only
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

  // ====== HOTEL CREATION ======
  static Future<Map<String, dynamic>> createHotel({
    required String name,
    required String address,
    required String state,
    required String postalCode,
    required double latitude,
    required double longitude,
    required List<String> rules,
    required String email,
    required String mobile,
    required bool enableShortStay,
    required bool enableLongStay,
    required String description,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/hotel/');
        final requestBody = {
          "name": name,
          "address": address,
          "state": state,
          "postal_code": postalCode,
          "latitude": latitude,
          "longitude": longitude,
          "rules": rules,
          "email": email,
          "mobile": mobile,
          "enable_short_stay": enableShortStay,
          "enable_long_stay": enableLongStay,
          "description": description,
        };
        print("Creating hotel: $name");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(requestBody),
        );
        print("Hotel creation response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            'Hotel Creation Error: ${response.statusCode} - ${response.body}',
          );
          throw Exception('Failed to create hotel: ${response.body}');
        }
      },
    );
  }

  // ====== SEARCH HOTELS ======
  static Future<List<Hotel>> searchHotels({
    String? state,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    return await _makeAuthenticatedRequest<List<Hotel>>(
      requestFunction: (token) async {
        final queryParams = <String, String>{};
        if (state != null) queryParams['state'] = state;
        if (latitude != null) queryParams['latitude'] = latitude.toString();
        if (longitude != null) queryParams['longitude'] = longitude.toString();
        if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();

        final uri = Uri.parse(
          '$baseUrl/hotel/',
        ).replace(queryParameters: queryParams);
        print("Searching hotels with params: $queryParams");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        print("Hotel search response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> hotelsJson = jsonDecode(response.body);
          return hotelsJson.map((json) => Hotel.fromJson(json)).toList();
        } else {
          print(
            'Hotel Search Error: ${response.statusCode} - ${response.body}',
          );
          throw Exception('Failed to search hotels: ${response.body}');
        }
      },
    );
  }

  // ====== GET ALL HOTELS (DEFAULT VIEW) ======
  static Future<List<Hotel>> getAllHotels() async {
    return await searchHotels(); // Call without filters
  }

  // ====== GET HOTEL BY ID ======
  static Future<Hotel> getHotelById(int hotelId) async {
    return await _makeAuthenticatedRequest<Hotel>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/hotel/$hotelId');
        print("Getting hotel details for ID: $hotelId");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        print("Get hotel response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          return Hotel.fromJson(jsonDecode(response.body));
        } else {
          print('Get Hotel Error: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to get hotel details: ${response.body}');
        }
      },
    );
  }

  // ====== UPLOAD HOTEL IMAGES ======
  static Future<Map<String, dynamic>> uploadHotelImages({
    required int id,
    required List<XFile> images,
  }) async {
    final token = await _getValidToken();
    if (token == null) throw Exception("No valid token");

    final uri = Uri.parse('$baseUrl/hotel/$id/images');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (var imageFile in images) {
      final file = File(imageFile.path);
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      final contentType =
          (ext == 'png')
              ? MediaType('image', 'png')
              : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename: fileName,
          contentType: contentType,
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to upload hotel images: ${res.body}');
    }
  }

  // ====== IMAGE PICKER METHODS ======
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1440,
      );
      return image;
    } catch (e) {
      print("Error picking image from gallery: $e");
      return null;
    }
  }

  static Future<XFile?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1440,
      );
      return image;
    } catch (e) {
      print("Error taking photo with camera: $e");
      return null;
    }
  }

  // ====== ALTERNATIVE UPLOAD METHOD (if the first one doesn't work) ======
  static Future<Map<String, dynamic>> uploadHotelImagesAlternative({
    required int hotelId,
    required List<XFile> imageFiles,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/hotel/$hotelId/images');
        print("Uploading images using alternative method for hotel: $hotelId");

        // Create a multipart request
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $token';

        // Add each image as a separate part
        for (int i = 0; i < imageFiles.length; i++) {
          final file = File(imageFiles[i].path);
          final fileName = file.path.split('/').last;

          request.files.add(
            http.MultipartFile(
              'image_$i', // Field name
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }

        print(
          "Sending alternative multipart request with ${request.files.length} files",
        );
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print("Alternative upload response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            'Alternative Upload Error: ${response.statusCode} - ${response.body}',
          );
          throw Exception('Failed to upload hotel images: ${response.body}');
        }
      },
    );
  }

  // ====== HOTEL VERIFICATION ======
  static Future<Map<String, dynamic>> submitHotelVerification({
    required int hotelId,
    required String identityNumber,
    required String verificationDocumentType,
    required String verificationDocument,
    required DateTime verificationDate,
    required bool verifiedStatus,
    required String selfie,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final url = Uri.parse("$baseUrl/hotel/verification/$hotelId");

        final body = jsonEncode({
          "identity_number": identityNumber,
          "verification_document_type": verificationDocumentType,
          "verification_document": verificationDocument,
          "verification_date": verificationDate.toIso8601String(),
          "verified_status": verifiedStatus,
          "selfie": selfie,
        });

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("Verification create status: ${response.statusCode}");
        print("Verification create response: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          throw Exception(
            "Failed to create verification entry: ${response.statusCode} ${response.body}",
          );
        }
      },
    );
  }

  // ====== UPLOAD VERIFICATION FILES ======
  static Future<Map<String, dynamic>> uploadVerificationFiles({
    required int hotelId,
    required File docFile,
    required File selfieFile,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final url = Uri.parse("$baseUrl/hotel/verification/$hotelId/files");
        final request = http.MultipartRequest("POST", url);

        // ✅ add Authorization header
        request.headers["Authorization"] = "Bearer $token";

        request.files.add(
          await http.MultipartFile.fromPath("doc", docFile.path),
        );
        request.files.add(
          await http.MultipartFile.fromPath("selfie", selfieFile.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print("Upload files status: ${response.statusCode}");
        print("Upload files response: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          throw Exception(
            "Failed to upload verification files: ${response.statusCode} ${response.body}",
          );
        }
      },
    );
  }
}
