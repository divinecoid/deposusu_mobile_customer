import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/order_history_provider.dart';
import '../../../tracking/data/models/order_tracking_model.dart';
import '../../../tracking/presentation/widgets/tracking_stepper.dart';

class OrderHistoryPage extends StatefulWidget {
  final int initialIndex;

  const OrderHistoryPage({super.key, this.initialIndex = 0});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 Tabs: Semua, Selesai, Dibatalkan
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pesanan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46.0),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Semua', textAlign: TextAlign.center))),
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Selesai', textAlign: TextAlign.center))),
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Dibatalkan', textAlign: TextAlign.center))),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSemuaTab(),
          _buildSelesaiTab(),
          _buildDibatalkanTab(),
        ],
      ),
    );
  }

  void _onPesanLagiClicked() {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      ),
    );

    // Simulate network request
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('3 produk ditambahkan ke keranjang. 1 produk tidak tersedia.'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'LIHAT',
              textColor: Colors.white,
              onPressed: () {
                // Should navigate to cart in real app
              },
            ),
          ),
        );
      }
    });
  }

  Widget _buildOrderCard(OrderTrackingModel order) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final date = order.history.isNotEmpty ? dateFormat.format(order.history.first.timestamp) : 'Baru Saja';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          // Embedded TrackingStepper instead of simple dot
          TrackingStepper(
            currentStatus: order.currentStatus,
            paymentMethod: order.paymentMethod,
            paymentStatus: order.paymentStatus,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.paymentMethod == 'COD' ? 'Bayar Saat Diterima' : (order.paymentMethod ?? 'Pembayaran Digital'), 
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
              ),
              ElevatedButton(
                onPressed: _onPesanLagiClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                child: const Text('Pesan Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemuaTab() {
    final provider = context.watch<OrderHistoryProvider>();
    if (provider.orders.isEmpty) {
      return _buildEmptyState('Belum ada pesanan');
    }
    
    return ListView.builder(
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(provider.orders[index]);
      },
    );
  }

  Widget _buildSelesaiTab() {
    final provider = context.watch<OrderHistoryProvider>();
    final completed = provider.orders.where((o) => o.currentStatus == OrderStatus.completed).toList();
    
    if (completed.isEmpty) {
      return _buildEmptyState('Belum ada pesanan selesai');
    }
    
    return ListView.builder(
      itemCount: completed.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(completed[index]);
      },
    );
  }

  Widget _buildDibatalkanTab() {
    return _buildEmptyState('Belum ada pesanan dibatalkan');
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
