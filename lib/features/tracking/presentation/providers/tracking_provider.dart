import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../data/models/order_tracking_model.dart';

class TrackingProvider extends ChangeNotifier {
  OrderTrackingModel? _currentOrder;
  OrderTrackingModel? get currentOrder => _currentOrder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _trackingTimer;
  String? _activeTrackingNumber;

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void initializeMockOrder() {
    _activeTrackingNumber = null;
    _trackingTimer?.cancel();
    _errorMessage = null;
    
    _currentOrder = OrderTrackingModel(
      orderNumber: 'TRX-101 (Simulasi)',
      currentStatus: OrderStatus.pending,
      estimatedDeliveryTime: DateTime.now().add(const Duration(hours: 1)),
      history: [
        TrackingHistoryItem(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
    );
    notifyListeners();
  }

  // Real-time Order Tracking via Laravel API
  Future<void> startTrackingRealOrder(String orderNumber) async {
    _activeTrackingNumber = orderNumber;
    _errorMessage = null;
    _trackingTimer?.cancel();

    // Fetch immediately
    await fetchOrderTracking(orderNumber);

    // Setup periodic polling every 5 seconds for real-time updates
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_activeTrackingNumber != null) {
        await fetchOrderTracking(_activeTrackingNumber!, isSilent: true);
      }
    });
  }

  Future<void> fetchOrderTracking(String orderNumber, {bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/track/$orderNumber'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          final String statusStr = data['status'];
          final String orderNum = data['order_number'];
          final String createdAtStr = data['created_at'];
          final DateTime createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

          // Map database status string to OrderStatus enum
          OrderStatus currentStatus = OrderStatus.pending;
          if (statusStr == 'prepared') {
            currentStatus = OrderStatus.prepared;
          } else if (statusStr == 'ondelivery') {
            currentStatus = OrderStatus.delivering;
          } else if (statusStr == 'delivered' || statusStr == 'done') {
            currentStatus = OrderStatus.completed;
          }

          // Build chronological history based on current status
          final List<TrackingHistoryItem> history = [];
          
          // 1. Pending (Diproses)
          history.add(TrackingHistoryItem(
            status: OrderStatus.pending,
            timestamp: createdAt,
          ));

          // 2. Prepared (Dikemas)
          if (currentStatus.index >= OrderStatus.prepared.index) {
            history.add(TrackingHistoryItem(
              status: OrderStatus.prepared,
              timestamp: createdAt.add(const Duration(minutes: 10)),
            ));
          }

          // 3. Delivering (Dikirim)
          if (currentStatus.index >= OrderStatus.delivering.index) {
            history.add(TrackingHistoryItem(
              status: OrderStatus.delivering,
              timestamp: createdAt.add(const Duration(minutes: 15)),
            ));
          }

          // 4. Completed (Selesai)
          if (currentStatus.index >= OrderStatus.completed.index) {
            history.add(TrackingHistoryItem(
              status: OrderStatus.completed,
              timestamp: createdAt.add(const Duration(minutes: 25)),
            ));
          }

          _currentOrder = OrderTrackingModel(
            orderNumber: orderNum,
            currentStatus: currentStatus,
            estimatedDeliveryTime: createdAt.add(const Duration(hours: 1)),
            history: history,
          );
          _errorMessage = null;
        } else {
          _errorMessage = decoded['message'] ?? 'Gagal mengambil detail pelacakan.';
        }
      } else {
        final decoded = jsonDecode(response.body);
        _errorMessage = decoded['message'] ?? 'Gagal menghubungi server.';
      }
    } catch (e) {
      print('Tracking API Error: $e');
      if (!isSilent) {
        _errorMessage = 'Gagal terhubung ke server. Pastikan koneksi aktif.';
      }
    } finally {
      if (!isSilent || _errorMessage != null) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Simulation method to advance status (Offline Mock Fallback)
  void simulateNextStatus() {
    if (_currentOrder == null) return;
    
    final currentStatusIndex = _currentOrder!.currentStatus.index;
    if (currentStatusIndex < OrderStatus.values.length - 1) {
      final nextStatus = OrderStatus.values[currentStatusIndex + 1];
      
      final updatedHistory = List<TrackingHistoryItem>.from(_currentOrder!.history);
      updatedHistory.add(
        TrackingHistoryItem(
          status: nextStatus,
          timestamp: DateTime.now(),
        ),
      );

      _currentOrder = OrderTrackingModel(
        orderNumber: _currentOrder!.orderNumber,
        currentStatus: nextStatus,
        estimatedDeliveryTime: _currentOrder!.estimatedDeliveryTime,
        history: updatedHistory,
      );
      notifyListeners();
    }
  }
}
