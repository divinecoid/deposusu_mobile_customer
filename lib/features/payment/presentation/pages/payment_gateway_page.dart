import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class PaymentGatewayPage extends StatefulWidget {
  final String paymentMethodCode;
  final String paymentMethodLabel;
  final int amount;
  final String? orderId;
  final Function(String orderId) onPaymentSuccess;
  final Function(String orderId) onPaymentFailed;

  const PaymentGatewayPage({
    super.key,
    required this.paymentMethodCode,
    required this.paymentMethodLabel,
    required this.amount,
    this.orderId,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> with SingleTickerProviderStateMixin {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _processPayment(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.blueAccent),
                const SizedBox(height: 16),
                const Text(
                  'Mengirimkan Callback...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  success ? 'Menghubungkan ke API DepoSusu...' : 'Membatalkan pembayaran...',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1500 ~/ 1000), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Pop Gateway page
        
        final String generatedOrderId = widget.orderId ?? 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        if (success) {
          widget.onPaymentSuccess(generatedOrderId);
        } else {
          widget.onPaymentFailed(generatedOrderId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Ultra-premium deep midnight
      appBar: AppBar(
        title: const Text('DepoSusu Secure Gateway', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () {
              // Simulates user cancel = payment failure
              _processPayment(false);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background soft glowing light circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Lock Icon with glowing animation
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.1 + (_glowController.value * 0.1)),
                            blurRadius: 20,
                            spreadRadius: _glowController.value * 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.security, color: Colors.blueAccent, size: 40),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selesaikan Pembayaran Anda',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gunakan simulasi di bawah untuk menguji keberhasilan pemesanan dan integrasi operasional.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Premium Glassmorphic Invoice Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Merchant', 'DepoSusu Store (Official)'),
                          const Divider(color: Colors.white10, height: 24),
                          _buildDetailRow('Metode Pembayaran', widget.paymentMethodLabel),
                          const Divider(color: Colors.white10, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Tagihan', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                _currencyFormat.format(widget.amount),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),

                // Action Buttons representing Simulated Callback Triggers
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _processPayment(true),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text(
                          'Simulasi Pembayaran Sukses',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: Colors.green.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _processPayment(false),
                        icon: const Icon(Icons.error_outline, color: Colors.red),
                        label: const Text(
                          'Simulasi Pembayaran Gagal',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
