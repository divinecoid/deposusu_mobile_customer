import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'id';
  bool _rememberChoice = true;

  void _onContinue() {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    provider.setLanguage(_selectedLanguage, remember: _rememberChoice);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pilih Bahasa / Choose Language', 
          style: TextStyle(color: Colors.black, fontSize: 16)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildLanguageOption(
              title: 'Bahasa Indonesia',
              value: 'id',
              flag: '🇮🇩',
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              title: 'English',
              value: 'en',
              flag: '🇺🇸',
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Checkbox(
                  value: _rememberChoice,
                  onChanged: (val) {
                    setState(() {
                      _rememberChoice = val ?? false;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                const Expanded(
                  child: Text(
                    'Ingat pilihan saya (Remember my choice)',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lanjutkan / Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String value,
    required String flag,
  }) {
    final isSelected = _selectedLanguage == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
