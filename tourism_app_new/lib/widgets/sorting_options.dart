// models/sort_options.dart
enum SortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  nameAZ,
  distanceNearToFar,
  popularityHighToLow,
  newest,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.recommended:
        return 'Recommended';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.ratingHighToLow:
        return 'Rating: High to Low';
      case SortOption.nameAZ:
        return 'Name: A to Z';
      case SortOption.distanceNearToFar:
        return 'Distance: Near to Far';
      case SortOption.popularityHighToLow:
        return 'Popularity: High to Low';
      case SortOption.newest:
        return 'Newest First';
    }
  }

  String get apiValue {
    switch (this) {
      case SortOption.recommended:
        return 'recommended';
      case SortOption.priceLowToHigh:
        return 'price_asc';
      case SortOption.priceHighToLow:
        return 'price_desc';
      case SortOption.ratingHighToLow:
        return 'rating_desc';
      case SortOption.nameAZ:
        return 'name_asc';
      case SortOption.distanceNearToFar:
        return 'distance_asc';
      case SortOption.popularityHighToLow:
        return 'popularity_desc';
      case SortOption.newest:
        return 'created_desc';
    }
  }

  String get description {
    switch (this) {
      case SortOption.recommended:
        return 'Our top picks for you';
      case SortOption.priceLowToHigh:
        return 'Find the best deals first';
      case SortOption.priceHighToLow:
        return 'Premium options first';
      case SortOption.ratingHighToLow:
        return 'Highest rated properties';
      case SortOption.nameAZ:
        return 'Alphabetical order';
      case SortOption.distanceNearToFar:
        return 'Closest to your location';
      case SortOption.popularityHighToLow:
        return 'Most popular choices';
      case SortOption.newest:
        return 'Recently added properties';
    }
  }
}

class SortOptionsHelper {
  // Convert string from backend to SortOption enum
  static SortOption fromApiValue(String apiValue) {
    return SortOption.values.firstWhere(
      (option) => option.apiValue == apiValue,
      orElse: () => SortOption.recommended,
    );
  }

  // Get all available sort options
  static List<SortOption> getAllOptions() {
    return SortOption.values;
  }

  // Get commonly used sort options for quick access
  static List<SortOption> getCommonOptions() {
    return [
      SortOption.recommended,
      SortOption.priceLowToHigh,
      SortOption.priceHighToLow,
      SortOption.ratingHighToLow,
    ];
  }
}
