import 'package:flutter/material.dart';

class ExclusiveAddonsWidget extends StatefulWidget {
  const ExclusiveAddonsWidget({Key? key}) : super(key: key);

  @override
  State<ExclusiveAddonsWidget> createState() => _ExclusiveAddonsWidgetState();
}

class _ExclusiveAddonsWidgetState extends State<ExclusiveAddonsWidget> {
  int? expandedIndex;

  final List<AddOnItem> addOns = [
    AddOnItem(
      icon: Icons.directions_bike,
      title: 'Cycling',
      description:
          'Discover scenic trails at your own pace. Whether you\'re up for a relaxing ride or an adventurous spin, our cycling experience gives you the freedom to explore Galle like a local.',
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1544191696-15693072b5a7?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.flight,
      title: 'Airport Pickup',
      description:
          'Comfortable and reliable airport transfer service. We ensure you reach your destination safely and on time.',
      images: [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1605548371600-7a54b4e89f6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.local_bar,
      title: 'Minibar',
      description:
          'Enjoy premium beverages and snacks from our well-stocked minibar in your room. Our selection includes local and international drinks, gourmet snacks, and refreshing beverages to complement your stay experience.',
      images: [
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1551024709-8f23befc6f87?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1470337458703-46ad1756a187?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.fitness_center,
      title: 'Gym',
      description:
          'State-of-the-art fitness equipment and facilities to maintain your workout routine during your stay.',
      images: [
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.restaurant,
      title: 'Kitchen',
      description:
          'Fully equipped kitchen with modern appliances for your cooking convenience. Features include refrigerator, microwave, stovetop, dishwasher, and all necessary cooking utensils for a complete culinary experience.',
      images: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1565538810643-b5bdb714032a?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.flight,
      title: 'Airport Pickup',
      description:
          'Comfortable and reliable airport transfer service. We ensure you reach your destination safely and on time.',
      images: [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1605548371600-7a54b4e89f6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
    AddOnItem(
      icon: Icons.flight,
      title: 'Airport Pickup',
      description:
          'Comfortable and reliable airport transfer service. We ensure you reach your destination safely and on time.',
      images: [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1605548371600-7a54b4e89f6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      ],
    ),
  ];

  double _calculateDropdownHeight(String description) {
    double baseHeight = 180;
    int estimatedLines = (description.length / 40).ceil();
    double textHeight = estimatedLines * 20.0;
    return baseHeight + textHeight;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    double iconSize = isSmallScreen ? 50 : 60;
    double iconSpacing = isSmallScreen ? 15 : 20;
    double dropdownWidth = isSmallScreen ? 280 : 320;

    double dropdownHeight =
        expandedIndex != null
            ? _calculateDropdownHeight(addOns[expandedIndex!].description)
            : 0;

    return Container(
      height:
          expandedIndex != null
              ? (iconSize + 50 + dropdownHeight)
              : (iconSize + 50),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            SizedBox(
              width: (addOns.length * (iconSize + iconSpacing)) + dropdownWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(addOns.length, (index) {
                      final addOn = addOns[index];
                      final isExpanded = expandedIndex == index;

                      return Container(
                        margin: EdgeInsets.only(right: iconSpacing),
                        width: iconSize,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandedIndex = isExpanded ? null : index;
                                });
                              },
                              child: Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius:
                                      isExpanded
                                          ? BorderRadius.only(
                                            topLeft: Radius.circular(
                                              iconSize / 2,
                                            ),
                                            topRight: Radius.circular(
                                              iconSize / 2,
                                            ),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          )
                                          : BorderRadius.circular(iconSize / 2),
                                ),
                                child: Icon(
                                  addOn.icon,
                                  size: isSmallScreen ? 20 : 24,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Container(
                              width: iconSize,
                              height: 45,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    isExpanded
                                        ? const Color(0xFFE0E0E0)
                                        : Colors.transparent,
                                borderRadius:
                                    isExpanded
                                        ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        )
                                        : null,
                              ),
                              child: Text(
                                addOn.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (expandedIndex != null)
                    Positioned(
                      top: iconSize + 37,
                      left: (expandedIndex! * (iconSize + iconSpacing)),
                      child: Container(
                        width: dropdownWidth,
                        constraints: BoxConstraints(
                          minHeight: 200,
                          maxHeight: dropdownHeight,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              addOns[expandedIndex!].description,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // ✅ Modified Image Row
                            SizedBox(
                              height: isSmallScreen ? 50 : 60,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                    addOns[expandedIndex!].images.map((
                                      imageUrl,
                                    ) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: isSmallScreen ? 60 : 70,
                                        height: isSmallScreen ? 50 : 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[400],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 40 : 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  print(
                                    'Continue to Choose a Room for ${addOns[expandedIndex!].title}',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 20 : 22,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Continue to Choose a Room',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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
          ],
        ),
      ),
    );
  }
}

class AddOnItem {
  final IconData icon;
  final String title;
  final String description;
  final List<String> images;

  AddOnItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.images,
  });
}
