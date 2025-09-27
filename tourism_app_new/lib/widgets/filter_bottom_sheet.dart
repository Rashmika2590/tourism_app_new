// widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/testing/Availability/availability_result_page.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/filtering%20option.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilters;
  final List<HotelWithRoomDetails>? hotels;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    this.hotels,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _tempFilters;
  late double _minPriceRange;
  late double _maxPriceRange;

  @override
  void initState() {
    super.initState();
    _tempFilters = FilterOptions(
      minPrice: widget.currentFilters.minPrice,
      maxPrice: widget.currentFilters.maxPrice,
      selectedAmenities: List.from(widget.currentFilters.selectedAmenities),
      minRating: widget.currentFilters.minRating,
      maxDistance: widget.currentFilters.maxDistance,
      selectedHotelTypes: List.from(widget.currentFilters.selectedHotelTypes),
      freeWifi: widget.currentFilters.freeWifi,
      freeParking: widget.currentFilters.freeParking,
      petFriendly: widget.currentFilters.petFriendly,
      pool: widget.currentFilters.pool,
      gym: widget.currentFilters.gym,
      spa: widget.currentFilters.spa,
      restaurant: widget.currentFilters.restaurant,
      roomService: widget.currentFilters.roomService,
    );

    // Calculate price range from available hotels
    if (widget.hotels != null && widget.hotels!.isNotEmpty) {
      final prices = widget.hotels!.map((h) => h.cheapestRoom.price).toList();
      _minPriceRange = prices.reduce((a, b) => a < b ? a : b);
      _maxPriceRange = prices.reduce((a, b) => a > b ? a : b);
    } else {
      _minPriceRange = 0;
      _maxPriceRange = 50000;
    }

    // Set default values if not set
    _tempFilters.minPrice ??= _minPriceRange;
    _tempFilters.maxPrice ??= _maxPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilters = FilterOptions();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.mainGreen),
                  ),
                ),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range - Only show if hotel price data is available
                  if (widget.hotels != null && widget.hotels!.isNotEmpty) ...[
                    _buildPriceRangeSection(),
                    const SizedBox(height: 24),
                  ],

                  // Rating
                  _buildRatingSection(),
                  const SizedBox(height: 24),

                  // Amenities
                  _buildAmenitiesSection(),
                  const SizedBox(height: 24),

                  // Hotel Types
                  _buildHotelTypesSection(),
                  const SizedBox(height: 24),

                  // Distance
                  _buildDistanceSection(),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _tempFilters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range (LKR)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(
            _tempFilters.minPrice ?? _minPriceRange,
            _tempFilters.maxPrice ?? _maxPriceRange,
          ),
          min: _minPriceRange,
          max: _maxPriceRange,
          divisions: 20,
          activeColor: AppColors.buttonColor,
          labels: RangeLabels(
            'LKR ${(_tempFilters.minPrice ?? _minPriceRange).round()}',
            'LKR ${(_tempFilters.maxPrice ?? _maxPriceRange).round()}',
          ),
          onChanged: (values) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LKR ${(_tempFilters.minPrice ?? _minPriceRange).round()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'LKR ${(_tempFilters.maxPrice ?? _maxPriceRange).round()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              [1, 2, 3, 4, 5].map((rating) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _tempFilters = _tempFilters.copyWith(
                            minRating:
                                _tempFilters.minRating == rating
                                    ? null
                                    : rating,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _tempFilters.minRating == rating
                                  ? AppColors.buttonColor
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color:
                                  _tempFilters.minRating == rating
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$rating+',
                              style: TextStyle(
                                color:
                                    _tempFilters.minRating == rating
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'key': 'freeWifi', 'label': 'Free WiFi', 'icon': Icons.wifi},
      {
        'key': 'freeParking',
        'label': 'Free Parking',
        'icon': Icons.local_parking,
      },
      {'key': 'petFriendly', 'label': 'Pet Friendly', 'icon': Icons.pets},
      {'key': 'pool', 'label': 'Swimming Pool', 'icon': Icons.pool},
      {'key': 'gym', 'label': 'Fitness Center', 'icon': Icons.fitness_center},
      {'key': 'spa', 'label': 'Spa', 'icon': Icons.spa},
      {'key': 'restaurant', 'label': 'Restaurant', 'icon': Icons.restaurant},
      {
        'key': 'roomService',
        'label': 'Room Service',
        'icon': Icons.room_service,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              amenities.map((amenity) {
                bool isSelected = _getAmenityValue(amenity['key'] as String);
                return InkWell(
                  onTap: () => _toggleAmenity(amenity['key'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.buttonColor
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          amenity['icon'] as IconData,
                          size: 16,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          amenity['label'] as String,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildHotelTypesSection() {
    final hotelTypes = [
      'Hotel',
      'Resort',
      'Villa',
      'Apartment',
      'Guest House',
      'Hostel',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              hotelTypes.map((type) {
                bool isSelected = _tempFilters.selectedHotelTypes.contains(
                  type,
                );
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _tempFilters.selectedHotelTypes.remove(type);
                      } else {
                        _tempFilters.selectedHotelTypes.add(type);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.buttonColor
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Radius from current location (km)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _tempFilters.maxDistance ?? 10,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: AppColors.buttonColor,
          label: '${(_tempFilters.maxDistance ?? 10).round()} km',
          onChanged: (value) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(maxDistance: value);
            });
          },
        ),
        Text(
          'Within ${(_tempFilters.maxDistance ?? 10).round()} km',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  bool _getAmenityValue(String key) {
    switch (key) {
      case 'freeWifi':
        return _tempFilters.freeWifi ?? false;
      case 'freeParking':
        return _tempFilters.freeParking ?? false;
      case 'petFriendly':
        return _tempFilters.petFriendly ?? false;
      case 'pool':
        return _tempFilters.pool ?? false;
      case 'gym':
        return _tempFilters.gym ?? false;
      case 'spa':
        return _tempFilters.spa ?? false;
      case 'restaurant':
        return _tempFilters.restaurant ?? false;
      case 'roomService':
        return _tempFilters.roomService ?? false;
      default:
        return false;
    }
  }

  void _toggleAmenity(String key) {
    setState(() {
      switch (key) {
        case 'freeWifi':
          _tempFilters = _tempFilters.copyWith(
            freeWifi: !(_tempFilters.freeWifi ?? false),
          );
          break;
        case 'freeParking':
          _tempFilters = _tempFilters.copyWith(
            freeParking: !(_tempFilters.freeParking ?? false),
          );
          break;
        case 'petFriendly':
          _tempFilters = _tempFilters.copyWith(
            petFriendly: !(_tempFilters.petFriendly ?? false),
          );
          break;
        case 'pool':
          _tempFilters = _tempFilters.copyWith(
            pool: !(_tempFilters.pool ?? false),
          );
          break;
        case 'gym':
          _tempFilters = _tempFilters.copyWith(
            gym: !(_tempFilters.gym ?? false),
          );
          break;
        case 'spa':
          _tempFilters = _tempFilters.copyWith(
            spa: !(_tempFilters.spa ?? false),
          );
          break;
        case 'restaurant':
          _tempFilters = _tempFilters.copyWith(
            restaurant: !(_tempFilters.restaurant ?? false),
          );
          break;
        case 'roomService':
          _tempFilters = _tempFilters.copyWith(
            roomService: !(_tempFilters.roomService ?? false),
          );
          break;
      }
    });
  }
}