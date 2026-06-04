import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String name;
  final int price;
  int qty;
  final int stock;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.stock,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'qty': qty,
    'stock': stock,
    'isSelected': isSelected,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    qty: json['qty'],
    stock: json['stock'],
    isSelected: json['isSelected'] ?? true,
  );
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isGuest = true; // By default we assume guest until init or sync

  List<CartItem> get items => _items;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('guest_cart');
    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      _items = decoded.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    if (_isGuest) {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('guest_cart', encoded);
    } else {
      // If not guest, we'd typically fire an API call here: 
      // fetch("/cart/update", { items: _items })
      // For now, we simulate server success
    }
  }

  Future<void> syncCartAfterLogin() async {
    _isGuest = false;
    final prefs = await SharedPreferences.getInstance();
    final String? guestCartStr = prefs.getString('guest_cart');
    
    if (guestCartStr != null) {
      final List<dynamic> guestCart = json.decode(guestCartStr);
      if (guestCart.isNotEmpty) {
        // Simulate sending to backend
        print("SYNCING CART TO BACKEND: $guestCartStr");
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Remove guest cart from local storage
        await prefs.remove('guest_cart');
      }
    }
    
    // In a real app, we would now fetch the server cart:
    // _items = await fetchServerCart();
    
    notifyListeners();
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.qty);
  }

  int get cartTotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  int get selectedSubtotal {
    int sum = 0;
    for (var item in _items) {
      if (item.isSelected) {
        sum += (item.price * item.qty);
      }
    }
    return sum;
  }

  int get selectedCount {
    int count = 0;
    for (var item in _items) {
      if (item.isSelected) {
        count += item.qty;
      }
    }
    return count;
  }

  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  void addToCart(String id, String name, int price, int stock, {int qty = 1}) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].qty + qty <= stock) {
        _items[existingIndex].qty += qty;
        _saveCart();
        notifyListeners();
      }
    } else {
      if (stock > 0) {
        _items.add(CartItem(
          id: id,
          name: name,
          price: price,
          qty: qty,
          stock: stock,
          isSelected: true,
        ));
        _saveCart();
        notifyListeners();
      }
    }
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final newQty = _items[index].qty + delta;
      if (newQty > _items[index].stock) {
        return;
      }
      if (newQty <= 0) {
        return;
      }
      _items[index].qty = newQty;
      _saveCart();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  void toggleSelection(String id, bool isSelected) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].stock > 0) {
        _items[index].isSelected = isSelected;
        _saveCart();
        notifyListeners();
      }
    }
  }

  void toggleSelectAll(bool isSelected) {
    for (var item in _items) {
      if (item.stock > 0) {
        item.isSelected = isSelected;
      }
    }
    _saveCart();
    notifyListeners();
  }

  void clearCheckedOutItems() {
    _items.removeWhere((item) => item.isSelected);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}
