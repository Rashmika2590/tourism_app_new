class ReviewFormData {
  int hotelId;
  int rating;
  String comment;
  List<String> selectedImagePaths;

  ReviewFormData({
    required this.hotelId,
    this.rating = 0,
    this.comment = '',
    this.selectedImagePaths = const [],
  });

  bool get isValid => rating > 0 && comment.isNotEmpty;

  ReviewFormData copyWith({
    int? hotelId,
    int? rating,
    String? comment,
    List<String>? selectedImagePaths,
  }) {
    return ReviewFormData(
      hotelId: hotelId ?? this.hotelId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
    );
  }
}
