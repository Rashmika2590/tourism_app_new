// room_availability_results.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/Screens/testing/hotel_detail.dart';
import 'package:tourism_app_new/models/search_params_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Location/location_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/widgets/expandable_map_widget.dart';
import 'package:tourism_app_new/widgets/filtering%20option.dart';
import 'package:tourism_app_new/widgets/post_searching_dropdowns.dart';
import 'package:tourism_app_new/widgets/filter_bottom_sheet.dart';
import 'package:tourism_app_new/widgets/sort_bottom_sheet.dart';
import 'package:tourism_app_new/widgets/sorting_options.dart';

class HotelWithRoomDetails {
  final Hotel hotel;
  final List<Room> availableRooms;
  final Room cheapestRoom;

  HotelWithRoomDetails({
    required this.hotel,
    required this.availableRooms,
    required this.cheapestRoom,
  });
}

class RoomAvailabilityResultsScreen extends StatefulWidget {
  final RoomAvailability availability;
  final List<HotelWithRoomDetails> hotelWithRoomDetails;

  const RoomAvailabilityResultsScreen({
    super.key,
    required this.availability,
    required this.hotelWithRoomDetails,
  });

  @override
  State<RoomAvailabilityResultsScreen> createState() =>
      _RoomAvailabilityResultsScreenState();
}

class _RoomAvailabilityResultsScreenState
    extends State<RoomAvailabilityResultsScreen> {
  bool _isMapExpanded = false;
  final themeColor = const Color(0xFF4ECDC4);

  // State variables for search results (not managed by provider)
  late RoomAvailability _currentAvailability;
  late List<HotelWithRoomDetails> _currentHotelWithRoomDetails;
  late List<HotelWithRoomDetails>
  _originalHotelWithRoomDetails; // Keep original for filtering
  bool _isLoading = false;
  String? _errorMessage;

  // Filter and Sort states
  FilterOptions _currentFilters = FilterOptions();
  SortOption _currentSortOption = SortOption.recommended;

  @override
  void initState() {
    super.initState();
    // Initialize with widget values
    _currentAvailability = widget.availability;
    _currentHotelWithRoomDetails = widget.hotelWithRoomDetails;
    _originalHotelWithRoomDetails = List.from(widget.hotelWithRoomDetails);

    final bookingState = Provider.of<BookingState>(context, listen: false);
    if (bookingState.state.isEmpty) {
      _fetchCurrentLocationAndUpdateState(bookingState);
    }
  }

  Future<void> _fetchCurrentLocationAndUpdateState(
    BookingState bookingState,
  ) async {
    try {
      final position = await LocationService.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        if (placemark.administrativeArea != null) {
          bookingState.setState(placemark.administrativeArea!);
        }
      }
    } catch (e) {
      // Handle location error, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not determine your location. Please enter one manually.',
          ),
        ),
      );
    }
  }

  void _toggleMap() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }

  // Function to handle search from SearchCardWithData
  Future<void> _handleSearch({
    required String state,
    required DateTime checkInDate,
    required TimeOfDay checkInTime,
    required int duration,
    required int adults,
    required int children,
    required BookingState bookingState,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Update provider state first
      bookingState.setState(state);
      bookingState.setCheckInDate(checkInDate);
      bookingState.setCheckInTime(checkInTime);
      bookingState.setDuration(duration);
      bookingState.setGuests(adultCount: adults, childrenCount: children);

      // Calculate checkOutDate based on duration
      final checkOutDate = checkInDate.add(Duration(days: duration));

      // Format times for API
      final formattedCheckInTime =
          '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}:00';
      final formattedCheckOutTime =
          '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}:00';

      // Call the availability API
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: checkInDate,
        checkInTime: formattedCheckInTime,
        checkOutDate: checkOutDate,
        checkOutTime: formattedCheckOutTime,
        state: state,
        adultCount: adults,
        childrenCount: children,
      );

      // Fetch hotel and room details
      final hotelWithRoomDetails = await _fetchHotelAndRoomDetails(
        availability,
      );

      setState(() {
        _currentAvailability = availability;
        _currentHotelWithRoomDetails = hotelWithRoomDetails;
        _originalHotelWithRoomDetails = List.from(hotelWithRoomDetails);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<HotelWithRoomDetails>> _fetchHotelAndRoomDetails(
    RoomAvailability availability,
  ) async {
    if (availability.hotelIds.isEmpty) return [];

    final List<HotelWithRoomDetails> hotelWithRoomDetailsList = [];

    for (int hotelId in availability.hotelIds) {
      final availableRoomIds = availability.getRoomIdsForHotel(hotelId);

      if (availableRoomIds.isEmpty) continue;

      try {
        final hotelFuture = HotelApiService.getHotelById(hotelId);
        final roomFutures = availableRoomIds.map(
          (roomId) => RoomApiService.getRoomById(roomId),
        );

        final results = await Future.wait([hotelFuture, ...roomFutures]);

        final hotel = results[0] as Hotel;
        final rooms = results.skip(1).cast<Room>().toList();

        if (rooms.isNotEmpty) {
          final cheapestRoom = rooms.reduce(
            (current, next) => current.price < next.price ? current : next,
          );

          hotelWithRoomDetailsList.add(
            HotelWithRoomDetails(
              hotel: hotel,
              availableRooms: rooms,
              cheapestRoom: cheapestRoom,
            ),
          );
        }
      } catch (e) {
        print('Error fetching details for hotel $hotelId: $e');
      }
    }

    return hotelWithRoomDetailsList;
  }

  // Format duration for display
  String _formatDuration(int days) {
    if (days == 1) {
      return '$days day';
    } else {
      return '$days days';
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      color: Colors.transparent,
      child: Column(
        children: [
          // Filter and Sort buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Advanced filter button on the left
              InkWell(
                onTap: () => _showAdvancedFilter(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: Colors.grey[600], size: 24),
                    const SizedBox(width: 6),
                    Text(
                      'Advanced',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Sort by dropdown on the right
              InkWell(
                onTap: () => _showSortOptions(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort by',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilter() async {
    final newFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            currentFilters: _currentFilters,
            hotels: _originalHotelWithRoomDetails,
          ),
    );

    if (newFilters != null) {
      setState(() {
        _currentFilters = newFilters;
        _applyFiltersAndSort();
      });
    }
  }

  void _showSortOptions() async {
    final newSortOption = await showModalBottomSheet<SortOption>(
      context: context,
      builder:
          (context) => SortBottomSheet(currentSortOption: _currentSortOption),
    );

    if (newSortOption != null) {
      setState(() {
        _currentSortOption = newSortOption;
        _applyFiltersAndSort();
      });
    }
  }

  void _applyFiltersAndSort() {
    List<HotelWithRoomDetails> filteredResults = List.from(
      _originalHotelWithRoomDetails,
    );

    // Apply filters
    if (_currentFilters.minPrice != null || _currentFilters.maxPrice != null) {
      filteredResults =
          filteredResults.where((hotel) {
            final price = hotel.cheapestRoom.price;
            final minPrice = _currentFilters.minPrice ?? 0;
            final maxPrice = _currentFilters.maxPrice ?? double.infinity;
            return price >= minPrice && price <= maxPrice;
          }).toList();
    }

    if (_currentFilters.selectedAmenities.isNotEmpty) {
      filteredResults =
          filteredResults.where((hotel) {
            return _currentFilters.selectedAmenities.every(
              (amenity) => hotel.cheapestRoom.amenities.contains(amenity),
            );
          }).toList();
    }

    // Apply sorting
    switch (_currentSortOption) {
      case SortOption.priceLowToHigh:
        filteredResults.sort(
          (a, b) => a.cheapestRoom.price.compareTo(b.cheapestRoom.price),
        );
        break;
      case SortOption.priceHighToLow:
        filteredResults.sort(
          (a, b) => b.cheapestRoom.price.compareTo(a.cheapestRoom.price),
        );
        break;
      case SortOption.ratingHighToLow:
        filteredResults.sort(
          (a, b) => b.hotel.latitude.compareTo(a.hotel.latitude),
        );
        break;
      case SortOption.nameAZ:
        filteredResults.sort((a, b) => a.hotel.name.compareTo(b.hotel.name));
        break;
      case SortOption.recommended:
      default:
        // Keep original order for recommended
        break;
    }

    setState(() {
      _currentHotelWithRoomDetails = filteredResults;
    });
  }

  Widget _buildEnhancedHotelCard(
    HotelWithRoomDetails hotelWithRooms,
    BookingState bookingState,
  ) {
    final hotel = hotelWithRooms.hotel;
    final cheapestRoom = hotelWithRooms.cheapestRoom;
    final displayAmenities = cheapestRoom.amenities.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child:
                  hotel.images.isNotEmpty
                      ? Image.network(
                        hotel.images[0],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey.shade400,
                              child: const Center(
                                child: Icon(
                                  Icons.hotel,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade400,
                        child: const Center(
                          child: Icon(
                            Icons.hotel,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              top: -5,
              bottom: 0,
              left: 0,
              right: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${hotel.name}',
                          style: const TextStyle(
                            color: AppColors.mainGreen,
                            fontSize: 28,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          'in ${hotel.state}',
                          style: const TextStyle(
                            color: AppColors.mainGreen,
                            fontSize: 18,
                            height: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.latitude.toStringAsFixed(1)} (${hotel.longitude})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'LKR ',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${cheapestRoom.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ onwards',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '(all inclusive)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          displayAmenities.map((amenity) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 4,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    amenity.trim(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final searchParams = SearchParams(
                      state: bookingState.state,
                      checkInDate: bookingState.checkInDate,
                      checkInTime: bookingState.checkInTime,
                      durationHours: bookingState.duration,
                      adults: bookingState.adults,
                      children: bookingState.children,
                      rooms: 1,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => EnhancedHotelDetailsScreen(
                              hotel: hotelWithRooms.hotel,
                              searchParams: searchParams,
                            ),
                      ),
                    );
                  },
                  splashColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context, listen: true);
    final resultsCount = _currentHotelWithRoomDetails.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ExpandableMapWidget(
                              isExpanded: _isMapExpanded,
                              onToggle: _toggleMap,
                              location: bookingState.state,
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Handpicked for you ($resultsCount ${resultsCount == 1 ? 'result' : 'results'})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchCardWithData(
                            searchParams: SearchParams(
                              state: bookingState.state,
                              checkInDate: bookingState.checkInDate,
                              checkInTime: bookingState.checkInTime,
                              durationHours: bookingState.duration,
                              adults: bookingState.adults,
                              children: bookingState.children,
                              rooms: 1,
                            ),
                            onSearchPressed: (searchParams) {
                              _handleSearch(
                                state: searchParams.state,
                                checkInDate: searchParams.checkInDate,
                                checkInTime: searchParams.checkInTime,
                                duration: searchParams.durationHours,
                                adults: searchParams.adults,
                                children: searchParams.children,
                                bookingState: bookingState,
                              );
                            },
                          ),
                        ),

                        // Results count and filter/sort buttons
                        if (_currentAvailability.hasAvailableRooms() &&
                            !_isLoading &&
                            _errorMessage == null)
                          _buildResultsHeader(),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          )
                        else if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: $_errorMessage',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else if (_currentAvailability.hasAvailableRooms())
                          Column(
                            children:
                                _currentHotelWithRoomDetails.map((hotel) {
                                  return _buildEnhancedHotelCard(
                                    hotel,
                                    bookingState,
                                  );
                                }).toList(),
                          )
                        else
                          Center(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No rooms available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your search criteria',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
