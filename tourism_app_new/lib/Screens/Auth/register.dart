import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/auth_service..dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tourism_app_new/constants/buttons.dart';
import 'package:tourism_app_new/routs.dart';
import 'package:tourism_app_new/widgets/auth_backround.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumber = ValueNotifier<String>('');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() => _isRegistering = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final user = await _authService.registerWithEmailPassword(
        email,
        password,
      );

      setState(() => _isRegistering = false);

      if (user != null) {
        Navigator.pushNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Just a few steps and you're good",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: Icon(Icons.person_outline, size: 36),
                            ),
                            const SizedBox(height: 20),

                            _buildLabeledField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              child: TextFormField(
                                controller: _fullNameController,
                                decoration: _fieldDecoration(
                                  'Enter your full name',
                                ),
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Enter your name'
                                            : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildLabeledField(
                              label: 'Email Address',
                              hint: 'Enter your email',
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration(
                                  'Enter your email',
                                ),
                                validator: _validateEmail,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildLabeledField(
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              child: IntlPhoneField(
                                decoration: _fieldDecoration(
                                  'Enter your phone number',
                                ),
                                initialCountryCode: 'LK',
                                onChanged:
                                    (phone) =>
                                        _phoneNumber.value =
                                            phone.completeNumber,
                              ),
                            ),
                            _buildLabeledField(
                              label: 'Password',
                              hint: 'Enter your password',
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: _fieldDecoration(
                                  'Enter your password',
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        ),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildLabeledField(
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: _fieldDecoration(
                                  'Re-enter your password',
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                        ),
                                  ),
                                ),
                                validator: _validateConfirmPassword,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  activeColor: Colors.orange,
                                  onChanged:
                                      (value) => setState(
                                        () => _agreeToTerms = value ?? false,
                                      ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Terms',
                                          style: TextStyle(
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' & ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Create Account button
                CommonButton(
                  label: 'Create my Account',
                  onPressed: _register,
                  isLoading: _isRegistering,
                  height: 50,
                  fontSize: 16,
                ),

                const SizedBox(height: 16),

                // Already have an account? Sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.0),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        child,
      ],
    );
  }
}
