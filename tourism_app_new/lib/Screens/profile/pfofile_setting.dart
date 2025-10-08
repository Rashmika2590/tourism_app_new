import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/Services/utils/user_shared_prefernce.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/user_model.dart';
import 'package:tourism_app_new/routs.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool pushNotifications = false;
  bool emailAlerts = false;

  String selectedLanguage = '🇱🇰';
  String selectedCurrency = '🇱🇰';

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
        _fullNameController = TextEditingController(text: user?.name ?? "User");
        _emailController = TextEditingController(
          text: user?.email ?? "No email",
        );
        _phoneController = TextEditingController(
          text: user?.phone ?? "+94 77 123 4567",
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      await SharedPrefUser.saveUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      const AssetImage("assets/images/forgot_password.png")
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.name ?? "User",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? "No email",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            _sectionHeader("Edit Personal Info"),
            _buildInputField("Full Name", _fullNameController, Icons.person),
            _buildInputField(
              "Email address",
              _emailController,
              Icons.email,
              enabled: false,
            ),
            _buildInputField("Phone number", _phoneController, Icons.phone),

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
              _buildDebugTile(
                Icons.info,
                "User Info",
                "UID: ${_currentUser?.uid ?? 'N/A'}",
                () => _showUserInfo(),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
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
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade300,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
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
              activeColor: Colors.white,
              activeTrackColor: AppColors.buttonColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.mainGreen.withOpacity(0.3),
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

  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('UID: ${_currentUser?.uid ?? 'N/A'}'),
                Text('Email: ${_currentUser?.email ?? 'N/A'}'),
                Text('Name: ${_currentUser?.name ?? 'N/A'}'),
                Text('Phone: ${_currentUser?.phone ?? 'N/A'}'),
                //Text('Points: ${_currentUser?.points ?? 0}'),
                //Text('Level: ${_currentUser?.level ?? 'N/A'}'),
                //if (_currentUser?.photoURL != null)
                //Text('Photo URL: ${_currentUser!.photoURL}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
