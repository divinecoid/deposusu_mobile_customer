import 'package:flutter/material.dart';
import '../../data/models/order_tracking_model.dart';
import '../../../../core/theme/app_theme.dart';

class TrackingStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  
  const TrackingStepper({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          context: context,
          title: 'Diproses',
          emoji: '🛒',
          isActive: currentStatus.index >= OrderStatus.pending.index,
          isLast: false,
        ),
        _buildStep(
          context: context,
          title: 'Dikemas',
          emoji: '📦',
          isActive: currentStatus.index >= OrderStatus.prepared.index,
          isLast: false,
        ),
        _buildStep(
          context: context,
          title: 'Dikirim',
          emoji: '🚚',
          isActive: currentStatus.index >= OrderStatus.delivering.index,
          isLast: false,
        ),
        _buildStep(
          context: context,
          title: 'Selesai',
          emoji: '✅',
          isActive: currentStatus.index >= OrderStatus.completed.index,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required String title,
    required String emoji,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isActive ? AppTheme.deposusuBlue : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column for icon and line
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.1) : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Right column for texts
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getDescription(title),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDescription(String title) {
    switch (title) {
      case 'Diproses':
        return 'Pesanan Anda telah kami terima dan sedang diproses.';
      case 'Dikemas':
        return 'Pesanan sedang disiapkan dan dikemas dengan rapi.';
      case 'Dikirim':
        return 'Kurir kami sedang mengantarkan pesanan ke tempat Anda.';
      case 'Selesai':
        return 'Pesanan telah tiba di tujuan.';
      default:
        return '';
    }
  }
}
