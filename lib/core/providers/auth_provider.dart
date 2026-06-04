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
    
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _isGuest = false;
      // TODO: decode token to get user data if real JWT
      _user = {'name': 'User Mock'};
    } else {
      _isGuest = true;
    }
    notifyListeners();
  }

  Future<void> login(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    
    _token = token;
    _user = userData;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Also clear other user-specific data here or in AccountPage
    _token = null;
    _user = null;
    _isGuest = true;
    notifyListeners();
  }
}
