import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app_new/Screens/Auth/auth_service..dart';
import 'package:tourism_app_new/Screens/Auth/login.dart';
import 'package:tourism_app_new/Screens/google_map.dart';
import 'package:tourism_app_new/Screens/searching_page.dart';
import 'package:tourism_app_new/core/utils/shared_preferences.dart';
import 'package:tourism_app_new/widgets/bottom_navbar.dart';

// Import your custom navigation bar
// import 'path_to_your_animated_bottom_nav_bar.dart'; // Add this import

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

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the 3 pages you want to show for each tab:
    final pages = <Widget>[
      _buildUserInfo(),
      const SearchPage(),
      GoogleMapScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      // Replace the default BottomNavigationBar with your custom one
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
      ),

      // OLD CODE - Remove this:
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onNavBarTapped,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      //     BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
      //   ],
      // ),
    );
  }
}
