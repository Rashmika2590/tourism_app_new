class Room {
  final int id;
  final int hotelId;
  final String name;
  final String type;
  final double price;
  final int maxOccupancy;
  final List<String> amenities;
  final List<String> images; // Added images field

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.price,
    required this.maxOccupancy,
    required this.amenities,
    this.images = const [], // Default empty list
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'type': type,
      'price': price,
      'max_occupancy': maxOccupancy,
      'amenities': amenities,
      'images': images,
    };
  }
}
