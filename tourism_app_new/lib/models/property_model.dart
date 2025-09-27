class Property {
  final String id;
  String propertyName;
  int propertyType;
  int availability;
  bool allowShortStays;
  bool allowLongStays;
  int userRole;
  int numOfHours;
  int guestStayType;
  Address address;
  PropertyImage propertyImage;
  List<GuestCapacity> guestCapacities;
  List<Package> packages;
  Rating rating; // Changed to single Rating instead of List<Rating>

  Property({
    required this.id,
    required this.propertyName,
    required this.propertyType,
    required this.availability,
    required this.allowShortStays,
    required this.allowLongStays,
    required this.userRole,
    required this.numOfHours,
    required this.guestStayType,
    required this.address,
    required this.propertyImage,
    required this.guestCapacities,
    required this.packages,
    required this.rating, // Initialize rating
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      propertyName: json['propertyName'] ?? '',
      propertyType: int.tryParse(json['propertyType'].toString()) ?? 1,
      availability: int.tryParse(json['availability'].toString()) ?? 0,
      allowShortStays: json['allowShortStays'] ?? false,
      allowLongStays: json['allowLongStays'] ?? false,
      userRole: int.tryParse(json['userRole'].toString()) ?? 0,
      numOfHours: int.tryParse(json['numOfHours'].toString()) ?? 0,
      guestStayType: int.tryParse(json['guestStayType'].toString()) ?? 0,
      address:
          json['address'] != null
              ? Address.fromJson(json['address'])
              : Address(
                no: '',
                street: '',
                city: json['city'],
                province: '',
                country: '',
                postalCode: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
      propertyImage:
          json['propertyImage'] != null
              ? PropertyImage.fromJson(json['propertyImage'])
              : PropertyImage(primaryImageUrl: '', secondaryImages: []),
      guestCapacities:
          (json['guestCapacities'] as List?)
              ?.map((e) => GuestCapacity.fromJson(e))
              .toList() ??
          [],
      packages:
          (json['packages'] as List?)
              ?.map((e) => Package.fromJson(e))
              .toList() ??
          [],
      // Check if rating is a Map<String, dynamic> or a primitive value
      rating:
          json['rating'] is Map<String, dynamic>
              ? Rating.fromJson(json['rating'])
              : Rating(
                userId: '',
                rating:
                    json['rating']?.toDouble() ??
                    0.0, // if it's a primitive type, just use it
                comment: '',
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyName': propertyName,
      'propertyType': propertyType,
      'availability': availability,
      'allowShortStays': allowShortStays,
      'allowLongStays': allowLongStays,
      'userRole': userRole,
      'numOfHours': numOfHours,
      'guestStayType': guestStayType,
      'address': address.toJson(),
      'propertyImage': propertyImage.toJson(),
      'guestCapacities': guestCapacities.map((e) => e.toJson()).toList(),
      'packages': packages.map((e) => e.toJson()).toList(),
      'rating': rating.toJson(), // Store the single rating in toJson
    };
  }
}

class Rating {
  String userId;
  double rating;
  String comment;

  Rating({required this.userId, required this.rating, required this.comment});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      userId: json['userId'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'rating': rating, 'comment': comment};
  }
}

class Package {
  String packageName;
  int packageType;
  PackageImage packageImage;
  PackagePriceDetail packagePriceDetail;

  Package({
    required this.packageName,
    required this.packageType,
    required this.packageImage,
    required this.packagePriceDetail,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageName: json['packageName'] ?? '',
      packageType: json['packageType'] ?? 0,
      packageImage:
          json['packageImage'] != null
              ? PackageImage.fromJson(json['packageImage'])
              : PackageImage(primaryImageUrl: '', secondaryImages: []),
      packagePriceDetail:
          json['packagePriceDetail'] != null
              ? PackagePriceDetail.fromJson(json['packagePriceDetail'])
              : PackagePriceDetail(
                basePrice: 0,
                weekendPrice: 0,
                monthlyDiscount: 0,
                isWiFiIncluded: false,
                wiFiPrice: 0,
                isParkingIncluded: false,
                parkingPrice: 0,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'packageType': packageType,
      'packageImage': packageImage.toJson(),
      'packagePriceDetail': packagePriceDetail.toJson(),
    };
  }
}

class PackageImage {
  String primaryImageUrl;
  List<String> secondaryImages;

  PackageImage({required this.primaryImageUrl, required this.secondaryImages});

  factory PackageImage.fromJson(Map<String, dynamic> json) {
    return PackageImage(
      primaryImageUrl: json['primaryImageUrl'] ?? '',
      secondaryImages:
          [
            json['secondaryImageUrl1'],
            json['secondaryImageUrl2'],
            json['secondaryImageUrl3'],
            json['secondaryImageUrl4'],
            json['secondaryImageUrl5'],
          ].where((e) => e != null).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrl1':
          secondaryImages.isNotEmpty ? secondaryImages[0] : '',
      'secondaryImageUrl2':
          secondaryImages.length > 1 ? secondaryImages[1] : '',
      'secondaryImageUrl3':
          secondaryImages.length > 2 ? secondaryImages[2] : '',
      'secondaryImageUrl4':
          secondaryImages.length > 3 ? secondaryImages[3] : '',
      'secondaryImageUrl5':
          secondaryImages.length > 4 ? secondaryImages[4] : '',
    };
  }
}

class PackagePriceDetail {
  int basePrice;
  int weekendPrice;
  int monthlyDiscount;
  bool isWiFiIncluded;
  int wiFiPrice;
  bool isParkingIncluded;
  int parkingPrice;

  PackagePriceDetail({
    required this.basePrice,
    required this.weekendPrice,
    required this.monthlyDiscount,
    required this.isWiFiIncluded,
    required this.wiFiPrice,
    required this.isParkingIncluded,
    required this.parkingPrice,
  });

  factory PackagePriceDetail.fromJson(Map<String, dynamic> json) {
    return PackagePriceDetail(
      basePrice: json['basePrice'] ?? 0,
      weekendPrice: json['weekendPrice'] ?? 0,
      monthlyDiscount: json['monthlyDiscount'] ?? 0,
      isWiFiIncluded: json['isWiFiIncluded'] ?? false,
      wiFiPrice: json['wiFiPrice'] ?? 0,
      isParkingIncluded: json['isParkingIncluded'] ?? false,
      parkingPrice: json['parkingPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'weekendPrice': weekendPrice,
      'monthlyDiscount': monthlyDiscount,
      'isWiFiIncluded': isWiFiIncluded,
      'wiFiPrice': wiFiPrice,
      'isParkingIncluded': isParkingIncluded,
      'parkingPrice': parkingPrice,
    };
  }
}

class Address {
  String no;
  String street;
  String city;
  String province;
  String country;
  String postalCode;
  double latitude;
  double longitude;

  Address({
    required this.no,
    required this.street,
    required this.city,
    required this.province,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      no: json['no'],
      street: json['street'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      postalCode: json['postalCode'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'street': street,
      'city': city,
      'province': province,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PropertyImage {
  String primaryImageUrl;
  List<String> secondaryImages;

  PropertyImage({required this.primaryImageUrl, required this.secondaryImages});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      primaryImageUrl: json['primaryImageUrl'],
      secondaryImages:
          [
            json['secondaryImageUrl1'],
            json['secondaryImageUrl2'],
            json['secondaryImageUrl3'],
            json['secondaryImageUrl4'],
            json['secondaryImageUrl5'],
          ].where((e) => e != null).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrl1':
          secondaryImages.isNotEmpty ? secondaryImages[0] : '',
      'secondaryImageUrl2':
          secondaryImages.length > 1 ? secondaryImages[1] : '',
      'secondaryImageUrl3':
          secondaryImages.length > 2 ? secondaryImages[2] : '',
      'secondaryImageUrl4':
          secondaryImages.length > 3 ? secondaryImages[3] : '',
      'secondaryImageUrl5':
          secondaryImages.length > 4 ? secondaryImages[4] : '',
    };
  }
}

class GuestCapacity {
  int guestType;
  int maxGuests;

  GuestCapacity({required this.guestType, required this.maxGuests});

  factory GuestCapacity.fromJson(Map<String, dynamic> json) {
    return GuestCapacity(
      guestType: json['guestType'],
      maxGuests: json['maxGuests'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'guestType': guestType, 'maxGuests': maxGuests};
  }
}
