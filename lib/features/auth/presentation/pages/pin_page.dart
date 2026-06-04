import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../../../../core/services/biometric_service.dart';
import 'otp_page.dart';

enum PinPageMode { create, confirm, login, disable }

class PinPage extends StatefulWidget {
  final PinPageMode mode;
  final String? initialPin;

  const PinPage({
    super.key,
    required this.mode,
    this.initialPin,
  });

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isError = false;
  bool _hasBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasBio = prefs.getBool('has_biometric') ?? false;
    setState(() {
      _hasBiometric = hasBio;
    });

    if (hasBio && widget.mode == PinPageMode.login) {
      _triggerBiometricAuth();
    }
  }

  Future<void> _triggerBiometricAuth() async {
    final biometricService = BiometricService();
    final authenticated = await biometricService.authenticate();
    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  void _onKeyPress(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _processPin();
      }
    }
  }

  void _onDeletePress() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _processPin() async {
    // Add small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (widget.mode == PinPageMode.create) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PinPage(
            mode: PinPageMode.confirm,
            initialPin: _pin,
          ),
        ),
      );
    } else if (widget.mode == PinPageMode.confirm) {
      if (_pin == widget.initialPin) {
        // Save PIN
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_pin', true);
        await prefs.setString('user_pin', _pin);
        
        if (!mounted) return;
        _showBiometricPrompt(context);
      } else {
        // PIN mismatch
        setState(() {
          _isError = true;
          _pin = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN tidak cocok, silakan coba lagi')),
        );
      }
    } else if (widget.mode == PinPageMode.login) {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('user_pin');
      
      if (_pin == savedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        setState(() {
          _isError = true;
          _pin = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN salah')),
        );
      }
    } else if (widget.mode == PinPageMode.disable) {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('user_pin');
      
      if (_pin == savedPin) {
        Navigator.pop(context, true); // Return true to signify successful disable
      } else {
        setState(() {
          _isError = true;
          _pin = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN salah')),
        );
      }
    }
  }

  void _showBiometricPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fingerprint, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Step 4 — Aktifkan Biometrik sebagai opsi pin',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk dan bertransaksi lebih cepat tanpa memasukkan PIN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final biometricService = BiometricService();
                      final canUse = await biometricService.canUseBiometrics();
                      if (!canUse) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sistem HP belum mendukung atau Fingerprint belum didaftarkan.')),
                          );
                        }
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_biometric', true);
                      if (context.mounted) {
                        Navigator.pop(context); // close modal
                        Navigator.pop(context, true); // return to security settings page
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Aktifkan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // close modal
                      Navigator.pop(context, true); // return to security settings page
                    },
                    child: const Text('Nanti', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _title {
    switch (widget.mode) {
      case PinPageMode.create:
        return 'Step 2 — Buat PIN';
      case PinPageMode.confirm:
        return 'Step 3 — Konfirmasi PIN';
      case PinPageMode.login:
        return 'Masukkan PIN';
      case PinPageMode.disable:
        return 'Nonaktifkan PIN Keamanan';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case PinPageMode.create:
        return 'Gunakan 6 digit angka yang mudah Anda ingat namun sulit ditebak.';
      case PinPageMode.confirm:
        return 'Masukkan ulang PIN yang baru saja dibuat';
      case PinPageMode.login:
        return 'Masukkan PIN 6 digit Anda';
      case PinPageMode.disable:
        return 'Masukkan PIN Anda untuk menonaktifkan PIN Keamanan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            
            // PIN Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pinLength,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pin.length > index
                        ? Theme.of(context).primaryColor
                        : (_isError ? Colors.red : Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Biometric or Empty
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: (widget.mode == PinPageMode.login && _hasBiometric)
                            ? IconButton(
                                onPressed: _triggerBiometricAuth,
                                icon: Icon(Icons.fingerprint, size: 40, color: Theme.of(context).primaryColor),
                              )
                            : null,
                      ),
                      _buildKeypadButton('0'),
                      // Backspace
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: IconButton(
                          onPressed: _onDeletePress,
                          icon: Icon(Icons.backspace_outlined, size: 32, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (widget.mode == PinPageMode.login) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OtpPage()), // Go to OTP page for recovery
                  );
                },
                child: Text(
                  'Lupa PIN?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => _onKeyPress(key),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
