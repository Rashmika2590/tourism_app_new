class Room {
  final int? id;
  final int hotelId;
  final String type;
  final double price;
  final int maxOccupancy;
  final String name;
  final List<String> amenities;

  Room({
    this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    required this.maxOccupancy,
    required this.name,
    required this.amenities,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      hotelId: json['hotel_id'] ?? 0,
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      maxOccupancy: json['max_occupancy'] ?? 0,
      name: json['name'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'hotel_id': hotelId,
      'type': type,
      'price': price,
      'max_occupancy': maxOccupancy,
      'name': name,
      'amenities': amenities,
    };
  }

  Room copyWith({
    int? id,
    int? hotelId,
    String? type,
    double? price,
    int? maxOccupancy,
    String? name,
    List<String>? amenities,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      type: type ?? this.type,
      price: price ?? this.price,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      name: name ?? this.name,
      amenities: amenities ?? this.amenities,
    );
  }

  @override
  String toString() {
    return 'Room{id: $id, hotelId: $hotelId, type: $type, price: $price, maxOccupancy: $maxOccupancy, name: $name, amenities: $amenities}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          hotelId == other.hotelId &&
          type == other.type &&
          price == other.price &&
          maxOccupancy == other.maxOccupancy &&
          name == other.name;

  @override
  int get hashCode =>
      id.hashCode ^
      hotelId.hashCode ^
      type.hashCode ^
      price.hashCode ^
      maxOccupancy.hashCode ^
      name.hashCode;
}
