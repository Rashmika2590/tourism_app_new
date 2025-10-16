// Screens/booking_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/booking_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/booking_api_service.dart';
import 'package:tourism_app_new/Services/utils/user_shared_prefernce.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/user_model.dart';
import 'package:tourism_app_new/widgets/terms_condition_widget.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime checkOutDate;
  final String checkOutTime;
  final int adultCount;
  final int childrenCount;
  final Hotel hotel;
  final double totalprice;

  const BookingScreen({
    Key? key,
    required this.room,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    required this.adultCount,
    required this.childrenCount,
    required this.hotel,
    required this.totalprice,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _relationshipController = TextEditingController();

  String _selectedPaymentMethod = 'Card Payment';
  bool _isBooking = false;
  bool _agreeToTerms = false;
  bool _isBookingForSomeoneElse = false;
  double _totalPrice = 0.0;
  //double _serviceFee = 5.0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.totalprice;
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestController.dispose();
    _promoCodeController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Widget _buildFreeCancellationBadge() {
    if (widget.room.hasFreeCancellation == false) {
      return const SizedBox.shrink();
    }

    return Center(
      child: const Text(
        '*Free cancellation within 24 hours of booking',
        style: TextStyle(color: AppColors.mainGreen, fontSize: 12),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SharedPrefUser.getUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTimeForAPI(String time) {
    return time;
  }

  String _getDurationText() {
    final duration = widget.checkOutDate.difference(widget.checkInDate);
    final hours = duration.inHours > 0 ? duration.inHours : 1;
    return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  }

  Future<void> _submitBooking() async {
    // Debug print to check if method is called
    print('Submit booking called');

    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to the Terms & Conditions');
      return;
    }

    if (_currentUser == null) {
      _showErrorDialog('User data not available. Please try again.');
      return;
    }

    // Validate guest details if booking for someone else
    if (_isBookingForSomeoneElse) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        _showErrorDialog(
          'Please fill all guest details for booking someone else',
        );
        return;
      }
    }

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
        // Add guest information for booking someone else
        guestName: _isBookingForSomeoneElse ? _nameController.text : null,
        guestEmail: _isBookingForSomeoneElse ? _emailController.text : null,
        guestPhone: _isBookingForSomeoneElse ? _phoneController.text : null,
        //relationshiptoUser:
        //_isBookingForSomeoneElse ? _relationshipController.text : null,
      );

      print('Sending booking request...');
      final response = await BookingApiService.createBooking(bookingRequest);
      print('Booking response received: ${response.id}');

      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      print('Booking error: $e');
      if (mounted) {
        _showErrorDialog('Booking failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _showSuccessDialog(BookingResponse booking) {
    print('Showing success dialog');
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
                Text('Total Price: LKR ${_totalPrice.toStringAsFixed(0)}'),
                if (_isBookingForSomeoneElse && booking.guestName != null)
                  Text('Guest: ${booking.guestName}'),
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
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
    ).then((value) {
      print('Dialog closed');
    });
  }

  void _showErrorDialog(String error) {
    print('Showing error dialog: $error');
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected ? AppColors.mainGreen : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainGreen : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        trailing:
            isSelected
                ? Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.mainGreen,
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

  void _handleBookingForSomeoneElse() {
    setState(() {
      _isBookingForSomeoneElse = !_isBookingForSomeoneElse;
    });
  }

  void _showRelationshipDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Relationship to You'),
            content: TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                hintText: 'E.g., Friend, Family, Colleague, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
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

                  // Expandable form fields for booking someone else
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
                                        labelText: 'Guest Full Name *',
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
                                        labelText: 'Guest Email *',
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
                                        labelText: 'Guest Phone *',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Relationship field
                                  GestureDetector(
                                    onTap: _showRelationshipDialog,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                        leading: const Icon(
                                          Icons.people_outline,
                                          color: Colors.grey,
                                        ),
                                        title: Text(
                                          _relationshipController.text.isEmpty
                                              ? 'Relationship to You'
                                              : _relationshipController.text,
                                          style: TextStyle(
                                            color:
                                                _relationshipController
                                                        .text
                                                        .isEmpty
                                                    ? Colors.grey
                                                    : Colors.black,
                                          ),
                                        ),
                                        subtitle:
                                            _relationshipController.text.isEmpty
                                                ? const Text(
                                                  'Tap to select relationship',
                                                )
                                                : null,
                                        trailing: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey,
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

            _buildFreeCancellationBadge(),

            const SizedBox(height: 16),

            // Guest details form (shows current user OR guest details)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _currentUser == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isBookingForSomeoneElse
                                ? 'Guest Details'
                                : 'Your Details',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Name",
                            _isBookingForSomeoneElse &&
                                    _nameController.text.isNotEmpty
                                ? _nameController.text
                                : _currentUser!.name,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "E-mail",
                            _isBookingForSomeoneElse &&
                                    _emailController.text.isNotEmpty
                                ? _emailController.text
                                : _currentUser!.email,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Phone",
                            _isBookingForSomeoneElse &&
                                    _phoneController.text.isNotEmpty
                                ? _phoneController.text
                                : _currentUser!.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow("Country", 'Sri Lanka'),
                          if (_isBookingForSomeoneElse &&
                              _relationshipController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              "Relationship",
                              _relationshipController.text,
                            ),
                          ],
                        ],
                      ),
            ),

            // Price details section - UPDATED FOR CANCELLATION FEE
            const SizedBox(height: 16),
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

                  // Room base price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.room.name} (${_getDurationText()})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'LKR ${_getRoomBasePrice().toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Cancellation fee (only show if applicable)
                  if (_hasCancellationFee()) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cancellation Fee',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Text(
                          'LKR ${_getCancellationFee().toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Add-ons (only show if applicable)
                  if (_hasAddOns()) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add-ons',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          'LKR ${_getAddOnsTotal().toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  const Divider(height: 24),

                  // Total price
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
                        'LKR ${_totalPrice.toStringAsFixed(0)}',
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
                color: Colors.grey.shade200,
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
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        TermsConditionsWidget.showTermsAndConditions(
                          context: context,
                          terms: widget.hotel.terms,
                          title: "Terms & Conditions",
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Terms & Conditions',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.mainGreen,
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
                            style: const TextStyle(
                              color: Colors.black,
                            ), // base style
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: const TextStyle(
                                  color: AppColors.mainGreen,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        TermsConditionsWidget.showTermsAndConditions(
                                          context: context,
                                          terms:
                                              widget
                                                  .hotel
                                                  .terms, // 👈 pass hotel terms list
                                          title: "Terms & Conditions",
                                        );
                                      },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppColors.mainGreen,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        // 👉 show Privacy Policy page or bottom sheet here
                                      },
                              ),
                              const TextSpan(text: '.'),
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
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(28),
                )
                : BoxDecoration(
                  color: AppColors.mainGreen,
                  borderRadius: BorderRadius.circular(28),
                ),
        child: FloatingActionButton.extended(
          onPressed: (_isBooking || !_agreeToTerms) ? null : _submitBooking,
          backgroundColor: Colors.transparent,
          elevation: 0,
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
    return Padding(
      padding: const EdgeInsets.only(right: 25.0, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Add these helper methods to calculate different price components
  double _getRoomBasePrice() {
    final duration = widget.checkOutDate.difference(widget.checkInDate);
    final hours = duration.inHours > 0 ? duration.inHours : 1;
    return widget.room.price * hours;
  }

  double _getCancellationFee() {
    // Calculate cancellation fee based on the room's cancellation percentage
    final roomBasePrice = _getRoomBasePrice();
    final cancellationPercentage =
        widget.room.hotelCancellationPercentage ?? 0.0;
    return roomBasePrice * (cancellationPercentage / 100);
  }

  double _getAddOnsTotal() {
    // Since we don't have direct access to add-ons in BookingScreen,
    // we'll calculate it from the total price
    final roomTotal = _getRoomBasePrice() + _getCancellationFee();
    return widget.totalprice - roomTotal;
  }

  bool _hasCancellationFee() {
    return _getCancellationFee() > 0;
  }

  bool _hasAddOns() {
    return _getAddOnsTotal() > 0;
  }
}
