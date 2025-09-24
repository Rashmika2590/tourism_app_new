class FAQ {
  final int id;
  final String userId;
  final int hotelId;
  final String question;
  final String? answer;
  final int likeCount;
  final int dislikeCount;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String? userReaction; // 🆕 ADDED THIS FIELD for user reaction status

  FAQ({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.question,
    this.answer,
    required this.likeCount,
    required this.dislikeCount,
    required this.createdDate,
    required this.updatedDate,
    this.userReaction, // 🆕 ADDED THIS FIELD
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      hotelId: json['hotel_id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'],
      likeCount: json['like_count'] ?? 0,
      dislikeCount: json['dislike_count'] ?? 0,
      createdDate: DateTime.parse(json['created_date']),
      updatedDate: DateTime.parse(json['updated_date']),
      userReaction:
          json['user_reaction'], // 🆕 ADDED THIS FIELD - can be 'like', 'dislike', or null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'question': question,
      'answer': answer,
      'like_count': likeCount,
      'dislike_count': dislikeCount,
      'created_date': createdDate.toIso8601String(),
      'updated_date': updatedDate.toIso8601String(),
      'user_reaction': userReaction, // 🆕 ADDED THIS FIELD
    };
  }
}

class FAQResponse {
  final int hotelId;
  final List<FAQ> faqs;

  FAQResponse({required this.hotelId, required this.faqs});

  factory FAQResponse.fromJson(Map<String, dynamic> json) {
    final faqsList =
        (json['faqs'] as List? ?? [])
            .map((faqJson) => FAQ.fromJson(faqJson))
            .toList();
    return FAQResponse(hotelId: json['hotel_id'] ?? 0, faqs: faqsList);
  }
}

class CreateFAQRequest {
  final int hotelId;
  final String question;
  final DateTime createdDate;
  final DateTime updatedDate;

  CreateFAQRequest({
    required this.hotelId,
    required this.question,
    required this.createdDate,
    required this.updatedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'question': question,
      'created_date': createdDate.toIso8601String(),
      'updated_date': updatedDate.toIso8601String(),
    };
  }
}

class CreateFAQResponse {
  final String message;
  final int faqId;

  CreateFAQResponse({required this.message, required this.faqId});

  factory CreateFAQResponse.fromJson(Map<String, dynamic> json) {
    return CreateFAQResponse(
      message: json['message'] ?? '',
      faqId: json['faq_id'] ?? 0,
    );
  }
}

class FAQReactionRequest {
  final bool isLike;
  final DateTime createdDate;

  FAQReactionRequest({required this.isLike, required this.createdDate});

  Map<String, dynamic> toJson() {
    return {'is_like': isLike, 'created_date': createdDate.toIso8601String()};
  }
}

class FAQReactionResponse {
  final String detail;

  FAQReactionResponse({required this.detail});

  factory FAQReactionResponse.fromJson(Map<String, dynamic> json) {
    return FAQReactionResponse(detail: json['detail'] ?? '');
  }
}
