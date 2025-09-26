// models/filter_options.dart
class FilterOptions {
  double? minPrice;
  double? maxPrice;
  List<String> selectedAmenities;
  int? minRating;
  double? maxDistance;
  List<String> selectedHotelTypes;
  bool? freeWifi;
  bool? freeParking;
  bool? petFriendly;
  bool? pool;
  bool? gym;
  bool? spa;
  bool? restaurant;
  bool? roomService;

  FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.selectedAmenities = const [],
    this.minRating,
    this.maxDistance,
    this.selectedHotelTypes = const [],
    this.freeWifi,
    this.freeParking,
    this.petFriendly,
    this.pool,
    this.gym,
    this.spa,
    this.restaurant,
    this.roomService,
  });

  // Create a copy with modified values
  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? selectedAmenities,
    int? minRating,
    double? maxDistance,
    List<String>? selectedHotelTypes,
    bool? freeWifi,
    bool? freeParking,
    bool? petFriendly,
    bool? pool,
    bool? gym,
    bool? spa,
    bool? restaurant,
    bool? roomService,
  }) {
    return FilterOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      minRating: minRating ?? this.minRating,
      maxDistance: maxDistance ?? this.maxDistance,
      selectedHotelTypes: selectedHotelTypes ?? this.selectedHotelTypes,
      freeWifi: freeWifi ?? this.freeWifi,
      freeParking: freeParking ?? this.freeParking,
      petFriendly: petFriendly ?? this.petFriendly,
      pool: pool ?? this.pool,
      gym: gym ?? this.gym,
      spa: spa ?? this.spa,
      restaurant: restaurant ?? this.restaurant,
      roomService: roomService ?? this.roomService,
    );
  }

  // Convert to JSON for backend API
  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'selectedAmenities': selectedAmenities,
      'minRating': minRating,
      'maxDistance': maxDistance,
      'selectedHotelTypes': selectedHotelTypes,
      'freeWifi': freeWifi,
      'freeParking': freeParking,
      'petFriendly': petFriendly,
      'pool': pool,
      'gym': gym,
      'spa': spa,
      'restaurant': restaurant,
      'roomService': roomService,
    };
  }

  // Create from JSON response from backend
  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      selectedAmenities: List<String>.from(json['selectedAmenities'] ?? []),
      minRating: json['minRating'],
      maxDistance: json['maxDistance']?.toDouble(),
      selectedHotelTypes: List<String>.from(json['selectedHotelTypes'] ?? []),
      freeWifi: json['freeWifi'],
      freeParking: json['freeParking'],
      petFriendly: json['petFriendly'],
      pool: json['pool'],
      gym: json['gym'],
      spa: json['spa'],
      restaurant: json['restaurant'],
      roomService: json['roomService'],
    );
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        selectedAmenities.isNotEmpty ||
        minRating != null ||
        maxDistance != null ||
        selectedHotelTypes.isNotEmpty ||
        freeWifi == true ||
        freeParking == true ||
        petFriendly == true ||
        pool == true ||
        gym == true ||
        spa == true ||
        restaurant == true ||
        roomService == true;
  }

  // Reset all filters
  FilterOptions clearAll() {
    return FilterOptions();
  }
}
