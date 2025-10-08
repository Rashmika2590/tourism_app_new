// Widgets/booking_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/Calender/calender_service.dart';

class BookingCalendarWidget extends StatefulWidget {
  final int hotelId;
  final Function(List<HotelRoom> availableRooms, DateTime selectedDate)?
  onDateSelected;

  const BookingCalendarWidget({
    Key? key,
    required this.hotelId,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  // MAIN STATE VARIABLES
  DateTime _currentMonth = DateTime.now(); // Currently displayed month
  DateTime? _selectedDate; // Currently selected date by user

  HotelCalendarData? _calendarData; // Hotel booking data from API
  bool _isLoading = true; // Loading state for API calls
  String? _errorMessage; // Error message if API fails

  // DROPDOWN STATE
  bool _isExpanded = false; // Controls dropdown expansion

  // CACHE FOR PERFORMANCE OPTIMIZATION
  Map<String, List<HotelRoom>> _dailyAvailabilityCache =
      {}; // Cache for daily room availability

  @override
  void initState() {
    super.initState();
    _loadCalendarData(); // Load data when widget initializes
  }

  // MAIN DATA LOADING METHOD
  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // API CALL: Fetch calendar data from service
      final data = await BookingCalendarService.getCalendarData(widget.hotelId);
      setState(() {
        _calendarData = data;
        _isLoading = false;
        _buildAvailabilityCache(); // Build cache after data loads
      });
    } catch (e) {
      // ERROR HANDLING: Display error if API call fails
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // CACHE BUILDING METHOD - Optimizes performance by pre-calculating availability
  void _buildAvailabilityCache() {
    if (_calendarData == null) return;

    _dailyAvailabilityCache.clear();

    // Build cache for next 90 days for smooth scrolling
    final today = DateTime.now();
    for (int i = 0; i < 90; i++) {
      final date = today.add(Duration(days: i));
      final dateKey = _getDateKey(date);
      _dailyAvailabilityCache[dateKey] = _getAvailableRoomsForDate(date);
    }
  }

  // DATE KEY GENERATION - Creates unique key for date caching
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ROOM AVAILABILITY CHECK - Returns available rooms for a specific date
  List<HotelRoom> _getAvailableRoomsForDate(DateTime date) {
    if (_calendarData == null) return [];

    // Define date range for availability check (whole day)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _calendarData!.getAvailableRooms(startOfDay, endOfDay);
  }

  // CHEAPEST ROOM FINDER - Returns the lowest priced available room for a date
  HotelRoom? _getCheapestRoomForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    final availableRooms = _dailyAvailabilityCache[dateKey] ?? [];

    if (availableRooms.isEmpty) return null;

    // SORTING: Sort rooms by price ascending to find cheapest
    availableRooms.sort(
      (a, b) => double.parse(a.price).compareTo(double.parse(b.price)),
    );

    return availableRooms.first;
  }

  // DATE SELECTION HANDLER - Called when user taps a date
  void _onDayTapped(DateTime day) {
    final dateKey = _getDateKey(day);
    final availableRooms = _dailyAvailabilityCache[dateKey] ?? [];

    setState(() {
      _selectedDate = day;
    });

    // CALLBACK: Notify parent widget about date selection
    widget.onDateSelected?.call(availableRooms, day);
  }

  // CALENDAR GRID GENERATION - Returns all days in current month
  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  // WEEKDAY CALCULATION - Returns weekday of first day of month (0-6, Sun-Sat)
  int _getFirstWeekday(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday;
  }

  // DATE FORMATTING - Converts DateTime to readable format
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // DATE COMPARISON - Checks if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // TOGGLE DROPDOWN VISIBILITY
  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DROPDOWN TRIGGER BUTTON - Keep it on the right side
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // This keeps the icon on the right
          children: [
            IconButton(
              onPressed: _toggleDropdown,
              icon: Icon(Icons.calendar_month, color: AppColors.mainGreen),
            ),
          ],
        ),

        // DROPDOWN CONTENT
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          _buildCalendarContent(),
        ],
      ],
    );
  }

  // CALENDAR CONTENT (moved from main build method)
  Widget _buildCalendarContent() {
    // LOADING STATE - Show progress indicator
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ERROR STATE - Show error message with retry option
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCalendarData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // EMPTY STATE - No rooms available
    if (_calendarData == null || _calendarData!.rooms.isEmpty) {
      return const Center(child: Text('No rooms available'));
    }

    // MAIN CALENDAR UI
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildCalendar(), // Main calendar grid
          if (_selectedDate != null)
            _buildSelectedDateDetails(), // Selected date details panel
        ],
      ),
    );
  }

  // MAIN CALENDAR CONTAINER
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMonthHeader(), // Month navigation header
              const SizedBox(height: 16),
              _buildWeekdayHeaders(), // Sun, Mon, Tue... headers
              const SizedBox(height: 8),
              _buildCalendarGrid(), // Main calendar dates grid
            ],
          ),
        ),
      ),
    );
  }

  // MONTH NAVIGATION HEADER - Previous/Next month buttons
  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // PREVIOUS MONTH BUTTON
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
        ),

        // CURRENT MONTH DISPLAY
        Text(
          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // NEXT MONTH BUTTON
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  // WEEKDAY HEADERS - Sun, Mon, Tue, etc.
  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // CALENDAR GRID BUILDER - Creates 7xN grid of dates
  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstWeekday = _getFirstWeekday(_currentMonth);
    final leadingEmptyCells = firstWeekday % 7; // Empty cells before first day

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days in a week
        childAspectRatio: 1.0, // Square cells
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: leadingEmptyCells + daysInMonth.length,
      itemBuilder: (context, index) {
        // EMPTY CELLS: For days before month starts
        if (index < leadingEmptyCells) {
          return const SizedBox.shrink();
        }

        final dayIndex = index - leadingEmptyCells;
        final day = daysInMonth[dayIndex];

        return _buildDayCell(day); // Build individual date cell
      },
    );
  }

  // INDIVIDUAL DATE CELL WIDGET
  Widget _buildDayCell(DateTime day) {
    // DATE STATE CALCULATIONS
    final isPast = day.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _selectedDate != null && _isSameDay(day, _selectedDate!);

    final cheapestRoom = _getCheapestRoomForDate(day);
    final hasAvailability = cheapestRoom != null;

    // COLOR CODING LOGIC
    Color bgColor;
    if (isPast) {
      bgColor = Colors.grey.shade100; // Grey for past dates
    } else if (isSelected) {
      bgColor = Colors.blue.shade50; // Blue for selected date
    } else if (hasAvailability) {
      bgColor = AppColors.mainGreen.withOpacity(
        0.1,
      ); // App main green for available dates
    } else {
      bgColor = Colors.red.shade50; // Red for unavailable dates
    }

    // MAIN DATE CELL
    return GestureDetector(
      onTap:
          isPast ? null : () => _onDayTapped(day), // Disable tap for past dates
      child: Container(
        decoration: BoxDecoration(
          color: bgColor, // Background color based on availability
          borderRadius: BorderRadius.circular(10),
          // NO BORDER - Removed border as requested
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DAY NUMBER - Always displayed
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPast ? Colors.grey : Colors.black87,
              ),
            ),

            // AVAILABILITY INFO - Only for future dates
            if (!isPast) ...[
              const SizedBox(height: 2),

              if (hasAvailability) ...[
                // PRICE DISPLAY - Show cheapest room price
                Text(
                  'LKR ${cheapestRoom.price}',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainGreen, // App main green color
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                // UNAVAILABLE TEXT
                Text(
                  'Unavailable',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // SELECTED DATE DETAILS PANEL - Shows when a date is selected
  Widget _buildSelectedDateDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final dateKey = _getDateKey(_selectedDate!);
    final availableRooms = _dailyAvailabilityCache[dateKey] ?? [];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PANEL HEADER - Date and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Rooms',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(_selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                // CLOSE BUTTON - Hide details panel
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 24),

            // EMPTY STATE - No rooms available
            if (availableRooms.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.hotel_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No rooms available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All rooms are booked for this date',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ROOMS COUNT SUMMARY
              Text(
                '${availableRooms.length} room type${availableRooms.length > 1 ? 's' : ''} available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // ROOM LIST - Sorted by price (cheapest first)
              ...() {
                final sortedRooms = List<HotelRoom>.from(availableRooms);
                sortedRooms.sort(
                  (a, b) =>
                      double.parse(a.price).compareTo(double.parse(b.price)),
                );
                return sortedRooms.map((room) => _buildRoomCard(room)).toList();
              }(),
            ],
          ],
        ),
      ),
    );
  }

  // INDIVIDUAL ROOM CARD - Display room details and booking option
  Widget _buildRoomCard(HotelRoom room) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.mainGreen.withOpacity(0.3),
          width: 1,
        ), // App main green border
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // ROOM ICON SECTION
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mainGreen.withOpacity(
                  0.1,
                ), // App main green background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.hotel,
                size: 32,
                color: AppColors.mainGreen, // App main green icon
              ),
            ),
            const SizedBox(width: 12),

            // ROOM DETAILS SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROOM NAME
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ROOM TYPE
                  Text(
                    room.type,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  // OCCUPANCY INFO
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Max ${room.maxOccupancy} guests',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  // AMENITIES DISPLAY (first 3 only)
                  if (room.amenities.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children:
                          room.amenities.take(3).map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                amenity,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // PRICE AND BOOKING SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // PRICE DISPLAY
                Text(
                  'LKR ${room.price}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainGreen, // App main green price
                  ),
                ),
                const Text(
                  'per night',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // BOOK BUTTON
                ElevatedButton(
                  onPressed: () {
                    _onRoomSelected(room); // Handle room selection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.mainGreen, // App main green button
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ROOM SELECTION HANDLER - Shows booking confirmation dialog
  void _onRoomSelected(HotelRoom room) {
    // BOOKING CONFIRMATION DIALOG
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book ${room.name}'),
            content: Text(
              'Selected Date: ${_formatDate(_selectedDate!)}\n'
              'Room: ${room.name}\n'
              'Price: LKR ${room.price}/night',
            ),
            actions: [
              // CANCEL BUTTON
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              // CONFIRM BUTTON
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement actual booking logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Booking ${room.name} for ${_formatDate(_selectedDate!)}',
                      ),
                      backgroundColor:
                          AppColors.mainGreen, // App main green success color
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.mainGreen, // App main green confirm button
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // MONTH NAME HELPER - Converts month number to name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
