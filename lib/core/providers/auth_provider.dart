import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isGuest = true;
  String? _token;
  Map<String, dynamic>? _user;
  int _balance = 120000; // Default balance Rp 120.000

  bool get isGuest => _isGuest;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  int get balance => _balance;

  void deductBalance(int amount) {
    _balance -= amount;
    if (_balance < 0) _balance = 0;
    notifyListeners();
  }

  void refundBalance(int amount) {
    _balance += amount;
    notifyListeners();
  }

  AuthProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    
    // Load persisted profile data
    final String name = prefs.getString('profile_name') ?? 'Felinika';
    final String phone = prefs.getString('profile_phone') ?? '08123456789';
    final String email = prefs.getString('profile_email') ?? 'felinika@deposusu.com';
    final String? photoPath = prefs.getString('profile_photo');

    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _isGuest = false;
      _user = {
        'name': name,
        'phone': phone,
        'email': email,
        'photo': photoPath,
      };
    } else {
      _isGuest = true;
      // Even if guest, we might want to keep the form populated for demo, or keep it null.
      // Let's just mock it up anyway since login is mocked.
      _user = {
        'name': name,
        'phone': phone,
        'email': email,
        'photo': photoPath,
      };
    }
    notifyListeners();
  }

  Future<void> login(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    
    // If user logs in, we can either override or keep existing persisted data.
    // For this mock, we'll ensure the existing persisted data is loaded if available.
    final String name = prefs.getString('profile_name') ?? userData['name'] ?? 'Felinika';
    final String phone = prefs.getString('profile_phone') ?? '08123456789';
    final String email = prefs.getString('profile_email') ?? userData['email'] ?? 'felinika@deposusu.com';
    final String? photoPath = prefs.getString('profile_photo');

    _token = token;
    _user = {
      'name': name,
      'phone': phone,
      'email': email,
      'photo': photoPath,
    };
    _isGuest = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Note: We DO NOT remove profile data so it persists across logout/login as requested.
    _token = null;
    _isGuest = true;
    notifyListeners();
  }

  // --- Profile Edit Logic ---

  Future<void> updateBasicProfile(String name, String? photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    if (photoPath != null) {
      await prefs.setString('profile_photo', photoPath);
    }

    if (_user != null) {
      _user!['name'] = name;
      if (photoPath != null) _user!['photo'] = photoPath;
      notifyListeners();
    }
  }

  Future<String> requestOtp(String type, String newValue) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock OTP is always 1234
    return '1234';
  }

  Future<bool> verifyAndUpdateSecureProfile(String type, String newValue, String otp) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate verification delay

    if (otp == '1234') {
      final prefs = await SharedPreferences.getInstance();
      if (type == 'phone') {
        await prefs.setString('profile_phone', newValue);
        if (_user != null) _user!['phone'] = newValue;
      } else if (type == 'email') {
        await prefs.setString('profile_email', newValue);
        if (_user != null) _user!['email'] = newValue;
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}
