import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../main/presentation/pages/main_page.dart';
import 'otp_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  void _onContinue() {
    if (_phoneController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtpPage()),
      );
    }
  }

  // 🔵 FRONTEND LOGIC: OAuth Flow (Google)
  Future<void> _handleGoogleLogin() async {
    // 1. Pemicu OAuth Flow (Redirect ke Backend)
    // Dalam real app: launchUrl(Uri.parse('https://api.deposusu.com/auth/google'))
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulasi user login di browser Google, lalu backend kirim callback ke App (via Deep Link)
    await Future.delayed(const Duration(seconds: 2));

    // 🔐 FRONTEND HANDLE SUCCESS: Tangkap JWT Token dari URL Callback
    final mockTokenFromCallback = 'jwt_token_google_123';
    await _handleLoginSuccess(mockTokenFromCallback, 'User Google');
  }

  // 🍎 FRONTEND LOGIC: OAuth Flow (Apple)
  Future<void> _handleAppleLogin() async {
    // 1. Pemicu OAuth Flow (Redirect ke Backend)
    // Dalam real app: launchUrl(Uri.parse('https://api.deposusu.com/auth/apple'))
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulasi user login di layar Apple, lalu backend kirim callback ke App
    await Future.delayed(const Duration(seconds: 2));

    // 🔐 FRONTEND HANDLE SUCCESS
    final mockTokenFromCallback = 'jwt_token_apple_123';
    await _handleLoginSuccess(mockTokenFromCallback, 'User Apple');
  }

  Future<void> _handleLoginSuccess(String token, String name) async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    // 1. Simpan session (Token) + Masuk App
    await authProvider.login(token, {'name': name, 'email': 'user@deposusu.com'});
    
    // 2. CRITICAL PART: Guest -> Auth Cart Sync
    await cartProvider.syncCartAfterLogin();

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Masuk atau Daftar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masukkan nomor HP Anda',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Phone Input Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        '+62',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Nomor HP',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Lanjutkan Button
              ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('atau', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Social Logins
              OutlinedButton.icon(
                onPressed: _handleGoogleLogin,
                icon: Icon(Icons.g_mobiledata, color: Theme.of(context).colorScheme.onSurface, size: 32),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _handleAppleLogin,
                icon: Icon(Icons.apple, color: Theme.of(context).colorScheme.onSurface, size: 28),
                label: Text(
                  'Continue with Apple',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
