import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../language/presentation/pages/language_selection_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/pin_page.dart';
import '../../../main/presentation/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLanguageAndNavigate();
  }

  Future<void> _checkLanguageAndNavigate() async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // If not initialized yet, wait
    while (!languageProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    if (languageProvider.isLanguageSaved) {
      if (authProvider.isGuest) {
        // Belum login -> Halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Sudah login -> Cek apakah mengaktifkan PIN/Biometric
        final prefs = await SharedPreferences.getInstance();
        final hasPin = prefs.getBool('has_pin') ?? false;

        if (hasPin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PinPage(mode: PinPageMode.login)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DepoSusu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stock Less, Live More',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
