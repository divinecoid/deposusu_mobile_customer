import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import 'create_ticket_page.dart';

class IssueListPage extends StatelessWidget {
  final String category; // 'Pesanan' or 'Pembayaran'

  const IssueListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    // Determine title based on category
    final title = category == 'Pesanan' ? lang.t('help_orders') : lang.t('help_payment');
    
    // Define issues based on category
    final issues = category == 'Pesanan'
        ? [
            {'icon': Icons.inventory_2, 'text': lang.t('issue_order_not_received')},
            {'icon': Icons.inventory, 'text': lang.t('issue_product_missing')},
            {'icon': Icons.broken_image, 'text': lang.t('issue_product_damaged')},
            {'icon': Icons.swap_horiz, 'text': lang.t('issue_wrong_product')},
            {'icon': Icons.currency_exchange, 'text': lang.t('issue_refund')},
          ]
        : [
            {'icon': Icons.error_outline, 'text': lang.t('issue_payment_failed')},
            {'icon': Icons.account_balance_wallet, 'text': lang.t('issue_balance_not_received')},
            {'icon': Icons.currency_exchange, 'text': lang.t('issue_payment_refund')},
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: issues.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final issue = issues[index];
          return ListTile(
            leading: Icon(issue['icon'] as IconData, color: Colors.black54),
            title: Text(issue['text'] as String),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateTicketPage(issueType: issue['text'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
