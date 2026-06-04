import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Metode Pembayaran', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(context, 'Saldo DepoSusu'),
          _buildPaymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            iconColor: Theme.of(context).primaryColor,
            title: 'Saldo DepoSusu',
            subtitle: 'Rp 150.000',
            trailing: const Text('Top Up', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 16),
          const Divider(thickness: 8, color: Colors.black12),
          const SizedBox(height: 16),
          
          _buildSectionHeader(context, 'Dompet Digital'),
          _buildPaymentItem(
            context: context,
            icon: Icons.qr_code_scanner,
            iconColor: Colors.green,
            title: 'GoPay',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(indent: 56),
          _buildPaymentItem(
            context: context,
            icon: Icons.money,
            iconColor: Colors.deepPurple,
            title: 'OVO',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(indent: 56),
          _buildPaymentItem(
            context: context,
            icon: Icons.account_balance,
            iconColor: Colors.blueAccent,
            title: 'DANA',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(indent: 56),
          _buildPaymentItem(
            context: context,
            icon: Icons.shopping_bag,
            iconColor: Colors.orange,
            title: 'ShopeePay',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),

          const SizedBox(height: 16),
          const Divider(thickness: 8, color: Colors.black12),
          const SizedBox(height: 16),

          _buildSectionHeader(context, 'Transfer Bank'),
          _buildPaymentItem(
            context: context,
            icon: Icons.account_balance_outlined,
            iconColor: Colors.grey[700]!,
            title: 'Virtual Account',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),

          const SizedBox(height: 16),
          const Divider(thickness: 8, color: Colors.black12),
          const SizedBox(height: 16),

          _buildSectionHeader(context, 'Kartu Kredit / Debit'),
          _buildPaymentItem(
            context: context,
            icon: Icons.credit_card,
            iconColor: Colors.grey[700]!,
            title: 'Tambah Kartu Baru',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPaymentItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: trailing,
      onTap: () {},
    );
  }
}
