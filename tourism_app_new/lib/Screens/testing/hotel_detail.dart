import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_creation.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/models/search_params_model.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/FAQ_widget.dart';
import 'package:tourism_app_new/widgets/activity_row.dart';
import 'package:tourism_app_new/widgets/nearest_places.dart';
import 'package:tourism_app_new/widgets/reviewCard.dart';
import 'package:tourism_app_new/widgets/terms_condition_widget.dart';

class EnhancedHotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final SearchParams? searchParams;

  const EnhancedHotelDetailsScreen({
    Key? key,
    required this.hotel,
    this.searchParams,
  }) : super(key: key);

  @override
  State<EnhancedHotelDetailsScreen> createState() =>
      _EnhancedHotelDetailsScreenState();
}

class _EnhancedHotelDetailsScreenState
    extends State<EnhancedHotelDetailsScreen> {
  late SearchParams _searchParams;
  late bool isFavorite;
  int currentImageIndex = 0;
  List<Room> hotelRooms = [];
  bool isLoadingRooms = true;
  Room? cheapestRoom;
  Set<String> allAmenities = {};
  bool isUpdatingFavorite = false;

  // Availability card state variables
  bool showDatePicker = false;
  bool showDurationDropdown = false;
  bool showGuestSelector = false;
  bool showCheckoutInfo = false;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int selectedDurationHours;
  late int adults;
  late int children;
  late int rooms;

  final themeColor = const Color(0xFF4ECDC4);
  final List<int> durationOptions = [1, 2, 3, 4, 5, 6, 8, 12, 24, 48, 72];

  RoomAvailability? availability;
  bool _isCheckingAvailability = false;
  String? availabilityMessage;
  bool hasAvailability = false;

  @override
  void initState() {
    super.initState();
    //isFavorite = widget.hotel.isFavourite;
    _searchParams =
        widget.searchParams ??
        SearchParams(
          state: widget.hotel.state,
          checkInDate: DateTime.now(),
          checkInTime: TimeOfDay.now(),
          durationHours: 1,
          adults: 1,
          children: 0,
          rooms: 1,
        );
    _initializeFromSearchParams();
    _loadHotelRooms();
  }

  void _initializeFromSearchParams() {
    selectedDate = _searchParams.checkInDate;
    selectedTime = _searchParams.checkInTime;
    selectedDurationHours = _searchParams.durationHours;
    adults = _searchParams.adults;
    children = _searchParams.children;
    rooms = _searchParams.rooms;
  }

  DateTime get checkoutDateTime =>
      selectedDate.add(Duration(hours: selectedDurationHours));
  TimeOfDay get checkoutTime => TimeOfDay.fromDateTime(checkoutDateTime);

  Future<void> _loadHotelRooms() async {
    try {
      final rooms = await RoomApiService.getRoomsByHotelId(widget.hotel.id);
      setState(() {
        hotelRooms = rooms;
        if (rooms.isNotEmpty) {
          cheapestRoom = rooms.reduce(
            (current, next) => current.price < next.price ? current : next,
          );
          for (var room in rooms) {
            allAmenities.addAll(room.amenities);
          }
        }
        isLoadingRooms = false;
      });
    } catch (e) {
      print('Error loading hotel rooms: $e');
      setState(() {
        isLoadingRooms = false;
      });
    }
  }

  // Future<void> _toggleFavorite() async {
  //   if (isUpdatingFavorite) return;

  //   setState(() {
  //     isUpdatingFavorite = true;
  //   });

  //   try {
  //     if (isFavorite) {
  //       await FavouriteApiService.removeFavourite(widget.hotel.id);
  //     } else {
  //       await FavouriteApiService.addFavourite(
  //         userId: "current_user_id",
  //         hotelId: widget.hotel.id,
  //       );
  //     }

  //     setState(() {
  //       isFavorite = !isFavorite;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           isFavorite ? 'Added to favorites' : 'Removed from favorites',
  //         ),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error toggling favorite: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to update favorites'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       isUpdatingFavorite = false;
  //     });
  //   }
  // }

  // Combined availability check and navigation function
  Future<void> _checkAvailabilityAndNavigate() async {
    setState(() {
      _isCheckingAvailability = true;
      availabilityMessage = null;
      hasAvailability = false;
    });

    try {
      final checkInTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
      final checkOutTime =
          '${checkoutTime.hour.toString().padLeft(2, '0')}:${checkoutTime.minute.toString().padLeft(2, '0')}:00';

      final result = await RoomAvailabilityService.searchAvailability(
        checkInDate: selectedDate,
        checkInTime: checkInTime,
        checkOutDate: checkoutDateTime,
        checkOutTime: checkOutTime,
        state: widget.hotel.state,
        adultCount: adults,
        childrenCount: children,
      );

      setState(() {
        availability = result;
        _isCheckingAvailability = false;
        hasAvailability = result.hasAvailableRooms();

        if (hasAvailability) {
          availabilityMessage =
              '${result.getTotalAvailableRooms()} rooms available!';
        } else {
          availabilityMessage =
              'No rooms available for the selected dates and criteria. Please try different dates or modify your search.';
        }
      });

      // Update provider with new search parameters
      final bookingState = Provider.of<BookingState>(context, listen: false);
      bookingState.setState(widget.hotel.state);
      bookingState.setCheckInDate(selectedDate);
      bookingState.setCheckInTime(selectedTime);
      bookingState.setDuration(selectedDurationHours);
      bookingState.setGuests(adultCount: adults, childrenCount: children);

      if (hasAvailability) {
        // Navigate to room list if availability found
        final searchParams = SearchParams(
          state: widget.hotel.state,
          checkInDate: selectedDate,
          checkInTime: selectedTime,
          durationHours: selectedDurationHours,
          adults: adults,
          children: children,
          rooms: rooms,
        );
        _navigateToRoomList(widget.hotel.id, searchParams);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(availabilityMessage!),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error checking availability: $e");
      setState(() {
        availability = RoomAvailability(available: {});
        _isCheckingAvailability = false;
        hasAvailability = false;
        availabilityMessage = 'Failed to check availability. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToRoomList(int hotelId, SearchParams searchParams) {
    final checkOutDate = searchParams.checkInDate.add(
      Duration(hours: searchParams.durationHours),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RoomsListScreen(
              hotel: widget.hotel,
              checkInDate: searchParams.checkInDate,
              checkInTime: _formatTimeOfDay(searchParams.checkInTime),
              checkOutDate: checkOutDate,
              checkOutTime: _formatTimeOfDay(
                TimeOfDay.fromDateTime(checkOutDate),
              ),
              adultCount: searchParams.adults,
              childrenCount: searchParams.children,
            ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDuration(int hours) {
    if (hours < 24) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      int days = hours ~/ 24;
      int remainingHours = hours % 24;
      if (remainingHours == 0) {
        return '$days day${days > 1 ? 's' : ''}';
      } else {
        return '$days day${days > 1 ? 's' : ''} ${remainingHours}h';
      }
    }
  }

  String _formatCheckoutDate() {
    DateTime checkoutDate = selectedDate.add(
      Duration(hours: selectedDurationHours),
    );
    return '${checkoutDate.day.toString().padLeft(2, '0')}-${checkoutDate.month.toString().padLeft(2, '0')}-${checkoutDate.year}';
  }

  String _formatCheckoutTime() {
    DateTime checkoutDate = selectedDate.add(
      Duration(hours: selectedDurationHours),
    );
    TimeOfDay checkoutTime = TimeOfDay.fromDateTime(checkoutDate);
    return checkoutTime.format(context);
  }

  Widget _buildIncludedItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.mainGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String name, String distance) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Completely rewritten availability card with proper layout
  Widget _buildCheckAvailabilityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main card content - ALWAYS VISIBLE
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Check-in/Check-out labels
                Row(
                  children: const [
                    Text(
                      'Check-in',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text(
                      'Check-out',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date and Time Row
                Row(
                  children: [
                    // Check-in Date and Time
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDatePicker = !showDatePicker;
                            showDurationDropdown = false;
                            showGuestSelector = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')}-'
                                  '${selectedDate.month.toString().padLeft(2, '0')}-'
                                  '${selectedDate.year}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedTime.format(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Check-out Date and Time
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color.fromARGB(255, 114, 114, 114),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatCheckoutDate(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 114, 114, 114),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCheckoutTime(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 114, 114, 114),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Duration and Guests Row
                Row(
                  children: [
                    // Duration
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDurationDropdown = !showDurationDropdown;
                          showDatePicker = false;
                          showGuestSelector = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(selectedDurationHours),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 114, 114, 114),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Guest and Room Info
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showGuestSelector = !showGuestSelector;
                            showDatePicker = false;
                            showDurationDropdown = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$adults Adults',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$children Children',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$rooms Room',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Extended sections - ONLY VISIBLE WHEN ACTIVATED
          if (showDatePicker) _buildDatePickerSection(),
          if (showDurationDropdown) _buildDurationSection(),
          if (showGuestSelector) _buildGuestSection(),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Check-in Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Check-in Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData(
                          colorScheme: ColorScheme.light(primary: themeColor),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
                child: Text(
                  selectedTime.format(context),
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showDatePicker = false;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: Colors.grey[400], size: 22),
              const SizedBox(width: 10),
              Text(
                'Choose duration',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView(
              children:
                  durationOptions
                      .map((hours) => _buildDurationOption(hours))
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showDurationDropdown = false;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int hours) {
    bool isSelected = selectedDurationHours == hours;
    return GestureDetector(
      onTap:
          () => setState(() {
            selectedDurationHours = hours;
          }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _formatDuration(hours),
          style: TextStyle(
            color: isSelected ? themeColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, color: Colors.grey[400], size: 22),
              const SizedBox(width: 10),
              const Text(
                'No. of guests',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGuestCounter(
            'Adults',
            adults,
            (value) => setState(() {
              adults = value;
            }),
          ),
          const SizedBox(height: 16),
          _buildGuestCounter(
            'Children',
            children,
            (value) => setState(() {
              children = value;
            }),
          ),
          const SizedBox(height: 16),
          _buildGuestCounter(
            'Rooms',
            rooms,
            (value) => setState(() {
              rooms = value;
            }),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showGuestSelector = false;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            _buildCounterButton(
              Icons.remove,
              () => value > 0 ? onChanged(value - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
            ),
            _buildCounterButton(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return Container(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (dayIndex) {
                int day = weekIndex * 7 + dayIndex - 2;
                if (day <= 0 || day > 31)
                  return Container(width: 36, height: 36);
                bool isSelected = day == selectedDate.day;
                return GestureDetector(
                  onTap:
                      () => setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          day,
                        );
                      }),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                        isSelected
                            ? BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(18),
                            )
                            : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    backgroundColor: themeColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Container(
              //   margin: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.1),
              //         blurRadius: 8,
              //         offset: const Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: IconButton(
              //     icon:
              //         isUpdatingFavorite
              //             ? const SizedBox(
              //               width: 20,
              //               height: 20,
              //               child: CircularProgressIndicator(
              //                 strokeWidth: 2,
              //                 valueColor: AlwaysStoppedAnimation<Color>(
              //                   Colors.grey,
              //                 ),
              //               ),
              //             )
              //             : Icon(
              //               isFavorite ? Icons.favorite : Icons.favorite_border,
              //               color: isFavorite ? Colors.red : Colors.black,
              //             ),
              //     onPressed: isUpdatingFavorite ? null : _toggleFavorite,
              //   ),
              // ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (widget.hotel.images.isNotEmpty)
                    PageView.builder(
                      itemCount: widget.hotel.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.hotel.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.hotel,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.hotel,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  // Rating overlay on image
                  Positioned(
                    top: 60,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.hotel.rating?.toStringAsFixed(1) ?? '4.8',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.hotel.totalReviews ?? 73} reviews)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.hotel.images.length > 1)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentImageIndex + 1}/${widget.hotel.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: widget.hotel.name,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' in ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.hotel.state,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.hotel.address}, ${widget.hotel.state}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // FIXED: Availability card
                    const SizedBox(height: 16),
                    _buildCheckAvailabilityCard(),
                    const SizedBox(height: 24),

                    // Exclusive Add-ons Widget
                    const Text(
                      "Tap for Exclusive Add-ons",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExclusiveAddonsWidget(),
                    const SizedBox(height: 16),

                    // Combined Amenities and What's Included Section
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'What\'s Included in Your Stay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildIncludedItem(
                            'Free Cancellation',
                            'Cancel up to 24 hours before',
                          ),
                          _buildIncludedItem(
                            'Breakfast',
                            'Complimentary breakfast included',
                          ),
                          _buildIncludedItem(
                            'WiFi',
                            'Free high-speed internet',
                          ),
                          _buildIncludedItem(
                            'Parking',
                            'Free parking available',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainGreen.withOpacity(0.3),
                            AppColors.mainGreen.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: AppColors.buttonColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Special Offer Available!',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 1, 93, 88),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Book now and save up to 20% on your stay',
                                  style: TextStyle(
                                    color: AppColors.buttonColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 20,
                      ),
                      child: Text(
                        'Earn Crabby points every time you book a stay, and use them later for discounts, perks, or upgrades.',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[500]!, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            offset: const Offset(1, 3),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  widget.hotel.latitude,
                                  widget.hotel.longitude,
                                ),
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId("hotel_location"),
                                  position: LatLng(
                                    widget.hotel.latitude,
                                    widget.hotel.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: widget.hotel.name,
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FullScreenMapPage(
                                          hotel: widget.hotel,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.fullscreen, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    NearestPlacesWidget(
                      latitude: widget.hotel.latitude,
                      longitude: widget.hotel.longitude,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About this hotel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.hotel.description.isNotEmpty
                          ? '${widget.hotel.description} Wake up to sweeping ocean views and the gentle rhythm of waves at Seaside Paradise, a peaceful beachfront retreat nestled on the golden shores of Mirissa. Designed with simplicity and comfort in mind, this cozy stay is ideal for couples or solo travelers craving a short, refreshing getaway. Inside, the space is thoughtfully arranged to maximize comfort and functionality.'
                          : 'Located in one of the most vibrant places and easily accessible to major attractions. Our hotel offers comfortable accommodations with modern amenities and excellent service to make your stay memorable. Experience luxury and comfort in the heart of ${widget.hotel.state}.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ReviewCarousel(),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: FAQWidget(hotelId: widget.hotel.id),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return RoomCreationScreen(
                                hotelId: widget.hotel.id,
                              );
                            },
                          ),
                        );
                      },
                      child: Text('add room'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Full-width green bar at top
            Container(
              height: 2,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mainGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price + All-inclusive
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (isLoadingRooms)
                            const Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          else if (cheapestRoom != null)
                            Row(
                              children: [
                                Text(
                                  ' LKR ${cheapestRoom!.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '/All Inclusive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Price unavailable',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      // ignore: unnecessary_null_comparison
                      widget.hotel != null
                          ? TermsConditionsWidget.buildTermsButton(
                            context: context,
                            terms: widget.hotel.terms,
                            text: "Terms & Conditions Apply",
                          )
                          : GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Terms not available'),
                                ),
                              );
                            },
                            child: Text(
                              "Terms & Conditions Apply",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                    ],
                  ),

                  const Spacer(),

                  // Updated button with integrated availability check
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isCheckingAvailability
                              ? null
                              : _checkAvailabilityAndNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child:
                          _isCheckingAvailability
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Check & Book Now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

class FullScreenMapPage extends StatelessWidget {
  final Hotel hotel;
  const FullScreenMapPage({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(hotel.latitude, hotel.longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("hotel_location"),
            position: LatLng(hotel.latitude, hotel.longitude),
            infoWindow: InfoWindow(title: hotel.name),
          ),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
