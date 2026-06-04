import 'package:flutter/material.dart';

class Address {
  final String id;
  final String label; // 'Rumah', 'Kantor', 'Lainnya'
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String note;
  bool isPrimary;

  Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    this.note = '',
    this.isPrimary = false,
  });
}

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [
    Address(
      id: '1',
      label: 'Rumah',
      recipientName: 'Felinika',
      phoneNumber: '08123456789',
      fullAddress: 'Jl. Melati No. 12, Bandung Barat',
      note: 'Rumah pojok cat putih',
      isPrimary: true,
    ),
  ];
  
  String? _activeAddressId = '1';

  List<Address> get addresses => _addresses;
  
  Address? get activeAddress {
    if (_activeAddressId == null && _addresses.isNotEmpty) {
      _activeAddressId = _addresses.firstWhere((a) => a.isPrimary, orElse: () => _addresses.first).id;
    }
    try {
      return _addresses.firstWhere((a) => a.id == _activeAddressId);
    } catch (e) {
      return null;
    }
  }

  Address? get primaryAddress {
    try {
      return _addresses.firstWhere((a) => a.isPrimary);
    } catch (e) {
      return null;
    }
  }

  void addAddress(Address address) {
    if (address.isPrimary || _addresses.isEmpty) {
      _clearPrimary();
      address.isPrimary = true;
      _activeAddressId = address.id;
    }
    _addresses.add(address);
    notifyListeners();
  }

  void deleteAddress(String id) {
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final isDeletingPrimary = _addresses[index].isPrimary;
      _addresses.removeAt(index);
      
      if (isDeletingPrimary && _addresses.isNotEmpty) {
        _addresses.first.isPrimary = true;
        if (_activeAddressId == id) {
          _activeAddressId = _addresses.first.id;
        }
      } else if (_addresses.isEmpty) {
        _activeAddressId = null;
      }
      notifyListeners();
    }
  }

  void setPrimary(String id) {
    _clearPrimary();
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _addresses[index].isPrimary = true;
      notifyListeners();
    }
  }

  void setActiveAddress(String id) {
    _activeAddressId = id;
    notifyListeners();
  }

  void _clearPrimary() {
    for (var address in _addresses) {
      address.isPrimary = false;
    }
  }
}
