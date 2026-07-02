import 'package:flutter/material.dart';
import '../../data/models/order_tracking_model.dart';

class TrackingStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  final String? paymentMethod;
  final String? paymentStatus;
  
  const TrackingStepper({
    super.key,
    required this.currentStatus,
    this.paymentMethod,
    this.paymentStatus,
  });

  int _getCurrentState() {
    final isCOD = paymentMethod == 'COD' || paymentMethod == 'PAY_ON_DELIVERY';
    
    if (currentStatus == OrderStatus.completed) return 4;
    if (currentStatus == OrderStatus.delivering) return 3;
    
    if (!isCOD && paymentStatus == 'PENDING') {
      return 1; // Menunggu Pembayaran
    }
    
    return 2; // Diproses
  }

  IconData _getIconForIndex(int index, int currentState) {
    if (currentState == 1) { // Menunggu Pembayaran
      return index == 0 ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    } else if (currentState == 2) { // Diproses
      if (index <= 1) return Icons.circle;
      return Icons.radio_button_unchecked;
    } else if (currentState == 3) { // Dikirim
      if (index <= 2) return Icons.circle;
      return Icons.radio_button_unchecked;
    } else if (currentState == 4) { // Selesai
      return Icons.circle;
    }
    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _getCurrentState();
    final labels = ['Bayar', 'Proses', 'Kirim', 'Selesai'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final iconData = _getIconForIndex(index, currentState);
            // In Flutter 3.10+, we can use size. 
            // For a minimal look, we'll use black/white theme adapting colors
            final iconColor = (iconData == Icons.radio_button_unchecked) 
                ? Colors.grey.shade600 
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87);
                
            Widget node = Icon(iconData, color: iconColor, size: 24);
            
            if (index == 3) {
              return node;
            }
            
            // Generate lines between nodes
            // If current index and next index are both filled/active, line is solid.
            // For state 1: none are solid except none.
            // For state 2: line 0-1 is solid.
            // For state 3: line 0-1, 1-2 are solid.
            // For state 4: all solid.
            bool isLineSolid = false;
            if (currentState >= 2 && index == 0) isLineSolid = true;
            if (currentState >= 3 && index <= 1) isLineSolid = true;
            if (currentState == 4) isLineSolid = true;

            return Expanded(
              child: Row(
                children: [
                  node,
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isLineSolid 
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                        : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final isReached = currentState > index || (currentState == 1 && index == 0);
            return SizedBox(
              width: 60,
              child: Text(
                labels[index],
                textAlign: index == 0 ? TextAlign.left : (index == 3 ? TextAlign.right : TextAlign.center),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                  color: isReached 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                    : Colors.grey.shade600,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _buildStatusDescription(currentState, context),
      ],
    );
  }

  Widget _buildStatusDescription(int state, BuildContext context) {
    String title = '';
    String desc = '';
    
    if (state == 1) {
      title = 'Menunggu Pembayaran';
      desc = 'Silakan selesaikan pembayaran agar pesanan dapat diproses.';
    } else if (state == 2) {
      title = 'Pesanan Diproses';
      desc = 'Pesanan Anda telah kami terima dan sedang disiapkan.';
    } else if (state == 3) {
      title = 'Pesanan Dikirim';
      desc = 'Driver kami sedang mengantarkan pesanan ke tempat Anda.';
    } else if (state == 4) {
      title = 'Pesanan Selesai';
      desc = 'Pesanan telah berhasil diterima. Terima kasih!';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withValues(alpha: 0.05) 
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12, 
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade400 
                  : Colors.grey.shade700
            ),
          ),
        ],
      ),
    );
  }
}
