import 'package:flutter/material.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedBottomNavBarState createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  static const double selectedIconSize = 28;
  static const double unselectedIconSize = 24;
  static const Duration animationDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Color(0xFF0D2951), // Even darker blue to ensure visibility
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final bool isSelected = index == widget.currentIndex;

          // Icons for the 3 items - matching the reference image
          final icons = [
            Icons.access_time_rounded, // Clock icon
            Icons.home_rounded, // Home icon
            Icons.menu_rounded, // Menu icon
          ];

          // Labels for the 3 items
          final labels = ['Time', 'Home', 'Menu'];

          return GestureDetector(
            onTap: () {
              widget.onTap(index);
            },
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border:
                    isSelected
                        ? Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        )
                        : null,
              ),
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                child: Icon(
                  icons[index],
                  color:
                      isSelected
                          ? Color(0xFF1B3A6B) // Dark blue for selected
                          : Colors.white, // White for unselected
                  size: isSelected ? selectedIconSize : unselectedIconSize,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
