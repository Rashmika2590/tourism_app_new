class Room {
  final int id;
  final int hotelId;
  final String name;
  final String type;
  final String description;
  final double price;
  final int maxOccupancy;
  final List<String> amenities;
  final List<String> images;
  final bool? freeCancellation;
  final double? hotelCancellationPercentage;

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.description,
    required this.price,
    required this.maxOccupancy,
    required this.amenities,
    this.images = const [],
    this.freeCancellation,
    this.hotelCancellationPercentage,
  });

  // Calculate the actual price with cancellation fee if applicable
  double get effectivePrice {
    if (freeCancellation == true &&
        hotelCancellationPercentage != null &&
        hotelCancellationPercentage! > 0) {
      final increasedPrice =
          price + (price * hotelCancellationPercentage! / 100);
      print(
        "Room $id: Applying cancellation fee. Base: $price, Percentage: $hotelCancellationPercentage%, Effective: $increasedPrice",
      );
      return increasedPrice;
    } else if (freeCancellation == true) {
      print(
        "Room $id: Free cancellation enabled but no percentage set. Using base price: $price",
      );
    } else {
      print("Room $id: No free cancellation. Using base price: $price");
    }
    return price;
  }

  // Check if room has free cancellation enabled
  bool get hasFreeCancellation =>
      freeCancellation == true &&
      hotelCancellationPercentage != null &&
      hotelCancellationPercentage! > 0;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['type_description'] ?? '',
      price:
          json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] as num?)?.toDouble() ?? 0.0,
      maxOccupancy:
          json['max_occupancy'] is String
              ? int.tryParse(json['max_occupancy']) ?? 0
              : (json['max_occupancy'] ?? 0),
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      freeCancellation: json['free_cancellation'] as bool?,
      hotelCancellationPercentage:
          json['hotel_cancellation_percentage']?.toDouble() ??
          json['cancellation_percentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'type': type,
      'type_description': description,
      'price': price,
      'max_occupancy': maxOccupancy,
      'amenities': amenities,
      'images': images,
      'free_cancellation': freeCancellation,
      'hotel_cancellation_percentage': hotelCancellationPercentage,
    };
  }

  Room copyWith({
    int? id,
    int? hotelId,
    String? name,
    String? type,
    double? price,
    int? maxOccupancy,
    List<String>? amenities,
    List<String>? images,
    bool? freeCancellation,
    double? hotelCancellationPercentage,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description,
      price: price ?? this.price,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      freeCancellation: freeCancellation ?? this.freeCancellation,
      hotelCancellationPercentage:
          hotelCancellationPercentage ?? this.hotelCancellationPercentage,
    );
  }
}
