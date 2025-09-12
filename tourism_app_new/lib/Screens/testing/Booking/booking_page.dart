// Screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/booking_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/booking_api_service.dart';
import 'package:tourism_app_new/Services/utils/user_shared_prefernce.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/user_model.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime checkOutDate;
  final String checkOutTime;
  final int adultCount;
  final int childrenCount;

  const BookingScreen({
    Key? key,
    required this.room,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    required this.adultCount,
    required this.childrenCount,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestController = TextEditingController();
  final _promoCodeController = TextEditingController();

  String _selectedPaymentMethod = 'Card Payment';
  TimeOfDay _estimatedArrival = const TimeOfDay(hour: 8, minute: 0);
  bool _isBooking = false;
  bool _agreeToTerms = false;
  bool _isBookingForSomeoneElse = false;
  double _totalPrice = 0.0;
  double _serviceFee = 5.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
    // TODO: Load user details from app's registered user
    // For now, set some dummy data
    _nameController.text = 'Amantha Nirmal';
    _emailController.text = 'amantha.nirmal@email.com';
    _phoneController.text = '+94 77 123 4567';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    final duration = widget.checkOutDate.difference(widget.checkInDate);
    final days = duration.inDays;
    final roomPrice = widget.room.price * (days > 0 ? days : 1);
    _totalPrice = roomPrice + _serviceFee;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTimeForAPI(String time) {
    return time;
  }

  String _getDurationText() {
    final duration = widget.checkOutDate.difference(widget.checkInDate);
    final days = duration.inDays;
    final hours = duration.inHours;

    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    } else {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
  }

  double _getRoomPrice() {
    final duration = widget.checkOutDate.difference(widget.checkInDate);
    final days = duration.inDays;
    return widget.room.price * (days > 0 ? days : 1);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBooking = true);

    try {
      final bookingRequest = BookingRequest(
        roomId: widget.room.id,
        status: 'pending',
        ciDate:
            '${widget.checkInDate.year}-${widget.checkInDate.month.toString().padLeft(2, '0')}-${widget.checkInDate.day.toString().padLeft(2, '0')}',
        ciTime: _formatTimeForAPI(widget.checkInTime),
        coDate:
            '${widget.checkOutDate.year}-${widget.checkOutDate.month.toString().padLeft(2, '0')}-${widget.checkOutDate.day.toString().padLeft(2, '0')}',
        coTime: _formatTimeForAPI(widget.checkOutTime),
        adultCount: widget.adultCount,
        childrenCount: widget.childrenCount,
        specialRequest: _specialRequestController.text,
        price: _totalPrice,
        paymentMethod: _selectedPaymentMethod,
        paymentReference: '',
        promoCode: _promoCodeController.text,
        bookingTime: DateTime.now().toIso8601String(),
      );

      final response = await BookingApiService.createBooking(bookingRequest);

      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _showSuccessDialog(BookingResponse booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: const Text('Booking Confirmed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (booking.id != null) Text('Booking ID: ${booking.id}'),
                Text('Room: ${widget.room.name}'),
                Text('Status: ${booking.status}'),
                Text('Total Price: LKR ${booking.price.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                const Text(
                  'You will receive a confirmation email shortly.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<User?> _loadUser() async {
    return await SharedPrefUser.getUser(); // This returns your User model
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.error, color: Colors.red, size: 60),
            title: const Text('Booking Failed'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade600),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing:
            isSelected
                ? Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                )
                : null,
        onTap: () {
          setState(() {
            _selectedPaymentMethod = title;
          });
        },
      ),
    );
  }

  // void _handleBookingForSomeoneElse() {
  //   setState(() {
  //     _isBookingForSomeoneElse = !_isBookingForSomeoneElse;
  //     if (!_isBookingForSomeoneElse) {
  //       // Reset to default user details
  //       _nameController.text = 'Amantha Nirmal';
  //       _emailController.text = 'amantha.nirmal@email.com';
  //       _phoneController.text = '+94 77 123 4567';
  //     } else {
  //       // Clear fields for someone else's details
  //       _nameController.clear();
  //       _emailController.clear();
  //       _phoneController.clear();
  //     }
  //   });
  // }

  // Add this method to handle the tap
  void _handleBookingForSomeoneElse() {
    setState(() {
      _isBookingForSomeoneElse = !_isBookingForSomeoneElse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Booking details section

            // Updated Container widget
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Date and time row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(widget.checkInDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.checkInTime.substring(0, 5),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.grey.shade400),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(widget.checkOutDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.checkOutTime.substring(0, 5),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Duration and guests row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getDurationText(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),

                        // Guests
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.adultCount} Adults  ${widget.childrenCount} children  1 Room',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Booking for someone else toggle
                  GestureDetector(
                    onTap: _handleBookingForSomeoneElse,
                    child: Row(
                      children: [
                        Text(
                          _isBookingForSomeoneElse
                              ? 'Booking for yourself?'
                              : 'Booking for someone else?',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isBookingForSomeoneElse
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  // Expandable form fields
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isBookingForSomeoneElse ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isBookingForSomeoneElse ? 1.0 : 0.0,
                      child:
                          _isBookingForSomeoneElse
                              ? Column(
                                children: [
                                  const SizedBox(height: 16),

                                  // Name field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        prefixIcon: Icon(Icons.person_outline),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Email field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Phone field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '*Free cancellation within 24 hours of booking',
              style: TextStyle(color: Colors.teal, fontSize: 12),
            ),

            // Guest details form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FutureBuilder<User?>(
                future: _loadUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Text("No user data found");
                  }

                  final user = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Name", user.name),
                      const SizedBox(height: 12),
                      _buildDetailRow("E-mail", user.email),
                      const SizedBox(height: 12),
                      _buildDetailRow("Phone", user.phone),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Country",
                        user.updatedBy,
                      ), // if you stored country there
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Price details section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.room.name} (${_getDurationText()})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'LKR${_getRoomPrice().toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service fee',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'LKR${_serviceFee.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'LKR${_totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment methods section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pay with',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  _buildPaymentOption(
                    'Card Payment',
                    'Accepting Visa, Mastercard, etc',
                    Icons.credit_card,
                  ),

                  _buildPaymentOption(
                    'Google Pay',
                    '',
                    Icons.account_balance_wallet,
                  ),

                  _buildPaymentOption(
                    'Crabby Points',
                    'Pay with your Crabby Points',
                    Icons.stars,
                  ),

                  const SizedBox(height: 12),

                  // Promo code section
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Enter Promo Code'),
                              content: TextFormField(
                                controller: _promoCodeController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter promo code',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          const Text(
                            'Enter Promo code',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional sections
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Terms & Conditions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Special requests
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Any Special Request(s)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Special Requests'),
                                    content: TextFormField(
                                      controller: _specialRequestController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Enter any special requests...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Estimated arrival time
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Arrival time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_estimatedArrival.hour.toString().padLeft(2, '0')}:${_estimatedArrival.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('AM'),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('PM'),
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

            const SizedBox(height: 16),

            // Terms text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Free cancellation if you cancel within 24 hours of booking',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    '• A security deposit of LKR 5,000 will be collected at check-in',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    '• Late check-out charges may apply after 11:00 AM',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    '• Prices shown include service fees and taxes (if applicable)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            children: const [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),

      // Bottom floating button
      floatingActionButton: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration:
            (_isBooking || !_agreeToTerms)
                ? BoxDecoration(
                  color: Colors.grey, // disabled state
                  borderRadius: BorderRadius.circular(28),
                )
                : BoxDecoration(
                  gradient:
                      AppGradients
                          .primaryGradient, // <-- your gradient from constants
                  borderRadius: BorderRadius.circular(28),
                ),
        child: FloatingActionButton.extended(
          onPressed: (_isBooking || !_agreeToTerms) ? null : _submitBooking,
          backgroundColor: Colors.transparent, // make FAB itself transparent
          elevation: 0, // so gradient shows nicely
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          label:
              _isBooking
                  ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Processing...'),
                    ],
                  )
                  : const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}
