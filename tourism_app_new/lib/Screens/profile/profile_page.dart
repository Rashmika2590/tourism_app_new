import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/Services/utils/user_shared_prefernce.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/user_model.dart';
import 'package:tourism_app_new/routs.dart';

const double kBottomNavBarHeight = 100;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SharedPrefUser.getUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    kBottomNavBarHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Image
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              //_currentUser?.photoURL != null
                              //? NetworkImage(_currentUser!.photoURL!)
                              const AssetImage(
                                    "assets/images/forgot_password.png",
                                  )
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name and Email
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _currentUser?.name ?? "User",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currentUser?.email ?? "No email",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Edit Profile Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.profile_settings,
                            ).then((_) => _loadUserData());
                          },
                          child: const Text(
                            "Edit Profile Details",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Level Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/google_icon.png",
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   "Level ${_getUserLevel(_currentUser?.points ?? 0)} : ${_currentUser?.level ?? 'Explorer'}",
                                  //   style: const TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 6),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 6,
                                        // width: _calculateProgressWidth(
                                        //   _currentUser?.points ?? 0,
                                        // ),
                                        decoration: BoxDecoration(
                                          color: AppColors.buttonColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Text(
                                  //   "${_currentUser?.points ?? 0} points",
                                  //   style: const TextStyle(fontSize: 12),
                                  // ),
                                ],
                              ),
                            ),
                            Column(
                              children: const [
                                Text(
                                  "More Details",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Navigation Items
                      buildMenuItem(
                        context,
                        Icons.book_online,
                        "My Bookings",
                        AppRoutes.user_bookings,
                      ),
                      buildMenuItem(
                        context,
                        Icons.chat,
                        "Chats",
                        AppRoutes.profile_settings,
                      ),
                      buildMenuItem(
                        context,
                        Icons.reviews,
                        "My Reviews",
                        AppRoutes.profile_settings,
                      ),
                      buildMenuItem(
                        context,
                        Icons.favorite_border,
                        "Favorites",
                        AppRoutes.favourites,
                      ),
                      buildMenuItem(
                        context,
                        Icons.settings,
                        "Profile Settings",
                        AppRoutes.profile_settings,
                      ),
                      buildMenuItem(
                        context,
                        Icons.help_outline,
                        "Support",
                        AppRoutes.profile_settings,
                      ),

                      const SizedBox(height: 30),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String routeName,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.textPrimary),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, routeName);
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
