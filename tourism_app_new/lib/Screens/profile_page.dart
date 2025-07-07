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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, kBottomNavBarHeight),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/forgot_password.png"),
            ),
            const SizedBox(height: 10),
            const Text(
              "Amantha Nirmal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "amantha@email.com",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Edit Profile Details",
                style: TextStyle(color: Colors.blue),
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

            buildMenuItem(Icons.book_online, "My Bookings"),
            buildMenuItem(Icons.chat, "Chats"),
            buildMenuItem(Icons.reviews, "My Reviews"),
            buildMenuItem(Icons.favorite_border, "Favorites"),
            buildMenuItem(Icons.settings, "Profile Settings"),
            buildMenuItem(Icons.help_outline, "Support"),

            const SizedBox(height: 30),

            // 🔴 Logout Button with same behavior as HomePage
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
    );
  }

  Widget buildMenuItem(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.textPrimary),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
