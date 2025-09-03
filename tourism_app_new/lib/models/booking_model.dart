// Models/booking_model.dart
class BookingRequest {
  final int roomId;
  final String status;
  final String ciDate;
  final String ciTime;
  final String coDate;
  final String coTime;
  final int adultCount;
  final int childrenCount;
  final String specialRequest;
  final double price;
  final String paymentMethod;
  final String paymentReference;
  final String promoCode;
  final String bookingTime;

  BookingRequest({
    required this.roomId,
    this.status = 'pending',
    required this.ciDate,
    required this.ciTime,
    required this.coDate,
    required this.coTime,
    required this.adultCount,
    required this.childrenCount,
    this.specialRequest = '',
    required this.price,
    required this.paymentMethod,
    this.paymentReference = '',
    this.promoCode = '',
    required this.bookingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'status': status,
      'ci_date': ciDate,
      'ci_time': ciTime,
      'co_date': coDate,
      'co_time': coTime,
      'adult_count': adultCount,
      'children_count': childrenCount,
      'special_request': specialRequest,
      'price': price,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'promo_code': promoCode,
      'booking_time': bookingTime,
    };
  }
}

class BookingResponse {
  final int? id;
  final int roomId;
  final String status;
  final String ciDate;
  final String ciTime;
  final String coDate;
  final String coTime;
  final int adultCount;
  final int childrenCount;
  final String specialRequest;
  final double price;
  final String paymentMethod;
  final String paymentReference;
  final String promoCode;
  final String bookingTime;
  final String? createdAt;
  final String? updatedAt;

  BookingResponse({
    this.id,
    required this.roomId,
    required this.status,
    required this.ciDate,
    required this.ciTime,
    required this.coDate,
    required this.coTime,
    required this.adultCount,
    required this.childrenCount,
    required this.specialRequest,
    required this.price,
    required this.paymentMethod,
    required this.paymentReference,
    required this.promoCode,
    required this.bookingTime,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'],
      roomId: json['room_id'] ?? 0,
      status: json['status'] ?? 'pending',
      ciDate: json['ci_date'] ?? '',
      ciTime: json['ci_time'] ?? '',
      coDate: json['co_date'] ?? '',
      coTime: json['co_time'] ?? '',
      adultCount: json['adult_count'] ?? 0,
      childrenCount: json['children_count'] ?? 0,
      specialRequest: json['special_request'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      paymentReference: json['payment_reference'] ?? '',
      promoCode: json['promo_code'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
