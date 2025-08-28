import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/routs.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _fullNameController = TextEditingController(text: "Amantha Nirmal");
  final _emailController = TextEditingController(text: "amantha@email.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");
  final AuthService _authService = AuthService();

  bool pushNotifications = false;
  bool emailAlerts = false;

  String selectedLanguage = '🇱🇰';
  String selectedCurrency = '🇱🇰';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile Settings",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    "assets/images/forgot_password.png",
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Amantha Nirmal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "amantha@email.com",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            _sectionHeader("Edit Personal Info"),
            _buildInputField("Full Name", _fullNameController),
            _buildInputField("Email address", _emailController),
            _buildInputField("Phone number", _phoneController),

            const SizedBox(height: 30),
            _sectionHeader("Security Settings"),
            _buildTile(Icons.lock_outline, "Change Password", () {
              // TODO: Navigate to change password
            }),
            _buildTile(Icons.history, "Activity log", () {
              // TODO: Navigate to activity log
            }),

            const SizedBox(height: 30),
            _sectionHeader("Notifications"),
            _buildSwitchTile(
              Icons.notifications,
              "Push Notifications",
              pushNotifications,
              (val) {
                setState(() => pushNotifications = val);
              },
            ),
            _buildSwitchTile(
              Icons.email_outlined,
              "Email Alerts",
              emailAlerts,
              (val) {
                setState(() => emailAlerts = val);
              },
            ),

            const SizedBox(height: 30),
            _sectionHeader("App Preferences"),
            _buildDropdownTile(
              Icons.language,
              "Change Language",
              selectedLanguage,
              (val) {
                setState(() => selectedLanguage = val!);
              },
            ),
            _buildDropdownTile(
              Icons.attach_money,
              "Change Currency",
              selectedCurrency,
              (val) {
                setState(() => selectedCurrency = val!);
              },
            ),

            const SizedBox(height: 30),
            _sectionHeader("Help & Support"),
            _buildTile(Icons.help_outline, "FAQ", () {
              // TODO: Navigate to FAQ
            }),
            _buildTile(Icons.support_agent, "Contact Support", () {
              // TODO: Navigate to contact support
            }),
            _buildTile(Icons.description_outlined, "Terms & Conditions", () {
              // TODO: Navigate to terms
            }),

            // Debug Section - Only visible in development
            if (kDebugMode) ...[
              const SizedBox(height: 30),
              _sectionHeader("Developer Tools"),
              _buildDebugTile(
                Icons.bug_report,
                "Debug User Status",
                "View authentication state",
                () {
                  Navigator.pushNamed(context, AppRoutes.debug);
                },
              ),
              _buildDebugTile(
                Icons.refresh,
                "Reset User Data",
                "Clear all stored data",
                () => _showResetConfirmation(),
              ),
            ],

            const SizedBox(height: 30),
            _sectionHeader("Account Actions"),

            // Logout Button
            _buildActionTile(
              Icons.logout,
              "Logout",
              "Sign out of your account",
              Colors.orange,
              () => _showLogoutConfirmation(),
            ),

            const SizedBox(height: 12),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showDeleteAccountConfirmation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Delete my Account",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1, height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.textPrimary),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildDebugTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.orange),
          title: Text(title, style: const TextStyle(color: Colors.orange)),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'DEV',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white, // Thumb when ON
              activeTrackColor: AppColors.buttonColor, // Track when ON
              inactiveThumbColor: Colors.white, // Thumb when OFF
              inactiveTrackColor: AppColors.mainGreen.withOpacity(
                0.3,
              ), // Track when OFF
              splashRadius: 60,
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildDropdownTile(
    IconData icon,
    String title,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.textPrimary),
          title: Text(title),
          trailing: DropdownButton<String>(
            value: selectedValue,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: '🇱🇰', child: Text('🇱🇰')),
              DropdownMenuItem(value: '🇺🇸', child: Text('🇺🇸')),
              DropdownMenuItem(value: '🇮🇳', child: Text('🇮🇳')),
            ],
            onChanged: onChanged,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  // Reset data confirmation dialog (debug only)
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset User Data'),
          content: const Text(
            'This will clear all stored user data and logout. This action is for debugging purposes only.\n\nAre you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetUserData();
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete account confirmation dialog
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.\n\nAre you sure you want to delete your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion feature coming soon'),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Logout functionality
  Future<void> _logout() async {
    try {
      await _authService.signOut(clearKeepSignedIn: true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  // Reset user data (debug only)
  Future<void> _resetUserData() async {
    try {
      await _authService.signOut(clearKeepSignedIn: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data reset successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reset failed: $e')));
    }
  }
}
