import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app_new/constants/buttons.dart';
import 'package:tourism_app_new/constants/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSending = false;
  bool _linkSent = false;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() => _linkSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Something went wrong")),
      );
    }

    setState(() => _isSending = false);
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/forgot_password.png', fit: BoxFit.cover),
          Center(
            // Center entire scroll view vertically
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically inside column
                children: [
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: screenHeight * 0.032,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "We'll send you a reset link.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenHeight * 0.018,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: screenWidth * 0.9,
                          // Set a min height or fixed height to increase size
                          constraints: BoxConstraints(
                            minHeight: screenHeight * 0.45, // Increased height
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.04,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLabeledField(
                                  label: 'Email Address',
                                  child: TextFormField(
                                    controller: _emailController,
                                    validator: _validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _inputDecoration(
                                      'Enter your email',
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                CommonButton(
                                  label: 'Send Reset Link',
                                  onPressed: _sendResetLink,
                                  isLoading: _isSending,
                                  height: screenHeight * 0.06,
                                  fontSize: screenHeight * 0.02,
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                if (_linkSent) ...[
                                  SizedBox(height: screenHeight * 0.015),
                                  Center(
                                    child: TextButton(
                                      onPressed:
                                          _isSending ? null : _sendResetLink,
                                      child: const Text(
                                        "Didn't get it? Resend",
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    "Make sure to check your spam folder.",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Outside blurred container, remember text
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: "Remembered it? ",
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Log in",
                              style: const TextStyle(
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " instead"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.0),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
