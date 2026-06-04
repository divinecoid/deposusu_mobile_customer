import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../features/auth/presentation/pages/pin_info_page.dart';
import '../../../../features/auth/presentation/pages/pin_page.dart';
import '../../../../core/services/biometric_service.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _isPinActive = false;
  bool _isBiometricActive = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPinActive = prefs.getBool('has_pin') ?? false;
      _isBiometricActive = prefs.getBool('has_biometric') ?? false;
    });
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      // Navigate to PinInfoPage -> PinPage
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinInfoPage()),
      );
      if (result == true) {
        _loadSettings(); // Reload after successful creation
      }
    } else {
      // Verify PIN to disable
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinPage(mode: PinPageMode.disable)),
      );
      if (result == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_pin', false);
        await prefs.remove('user_pin');
        await prefs.setBool('has_biometric', false);
        setState(() {
          _isPinActive = false;
          _isBiometricActive = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN Keamanan dinonaktifkan')),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_isPinActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktifkan PIN Keamanan terlebih dahulu')),
      );
      return;
    }
    
    if (value) {
      // Check if OS has enrolled biometrics
      final biometricService = BiometricService();
      final canUse = await biometricService.canUseBiometrics();
      if (!canUse) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sistem HP belum mendukung atau Fingerprint belum didaftarkan.')),
        );
        return; // Don't enable
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_biometric', value);
    setState(() {
      _isBiometricActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lang.t('menu_pin_settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('PIN Keamanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text('Lindungi akun dan transaksi Anda'),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${_isPinActive ? "Aktif" : "Belum Aktif"}',
                          style: TextStyle(
                            color: _isPinActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: _isPinActive,
                      onChanged: _togglePin,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: const Text('Biometrik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Masuk lebih cepat menggunakan Fingerprint'),
                    ),
                    trailing: Switch(
                      value: _isBiometricActive,
                      onChanged: _isPinActive ? _toggleBiometric : null,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
