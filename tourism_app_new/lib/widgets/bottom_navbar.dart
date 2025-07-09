import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar> {
  final List<IconData> icons = [
    Icons.access_time_rounded,
    Icons.home_rounded,
    Icons.menu_rounded,
  ];

  static const double navBarHeight = 70;
  static const double bubbleSize = 60;
  static const double cutoutRadius = bubbleSize / 2 + 15;
  static const double iconSize = 37;
  static const double iconSizeUnselected = 35;
  static const double gapBetweenBubbleAndBar = 15;
  static const double horizontalPadding = 10;
  static const double bubbleVerticalOffset = 5;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - (horizontalPadding * 2);
    final itemWidth = width / icons.length;

    final bubbleCenterX =
        horizontalPadding +
        itemWidth * widget.currentIndex +
        (itemWidth - bubbleSize) / 2;

    return SizedBox(
      height: navBarHeight + bubbleSize + bubbleVerticalOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav bar with cutout
          Positioned(
            bottom: bubbleVerticalOffset + 15,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      0,
                      52,
                      45,
                    ).withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(5, 10),
                  ),
                ],
              ),
              child: PhysicalModel(
                elevation: 20,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(35),
                shadowColor: Colors.black.withOpacity(0.8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: CustomPaint(
                    painter: NavBarPainter(
                      bubbleCenterX:
                          itemWidth * widget.currentIndex + itemWidth / 2,
                      radius: cutoutRadius,
                      gap: gapBetweenBubbleAndBar,
                      gradient: AppGradients.primaryGradient,
                    ),
                    child: SizedBox(
                      height: navBarHeight,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(icons.length, (index) {
                          final isSelected = index == widget.currentIndex;
                          return GestureDetector(
                            onTap: () => widget.onTap(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isSelected)
                                  Icon(
                                    icons[index],
                                    size: iconSizeUnselected,
                                    color: Colors.white,
                                  )
                                else
                                  SizedBox(height: iconSizeUnselected),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating bubble inside cutout — perfectly aligned
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: bubbleCenterX,
            bottom: navBarHeight - cutoutRadius + bubbleVerticalOffset + 15,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey<int>(widget.currentIndex),
                height: bubbleSize,
                width: bubbleSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ).withOpacity(0.5),
                      blurRadius: 7,
                      offset: Offset(3, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icons[widget.currentIndex],
                    size: iconSize,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double bubbleCenterX;
  final double radius;
  final double gap;
  final Gradient gradient;

  NavBarPainter({
    required this.bubbleCenterX,
    required this.radius,
    required this.gap,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          )
          ..style = PaintingStyle.fill;

    final barTop = 0.0;
    final barBottom = size.height;

    path.moveTo(0, barTop);
    path.lineTo(bubbleCenterX - radius - 20, barTop);

    path.quadraticBezierTo(
      bubbleCenterX - radius,
      barTop,
      bubbleCenterX - radius,
      gap,
    );

    path.arcToPoint(
      Offset(bubbleCenterX + radius, gap),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      bubbleCenterX + radius,
      barTop,
      bubbleCenterX + radius + 20,
      barTop,
    );

    path.lineTo(size.width, barTop);
    path.lineTo(size.width, barBottom);
    path.lineTo(0, barBottom);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NavBarPainter oldDelegate) =>
      oldDelegate.bubbleCenterX != bubbleCenterX ||
      oldDelegate.radius != radius ||
      oldDelegate.gap != gap;
}
