import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';

class CreateTicketPage extends StatefulWidget {
  final String issueType;

  const CreateTicketPage({super.key, required this.issueType});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  String? _selectedOrder;
  bool _isUploading = false;

  void _submitTicket(BuildContext context, LanguageProvider lang) {
    if (_selectedOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pesanan terlebih dahulu')),
      );
      return;
    }

    // Mockup loading and success
    setState(() {
      _isUploading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      
      _showSuccessDialog(context, lang);
    });
  }

  void _showSuccessDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                lang.t('ticket_success'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                lang.t('ticket_number'),
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                lang.t('ticket_status_waiting'),
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // close issue list
                    Navigator.pop(context); // close to help center
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('ticket_create_title')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.issueType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Order Dropdown Mockup
            Text(
              lang.t('ticket_select_order'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Order #...'),
                  value: _selectedOrder,
                  items: const [
                    DropdownMenuItem(value: 'Order #12345 (Susu Segar)', child: Text('Order #12345 (Susu Segar)')),
                    DropdownMenuItem(value: 'Order #12346 (Indomie)', child: Text('Order #12346 (Indomie)')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedOrder = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Photo Mockup
            Text(
              lang.t('ticket_upload_photo'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Mockup photo selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto berhasil dipilih (Mockup)')),
                );
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('Tap to upload', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Description Box
            const Text(
              'Deskripsi Tambahan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan detail masalahnya di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : () => _submitTicket(context, lang),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(lang.t('ticket_send'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
