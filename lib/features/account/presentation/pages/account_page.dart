import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import 'dart:io';
import '../../../../core/providers/language_provider.dart';
import 'edit_profile_page.dart';
import 'notification_settings_page.dart';
import 'routine_schedule_page.dart';
import '../../../../features/auth/presentation/pages/pin_page.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/orders/presentation/pages/order_history_page.dart';
import '../../../../features/payment/presentation/pages/payment_methods_page.dart';
import 'address_page.dart';
import '../../../../features/help/presentation/pages/help_center_page.dart';
import 'security_settings_page.dart';
import '../../../../core/providers/cart_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('menu_account_title'), style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // Header Section
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16.0),
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final user = auth.user;
                final name = user?['name'] ?? 'Felinika';
                final phone = user?['phone'] ?? '08123456789';
                final photoPath = user?['photo'];

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
                      backgroundImage: photoPath != null ? FileImage(File(photoPath)) : null,
                      child: photoPath == null ? Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          SizedBox(height: 4),
                          Text(phone, style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Detail Akun Section
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(lang.t('menu_account_details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                ),
                ListTile(
                  leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_edit_profile')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.security, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_pin_settings')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Pesanan Saya Section
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_my_orders')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage(initialIndex: 0)));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Jadwal Rutin Section
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.event_repeat, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_routine_schedule')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutineSchedulePage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Metode & Alamat Section
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_payment_methods')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()));
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_saved_addresses')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressPage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Pengaturan Lainnya
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_notification_settings')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.language, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_language')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.currentLanguage == 'id' ? 'Bahasa Indonesia' : 'English', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    _showLanguageBottomSheet(context);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  title: Text(lang.t('menu_help')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(lang.t('menu_logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin mau logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog

              // 1. Clear SharedPreferences (Token)
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // 2. Reset global state (Cart & User)
              if (context.mounted) {
                final cart = context.read<CartProvider>();
                cart.clearCart();
                // Optionally add UserProvider reset here if exists in the future

                // 3. Redirect to Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false, // Remove all previous routes
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<LanguageProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.t('choose_language'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildLanguageOption(context, provider, 'Bahasa Indonesia', 'id', '🇮🇩'),
                  const SizedBox(height: 16),
                  _buildLanguageOption(context, provider, 'English', 'en', '🇺🇸'),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageProvider provider, String title, String value, String flag) {
    final isSelected = provider.currentLanguage == value;
    return GestureDetector(
      onTap: () {
        provider.setLanguage(value, remember: true);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : Theme.of(context).cardColor,
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
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
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
