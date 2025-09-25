import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Services/Api%20Services/favourites_api_service.dart';
import 'package:tourism_app_new/models/search_params_model.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_creation.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/faq_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/FAQ_widget.dart';
import 'package:tourism_app_new/widgets/activity_row.dart';
import 'package:tourism_app_new/widgets/check_availability_card.dart';
import 'package:tourism_app_new/widgets/post_searching_dropdowns.dart';
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
  bool isLoadingFAQs = true;
  Room? cheapestRoom;
  Set<String> allAmenities = {};
  bool isUpdatingFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.hotel.isFavourite;
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
    _loadHotelRooms();
  }

  @override
  void dispose() {
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

  Future<void> _toggleFavorite() async {
    if (isUpdatingFavorite) return;

    setState(() {
      isUpdatingFavorite = true;
    });

    try {
      if (isFavorite) {
        // Remove from favorites - this would require the favourite ID
        // For now, we'll assume the API handles this by user_id and hotel_id
        await FavouriteApiService.removeFavourite(widget.hotel.id);
      } else {
        // Add to favorites - you'll need to get the current user ID
        await FavouriteApiService.addFavourite(
          userId: "current_user_id", // Replace with actual user ID
          hotelId: widget.hotel.id,
        );
      }

      setState(() {
        isFavorite = !isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isUpdatingFavorite = false;
      });
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
              hotelId: hotelId,
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
                  icon:
                      isUpdatingFavorite
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          )
                          : Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                  onPressed: isUpdatingFavorite ? null : _toggleFavorite,
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
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon:
                                  isUpdatingFavorite
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.grey,
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isFavorite
                                                ? Colors.red
                                                : Colors.black,
                                      ),
                              onPressed:
                                  isUpdatingFavorite ? null : _toggleFavorite,
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

                    // Hotel Rules Section (if any)
                    // if (widget.hotel.rules.isNotEmpty) ...[
                    //   const SizedBox(height: 16),
                    //   Container(
                    //     padding: const EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       color: Colors.orange[50],
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(color: Colors.orange[200]!),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Icon(
                    //               Icons.rule,
                    //               color: Colors.orange[700],
                    //               size: 20,
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Text(
                    //               'Hotel Rules',
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.orange[700],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         const SizedBox(height: 12),
                    //         ...widget.hotel.rules
                    //             .map(
                    //               (rule) => Padding(
                    //                 padding: const EdgeInsets.only(bottom: 8),
                    //                 child: Row(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Container(
                    //                       margin: const EdgeInsets.only(top: 6),
                    //                       width: 4,
                    //                       height: 4,
                    //                       decoration: BoxDecoration(
                    //                         color: Colors.orange[700],
                    //                         shape: BoxShape.circle,
                    //                       ),
                    //                     ),
                    //                     const SizedBox(width: 12),
                    //                     Expanded(
                    //                       child: Text(
                    //                         rule,
                    //                         style: TextStyle(
                    //                           fontSize: 14,
                    //                           color: Colors.orange[800],
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             )
                    //             .toList(),
                    //       ],
                    //     ),
                    //   ),
                    // ],

                    // Booking Details Section
                    const SizedBox(height: 16),
                    EnhancedCheckAvailabilityCard(
                      hotelId: widget.hotel.id,
                      hotelState: widget.hotel.state,
                      initialSearchParams: _searchParams,
                      onAvailabilityConfirmed: (newParams) {
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Container(
                      height: 400,
                      child: FAQWidget(hotelId: widget.hotel.id),
                    ),
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
                      widget.hotel != null
                          ? TermsConditionsWidget.buildTermsButton(
                            context: context,
                            terms: widget.hotel!.terms,
                            text: "Terms & Conditions Apply",
                          )
                          : GestureDetector(
                            onTap: () {
                              // Fallback for when hotel is null
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

                  // Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          () =>
                              hotelRooms.isNotEmpty
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
                      child: const Text(
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
