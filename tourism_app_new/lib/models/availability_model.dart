import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';

class AvailabilitySearchParams {
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime checkOutDate;
  final String checkOutTime;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? maxDistanceKm;
  final int adultCount;
  final int childrenCount;

  AvailabilitySearchParams({
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    this.state,
    this.latitude,
    this.longitude,
    this.maxDistanceKm,
    this.adultCount = 1,
    this.childrenCount = 0,
  });

  // Convert to query parameters for API call
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    // Format dates as YYYY-MM-DD
    params['ci_date'] =
        '${checkInDate.year.toString().padLeft(4, '0')}-${checkInDate.month.toString().padLeft(2, '0')}-${checkInDate.day.toString().padLeft(2, '0')}';
    params['co_date'] =
        '${checkOutDate.year.toString().padLeft(4, '0')}-${checkOutDate.month.toString().padLeft(2, '0')}-${checkOutDate.day.toString().padLeft(2, '0')}';

    // Add times (ensure HH:MM:SS format)
    params['ci_time'] =
        checkInTime.contains(':')
            ? (checkInTime.split(':').length == 2
                ? '$checkInTime:00'
                : checkInTime)
            : '$checkInTime:00:00';
    params['co_time'] =
        checkOutTime.contains(':')
            ? (checkOutTime.split(':').length == 2
                ? '$checkOutTime:00'
                : checkOutTime)
            : '$checkOutTime:00:00';

    // Add guest counts
    params['adult_count'] = adultCount.toString();
    params['children_count'] = childrenCount.toString();

    // Add optional location parameters
    if (state != null) params['state'] = state!;
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    if (maxDistanceKm != null)
      params['max_distance_km'] = maxDistanceKm.toString();

    return params;
  }

  // Create copy with updated values
  AvailabilitySearchParams copyWith({
    DateTime? checkInDate,
    String? checkInTime,
    DateTime? checkOutDate,
    String? checkOutTime,
    String? state,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
    int? adultCount,
    int? childrenCount,
  }) {
    return AvailabilitySearchParams(
      checkInDate: checkInDate ?? this.checkInDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      adultCount: adultCount ?? this.adultCount,
      childrenCount: childrenCount ?? this.childrenCount,
    );
  }

  @override
  String toString() {
    return 'AvailabilitySearchParams(checkIn: $checkInDate $checkInTime, checkOut: $checkOutDate $checkOutTime, adults: $adultCount, children: $childrenCount, state: $state, location: $latitude,$longitude, maxDistance: $maxDistanceKm)';
  }
}

// Response model based on actual backend response
class AvailabilityResponse {
  final Map<int, List<int>> available; // hotelId -> List of available room IDs

  AvailabilityResponse({required this.available});

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final Map<int, List<int>> availableMap = {};

    if (json['available'] != null) {
      final availableData = json['available'] as Map<String, dynamic>;

      availableData.forEach((key, value) {
        final hotelId = int.parse(key);
        final roomIds = List<int>.from(value as List);
        availableMap[hotelId] = roomIds;
      });
    }

    return AvailabilityResponse(available: availableMap);
  }

  // Get all hotel IDs that have availability
  List<int> get availableHotelIds => available.keys.toList();

  // Get available room IDs for a specific hotel
  List<int> getAvailableRoomIds(int hotelId) {
    return available[hotelId] ?? [];
  }

  // Check if a hotel has any availability
  bool hasAvailability(int hotelId) {
    return available.containsKey(hotelId) && available[hotelId]!.isNotEmpty;
  }

  // Get total number of available rooms across all hotels
  int get totalAvailableRooms {
    return available.values.fold(0, (sum, roomList) => sum + roomList.length);
  }

  @override
  String toString() {
    return 'AvailabilityResponse(available: $available)';
  }
}

// Model to combine hotel info with availability data
class HotelWithAvailability {
  final Hotel hotel;
  final List<int> availableRoomIds;
  final List<Room>? availableRooms; // Will be populated if rooms are fetched

  HotelWithAvailability({
    required this.hotel,
    required this.availableRoomIds,
    this.availableRooms,
  });

  // Get number of available rooms
  int get availableRoomCount => availableRoomIds.length;

  // Check if hotel has availability
  bool get hasAvailability => availableRoomIds.isNotEmpty;

  // Create copy with room details
  HotelWithAvailability copyWith({
    Hotel? hotel,
    List<int>? availableRoomIds,
    List<Room>? availableRooms,
  }) {
    return HotelWithAvailability(
      hotel: hotel ?? this.hotel,
      availableRoomIds: availableRoomIds ?? this.availableRoomIds,
      availableRooms: availableRooms ?? this.availableRooms,
    );
  }

  @override
  String toString() {
    return 'HotelWithAvailability(hotel: ${hotel.name}, availableRoomIds: $availableRoomIds, roomsLoaded: ${availableRooms != null})';
  }
}
