// widgets/sort_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/widgets/sorting_options.dart';

class SortBottomSheet extends StatefulWidget {
  final SortOption currentSortOption;

  const SortBottomSheet({super.key, required this.currentSortOption});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late SortOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Sort Options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: SortOption.values.length,
              itemBuilder: (context, index) {
                final option = SortOption.values[index];
                final isSelected = _selectedOption == option;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: Text(
                    option.displayName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.mainGreen : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    option.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check_circle, color: AppColors.mainGreen)
                          : Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey.shade400,
                          ),
                  leading: _getSortIcon(option, isSelected),
                  onTap: () {
                    setState(() {
                      _selectedOption = option;
                    });
                    // Slight delay for visual feedback
                    Future.delayed(const Duration(milliseconds: 150), () {
                      Navigator.pop(context, _selectedOption);
                    });
                  },
                );
              },
            ),
          ),

          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _getSortIcon(SortOption option, bool isSelected) {
    IconData iconData;
    Color iconColor = isSelected ? AppColors.mainGreen : Colors.grey.shade600;

    switch (option) {
      case SortOption.recommended:
        iconData = Icons.stars;
        break;
      case SortOption.priceLowToHigh:
        iconData = Icons.arrow_upward;
        break;
      case SortOption.priceHighToLow:
        iconData = Icons.arrow_downward;
        break;
      case SortOption.ratingHighToLow:
        iconData = Icons.star;
        break;
      case SortOption.nameAZ:
        iconData = Icons.sort_by_alpha;
        break;
      case SortOption.distanceNearToFar:
        iconData = Icons.near_me;
        break;
      case SortOption.popularityHighToLow:
        iconData = Icons.trending_up;
        break;
      case SortOption.newest:
        iconData = Icons.new_releases;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.mainGreen.withOpacity(0.1)
                : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
}
