import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _semua = true;
  bool _pesanan = true;
  bool _akun = true;
  bool _promo = true;
  bool _sistem = true;

  void _onSemuaChanged(bool value) {
    setState(() {
      _semua = value;
      _pesanan = value;
      _akun = value;
      _promo = value;
      _sistem = value;
    });
  }

  void _onChildChanged() {
    setState(() {
      _semua = _pesanan && _akun && _promo && _sistem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Semua notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
              value: _semua,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: _onSemuaChanged,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Notifikasi pesanan'),
              value: _pesanan,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                _pesanan = val;
                _onChildChanged();
              },
            ),
            SwitchListTile(
              title: const Text('Notifikasi akun'),
              value: _akun,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                _akun = val;
                _onChildChanged();
              },
            ),
            SwitchListTile(
              title: const Text('Notifikasi promo'),
              value: _promo,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                _promo = val;
                _onChildChanged();
              },
            ),
            SwitchListTile(
              title: const Text('Notifikasi sistem'),
              value: _sistem,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                _sistem = val;
                _onChildChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
