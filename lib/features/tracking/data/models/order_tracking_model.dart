enum OrderStatus {
  pending,      // 🛒 Diproses
  prepared,     // 📦 Dikemas
  delivering,   // 🚚 Dikirim
  completed,    // ✅ Selesai
}

class OrderTrackingModel {
  final String orderNumber;
  final OrderStatus currentStatus;
  final DateTime estimatedDeliveryTime;
  final List<TrackingHistoryItem> history;
  final String? paymentMethod;
  final String? paymentStatus;

  OrderTrackingModel({
    required this.orderNumber,
    required this.currentStatus,
    required this.estimatedDeliveryTime,
    required this.history,
    this.paymentMethod,
    this.paymentStatus,
  });
}

class TrackingHistoryItem {
  final OrderStatus status;
  final DateTime timestamp;

  TrackingHistoryItem({
    required this.status,
    required this.timestamp,
  });
}
