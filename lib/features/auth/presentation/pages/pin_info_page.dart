import 'package:flutter/material.dart';
import 'pin_page.dart';

class PinInfoPage extends StatelessWidget {
  const PinInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Aktifkan PIN', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Icon(
                Icons.security,
                size: 100,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Step 1 — Informasi PIN',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aktifkan PIN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'PIN digunakan untuk mengamankan akun dan transaksi Anda.',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              'Jangan gunakan tanggal lahir, nomor telepon, atau kombinasi angka yang mudah ditebak.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PinPage(mode: PinPageMode.create)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lanjut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
