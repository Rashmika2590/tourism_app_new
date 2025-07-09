import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/property_model.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final imageUrl =
        property.propertyImage.primaryImageUrl.isNotEmpty
            ? property.propertyImage.primaryImageUrl
            : null;

    final rating = property.rating.rating.toStringAsFixed(1);
    final reviewCount = "(104)";
    final address = '${property.address.street}, ${property.address.city}';
    final rooms =
        property.guestCapacities.isNotEmpty
            ? property.guestCapacities.first.maxGuests
            : 1;
    final area = "488 m²";
    final price =
        property.packages.isNotEmpty
            ? property.packages.first.packagePriceDetail.basePrice
            : 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image:
                      imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage(
                                'assets/images/background_leaf.jpg',
                              )
                              as ImageProvider,
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ✅ Blurred bottom right content
                  Positioned(
                    bottom: 12,
                    right: 12,
                    top: 12,
                    child: SizedBox(
                      width: cardWidth * 0.65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.mainGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Rating + Favorite Icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "$rating ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          reviewCount,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 25,
                                        color:
                                            isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Property Name
                                Text(
                                  property.propertyName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mainGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Address
                                Text(
                                  address,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),

                                // Room + Area
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.king_bed_outlined,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$rooms room',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.apartment,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      area,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Price
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'LKR$price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.buttonColor,
                                      ),
                                    ),
                                    const Text(
                                      '/day',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
