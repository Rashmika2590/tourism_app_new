import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app_new/Screens/Auth/auth_service..dart';
import 'package:tourism_app_new/Screens/Auth/login.dart';
import 'package:tourism_app_new/Screens/searching_page.dart';
import 'package:tourism_app_new/core/utils/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

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

  @override
  Widget build(BuildContext context) {
    final displayName =
        _user?.email ??
        (_user?.isAnonymous ?? false ? "Anonymous User" : "Unknown");

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
      body: Padding(
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
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: const Text("Search Properties by City"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
