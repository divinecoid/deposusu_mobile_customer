import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/address_provider.dart';
import '../../../account/presentation/pages/add_address_page.dart';
import '../../../../features/payment/presentation/pages/payment_gateway_page.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../../core/providers/order_history_provider.dart';
import '../../../tracking/data/models/order_tracking_model.dart';
import '../../../orders/presentation/pages/order_history_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  String? _selectedPaymentMethod; // 'SALDO', 'GOPAY', 'OVO', 'DANA', 'SHOPEEPAY', 'VA_BCA', 'VA_BNI', 'VA_MANDIRI', 'VA_BRI', 'QRIS', 'COD'

  void _showAddressSelectionBottomSheet(BuildContext context, AddressProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Alamat Pengiriman',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.addresses.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Belum ada alamat tersimpan', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = provider.addresses[index];
                    final isActive = address.id == provider.activeAddress?.id;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          address.label == 'Rumah' ? Icons.home : 
                          address.label == 'Kantor' ? Icons.business : Icons.place,
                          color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        title: Row(
                          children: [
                            Text(address.label, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                            if (address.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Utama', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(address.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: isActive ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                        onTap: () {
                          provider.setActiveAddress(address.id);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage()));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Alamat Baru'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _handlePlaceOrder(CartProvider cart, AuthProvider auth, Address? address) async {
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap tentukan alamat pengiriman terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih metode pembayaran.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int subtotal = cart.selectedSubtotal;
    int total = subtotal; // Ongkir gratis

    if (_selectedPaymentMethod == 'SALDO' && auth.balance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo DepoSusu Anda tidak mencukupi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final checkoutItems = cart.items
          .where((item) => item.isSelected)
          .map((item) => {
                'product_id': int.tryParse(item.id) ?? 1,
                'quantity': item.qty,
              })
          .toList();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/customer/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'customer_name': address.recipientName,
          'phone': address.phoneNumber,
          'address': address.fullAddress,
          'items': checkoutItems,
          'payment_method': _selectedPaymentMethod,
        }),
      ).timeout(const Duration(seconds: 15));

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final String orderNum = decoded['order_number'];

          // Deduct mock balance locally if paid with Saldo
          if (_selectedPaymentMethod == 'SALDO') {
            auth.deductBalance(total);
          }

          // Clear items checked out
          cart.clearCheckedOutItems();

          String methodLabel = _selectedPaymentMethod == 'SALDO'
              ? '💰 Saldo DepoSusu'
              : _selectedPaymentMethod == 'COD'
                  ? '🚚 Bayar Saat Diterima (QRIS)'
                  : _getPaymentMethodLabel(_selectedPaymentMethod!);

          if (_selectedPaymentMethod == 'SALDO' || _selectedPaymentMethod == 'COD') {
            final paymentStatus = _selectedPaymentMethod == 'COD' ? 'PAY_ON_DELIVERY' : 'PAID';
            _addOrderToHistory(orderNum, _selectedPaymentMethod!, paymentStatus, total);
            
            _showCheckoutSuccessPage(
              orderNumber: orderNum,
              paymentMethodLabel: methodLabel,
              paymentStatus: paymentStatus,
              amount: total,
            );
          } else {
            // Payment Gateway Flow (GoPay, OVO, DANA, ShopeePay, VA, QRIS)
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentGatewayPage(
                  paymentMethodCode: _selectedPaymentMethod!,
                  paymentMethodLabel: methodLabel,
                  amount: total,
                  orderId: orderNum,
                  onPaymentSuccess: (orderId) {
                    _addOrderToHistory(orderId, _selectedPaymentMethod!, 'PAID', total);
                    _showCheckoutSuccessPage(
                      orderNumber: orderId,
                      paymentMethodLabel: methodLabel,
                      paymentStatus: 'PAID',
                      amount: total,
                    );
                  },
                  onPaymentFailed: (orderId) {
                    _addOrderToHistory(orderId, _selectedPaymentMethod!, 'PENDING', total);
                    _showCheckoutSuccessPage(
                      orderNumber: orderId,
                      paymentMethodLabel: methodLabel,
                      paymentStatus: 'PENDING',
                      amount: total,
                    );
                  },
                ),
              ),
            );
          }
        } else {
          _showErrorSnackBar(decoded['message'] ?? 'Gagal memproses pesanan.');
        }
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _showErrorSnackBar(decoded['message'] ?? 'Gagal memproses pesanan. (Status: ${response.statusCode})');
        } catch (e) {
          _showErrorSnackBar('Gagal menghubungi server. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Terjadi kesalahan koneksi ke server.');
      print('Checkout API Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getPaymentMethodLabel(String code) {
    switch (code) {
      case 'GOPAY': return 'GoPay';
      case 'OVO': return 'OVO';
      case 'DANA': return 'DANA';
      case 'SHOPEEPAY': return 'ShopeePay';
      case 'VA_BCA': return 'Virtual Account BCA';
      case 'VA_BNI': return 'Virtual Account BNI';
      case 'VA_MANDIRI': return 'Virtual Account Mandiri';
      case 'VA_BRI': return 'Virtual Account BRI';
      case 'QRIS': return 'QRIS';
      default: return 'Pembayaran Digital';
    }
  }

  void _addOrderToHistory(String orderNumber, String paymentMethod, String paymentStatus, int total) {
    if (!mounted) return;
    
    final status = OrderStatus.pending;

    final order = OrderTrackingModel(
      orderNumber: orderNumber,
      currentStatus: status,
      estimatedDeliveryTime: DateTime.now().add(const Duration(hours: 1)),
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      history: [
        TrackingHistoryItem(
          status: status,
          timestamp: DateTime.now(),
        ),
      ],
    );
    
    context.read<OrderHistoryProvider>().addOrder(order);
  }

  void _showCheckoutSuccessPage({
    required String orderNumber,
    required String paymentMethodLabel,
    required String paymentStatus,
    required int amount,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => _CheckoutSuccessScreen(
          orderNumber: orderNumber,
          paymentMethodLabel: paymentMethodLabel,
          paymentStatus: paymentStatus,
          amount: amount,
          currencyFormat: _currencyFormat,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final address = addressProvider.activeAddress;

    int subtotal = cart.selectedSubtotal;
    int total = subtotal; // Ongkir gratis

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Shipping Info Section
                _buildSectionHeader('Informasi Pengiriman'),
                const SizedBox(height: 8),
                _buildShippingCard(address, addressProvider),
                const SizedBox(height: 24),

                // Grouped Payment Options Section
                _buildSectionHeader('Metode Pembayaran'),
                const SizedBox(height: 8),
                _buildPaymentMethodsList(auth, total),
                const SizedBox(height: 24),

                // Ringkasan Belanja
                _buildSectionHeader('Ringkasan Belanja'),
                const SizedBox(height: 8),
                _buildShoppingSummaryCard(subtotal, total),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Bottom Bar & place order button
          _buildBottomPlaceOrderBar(cart, auth, address, total),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
    );
  }

  Widget _buildShippingCard(Address? address, AddressProvider addressProvider) {
    if (address == null) {
      return GestureDetector(
        onTap: () => _showAddressSelectionBottomSheet(context, addressProvider),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.location_off_outlined, color: Colors.red[300], size: 40),
              const SizedBox(height: 8),
              const Text('Alamat pengiriman belum terpilih', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Ketuk di sini untuk menambahkan atau memilih alamat.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showAddressSelectionBottomSheet(context, addressProvider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      address.label == 'Rumah' ? Icons.home : 
                      address.label == 'Kantor' ? Icons.business : Icons.place,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Text('Ubah', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.recipientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(address.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(address.fullAddress, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Pin Lokasi Chip Mockup
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 14),
                  SizedBox(width: 4),
                  Text('📍 -6.9147, 107.6098 (Pin Lokasi Terpasang)', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (address.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Catatan: ${address.note}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(AuthProvider auth, int billTotal) {
    bool hasSufficientBalance = auth.balance >= billTotal;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Saldo DepoSusu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Saldo DepoSusu', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildPaymentRow(
            id: 'SALDO',
            icon: '💰',
            title: 'Saldo DepoSusu',
            subtitle: 'Saldo Anda: ${_currencyFormat.format(auth.balance)}',
            isEnabled: hasSufficientBalance,
            badge: hasSufficientBalance
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('✓ Bayar Sekarang', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Saldo tidak mencukupi', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
          ),
          const Divider(height: 1),

          // 2. E-Wallet Group
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('E-Wallet', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildPaymentRow(id: 'GOPAY', icon: '🟢', title: 'GoPay'),
          _buildPaymentRow(id: 'OVO', icon: '🟣', title: 'OVO'),
          _buildPaymentRow(id: 'DANA', icon: '🔵', title: 'DANA'),
          _buildPaymentRow(id: 'SHOPEEPAY', icon: '🟠', title: 'ShopeePay'),
          const Divider(height: 1),

          // 3. Bank Transfer Group
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Bank Transfer', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildPaymentRow(id: 'VA_BCA', icon: '🏦', title: 'Virtual Account BCA'),
          _buildPaymentRow(id: 'VA_BNI', icon: '🏦', title: 'Virtual Account BNI'),
          _buildPaymentRow(id: 'VA_MANDIRI', icon: '🏦', title: 'Virtual Account Mandiri'),
          _buildPaymentRow(id: 'VA_BRI', icon: '🏦', title: 'Virtual Account BRI'),
          const Divider(height: 1),

          // 4. QRIS Group
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('QRIS', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildPaymentRow(id: 'QRIS', icon: '📱', title: 'QRIS'),
          const Divider(height: 1),

          // 5. COD Group
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Bayar Saat Diterima', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildPaymentRow(
            id: 'COD',
            icon: '🚚',
            title: 'Bayar Saat Diterima (QRIS)',
            subtitle: 'Bayar dengan QRIS saat pesanan tiba.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String id,
    required String icon,
    required String title,
    String? subtitle,
    bool isEnabled = true,
    Widget? badge,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: isEnabled
            ? (badge ??
                Radio<String>(
                  value: id,
                  groupValue: _selectedPaymentMethod,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val;
                    });
                  },
                ))
            : badge,
        onTap: isEnabled
            ? () {
                setState(() {
                  _selectedPaymentMethod = id;
                });
              }
            : null,
      ),
    );
  }

  Widget _buildShoppingSummaryCard(int subtotal, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(_currencyFormat.format(subtotal), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ongkir', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('Gratis', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                _currencyFormat.format(total),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPlaceOrderBar(CartProvider cart, AuthProvider auth, Address? address, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total Bayar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    _currencyFormat.format(total),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handlePlaceOrder(cart, auth, address),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buat Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final String paymentMethodLabel;
  final String paymentStatus;
  final int amount;
  final NumberFormat currencyFormat;

  const _CheckoutSuccessScreen({
    required this.orderNumber,
    required this.paymentMethodLabel,
    required this.paymentStatus,
    required this.amount,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPaid = paymentStatus == 'PAID';
    final Color primaryColor = isPaid ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Premium Success Card
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.hourglass_empty,
                  color: primaryColor,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPaid ? 'Pesanan Berhasil Dibuat!' : 'Menunggu Pembayaran',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isPaid 
                    ? 'Pesanan Anda sedang diproses.' 
                    : 'Pesanan Anda terbuat! Segera selesaikan pembayaran agar pesanan dapat diproses.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Nomor Pesanan', orderNumber, isBold: true),
                    const Divider(height: 24),
                    _buildReceiptRow('Metode Pembayaran', paymentMethodLabel),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Total Pembayaran', currencyFormat.format(amount)),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      'Status Pembayaran', 
                      paymentStatus == 'PAID' ? 'Sudah Dibayar' : 
                      paymentStatus == 'PAY_ON_DELIVERY' ? 'Bayar Saat Diterima' : 'Menunggu Pembayaran',
                      customValueColor: primaryColor,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage(initialIndex: 0),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Lihat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              // Kembali ke beranda
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Kembali ke Beranda', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? customValueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: customValueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
