import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Services/Providers/favourite_provider.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/favourite_widget.dart';

class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onTap;
  final String? tag;

  const HotelCard({Key? key, required this.hotel, this.onTap, this.tag})
    : super(key: key);

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  double? lowestRoomPrice;
  bool isLoadingPrice = true;

  @override
  void initState() {
    super.initState();
    _fetchLowestRoomPrice();
  }

  Future<void> _fetchLowestRoomPrice() async {
    try {
      final rooms = await RoomApiService.getRoomsByHotelId(widget.hotel.id);

      if (rooms.isNotEmpty) {
        double minPrice = rooms.first.price;
        for (final room in rooms) {
          if (room.price < minPrice) {
            minPrice = room.price;
          }
        }
        setState(() {
          lowestRoomPrice = minPrice;
          isLoadingPrice = false;
        });
      } else {
        setState(() {
          lowestRoomPrice = null;
          isLoadingPrice = false;
        });
      }
    } catch (e) {
      print('Error fetching room prices: $e');
      setState(() {
        lowestRoomPrice = null;
        isLoadingPrice = false;
      });
    }
  }

  // Helper method to format rating display
  String _getRatingDisplay() {
    final rating =
        widget
            .hotel
            .rating; // This uses the getter that prioritizes averageRating
    final totalReviews = widget.hotel.totalReviews;

    if (rating == null || rating == 0.0) {
      return 'No ratings';
    }

    // Format the rating to 1 decimal place if needed
    final formattedRating =
        rating % 1 == 0 ? rating.toInt().toString() : rating.toStringAsFixed(1);

    if (totalReviews == 0) {
      return formattedRating;
    }

    return '$formattedRating ($totalReviews)';
  }

  // Helper method to get rating color based on value
  Color _getRatingColor() {
    final rating = widget.hotel.rating ?? 0;

    if (rating >= 4.5) return Colors.amber;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.amber;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    print('=== Hotel Data Debug ===');
    print('Hotel: ${widget.hotel.name}');
    print('Rating: ${widget.hotel.rating}');
    print('Average Rating: ${widget.hotel.averageRating}');
    //print('Review Rating: ${widget.hotel.reviewRating}');
    print('Total Reviews: ${widget.hotel.totalReviews}');
    print('========================');
    final hasRatings = widget.hotel.rating != null && widget.hotel.rating! > 0;
    final ratingDisplay = _getRatingDisplay();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
          ),
          child: Stack(
            children: [
              // Background image with overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  child:
                      widget.hotel.images.isNotEmpty
                          ? Stack(
                            children: [
                              Image.network(
                                widget.hotel.images.first,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF1E3A8A),
                                          Color(0xFF3B82F6),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              ),
                            ),
                          ),
                ),
              ),

              // Content overlay
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Stack(
                  children: [
                    // Right-aligned hotel details + price
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.hotel.name,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 5, 230, 208),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'in   ${widget.hotel.state}',
                                style: TextStyle(
                                  color: AppColors.mainGreen,
                                  fontSize: 18,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Rating Section - Updated with real data
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color:
                                        hasRatings
                                            ? _getRatingColor()
                                            : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ratingDisplay,
                                    style: TextStyle(
                                      color:
                                          hasRatings
                                              ? Colors.white
                                              : Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),

                              // Price info
                              isLoadingPrice
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : lowestRoomPrice != null
                                  ? Row(
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
                                                  '${lowestRoomPrice!.toStringAsFixed(0)}',
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
                                        '/ hour',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'Price N/A',
                                    style: TextStyle(
                                      color: Colors.orange[300],
                                      fontSize: 14,
                                    ),
                                  ),
                              const SizedBox(height: 2),
                              Text(
                                '(all inclusive)',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Top-left favorite icon - Using Consumer for automatic updates
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Consumer<FavouriteService>(
                        builder: (context, favouriteService, child) {
                          // Check if this hotel is in favourites
                          favouriteService.isFavourite(widget.hotel.id);
                          return FavouriteIcon(
                            hotelId: widget.hotel.id,
                            size: 25,
                          );
                        },
                      ),
                    ),

                    // Optional: Show "New" badge if no reviews yet
                    // if (!hasRatings)
                    //   Positioned(
                    //     top: 0,
                    //     right: 0,
                    //     child: Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 8,
                    //         vertical: 4,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: Colors.blue.withOpacity(0.8),
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: const Text(
                    //         'New',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 10,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
