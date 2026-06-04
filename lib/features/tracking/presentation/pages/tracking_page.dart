import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/tracking_stepper.dart';
import '../../data/models/order_tracking_model.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TrackingProvider>();
      if (provider.activeTrackingNumber == null) {
        provider.initializeMockOrder();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackingProvider>();
    final order = provider.currentOrder;
    final isMock = order?.orderNumber.contains('Simulasi') ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate Navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Lacak Pesanan Deposusu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        actions: [
          if (order != null && !isMock)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.cyan),
              onPressed: () {
                provider.fetchOrderTracking(order.orderNumber);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (order != null && !isMock) {
            await provider.fetchOrderTracking(order.orderNumber);
          } else {
            provider.initializeMockOrder();
          }
        },
        color: Colors.cyan,
        backgroundColor: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Glassmorphic Search Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.8),
                      const Color(0xFF0F172A).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masukkan Nomor Pesanan / Invoice',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Contoh: INV-20260529-00001',
                              hintStyle: const TextStyle(color: Color(0xFF64748B)),
                              prefixIcon: const Icon(Icons.receipt_long, color: Colors.cyan),
                              filled: true,
                              fillColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.cyan, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Color(0xFF0D9488)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                provider.startTrackingRealOrder(_searchController.text.trim());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tulis nomor invoice terlebih dahulu'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            provider.initializeMockOrder();
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.layers, size: 16, color: Color(0xFF94A3B8)),
                          label: const Text(
                            'Kembali ke Simulasi',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ),
                        if (isMock)
                          const Text(
                            'Mode Simulasi Aktif',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        else
                          const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                              SizedBox(width: 4),
                              Text(
                                'Live Tracking Aktif',
                                style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Loading State / Error State / Main Stepper Layout
              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan)),
                        SizedBox(height: 16),
                        Text(
                          'Menghubungkan ke Server Deposusu...',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF451A03), // Translucent Amber Dark
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Color(0xFFFED7AA), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              if (order != null && !provider.isLoading) ...[
                // Order Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nomor Pesanan',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                          // Premium badge based on current status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isMock
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : Colors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isMock ? 'SIMULASI' : 'REALTIME API',
                              style: TextStyle(
                                color: isMock ? Colors.orangeAccent : Colors.cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'Status Pengantaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stepper Timeline
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: TrackingStepper(currentStatus: order.currentStatus),
                ),
                
                const SizedBox(height: 32),
                
                // Simulation Control (Only visible in mockup simulation mode)
                if (isMock && order.currentStatus != OrderStatus.completed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kamu sedang di Mode Simulasi Offline.\nGunakan tombol di bawah untuk melompat ke status berikutnya.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              provider.simulateNextStatus();
                            },
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            label: const Text(
                              'Simulasikan Status Selanjutnya',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
