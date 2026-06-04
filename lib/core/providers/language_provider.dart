import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'id'; // Default 'id' for Bahasa Indonesia
  bool _isLanguageSaved = false;
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isLanguageSaved => _isLanguageSaved;
  bool get isInitialized => _isInitialized;

  String t(String key) {
    return AppTranslations.translations[_currentLanguage]?[key] ?? key;
  }

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isLanguageSaved = prefs.getBool('is_language_saved') ?? false;
    _currentLanguage = prefs.getString('current_language') ?? 'id';
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String langCode, {bool remember = false}) async {
    _currentLanguage = langCode;
    _isLanguageSaved = remember;
    
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool('is_language_saved', true);
      await prefs.setString('current_language', langCode);
    } else {
      await prefs.remove('is_language_saved');
      await prefs.remove('current_language');
    }
    notifyListeners();
  }
}
