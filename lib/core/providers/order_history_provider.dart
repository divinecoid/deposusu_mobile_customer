import 'package:flutter/material.dart';
import '../../features/tracking/data/models/order_tracking_model.dart';

class OrderHistoryProvider extends ChangeNotifier {
  final List<OrderTrackingModel> _orders = [];

  List<OrderTrackingModel> get orders => _orders;

  void addOrder(OrderTrackingModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
