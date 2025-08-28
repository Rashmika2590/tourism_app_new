class Hotel {
  final int id;
  final String name;
  final String address;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final List<String> rules;
  final String email;
  final String mobile;
  final List<String> images;
  final bool enableShortStay;
  final bool enableLongStay;
  final String description;
  final String userUid;
  final HotelVerification? verification;

  Hotel({
    required this.id,
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
    required this.userUid,
    this.verification,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rules: List<String>.from(json['rules'] ?? []),
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      enableShortStay: json['enable_short_stay'] ?? false,
      enableLongStay: json['enable_long_stay'] ?? false,
      description: json['description'] ?? '',
      userUid: json['user_uid'] ?? '',
      verification:
          json['verification'] != null
              ? HotelVerification.fromJson(json['verification'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'user_uid': userUid,
      'verification': verification?.toJson(),
    };
  }

  Hotel copyWith({
    int? id,
    String? name,
    String? address,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    List<String>? rules,
    String? email,
    String? mobile,
    List<String>? images,
    bool? enableShortStay,
    bool? enableLongStay,
    String? description,
    String? userUid,
    HotelVerification? verification,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rules: rules ?? this.rules,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      images: images ?? this.images,
      enableShortStay: enableShortStay ?? this.enableShortStay,
      enableLongStay: enableLongStay ?? this.enableLongStay,
      description: description ?? this.description,
      userUid: userUid ?? this.userUid,
      verification: verification ?? this.verification,
    );
  }
}

class HotelVerification {
  final String identityNumber;
  final String verificationDocumentType;
  final String verificationDocument;
  final DateTime verificationDate;
  final bool verifiedStatus;
  final String selfie;

  HotelVerification({
    required this.identityNumber,
    required this.verificationDocumentType,
    required this.verificationDocument,
    required this.verificationDate,
    required this.verifiedStatus,
    required this.selfie,
  });

  factory HotelVerification.fromJson(Map<String, dynamic> json) {
    return HotelVerification(
      identityNumber: json['identity_number'] ?? '',
      verificationDocumentType: json['verification_document_type'] ?? '',
      verificationDocument: json['verification_document'] ?? '',
      verificationDate:
          DateTime.tryParse(json['verification_date'] ?? '') ?? DateTime.now(),
      verifiedStatus: json['verified_status'] ?? false,
      selfie: json['selfie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity_number': identityNumber,
      'verification_document_type': verificationDocumentType,
      'verification_document': verificationDocument,
      'verification_date': verificationDate.toIso8601String(),
      'verified_status': verifiedStatus,
      'selfie': selfie,
    };
  }

  HotelVerification copyWith({
    String? identityNumber,
    String? verificationDocumentType,
    String? verificationDocument,
    DateTime? verificationDate,
    bool? verifiedStatus,
    String? selfie,
  }) {
    return HotelVerification(
      identityNumber: identityNumber ?? this.identityNumber,
      verificationDocumentType:
          verificationDocumentType ?? this.verificationDocumentType,
      verificationDocument: verificationDocument ?? this.verificationDocument,
      verificationDate: verificationDate ?? this.verificationDate,
      verifiedStatus: verifiedStatus ?? this.verifiedStatus,
      selfie: selfie ?? this.selfie,
    );
  }
}

// Data class for hotel creation request
class CreateHotelRequest {
  final String name;
  final String address;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final List<String> rules;
  final String email;
  final String mobile;
  final bool enableShortStay;
  final bool enableLongStay;
  final String description;

  CreateHotelRequest({
    required this.name,
    required this.address,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.rules,
    required this.email,
    required this.mobile,
    required this.enableShortStay,
    required this.enableLongStay,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'rules': rules,
      'email': email,
      'mobile': mobile,
      'enable_short_stay': enableShortStay,
      'enable_long_stay': enableLongStay,
      'description': description,
    };
  }
}

// Data class for hotel search filters
class HotelSearchFilters {
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  HotelSearchFilters({
    this.state,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  bool get hasFilters =>
      state != null ||
      latitude != null ||
      longitude != null ||
      radiusKm != null;

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (state != null) params['state'] = state!;
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    if (radiusKm != null) params['radius_km'] = radiusKm.toString();
    return params;
  }
}

// Data class for verification request
class VerificationRequest {
  final String identityNumber;
  final String verificationDocumentType;
  final String verificationDocument;
  final DateTime verificationDate;
  final bool verifiedStatus;
  final String selfie;

  VerificationRequest({
    required this.identityNumber,
    required this.verificationDocumentType,
    required this.verificationDocument,
    required this.verificationDate,
    required this.verifiedStatus,
    required this.selfie,
  });

  Map<String, dynamic> toJson() {
    return {
      'identity_number': identityNumber,
      'verification_document_type': verificationDocumentType,
      'verification_document': verificationDocument,
      'verification_date': verificationDate.toIso8601String(),
      'verified_status': verifiedStatus,
      'selfie': selfie,
    };
  }
}
