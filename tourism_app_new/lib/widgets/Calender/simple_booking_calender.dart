// Widgets/simple_booking_calendar.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/widgets/Calender/calender_service.dart';

class SimpleBookingCalendar extends StatefulWidget {
  final int hotelId;
  final Function(int roomId, DateTime checkIn, DateTime checkOut)?
  onDateRangeSelected;

  const SimpleBookingCalendar({
    Key? key,
    required this.hotelId,
    this.onDateRangeSelected,
  }) : super(key: key);

  @override
  State<SimpleBookingCalendar> createState() => _SimpleBookingCalendarState();
}

class _SimpleBookingCalendarState extends State<SimpleBookingCalendar> {
  DateTime _currentMonth = DateTime.now();
  int? _selectedRoomId;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  HotelCalendarData? _calendarData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await BookingCalendarService.getCalendarData(widget.hotelId);
      setState(() {
        _calendarData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isDateUnavailable(DateTime day, int roomId) {
    if (_calendarData == null) return false;

    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return !_calendarData!.isRoomAvailable(roomId, startOfDay, endOfDay);
  }

  void _onDayTapped(DateTime day) {
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room first')),
      );
      return;
    }

    setState(() {
      if (_rangeStart == null || (_rangeEnd != null)) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (day.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;

        final isAvailable =
            _calendarData?.isRoomAvailable(
              _selectedRoomId!,
              _rangeStart!,
              _rangeEnd!,
            ) ??
            false;

        if (isAvailable) {
          widget.onDateRangeSelected?.call(
            _selectedRoomId!,
            _rangeStart!,
            _rangeEnd!,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Room available from ${_formatDate(_rangeStart!)} to ${_formatDate(_rangeEnd!)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room not available for selected dates'),
              backgroundColor: Colors.red,
            ),
          );
          _rangeStart = null;
          _rangeEnd = null;
        }
      }
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  int _getFirstWeekday(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getDayColor(DateTime day) {
    if (_selectedRoomId == null) return Colors.grey.shade200;

    if (_isDateUnavailable(day, _selectedRoomId!)) {
      return Colors.red.shade300;
    }

    if (_rangeStart != null && _rangeEnd != null) {
      if ((day.isAfter(_rangeStart!) || day.isAtSameMomentAs(_rangeStart!)) &&
          (day.isBefore(_rangeEnd!) || day.isAtSameMomentAs(_rangeEnd!))) {
        return Colors.blue.shade200;
      }
    } else if (_rangeStart != null && day.isAtSameMomentAs(_rangeStart!)) {
      return Colors.blue.shade300;
    }

    return Colors.green.shade200;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (_calendarData == null || _calendarData!.rooms.isEmpty) {
      return const Center(child: Text('No rooms available'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRoomSelector(),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 16),
          if (_selectedRoomId != null) _buildCalendar(),
          if (_rangeStart != null && _rangeEnd != null)
            _buildSelectionSummary(),
        ],
      ),
    );
  }

  Widget _buildRoomSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _calendarData!.rooms.map((room) {
                    final isSelected = _selectedRoomId == room.id;
                    return FilterChip(
                      label: Text('${room.name} - LKR ${room.price}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoomId = selected ? room.id : null;
                          _rangeStart = null;
                          _rangeEnd = null;
                        });
                      },
                      selectedColor: Colors.blue,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Available', Colors.green.shade200),
                _buildLegendItem('Booked', Colors.red.shade300),
                _buildLegendItem('Selected', Colors.blue.shade200),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonthHeader(),
            const SizedBox(height: 16),
            _buildWeekdayHeaders(),
            const SizedBox(height: 8),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        Text(
          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstWeekday = _getFirstWeekday(_currentMonth);
    final leadingEmptyCells = firstWeekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: leadingEmptyCells + daysInMonth.length,
      itemBuilder: (context, index) {
        if (index < leadingEmptyCells) {
          return const SizedBox.shrink();
        }

        final dayIndex = index - leadingEmptyCells;
        final day = daysInMonth[dayIndex];
        final isPast = day.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        return GestureDetector(
          onTap: isPast ? null : () => _onDayTapped(day),
          child: Container(
            decoration: BoxDecoration(
              color: isPast ? Colors.grey.shade100 : _getDayColor(day),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPast ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (_selectedRoomId != null && !isPast)
                    Icon(
                      _isDateUnavailable(day, _selectedRoomId!)
                          ? Icons.close
                          : Icons.check,
                      size: 12,
                      color:
                          _isDateUnavailable(day, _selectedRoomId!)
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionSummary() {
    if (_rangeStart == null || _rangeEnd == null || _selectedRoomId == null) {
      return const SizedBox.shrink();
    }

    final room = _calendarData!.rooms.firstWhere(
      (r) => r.id == _selectedRoomId,
    );
    final nights = _rangeEnd!.difference(_rangeStart!).inDays;
    final totalPrice = double.parse(room.price) * nights;

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow('Room:', room.name),
            _buildSummaryRow('Check-in:', _formatDate(_rangeStart!)),
            _buildSummaryRow('Check-out:', _formatDate(_rangeEnd!)),
            _buildSummaryRow('Nights:', '$nights'),
            _buildSummaryRow('Price per night:', 'LKR ${room.price}'),
            const Divider(),
            _buildSummaryRow(
              'Total:',
              'LKR ${totalPrice.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

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
