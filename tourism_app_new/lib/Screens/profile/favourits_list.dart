import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';
import 'package:tourism_app_new/Services/Providers/favourite_provider.dart';
import 'package:tourism_app_new/constants/colors.dart';

const double kBottomNavBarHeight = 100;

class FavouriteHotelsPage extends StatefulWidget {
  const FavouriteHotelsPage({super.key});

  @override
  State<FavouriteHotelsPage> createState() => _FavouriteHotelsPageState();
}

class _FavouriteHotelsPageState extends State<FavouriteHotelsPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<FavouriteService>(
        context,
        listen: false,
      ).loadUserFavourites();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load favourites: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Favourites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavourites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : Consumer<FavouriteService>(
                builder: (context, favouriteService, child) {
                  final favourites = favouriteService.favouriteHotels;

                  if (favourites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _loadFavourites,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        kBottomNavBarHeight,
                      ),
                      itemCount: favourites.length,
                      itemBuilder: (context, index) {
                        return _buildHotelCard(favourites[index]);
                      },
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to hotel details
          // Navigator.pushNamed(
          //   context,
          //   AppRoutes.hoteldetails,
          //   arguments: hotel,
          // );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            // Stack(
            //   children: [
            //     ClipRRect(
            //       borderRadius: const BorderRadius.vertical(
            //         top: Radius.circular(16),
            //       ),
            //       child:
            //           hotel.imageUrls.isNotEmpty
            //               ? Image.network(
            //                 hotel.imageUrls.first,
            //                 height: 200,
            //                 width: double.infinity,
            //                 fit: BoxFit.cover,
            //                 errorBuilder: (context, error, stackTrace) {
            //                   return _buildPlaceholderImage();
            //                 },
            //               )
            //               : _buildPlaceholderImage(),
            //     ),
            //     // Favourite Button
            //     Positioned(
            //       top: 12,
            //       right: 12,
            //       child: CircleAvatar(
            //         backgroundColor: Colors.white,
            //         radius: 20,
            //         child: IconButton(
            //           icon: const Icon(
            //             Icons.favorite,
            //             color: Colors.red,
            //             size: 20,
            //           ),
            //           onPressed: () => _showRemoveDialog(hotel),
            //           padding: EdgeInsets.zero,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            // Hotel Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.address}, ${hotel.state}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (hotel.description.isNotEmpty)
                    Text(
                      hotel.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Stay Types
                  Row(
                    children: [
                      if (hotel.enableShortStay)
                        _buildStayTypeChip('Short Stay', Colors.blue),
                      if (hotel.enableShortStay && hotel.enableLongStay)
                        const SizedBox(width: 8),
                      if (hotel.enableLongStay)
                        _buildStayTypeChip('Long Stay', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayTypeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Favourites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding hotels to your favourites\nto see them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Explore Hotels',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadFavourites,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
