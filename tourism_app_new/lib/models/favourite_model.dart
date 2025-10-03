class Favourite {
  final int id;
  final String userId;
  final int hotelId;

  Favourite({required this.id, required this.userId, required this.hotelId});

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      id: json['id'],
      userId: json['user_id'],
      hotelId: json['hotel_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'hotel_id': hotelId};
  }
}
