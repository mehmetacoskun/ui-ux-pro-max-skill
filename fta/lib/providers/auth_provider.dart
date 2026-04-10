import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final String baseUrl = 'https://otp.joshqun.com';
  
  String? _accessToken;
  String? _refreshToken;
  String? _userEmail;
  bool _isLoading = false;
  Timer? _refreshTimer;

  bool get isAuthenticated => _accessToken != null;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;

  AuthProvider() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _userEmail = prefs.getString('user_email');
    
    if (_accessToken != null && _refreshToken != null) {
      _setupRefreshTimer();
    }
    notifyListeners();
  }

  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch(e) {
      debugPrint('Error requesting OTP: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyOtp(String email, String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _userEmail = data['user']['email'] ?? email;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('user_email', _userEmail!);
        
        _setupRefreshTimer();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch(e) {
      debugPrint('Error verifying OTP: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void _setupRefreshTimer() {
    _refreshTimer?.cancel();
    // Refresh access token every 10 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      refreshAccessToken();
    });
  }

  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        notifyListeners();
      } else {
        await signOut();
      }
    } catch(e) {
      debugPrint('Error refreshing token: $e');
    }
  }

  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _userEmail = null;
    _refreshTimer?.cancel();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_email');
    
    notifyListeners();
  }
}
