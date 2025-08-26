import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/core/services/Authentication/auth_service..dart';

class ApiService {
  static const String baseUrl =
      'https://crabi-go-backend.t7gbzs75g5tc2.ap-southeast-1.cs.amazonlightsail.com';
  static final AuthService _authService = AuthService();

  // ====== TOKEN HANDLING ======
  static Future<String?> _getValidToken() async {
    return await _authService.getValidToken();
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

    // Print token for debugging
    print("Bearer Token: $token");

    T response = await requestFunction(token);

    // Token refresh logic for http.Response only
    if (response is http.Response &&
        response.statusCode == 401 &&
        maxRetries > 0) {
      print("Token expired, refreshing and retrying...");
      token = await _authService.getFreshToken();
      if (token == null) {
        throw Exception("Authentication failed - could not refresh token");
      }
      print("Refreshed Bearer Token: $token");
      response = await requestFunction(token);
    }

    return response;
  }

  // ====== HOTEL APIS ======

  /// Create a new hotel
  static Future<Hotel> createHotel(Hotel hotel) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/hotel/');
        return await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(hotel.toJson()),
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return Hotel.fromJson(jsonData);
    } else {
      print(
        'Create Hotel Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to create hotel: ${response.body}');
    }
  }

  /// Search hotels with optional filters
  static Future<List<Hotel>> searchHotels({
    String? state,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final searchParams = HotelSearchParams(
      state: state,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final queryParams = searchParams.toQueryParams();
        final uri = Uri.parse(
          '$baseUrl/hotel/',
        ).replace(queryParameters: queryParams);

        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Hotel.fromJson(json)).toList();
    } else {
      print(
        'Search Hotels Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to search hotels: ${response.body}');
    }
  }

  /// Get all hotels (without filters)
  static Future<List<Hotel>> getAllHotels() async {
    return await searchHotels();
  }

  /// Attempt to fetch hotels by a list of ids.
  /// This assumes backend accepts `ids` query like /hotel/?ids=1,2,3
  /// If backend returns 400/404 for this pattern, the caller should handle fallback.
  static Future<List<Hotel>> getHotelsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final idsParam = ids.join(',');

    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse(
          '$baseUrl/hotel/',
        ).replace(queryParameters: {'ids': idsParam});
        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Hotel.fromJson(json)).toList();
    } else {
      // If backend doesn't support filtering by ids, fall back to fetching all
      print(
        'getHotelsByIds - unexpected status ${response.statusCode}, body: ${response.body}. Falling back to getAllHotels.',
      );
      return await getAllHotels();
    }
  }

  // ====== ROOM APIS ======

  /// Add a room to a hotel
  static Future<Room> addRoomToHotel(Room room) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/room/');
        return await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(room.toJson()),
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return Room.fromJson(jsonData);
    } else {
      print(
        'Add Room Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to add room: ${response.body}');
    }
  }

  /// Get all rooms for a specific hotel
  static Future<List<Room>> getHotelRooms(int hotelId) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse(
          '$baseUrl/room/',
        ).replace(queryParameters: {'hotel_id': hotelId.toString()});

        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Room.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // No rooms found for this hotel
      return [];
    } else {
      print(
        'Get Hotel Rooms Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to get hotel rooms: ${response.body}');
    }
  }

  /// Get a specific room by ID
  static Future<Room> getRoomById(int roomId) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/room/$roomId');
        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Room.fromJson(jsonData);
    } else {
      print(
        'Get Room Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to get room: ${response.body}');
    }
  }

  /// Update a room
  static Future<Room> updateRoom(Room room) async {
    if (room.id == null) {
      throw Exception('Room ID is required for update');
    }

    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/room/${room.id}');
        return await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(room.toJson()),
        );
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Room.fromJson(jsonData);
    } else {
      print(
        'Update Room Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to update room: ${response.body}');
    }
  }

  /// Delete a room
  static Future<bool> deleteRoom(int roomId) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('$baseUrl/room/$roomId');
        return await http.delete(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print(
        'Delete Room Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to delete room: ${response.body}');
    }
  }

  // ====== AVAILABILITY APIS ======

  static Future<AvailabilityResponse> searchAvailability(
    AvailabilitySearchParams searchParams,
  ) async {
    final response = await _makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final queryParams = searchParams.toQueryParams();
        final uri = Uri.parse(
          '$baseUrl/availability/',
        ).replace(queryParameters: queryParams);

        print('Searching availability with URL: $uri');

        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return AvailabilityResponse.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      // No availability found - return empty response
      return AvailabilityResponse(available: {});
    } else {
      print(
        'Search Availability Error - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to search availability: ${response.body}');
    }
  }

  /// Search availability and get detailed hotel information
  /// Improved: only fetch hotels by IDs returned from availability when possible.
  static Future<List<HotelWithAvailability>> searchAvailabilityWithHotelDetails(
    AvailabilitySearchParams searchParams,
  ) async {
    try {
      // First, get availability data
      final availabilityResponse = await searchAvailability(searchParams);

      if (availabilityResponse.availableHotelIds.isEmpty) {
        return [];
      }

      // If backend supports fetching hotels by ids, this will be efficient.
      // Fallback handled inside getHotelsByIds (it will return all hotels if ids query isn't supported).
      final List<Hotel> hotels = await getHotelsByIds(
        availabilityResponse.availableHotelIds,
      );

      // Filter hotels that have availability and create HotelWithAvailability objects
      final List<HotelWithAvailability> hotelsWithAvailability = [];

      for (final hotelId in availabilityResponse.availableHotelIds) {
        // Find the hotel in our hotel list
        final hotel = hotels.firstWhere(
          (h) => h.id == hotelId,
          orElse: () {
            print('Hotel with ID $hotelId not found in hotel list - skipping');
            return Hotel(
              id: hotelId,
              name: 'Unknown Hotel',
              address: '',
              state: '',
              postalCode: '',
              latitude: 0.0,
              longitude: 0.0,
              rules: [],
              email: '',
              mobile: '',
              images: '',
              enableShortStay: false,
              enableLongStay: false,
              description: '',
            );
          },
        );

        final availableRoomIds = availabilityResponse.getAvailableRoomIds(
          hotelId,
        );

        hotelsWithAvailability.add(
          HotelWithAvailability(
            hotel: hotel,
            availableRoomIds: availableRoomIds,
          ),
        );
      }

      return hotelsWithAvailability;
    } catch (e) {
      print('Error in searchAvailabilityWithHotelDetails: $e');
      throw Exception('Failed to search availability with hotel details: $e');
    }
  }

  /// Search availability with full hotel and room details
  static Future<List<HotelWithAvailability>> searchAvailabilityWithFullDetails(
    AvailabilitySearchParams searchParams,
  ) async {
    try {
      // Get hotels with availability (hotel objects + availableRoomIds)
      final hotelsWithAvailability = await searchAvailabilityWithHotelDetails(
        searchParams,
      );

      if (hotelsWithAvailability.isEmpty) return [];

      // Fetch room details for each hotel and populate availableRooms
      final List<HotelWithAvailability> completeResults = [];

      for (final hotelAvailability in hotelsWithAvailability) {
        try {
          // Get all rooms for this hotel
          final allRooms = await getHotelRooms(hotelAvailability.hotel.id!);

          // Filter only the available rooms
          final availableRooms =
              allRooms.where((room) {
                return hotelAvailability.availableRoomIds.contains(room.id);
              }).toList();

          completeResults.add(
            hotelAvailability.copyWith(availableRooms: availableRooms),
          );
        } catch (e) {
          print(
            'Error fetching rooms for hotel ${hotelAvailability.hotel.id}: $e',
          );
          // Still include the hotel even if room details failed
          completeResults.add(hotelAvailability);
        }
      }

      return completeResults;
    } catch (e) {
      print('Error in searchAvailabilityWithFullDetails: $e');
      throw Exception('Failed to search availability with full details: $e');
    }
  }

  /// Quick availability search with minimal parameters
  static Future<AvailabilityResponse> quickAvailabilitySearch({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String checkInTime = "14:00",
    String checkOutTime = "11:00",
    int adultCount = 1,
    int childrenCount = 0,
    String? state,
  }) async {
    final searchParams = AvailabilitySearchParams(
      checkInDate: checkInDate,
      checkInTime: checkInTime,
      checkOutDate: checkOutDate,
      checkOutTime: checkOutTime,
      adultCount: adultCount,
      childrenCount: childrenCount,
      state: state,
    );

    return await searchAvailability(searchParams);
  }

  /// Search availability near a specific location
  static Future<AvailabilityResponse> searchAvailabilityNearLocation({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double latitude,
    required double longitude,
    double maxDistanceKm = 10.0,
    String checkInTime = "14:00",
    String checkOutTime = "11:00",
    int adultCount = 1,
    int childrenCount = 0,
  }) async {
    final searchParams = AvailabilitySearchParams(
      checkInDate: checkInDate,
      checkInTime: checkInTime,
      checkOutDate: checkOutDate,
      checkOutTime: checkOutTime,
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
      adultCount: adultCount,
      childrenCount: childrenCount,
    );

    return await searchAvailability(searchParams);
  }

  /// Check availability for a specific hotel
  static Future<List<int>> checkHotelAvailability({
    required int hotelId,
    required AvailabilitySearchParams searchParams,
  }) async {
    final availabilityResponse = await searchAvailability(searchParams);
    return availabilityResponse.getAvailableRoomIds(hotelId);
  }

  /// Check if a specific room is available
  static Future<bool> isRoomAvailable({
    required int roomId,
    required int hotelId,
    required AvailabilitySearchParams searchParams,
  }) async {
    final availableRoomIds = await checkHotelAvailability(
      hotelId: hotelId,
      searchParams: searchParams,
    );
    return availableRoomIds.contains(roomId);
  }
}
