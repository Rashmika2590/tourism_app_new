import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _fullNameController = TextEditingController(text: "Amantha Nirmal");
  final _emailController = TextEditingController(text: "amantha@email.com");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");

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
            _buildTile(Icons.lock_outline, "Change Password"),
            _buildTile(Icons.history, "Activity log"),

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
            _buildTile(Icons.help_outline, "FAQ"),
            _buildTile(Icons.support_agent, "Contact Support"),
            _buildTile(Icons.description_outlined, "Terms & Conditions"),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add logic
                },
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

  Widget _buildTile(IconData icon, String title) {
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

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.orange.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            secondary: Icon(icon, color: AppColors.textPrimary),
            title: Text(title),
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.buttonColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
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
}
