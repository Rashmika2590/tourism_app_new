class Review {
  final int id;
  final String comment;
  final DateTime updatedDate;
  final String userId;
  final int hotelId;
  final int rating;
  final DateTime createdDate;
  final List<String> images;

  Review({
    required this.id,
    required this.comment,
    required this.updatedDate,
    required this.userId,
    required this.hotelId,
    required this.rating,
    required this.createdDate,
    required this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      comment: json['comment'] as String,
      updatedDate: DateTime.parse(json['updated_date']),
      userId: json['user_id'] as String,
      hotelId: json['hotel_id'] as int,
      rating: json['rating'] as int,
      createdDate: DateTime.parse(json['created_date']),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'updated_date': updatedDate.toIso8601String(),
      'user_id': userId,
      'hotel_id': hotelId,
      'rating': rating,
      'created_date': createdDate.toIso8601String(),
      'images': images,
    };
  }
}

class ReviewRequest {
  final String reviewData;
  final List<String>? images;

  ReviewRequest({required this.reviewData, this.images});

  Map<String, dynamic> toJson() {
    return {'review_data': reviewData, 'images': images};
  }
}
