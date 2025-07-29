import 'package:flutter/material.dart';
import 'package:tourism_app_new/widgets/activity_row.dart';
import 'package:tourism_app_new/widgets/expandable_map_widget.dart';
import 'package:tourism_app_new/widgets/post_searching_dropdowns.dart';
import 'package:tourism_app_new/widgets/reviewCard.dart';

class PropertyDetailsPage extends StatefulWidget {
  @override
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMapSize() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _heightAnimation,
                  builder: (context, child) {
                    return Container(
                      height: constraints.maxHeight * _heightAnimation.value,
                      child: ExpandableMapWidget(
                        isExpanded: _isExpanded,
                        onToggle: _toggleMapSize,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                // The rest of the scrollable content
                MainSearchCard(),
                ExclusiveAddonsWidget(),
                ReviewCarousel(),
              ],
            ),
          );
        },
      ),
    );
  }
}
