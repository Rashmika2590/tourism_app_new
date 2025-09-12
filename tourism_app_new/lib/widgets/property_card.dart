import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/favourites_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';

class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onTap;
  final String? tag; // e.g., "Available", "Short Stay"

  const HotelCard({Key? key, required this.hotel, this.onTap, this.tag})
    : super(key: key);

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  double? lowestRoomPrice;
  bool isLoadingPrice = true;

  // Favourite state
  bool isFavourite = false;
  int? favouriteId; // backend favourite id

  // Dummy review data (replace with backend integration later)
  final double reviewRating = 4.8;
  final int reviewCount = 73;

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

  Future<void> _toggleFavourite() async {
    try {
      if (isFavourite && favouriteId != null) {
        // Remove favourite
        final success = await FavouriteApiService.removeFavourite(favouriteId!);
        if (success) {
          setState(() {
            isFavourite = false;
            favouriteId = null;
          });
        }
      } else {
        const userId = "5F7pFXlyQcfTWJp69hOTU5bSrph1"; // replace with real user
        final response = await FavouriteApiService.addFavourite(
          userId: userId,
          hotelId: widget.hotel.id,
        );

        setState(() {
          isFavourite = true;
          favouriteId = response["id"];
        });
      }
    } catch (e) {
      final error = e.toString();
      if (error.contains("Already marked as favourite")) {
        setState(() {
          isFavourite = true;
        });
      } else {
        print("Favourite toggle error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [
                Color(0xFF1E3A8A), // Dark blue
                Color(0xFF3B82F6), // Lighter blue
              ],
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
                                  //fontWeight: FontWeight.bold,
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    '$reviewRating ($reviewCount)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Price info
                              // Price + /hour in one line
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

                    // Top-left favorite icon
                    Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: _toggleFavourite,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppColors.accent,
                            size: 24,
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
      ),
    );
  }
}
