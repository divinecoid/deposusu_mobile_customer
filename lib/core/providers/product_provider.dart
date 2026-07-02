import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final bool isBestSeller;
  final bool isPromo;
  final bool isNew;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isBestSeller = false,
    this.isPromo = false,
    this.isNew = false,
    this.stock = 100,
  });
}

class ProductProvider with ChangeNotifier {
  // Mock Database
  final List<Product> _products = [
    // Buah
    Product(id: '1', name: 'Apel Fuji', price: 15000, category: 'buah', isBestSeller: true, isNew: true),
    Product(id: '2', name: 'Pisang Cavendish', price: 20000, category: 'buah', isPromo: true),
    
    // Protein
    Product(id: '3', name: 'Daging Ayam Paha 1kg', price: 45000, category: 'protein', isBestSeller: true),
    Product(id: '4', name: 'Telur Ayam Negeri', price: 28000, category: 'protein', isPromo: true),
    
    // Siap Saji
    Product(id: '5', name: 'Nugget Fiesta 500g', price: 48000, category: 'siap_saji', isBestSeller: true),
    Product(id: '6', name: 'Sosis Kanzler', price: 35000, category: 'siap_saji', isNew: true),
    
    // Makanan Ringan
    Product(id: '7', name: 'Chitato Sapi Panggang', price: 12000, category: 'makanan_ringan', isPromo: true),
    Product(id: '8', name: 'Oreo Original', price: 8500, category: 'makanan_ringan'),
    
    // Sembako
    Product(id: '9', name: 'Beras Sania 5kg', price: 65000, category: 'sembako', isBestSeller: true),
    Product(id: '10', name: 'Minyak Goreng Bimoli 2L', price: 36000, category: 'sembako', isPromo: true),
    
    // Susu & Olahan
    Product(id: '11', name: 'Ultra Milk Full Cream 1L', price: 18000, category: 'susu', isBestSeller: true),
    Product(id: '12', name: 'Keju Kraft Cheddar', price: 22000, category: 'susu', isNew: true),
    
    // Minuman Ringan
    Product(id: '13', name: 'Aqua 600ml', price: 4000, category: 'minuman_ringan', isBestSeller: true),
    Product(id: '14', name: 'Teh Botol Sosro', price: 5000, category: 'minuman_ringan', isPromo: true),
    
    // Perawatan Rumah
    Product(id: '15', name: 'Rinso Anti Noda 700g', price: 25000, category: 'perawatan_rumah', isBestSeller: true),
    Product(id: '16', name: 'Sunlight Jeruk Nipis', price: 15000, category: 'perawatan_rumah'),
    
    // Bumbu & Saus
    Product(id: '17', name: 'Kecap Bango 520ml', price: 24000, category: 'bumbu_saus', isBestSeller: true),
    Product(id: '18', name: 'Saus Sambal ABC', price: 12000, category: 'bumbu_saus', isPromo: true),
    
    // Perawatan Diri
    Product(id: '19', name: 'Lifebuoy Sabun Cair', price: 30000, category: 'perawatan_diri', isBestSeller: true),
    Product(id: '20', name: 'Pepsodent 190g', price: 16000, category: 'perawatan_diri', isPromo: true),
  ];

  List<Product> get allProducts => _products;

  List<Product> getProductsByCategory(String category) {
    if (category == 'semua') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final lowerQuery = query.toLowerCase();
    
    // Simple typo tolerance simulation
    String effectiveQuery = lowerQuery;
    if (lowerQuery == 'indomi') effectiveQuery = 'indomie';

    return _products.where((p) {
      return p.name.toLowerCase().contains(effectiveQuery) ||
             p.category.toLowerCase().contains(effectiveQuery);
    }).toList();
  }
}
