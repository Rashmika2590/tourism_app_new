// Screens/booking_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/booking_api_service.dart';
import 'package:tourism_app_new/models/booking_model.dart';
import 'package:tourism_app_new/widgets/Calender/simple_booking_calender.dart';

class BookingCalendarScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const BookingCalendarScreen({
    Key? key,
    required this.hotelId,
    required this.hotelName,
  }) : super(key: key);

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  int? _selectedRoomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isBooking = false;

  void _onDateRangeSelected(int roomId, DateTime checkIn, DateTime checkOut) {
    setState(() {
      _selectedRoomId = roomId;
      _checkIn = checkIn;
      _checkOut = checkOut;
    });

    _showBookingConfirmation();
  }

  void _showBookingConfirmation() {
    if (_selectedRoomId == null || _checkIn == null || _checkOut == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBookingForm(),
    );
  }

  Widget _buildBookingForm() {
    final checkInTimeController = TextEditingController(text: '14:00:00');
    final checkOutTimeController = TextEditingController(text: '12:00:00');
    final adultCountController = TextEditingController(text: '1');
    final childrenCountController = TextEditingController(text: '0');
    final specialRequestController = TextEditingController();
    String selectedPaymentMethod = 'Card Payment';

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Booking',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Date Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Check-in:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_formatDate(_checkIn!)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Check-out:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_formatDate(_checkOut!)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Check-in Time
                TextField(
                  controller: checkInTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Check-in Time (HH:MM:SS)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 12),

                // Check-out Time
                TextField(
                  controller: checkOutTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Check-out Time (HH:MM:SS)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 12),

                // Guest Count
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: adultCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Adults',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: childrenCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Children',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.child_care),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Payment Method
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items:
                      ['Card Payment', 'Cash', 'Bank Transfer']
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Special Requests
                TextField(
                  controller: specialRequestController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Special Requests (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isBooking
                                ? null
                                : () => _confirmBooking(
                                  checkInTimeController.text,
                                  checkOutTimeController.text,
                                  int.tryParse(adultCountController.text) ?? 1,
                                  int.tryParse(childrenCountController.text) ??
                                      0,
                                  selectedPaymentMethod,
                                  specialRequestController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isBooking
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Confirm Booking'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmBooking(
    String checkInTime,
    String checkOutTime,
    int adultCount,
    int childrenCount,
    String paymentMethod,
    String specialRequest,
  ) async {
    if (_selectedRoomId == null || _checkIn == null || _checkOut == null) {
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final booking = BookingRequest(
        roomId: _selectedRoomId!,
        ciDate: _formatDateForApi(_checkIn!),
        ciTime: checkInTime,
        coDate: _formatDateForApi(_checkOut!),
        coTime: checkOutTime,
        adultCount: adultCount,
        childrenCount: childrenCount,
        specialRequest: specialRequest,
        price: 0.0, // Calculate based on room price and nights
        paymentMethod: paymentMethod,
        bookingTime: DateTime.now().toIso8601String(),
      );

      final response = await BookingApiService.createBooking(booking);

      if (mounted) {
        Navigator.pop(context); // Close the modal

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed! ID: ${response.id}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Optionally navigate to booking details or refresh calendar
        setState(() {
          _selectedRoomId = null;
          _checkIn = null;
          _checkOut = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hotelName} - Booking Calendar'),
        elevation: 0,
      ),
      body: SimpleBookingCalendar(
        hotelId: widget.hotelId,
        onDateRangeSelected: _onDateRangeSelected,
      ),
    );
  }
}
