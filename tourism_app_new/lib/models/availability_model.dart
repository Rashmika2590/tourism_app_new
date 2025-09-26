class RoomAvailabilityParams {
  final String ciDate;
  final String ciTime;
  final String coDate;
  final String coTime;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final int? adultCount;
  final int? childrenCount;

  RoomAvailabilityParams({
    required this.ciDate,
    required this.ciTime,
    required this.coDate,
    required this.coTime,
    this.state,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.adultCount,
    this.childrenCount,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'ci_date': ciDate,
      'ci_time': ciTime,
      'co_date': coDate,
      'co_time': coTime,
    };

    if (state != null) params['state'] = state;
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    if (radiusKm != null) params['radius_km'] = radiusKm.toString();
    if (adultCount != null) params['adult_count'] = adultCount.toString();
    if (childrenCount != null)
      params['children_count'] = childrenCount.toString();

    return params;
  }
}

class RoomAvailability {
  final Map<String, List<int>> available;

  RoomAvailability({required this.available});

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    final Map<String, List<int>> availableMap = {};

    if (json['available'] != null) {
      final available = json['available'] as Map<String, dynamic>;
      available.forEach((hotelId, roomIds) {
        if (roomIds is List) {
          availableMap[hotelId] = List<int>.from(roomIds);
        }
      });
    }

    return RoomAvailability(available: availableMap);
  }

  Map<String, dynamic> toJson() {
    return {'available': available};
  }

  // Convert hotel IDs to int
  List<int> get hotelIds =>
      available.keys
          .map((key) => int.tryParse(key))
          .where((id) => id != null)
          .map((id) => id!)
          .toList();

  List<int> getRoomIdsForHotel(int hotelId) {
    return available[hotelId.toString()] ?? [];
  }

  bool hasAvailableRooms() {
    return available.isNotEmpty;
  }

  int getTotalAvailableRooms() {
    return available.values
        .map((roomIds) => roomIds.length)
        .fold(0, (sum, count) => sum + count);
  }
}
