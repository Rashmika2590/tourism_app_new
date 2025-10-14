import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app_new/models/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingResponse booking;

  const BookingDetailScreen({required this.booking});

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return DateFormat('EEEE, MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _calculateDuration() {
    try {
      final checkOut = DateTime.parse(booking.coDate + ' ' + booking.coTime);
      final checkIn = DateTime.parse(booking.ciDate + ' ' + booking.ciTime);

      final totalDuration = checkOut.difference(checkIn);
      final totalHours = totalDuration.inHours;
      final days = totalHours ~/ 24;
      final hours = totalHours % 24;

      if (days > 0 && hours > 0) {
        return '$days day${days > 1 ? 's' : ''} $hours hour${hours > 1 ? 's' : ''} ($totalHours hours)';
      } else if (days > 0) {
        return '$days day${days > 1 ? 's' : ''} ($totalHours hours)';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
    } catch (e) {
      return '0 hours';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking #${booking.id}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Room #${booking.roomId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            booking.status,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Check-in section
                  _buildSection(
                    title: 'Check-in Details',
                    icon: Icons.login,
                    children: [
                      _buildDetailRow(
                        'Date',
                        _formatDate(booking.ciDate),
                        Icons.calendar_today,
                      ),
                      _buildDetailRow(
                        'Time',
                        booking.ciTime,
                        Icons.access_time,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Check-out section
                  _buildSection(
                    title: 'Check-out Details',
                    icon: Icons.logout,
                    children: [
                      _buildDetailRow(
                        'Date',
                        _formatDate(booking.coDate),
                        Icons.calendar_today,
                      ),
                      _buildDetailRow(
                        'Time',
                        booking.coTime,
                        Icons.access_time,
                      ),
                      _buildDetailRow(
                        'Duration',
                        _calculateDuration(),
                        Icons.access_time_filled,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Guests section
                  _buildSection(
                    title: 'Guests',
                    icon: Icons.people,
                    children: [
                      _buildDetailRow(
                        'Adults',
                        booking.adultCount.toString(),
                        Icons.person,
                      ),
                      _buildDetailRow(
                        'Children',
                        booking.childrenCount.toString(),
                        Icons.child_care,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Guest booking info
                  if (booking.guestName != null &&
                      booking.guestName!.isNotEmpty)
                    Column(
                      children: [
                        _buildSection(
                          title: 'Guest Information',
                          icon: Icons.person_outline,
                          children: [
                            _buildDetailRow(
                              'Name',
                              booking.guestName ?? '-',
                              Icons.badge,
                            ),
                            if (booking.guestEmail != null &&
                                booking.guestEmail!.isNotEmpty)
                              _buildDetailRow(
                                'Email',
                                booking.guestEmail ?? '-',
                                Icons.email,
                              ),
                            if (booking.guestPhone != null &&
                                booking.guestPhone!.isNotEmpty)
                              _buildDetailRow(
                                'Phone',
                                booking.guestPhone ?? '-',
                                Icons.phone,
                              ),
                            if (booking.relationshipToUser != null &&
                                booking.relationshipToUser!.isNotEmpty)
                              _buildDetailRow(
                                'Relationship',
                                booking.relationshipToUser ?? '-',
                                Icons.family_restroom,
                              ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  // Special requests
                  if (booking.specialRequest.isNotEmpty)
                    Column(
                      children: [
                        _buildSection(
                          title: 'Special Requests',
                          icon: Icons.note,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                booking.specialRequest,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  // Payment section
                  _buildSection(
                    title: 'Payment Details',
                    icon: Icons.payment,
                    children: [
                      _buildDetailRow(
                        'Payment Method',
                        booking.paymentMethod,
                        Icons.credit_card,
                      ),
                      if (booking.paymentReference.isNotEmpty)
                        _buildDetailRow(
                          'Reference',
                          booking.paymentReference,
                          Icons.receipt,
                        ),
                      if (booking.promoCode.isNotEmpty)
                        _buildDetailRow(
                          'Promo Code',
                          booking.promoCode,
                          Icons.local_offer,
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Price summary
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rs. ${booking.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Booking time
                  Center(
                    child: Text(
                      'Booked on ${_formatDate(booking.bookingTime)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
