import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Authentication/auth_service..dart';
import 'package:tourism_app_new/Services/Authentication/trac_registration_status.dart';

class DebugUserStatusScreen extends StatefulWidget {
  @override
  _DebugUserStatusScreenState createState() => _DebugUserStatusScreenState();
}

class _DebugUserStatusScreenState extends State<DebugUserStatusScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _authService.getUserAuthStatus();
      setState(() {
        _userStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading status: $e')));
    }
  }

  Future<void> _resetUserData() async {
    await UserStateManager.clearUserData();
    await _authService.signOut(clearKeepSignedIn: true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('User data reset successfully')));
    _loadUserStatus();
  }

  Future<void> _simulateFirstTimeUser() async {
    await UserStateManager.clearUserData();
    // Don't clear the first time user flag to simulate a truly new user
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Simulated first-time user state')));
    _loadUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Status Debug'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadUserStatus),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current User Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            if (_userStatus != null) ...[
                              _buildStatusRow(
                                'First Time App User',
                                _userStatus!['isFirstTimeAppUser'],
                              ),
                              _buildStatusRow(
                                'Has Registered',
                                _userStatus!['hasRegistered'],
                              ),
                              _buildStatusRow(
                                'Completed Onboarding',
                                _userStatus!['hasCompletedOnboarding'],
                              ),
                              _buildStatusRow(
                                'Keep Signed In',
                                _userStatus!['keepSignedIn'],
                              ),
                              _buildStatusRow(
                                'Should Auto Login',
                                _userStatus!['shouldAutoLogin'],
                              ),
                              _buildStatusRow(
                                'Registered Email',
                                _userStatus!['registeredEmail'] ?? 'None',
                              ),
                              _buildStatusRow(
                                'Firebase User',
                                _userStatus!['firebaseUser'] ?? 'None',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Journey Interpretation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildUserJourneyInfo(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _resetUserData,
                                child: Text('Reset All User Data'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _simulateFirstTimeUser,
                                child: Text('Simulate First-Time User'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(value),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic value) {
    if (value is bool) {
      return value ? Colors.green : Colors.grey;
    } else if (value == null || value == 'None') {
      return Colors.grey;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildUserJourneyInfo() {
    if (_userStatus == null) return Text('No status data available');

    final isFirstTime = _userStatus!['isFirstTimeAppUser'] as bool;
    final hasRegistered = _userStatus!['hasRegistered'] as bool;
    final shouldAutoLogin = _userStatus!['shouldAutoLogin'] as bool;
    final firebaseUser = _userStatus!['firebaseUser'];

    String interpretation;
    Color color;

    if (isFirstTime) {
      interpretation = "🆕 Brand new user - never opened the app before";
      color = Colors.purple;
    } else if (hasRegistered && shouldAutoLogin && firebaseUser != null) {
      interpretation =
          "✅ Registered user with auto-login enabled - should go to home screen";
      color = Colors.green;
    } else if (hasRegistered && !shouldAutoLogin) {
      interpretation =
          "👤 Registered user who chose not to stay logged in - should go to login";
      color = Colors.orange;
    } else if (!hasRegistered && firebaseUser != null) {
      interpretation =
          "🔑 User is signed in but not marked as registered (edge case)";
      color = Colors.red;
    } else {
      interpretation =
          "📱 User has used app before but never registered - show login";
      color = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        interpretation,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
