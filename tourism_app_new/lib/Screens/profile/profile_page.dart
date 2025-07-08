import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/auth_service..dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/routs.dart';

const double kBottomNavBarHeight = 100;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kBottomNavBarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Profile Image
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    "assets/images/forgot_password.png",
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Name and Email
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Amantha Nirmal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "amantha@email.com",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Edit Profile Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile_settings);
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
                          const Text(
                            "Level 3 : Explorer",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Container(
                                height: 6,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "283 points",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: const [
                        Text(
                          "More Details",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
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
                AppRoutes.profile_settings,
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
                AppRoutes.profile_settings,
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
