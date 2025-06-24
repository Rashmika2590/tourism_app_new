import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/Auth/auth_service..dart';
import 'package:tourism_app_new/Screens/Auth/register.dart';
import 'package:tourism_app_new/Screens/home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _keepMeSignedIn = false;

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be 6+ characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final user = await _authService.loginWithEmailPassword(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed")));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background_leaf.jpg', fit: BoxFit.cover),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.125),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: screenHeight * 0.037,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Let's get you signed in",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              _buildLabeledField(
                                label: 'Email Address',
                                child: TextFormField(
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: Colors.black),
                                  decoration: _inputDecoration(
                                    'Enter your email',
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildLabeledField(
                                label: 'Password',
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: _validatePassword,
                                  style: TextStyle(color: Colors.black),
                                  decoration: _inputDecoration(
                                    'Enter your password',
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Forgot password logic
                                  },
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      color: Color.fromRGBO(0, 100, 255, 1),
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: screenHeight * 0.065,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child:
                                      _isLoading
                                          ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenHeight * 0.02,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Keep me signed in",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Checkbox(
                                    value: _keepMeSignedIn,
                                    onChanged: (value) {
                                      setState(
                                        () => _keepMeSignedIn = value ?? false,
                                      );
                                    },
                                    activeColor: Colors.orange,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.black45),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.black45),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              SizedBox(
                                width: double.infinity,
                                height: screenHeight * 0.06,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Google sign-in logic
                                  },
                                  icon: Image.asset(
                                    'assets/images/google_icon.png',
                                    height: screenHeight * 0.03,
                                  ),
                                  label: Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.018,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.black),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
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
}
