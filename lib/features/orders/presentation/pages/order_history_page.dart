import 'package:flutter/material.dart';

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
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Selesai'),
              Tab(text: 'Dibatalkan'),
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

  Widget _buildOrderCard({
    required String orderId,
    required String date,
    required String itemCount,
    required String total,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
              Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(itemCount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Total $total', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              ElevatedButton(
                onPressed: _onPesanLagiClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        _buildOrderCard(
          orderId: '#DS2026001',
          date: '15 Mei 2026',
          itemCount: '3 Produk',
          total: 'Rp125.000',
          status: 'Selesai',
          statusColor: Colors.green,
        ),
        _buildOrderCard(
          orderId: '#DS2026002',
          date: '16 Mei 2026',
          itemCount: '2 Produk',
          total: 'Rp85.000',
          status: 'Dibatalkan',
          statusColor: Colors.grey.shade600,
        ),
        _buildOrderCard(
          orderId: '#DS2026003',
          date: '20 Mei 2026',
          itemCount: '5 Produk',
          total: 'Rp210.000',
          status: 'Selesai',
          statusColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSelesaiTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        _buildOrderCard(
          orderId: '#DS2026001',
          date: '15 Mei 2026',
          itemCount: '3 Produk',
          total: 'Rp125.000',
          status: 'Selesai',
          statusColor: Colors.green,
        ),
        _buildOrderCard(
          orderId: '#DS2026003',
          date: '20 Mei 2026',
          itemCount: '5 Produk',
          total: 'Rp210.000',
          status: 'Selesai',
          statusColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDibatalkanTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        _buildOrderCard(
          orderId: '#DS2026002',
          date: '16 Mei 2026',
          itemCount: '2 Produk',
          total: 'Rp85.000',
          status: 'Dibatalkan',
          statusColor: Colors.grey.shade600,
        ),
      ],
    );
  }
}
