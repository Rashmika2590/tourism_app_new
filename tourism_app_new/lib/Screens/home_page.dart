import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app_new/Screens/profile/profile_page.dart';
import 'package:tourism_app_new/Screens/testing/Availability/availability_search_screen.dart';
import 'package:tourism_app_new/Screens/testing/hotel_create.dart';
import 'package:tourism_app_new/Screens/testing/hotel_search_page.dart';
import 'package:tourism_app_new/Services/utils/shared_preferences.dart';
import 'package:tourism_app_new/widgets/bottom_navbar.dart';

const double kBottomNavBarHeight = 100;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTokenAndUser();
  }

  Future<void> _loadTokenAndUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildUserInfo() {
    final displayName =
        _user?.email ??
        (_user?.isAnonymous ?? false ? "Anonymous User" : "Unknown");

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, kBottomNavBarHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Login Successful!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text('👤 User: $displayName'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final token = await SharedPreferecesUtil.getToken();
              print(token);
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Saved Token'),
                      content: SelectableText(token ?? 'No token found'),
                    ),
              );
            },
            child: const Text("Test Get Firebase Token"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      RoomAvailabilityScreen(),
      const HotelSearchScreen(),
      HotelCreationScreen(), // no const here
      const ProfilePage(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, // 👈 Required to allow body to extend behind bottom bar
      body: Stack(
        children: [
          // Page content
          Positioned.fill(child: pages[_selectedIndex]),

          // Floating Bottom NavBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBottomNavBar(
              currentIndex: _selectedIndex,
              onTap: _onNavBarTapped,
            ),
          ),
        ],
      ),
    );
  }
}
