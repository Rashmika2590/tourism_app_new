import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';

class RoomApiService {
  static const String baseUrl =
      "https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com";
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

  // ====== UPLOAD ROOM TYPE IMAGES ======
  static Future<Map<String, dynamic>> uploadRoomTypeImages({
    required int hotelId,
    required String roomType,
    required List<File> imageFiles,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/$hotelId/$roomType/images");

        print('=== UPLOAD DEBUG INFO ===');
        print('Endpoint: $uri');
        print('Hotel ID: $hotelId');
        print('Room Type: $roomType');
        print('Number of images: ${imageFiles.length}');
        print('Method: PUT');
        print('========================');

        var request = http.MultipartRequest('PUT', uri); // Changed to PUT
        request.headers['Authorization'] = 'Bearer $token';

        // Add all image files
        for (var imageFile in imageFiles) {
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();
          var multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: path.basename(imageFile.path),
          );
          request.files.add(multipartFile);
        }

        print(
          "Uploading ${imageFiles.length} images for room type '$roomType' in hotel $hotelId",
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print(
          "Upload room type images response status: ${response.statusCode}",
        );
        print("Response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          print('✅ Upload successful: $result');
          return result;
        } else {
          print(
            "Upload Room Type Images Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception(
            "Failed to upload room type images: ${response.body}",
          );
        }
      },
    );
  }

  // ====== NEW: UPDATE ROOM TYPE ATTRIBUTES ======
  static Future<Map<String, dynamic>> updateRoomTypeAttributes({
    required int hotelId,
    required String roomType,
    String? typeDescription,
    double? price,
    int? maxOccupancy,
    String? name,
    List<String>? amenities,
    bool? freeCancellation,
    bool? enableShortStay,
    bool? enableLongStay,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/$hotelId/$roomType");

        // Build request body with only provided fields
        Map<String, dynamic> bodyData = {};
        if (typeDescription != null)
          bodyData['type_description'] = typeDescription;
        if (price != null) bodyData['price'] = price;
        if (maxOccupancy != null) bodyData['max_occupancy'] = maxOccupancy;
        if (name != null) bodyData['name'] = name;
        if (amenities != null) bodyData['amenities'] = amenities;
        if (freeCancellation != null)
          bodyData['free_cancellation'] = freeCancellation;
        if (enableShortStay != null)
          bodyData['enable_short_stay'] = enableShortStay;
        if (enableLongStay != null)
          bodyData['enable_long_stay'] = enableLongStay;

        final body = jsonEncode(bodyData);

        print("Updating room type '$roomType' in hotel $hotelId");

        final response = await http.put(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        print("Update room type response status: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            "Update Room Type Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to update room type: ${response.body}");
        }
      },
    );
  }

  // ====== UPLOAD IMAGE TO S3 (Legacy - kept for backward compatibility) ======
  static Future<String> uploadImageToS3(File imageFile) async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception("Authentication failed - no valid token available");
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      var response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseString);
        return responseData['imageUrl'];
      } else {
        throw Exception('Failed to upload image: $responseString');
      }
    } catch (e) {
      print('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // ====== PICK IMAGE FROM GALLERY ======
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  // ====== PICK MULTIPLE IMAGES FROM GALLERY ======
  static Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images from gallery: $e');
      throw Exception('Failed to pick multiple images from gallery: $e');
    }
  }

  // ====== CAPTURE IMAGE FROM CAMERA ======
  static Future<File?> captureImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error capturing image from camera: $e');
      throw Exception('Failed to capture image from camera: $e');
    }
  }

  // ====== ADD ROOM IMAGES (Legacy endpoint) ======
  static Future<Map<String, dynamic>> addRoomImages({
    required int roomId,
    required List<String> imageUrls,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/$roomId/images");
        final body = jsonEncode({"room_id": roomId, "images": imageUrls});
        print("Adding images to room: $roomId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );
        print("Add room images response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            "Add Room Images Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to add room images: ${response.body}");
        }
      },
    );
  }

  // ====== CREATE ROOM ======
  static Future<Map<String, dynamic>> createRoom({
    required int hotelId,
    required String name,
    required String type,
    required double price,
    required String description,
    required int maxOccupancy,
    required List<String> amenities,
    required bool freeCancellation,
    bool? enableShortStay,
    bool? enableLongStay,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/");
        final body = jsonEncode({
          "hotel_id": hotelId,
          "name": name,
          "type": type,
          "price": price,
          "type_description": description,
          "max_occupancy": maxOccupancy,
          "amenities": amenities,
          'free_cancellation': freeCancellation,
          if (enableShortStay != null) 'enable_short_stay': enableShortStay,
          if (enableLongStay != null) 'enable_long_stay': enableLongStay,
        });
        print("Creating room for hotel: $hotelId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );
        print("Room creation response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            "Room Creation Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to create room: ${response.body}");
        }
      },
    );
  }

  // ====== CREATE ROOMS IN BATCH ======
  static Future<Map<String, dynamic>> createRoomsBatch({
    required int hotelId,
    required int numberOfRooms,
    required String type,
    required double price,
    required int maxOccupancy,
    required String name,
    required List<String> amenities,
  }) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/batch");
        final body = jsonEncode({
          "hotel_id": hotelId,
          "number_of_rooms": numberOfRooms,
          "type": type,
          "price": price,
          "max_occupancy": maxOccupancy,
          "name": name,
          "amenities": amenities,
        });
        print("Creating $numberOfRooms rooms in batch for hotel: $hotelId");
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );
        print("Batch room creation response status: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          print(
            "Batch Room Creation Error: ${response.statusCode} - ${response.body}",
          );
          throw Exception("Failed to create rooms in batch: ${response.body}");
        }
      },
    );
  }

  // ====== GET ROOMS BY HOTEL ID ======
  static Future<List<Room>> getRoomsByHotelId(int hotelId) async {
    return await _makeAuthenticatedRequest<List<Room>>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/hotel/$hotelId/rooms");
        print("Getting rooms for hotel ID: $hotelId");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        print("Get rooms response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          try {
            final hotelResponse = await http.get(
              Uri.parse("$baseUrl/hotel/$hotelId"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            );
            if (hotelResponse.statusCode == 200) {
              final hotelData = jsonDecode(hotelResponse.body);
              final double? cancellationPercentage =
                  hotelData['cancellation_percentage']?.toDouble();
              print("=== INJECTING HOTEL CANCELLATION PERCENTAGE ===");
              print("Hotel ID: $hotelId");
              print("Cancellation Percentage: $cancellationPercentage");
              return data.map((roomJson) {
                final room = Room.fromJson(roomJson);
                return room.copyWith(
                  hotelCancellationPercentage: cancellationPercentage,
                );
              }).toList();
            }
          } catch (e) {
            print("Error fetching hotel details: $e");
          }
          return data.map((room) => Room.fromJson(room)).toList();
        } else {
          print("Get Rooms Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get rooms: ${response.body}");
        }
      },
    );
  }

  // ====== GET ROOM BY ID ======
  static Future<Room> getRoomById(int roomId) async {
    return await _makeAuthenticatedRequest<Room>(
      requestFunction: (token) async {
        final uri = Uri.parse("$baseUrl/room/$roomId");
        print("Getting room details for ID: $roomId");
        final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        print("Get room response status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final roomData = jsonDecode(response.body);
          final room = Room.fromJson(roomData);
          try {
            final hotelId = room.hotelId;
            final hotelResponse = await http.get(
              Uri.parse("$baseUrl/hotel/$hotelId"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            );
            if (hotelResponse.statusCode == 200) {
              final hotelData = jsonDecode(hotelResponse.body);
              final double? cancellationPercentage =
                  hotelData['cancellation_percentage']?.toDouble();
              print(
                "=== INJECTING CANCELLATION PERCENTAGE FOR ROOM $roomId ===",
              );
              print("Hotel ID: $hotelId");
              print("Cancellation Percentage: $cancellationPercentage");
              return room.copyWith(
                hotelCancellationPercentage: cancellationPercentage,
              );
            }
          } catch (e) {
            print("Error fetching hotel details for room $roomId: $e");
          }
          return room;
        } else {
          print("Get Room Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to get room details: ${response.body}");
        }
      },
    );
  }
}
