class Hotel {
  final int? id;
  final String name;
  final String address;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final List<String> rules;
  final String email;
  final String mobile;
  final String images;
  final bool enableShortStay;
  final bool enableLongStay;
  final String description;
  final String? userUid;
  final HotelVerification? verification;

  Hotel({
    this.id,
    required this.name,
    required this.address,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.rules,
    required this.email,
    required this.mobile,
    required this.images,
    required this.enableShortStay,
    required this.enableLongStay,
    required this.description,
    this.userUid,
    this.verification,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rules: List<String>.from(json['rules'] ?? []),
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      images: json['images'] ?? '',
      enableShortStay: json['enable_short_stay'] ?? false,
      enableLongStay: json['enable_long_stay'] ?? false,
      description: json['description'] ?? '',
      userUid: json['user_uid'],
      verification:
          json['verification'] != null
              ? HotelVerification.fromJson(json['verification'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'rules': rules,
      'email': email,
      'mobile': mobile,
      'images': images,
      'enable_short_stay': enableShortStay,
      'enable_long_stay': enableLongStay,
      'description': description,
      if (userUid != null) 'user_uid': userUid,
      if (verification != null) 'verification': verification!.toJson(),
    };
  }
}

class HotelVerification {
  final int? hotelId;
  final String identityNumber;
  final String identityDocumentType;
  final DateTime? identityVerificationDate;
  final bool verifiedStatus;
  final String selfie;

  HotelVerification({
    this.hotelId,
    required this.identityNumber,
    required this.identityDocumentType,
    this.identityVerificationDate,
    required this.verifiedStatus,
    required this.selfie,
  });

  factory HotelVerification.fromJson(Map<String, dynamic> json) {
    return HotelVerification(
      hotelId: json['hotel_id'],
      identityNumber: json['identity_number'] ?? '',
      identityDocumentType: json['identity_document_type'] ?? '',
      identityVerificationDate:
          json['identity_verification_date'] != null
              ? DateTime.parse(json['identity_verification_date'])
              : null,
      verifiedStatus: json['verified_status'] ?? false,
      selfie: json['selfie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (hotelId != null) 'hotel_id': hotelId,
      'identity_number': identityNumber,
      'identity_document_type': identityDocumentType,
      if (identityVerificationDate != null)
        'identity_verification_date':
            identityVerificationDate!.toIso8601String(),
      'verified_status': verifiedStatus,
      'selfie': selfie,
    };
  }
}

class HotelSearchParams {
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  HotelSearchParams({this.state, this.latitude, this.longitude, this.radiusKm});

  Map<String, String> toQueryParams() {
    Map<String, String> params = {};
    if (state != null && state!.isNotEmpty) params['state'] = state!;
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    if (radiusKm != null) params['radius_km'] = radiusKm.toString();
    return params;
  }
}
