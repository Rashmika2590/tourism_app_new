import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/models/search_params_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_creation.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/faq_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/activity_row.dart';
import 'package:tourism_app_new/widgets/post_searching_dropdowns.dart';
import 'package:tourism_app_new/widgets/reviewCard.dart';

class EnhancedHotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final SearchParams? searchParams;

  const EnhancedHotelDetailsScreen(
      {Key? key, required this.hotel, this.searchParams})
      : super(key: key);

  @override
  State<EnhancedHotelDetailsScreen> createState() =>
      _EnhancedHotelDetailsScreenState();
}

class _EnhancedHotelDetailsScreenState
    extends State<EnhancedHotelDetailsScreen> {
  late SearchParams _searchParams;
  bool isFavorite = false;
  int currentImageIndex = 0;
  List<Room> hotelRooms = [];
  List<FAQ> faqs = [];
  bool isLoadingRooms = true;
  bool isLoadingFAQs = true;
  bool _isCheckingAvailability = false;
  Room? cheapestRoom;
  Set<String> allAmenities = {};
  final TextEditingController _faqController = TextEditingController();
  bool _isSubmittingFAQ = false;

  // Dummy FAQs for display
  final List<Map<String, dynamic>> dummyFAQs = [
    {
      'question': 'Is parking available?',
      'answer': 'Yes, we offer complimentary parking for all guests.',
      'likes': 15,
      'dislikes': 2,
      'userReaction': null,
    },
    {
      'question': 'What time is check-in?',
      'answer': 'Check-in is from 3:00 PM and check-out is until 11:00 AM.',
      'likes': 23,
      'dislikes': 1,
      'userReaction': null,
    },
    {
      'question': 'Do you have a fitness center?',
      'answer': '',
      'likes': 8,
      'dislikes': 0,
      'userReaction': null,
    },
    {
      'question': 'Is WiFi free?',
      'answer':
          'Yes, complimentary high-speed WiFi is available throughout the hotel.',
      'likes': 34,
      'dislikes': 0,
      'userReaction': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchParams = widget.searchParams ??
        SearchParams(
          state: widget.hotel.state,
          checkInDate: DateTime.now(),
          checkInTime: TimeOfDay.now(),
          durationHours: 1,
          adults: 1,
          children: 0,
          rooms: 1,
        );
    _loadHotelRooms();
    _loadFAQs();
  }

  @override
  void dispose() {
    _faqController.dispose();
    super.dispose();
  }

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

  Future<void> _loadFAQs() async {
    try {
      final loadedFAQs = await FAQApiService.getFAQs(widget.hotel.id);
      setState(() {
        faqs = loadedFAQs;
        isLoadingFAQs = false;
      });
    } catch (e) {
      print('Error loading FAQs: $e');
      setState(() {
        isLoadingFAQs = false;
      });
    }
  }

  Future<void> _submitFAQ() async {
    if (_faqController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a question')));
      return;
    }

    setState(() {
      _isSubmittingFAQ = true;
    });

    try {
      final newFAQ = await FAQApiService.createFAQ(
        hotelId: widget.hotel.id,
        question: _faqController.text.trim(),
      );

      setState(() {
        faqs.add(newFAQ);
        _faqController.clear();
        _isSubmittingFAQ = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question submitted successfully!')),
      );
    } catch (e) {
      setState(() {
        _isSubmittingFAQ = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit question: $e')));
    }
  }

  Future<void> _reactToFAQ(int faqIndex, bool isLike) async {
    setState(() {
      final faq = dummyFAQs[faqIndex];

      // Remove previous reaction
      if (faq['userReaction'] == true) {
        faq['likes']--;
      } else if (faq['userReaction'] == false) {
        faq['dislikes']--;
      }

      // Add new reaction
      if (isLike) {
        faq['likes']++;
      } else {
        faq['dislikes']++;
      }

      faq['userReaction'] = isLike;
    });
  }

  Future<void> _navigateToRoomList(int hotelId, SearchParams searchParams) async {
    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      final checkOutDate = searchParams.checkInDate.add(
        Duration(hours: searchParams.durationHours),
      );
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: searchParams.checkInDate,
        checkInTime: DateFormat('HH:mm:ss').format(searchParams.checkInDate),
        checkOutDate: checkOutDate,
        checkOutTime: DateFormat('HH:mm:ss').format(checkOutDate),
        state: searchParams.state,
        adultCount: searchParams.adults,
        childrenCount: searchParams.children,
      );

      if (availability.hotelIds.contains(hotelId)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomsListScreen(
              hotelId: hotelId,
              checkInDate: searchParams.checkInDate,
              checkInTime: _formatTimeOfDay(searchParams.checkInTime),
              checkOutDate: checkOutDate,
              checkOutTime:
                  _formatTimeOfDay(TimeOfDay.fromDateTime(checkOutDate)),
              adultCount: searchParams.adults,
              childrenCount: searchParams.children,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No available rooms. Please change values or choose another hotel.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking availability: $e'),
        ),
      );
    } finally {
      setState(() {
        _isCheckingAvailability = false;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();
    if (amenityLower.contains('wifi') || amenityLower.contains('internet')) {
      return Icons.wifi;
    } else if (amenityLower.contains('parking')) {
      return Icons.local_parking;
    } else if (amenityLower.contains('pool')) {
      return Icons.pool;
    } else if (amenityLower.contains('gym') ||
        amenityLower.contains('fitness')) {
      return Icons.fitness_center;
    } else if (amenityLower.contains('restaurant') ||
        amenityLower.contains('dining')) {
      return Icons.restaurant;
    } else if (amenityLower.contains('spa')) {
      return Icons.spa;
    } else if (amenityLower.contains('tv')) {
      return Icons.tv;
    } else if (amenityLower.contains('air') || amenityLower.contains('ac')) {
      return Icons.ac_unit;
    } else if (amenityLower.contains('balcony')) {
      return Icons.balcony;
    } else if (amenityLower.contains('kitchen')) {
      return Icons.kitchen;
    }
    return Icons.check_circle;
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

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (faq['answer'] != null && faq['answer'].isNotEmpty)
                  Text(
                    faq['answer'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    'This question is awaiting an answer from the hotel.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Was this helpful?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _reactToFAQ(index, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              faq['userReaction'] == true
                                  ? AppColors.mainGreen.withOpacity(0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 14,
                              color:
                                  faq['userReaction'] == true
                                      ? AppColors.mainGreen
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${faq['likes']}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    faq['userReaction'] == true
                                        ? AppColors.mainGreen
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _reactToFAQ(index, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              faq['userReaction'] == false
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_down,
                              size: 14,
                              color:
                                  faq['userReaction'] == false
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${faq['dislikes']}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    faq['userReaction'] == false
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context, listen: true);
    final hasBookingDetails =
        bookingState.state.isNotEmpty &&
        bookingState.checkInDate != DateTime.now();

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
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
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
                          const Text(
                            '4.8',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(73 reviews)',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // shrink column height
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
                            IconButton(
                              padding:
                                  EdgeInsets.zero, // remove default padding
                              constraints:
                                  const BoxConstraints(), // remove extra space
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4), // reduce vertical spacing
                        Text(
                          '${widget.hotel.address}, ${widget.hotel.state}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Booking Details Section
                    const SizedBox(height: 16),
                    SearchCardWithData(
                      searchParams: _searchParams,
                      onSearchPressed: (newParams) {
                        setState(() {
                          _searchParams = newParams;
                        });
                        _navigateToRoomList(widget.hotel.id, newParams);
                      },
                    ),
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

                    //const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amenities section
                          // if (allAmenities.isNotEmpty) ...[
                          //   const Text(
                          //     'Available Amenities',
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w600,
                          //       color: Colors.black87,
                          //     ),
                          //   ),
                          //   const SizedBox(height: 12),
                          //   ...allAmenities
                          //       .take(6)
                          //       .map(
                          //         (amenity) => Padding(
                          //           padding: const EdgeInsets.symmetric(
                          //             vertical: 4,
                          //           ),
                          //           child: Row(
                          //             children: [
                          //               Icon(
                          //                 _getAmenityIcon(amenity),
                          //                 size: 20,
                          //                 color: Colors.green[600],
                          //               ),
                          //               const SizedBox(width: 12),
                          //               Text(
                          //                 amenity.trim(),
                          //                 style: const TextStyle(
                          //                   fontSize: 14,
                          //                   color: Colors.black87,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       )
                          //       .toList(),
                          //   const SizedBox(height: 16),
                          //   const Divider(color: Colors.grey),
                          //   const SizedBox(height: 16),
                          // ],

                          // What's included section
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
                      ), // reduced vertical padding
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
                          ), // slightly smaller icon
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize
                                      .min, // ensures column height shrinks to content
                              children: [
                                const Text(
                                  'Special Offer Available!',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 1, 93, 88),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13, // slightly smaller font
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Book now and save up to 20% on your stay',
                                  style: TextStyle(
                                    color: AppColors.buttonColor,
                                    fontSize: 11, // slightly smaller font
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
                        border: Border.all(
                          color: Colors.grey[500]!,
                          width: 2, // border width updated
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.35,
                            ), // shadow color
                            offset: const Offset(
                              1,
                              3,
                            ), // right and bottom shadow
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
                    const Text(
                      'Nearest public facilities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFacilityItem(
                            Icons.local_gas_station,
                            'Petrol station',
                            '3.2km',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFacilityItem(
                            Icons.local_hospital,
                            'Hospital',
                            '1.5km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFacilityItem(
                            Icons.restaurant,
                            'Restaurants',
                            '500m',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFacilityItem(
                            Icons.train,
                            'Train station',
                            '2.1km',
                          ),
                        ),
                      ],
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
                          ? '${widget.hotel.description} Wake up to sweeping ocean views and the gentle rhythm of waves at Seaside Paradise, a peaceful beachfront retreat nestled on the golden shores of Mirissa. Designed with simplicity and comfort in mind, this cozy stay is ideal for couples or solo travelers craving a short, refreshing getaway'
                              'Inside, the space is thoughtfully arranged to maximize comfort and functionality.'
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
                    const SizedBox(height: 350, child: ReviewCarousel()),

                    const SizedBox(height: 16),
                    const Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    //const SizedBox(height: 16),
                    // Container(
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[50],
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey[200]!),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'Ask a Question',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.grey[800],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 12),
                    //       TextField(
                    //         controller: _faqController,
                    //         maxLines: 3,
                    //         decoration: InputDecoration(
                    //           hintText:
                    //               'Type your question about this hotel...',
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //             borderSide: BorderSide(
                    //               color: Colors.grey[300]!,
                    //             ),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //             borderSide: BorderSide(
                    //               color: AppColors.mainGreen,
                    //             ),
                    //           ),
                    //           filled: true,
                    //           fillColor: Colors.white,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 12),
                    //       Align(
                    //         alignment: Alignment.centerRight,
                    //         child: ElevatedButton(
                    //           onPressed: _isSubmittingFAQ ? null : _submitFAQ,
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: AppColors.mainGreen,
                    //             foregroundColor: Colors.white,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //           ),
                    //           child:
                    //               _isSubmittingFAQ
                    //                   ? const SizedBox(
                    //                     width: 16,
                    //                     height: 16,
                    //                     child: CircularProgressIndicator(
                    //                       strokeWidth: 2,
                    //                       valueColor:
                    //                           AlwaysStoppedAnimation<Color>(
                    //                             Colors.white,
                    //                           ),
                    //                     ),
                    //                   )
                    //                   : const Text('Submit Question'),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    // Display dummy FAQs
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // light grey background
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // rounded corners
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ), // optional border
                      ),
                      child: Column(
                        children:
                            dummyFAQs
                                .asMap()
                                .entries
                                .map(
                                  (entry) =>
                                      _buildFAQItem(entry.value, entry.key),
                                )
                                .toList(),
                      ),
                    ),

                    //const SizedBox(height: 32),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder:
                    //                   (_) => RoomCreationScreen(
                    //                     hotelId: widget.hotel.id,
                    //                   ),
                    //             ),
                    //           );
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.blue[600],
                    //           foregroundColor: Colors.white,
                    //           padding: const EdgeInsets.symmetric(vertical: 16),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //         ),
                    //         child: const Text(
                    //           "Add Room",
                    //           style: TextStyle(fontWeight: FontWeight.w600),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: () {
                    //           if (hasBookingDetails) {
                    //             _navigateToRoomList(
                    //               widget.hotel.id,
                    //               bookingState,
                    //             );
                    //           } else {
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               const SnackBar(
                    //                 content: Text(
                    //                   'Please set booking details first',
                    //                 ),
                    //               ),
                    //             );
                    //           }
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: AppColors.mainGreen,
                    //           foregroundColor: Colors.white,
                    //           padding: const EdgeInsets.symmetric(vertical: 16),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //         ),
                    //         child: const Text(
                    //           "Show Rooms",
                    //           style: TextStyle(fontWeight: FontWeight.w600),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 32),
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
                      InkWell(
                        onTap: () {
                          // Open terms & conditions link
                        },
                        child: const Text(
                          '  View Terms & Conditions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () =>
                          hotelRooms.isNotEmpty && !_isCheckingAvailability
                              ? _navigateToRoomList(
                                  widget.hotel.id,
                                  _searchParams,
                                )
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isCheckingAvailability
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'See More Options',
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
