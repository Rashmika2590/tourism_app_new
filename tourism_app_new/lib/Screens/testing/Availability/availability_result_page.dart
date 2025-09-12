// room_availability_results.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/widgets/expandable_map_widget.dart'; // Import the map widget

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
  final String state;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String checkInTime;
  final String checkOutTime;
  final int adultsCount;
  final int childrenCount;
  final int roomsCount;
  final RoomAvailability availability;
  final List<HotelWithRoomDetails> hotelWithRoomDetails;

  const RoomAvailabilityResultsScreen({
    super.key,
    required this.state,
    required this.checkInDate,
    required this.checkOutDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.adultsCount,
    required this.childrenCount,
    required this.roomsCount,
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

  void _navigateToRoomList(int hotelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RoomsListScreen(
              hotelId: hotelId,
              checkInDate: widget.checkInDate,
              checkInTime: widget.checkInTime,
              checkOutDate: widget.checkOutDate,
              checkOutTime: widget.checkOutTime,
              adultCount: widget.adultsCount,
              childrenCount: widget.childrenCount,
            ),
      ),
    );
  }

  void _toggleMap() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }

  Widget _buildCompactSearchSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header - matches screenshot
          Text(
            'Handpicked for you (${widget.availability.getTotalAvailableRooms()} results)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Search criteria chips - matches screenshot layout
          Row(
            children: [
              // Check-in chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('dd-MM-yyyy').format(widget.checkInDate)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.checkInTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Check-out chip (without background)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy').format(widget.checkOutDate),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Second row of chips
          Row(
            children: [
              // Location chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      widget.state,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Guests chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.adultsCount} Adults  ${widget.childrenCount} children  ${widget.roomsCount} Room',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Advanced and Sort options - matches screenshot
          Row(
            children: [
              // Advanced
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Advanced',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Sort by
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sort, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
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

  Widget _buildEnhancedHotelCard(HotelWithRoomDetails hotelWithRooms) {
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
                  onTap: () => _navigateToRoomList(hotel.id),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Back arrow bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ✅ Scrollable content with map on top
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Map widget always on top
                    ExpandableMapWidget(
                      isExpanded: _isMapExpanded,
                      onToggle: _toggleMap,
                      location: widget.state, // Pass the location to the map
                    ),

                    // Compact search summary
                    _buildCompactSearchSummary(),

                    // Results list
                    if (widget.availability.hasAvailableRooms())
                      Column(
                        children:
                            widget.hotelWithRoomDetails.map((hotel) {
                              return _buildEnhancedHotelCard(hotel);
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
            ),
          ],
        ),
      ),
    );
  }
}
