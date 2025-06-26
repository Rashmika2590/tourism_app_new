import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:flutter/cupertino.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        property.propertyImage.primaryImageUrl.isNotEmpty
            ? property.propertyImage.primaryImageUrl
            : 'https://via.placeholder.com/400x200.png?text=No+Image';

    final rating = property.rating.rating.toStringAsFixed(1);
    final reviewCount = "(104)"; // You can make this dynamic if needed
    final address = '${property.address.street}, ${property.address.city}';
    final rooms =
        property.guestCapacities.isNotEmpty
            ? property.guestCapacities.first.maxGuests
            : 1;
    final area = "488 m²"; // Placeholder — can be dynamic if you have data
    final price =
        property.packages.isNotEmpty
            ? property.packages.first.packagePriceDetail.basePrice
            : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: Image.network(
                imageUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 140,
                      height: 140,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          "$rating ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          reviewCount,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      property.propertyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Address
                    Text(
                      address,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Room + Area
                    Row(
                      children: [
                        const Icon(
                          Icons.king_bed_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rooms room',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.apartment,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(area, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LKR$price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          '/day',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
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
