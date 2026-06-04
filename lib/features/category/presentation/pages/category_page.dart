import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/product_provider.dart';

class CategoryPage extends StatefulWidget {
  final String initialCategory;

  const CategoryPage({
    super.key,
    required this.initialCategory,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String activeCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'key': 'buah', 'label': 'Buah', 'icon': '🍎'},
    {'key': 'protein', 'label': 'Protein', 'icon': '🍗'},
    {'key': 'siap_saji', 'label': 'Siap Saji', 'icon': '🍱'},
    {'key': 'makanan_ringan', 'label': 'Cemilan', 'icon': '🍪'},
    {'key': 'sembako', 'label': 'Sembako', 'icon': '🛒'},
    {'key': 'susu', 'label': 'Susu', 'icon': '🥛'},
    {'key': 'minuman_ringan', 'label': 'Minuman', 'icon': '🥤'},
    {'key': 'perawatan_rumah', 'label': 'Rumah', 'icon': '🧼'},
    {'key': 'bumbu_saus', 'label': 'Bumbu', 'icon': '🧂'},
    {'key': 'perawatan_diri', 'label': 'Perawatan Diri', 'icon': '🧴'},
  ];

  @override
  void initState() {
    super.initState();
    activeCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void handleCategoryClick(String key) {
    setState(() {
      activeCategory = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Filter products based on activeCategory AND searchQuery
    var filteredProducts = productProvider.getProductsByCategory(activeCategory);
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar (Search & Back)
                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      BackButton(color: Theme.of(context).primaryColor),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Cari di kategori ini...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // Category Scroll (Sticky Header)
                Container(
                  color: Theme.of(context).cardColor,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: categories.map((c) {
                        final isActive = activeCategory == c['key'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => handleCategoryClick(c['key']!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c['label']!,
                                style: TextStyle(
                                  color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Divider
                Divider(height: 1, color: Theme.of(context).dividerColor.withAlpha(20)),

                // Product Grid
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text('Produk tidak ditemukan.', style: TextStyle(color: Colors.grey)),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // padding bottom for floating cart
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _buildProductCard(context, product, cart, currencyFormat);
                          },
                        ),
                ),
              ],
            ),

            // Floating Cart
            if (cart.items.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to view cart on home
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cart.totalItems} Barang',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              currencyFormat.format(cart.cartTotal),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Lihat Keranjang',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, CartProvider cart, NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                  if (product.isPromo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Promo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (product.isBestSeller && !product.isPromo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Terlaris', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(product.price),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cart.addToCart(
                        product.id,
                        product.name,
                        product.price,
                        product.stock,
                        qty: 1,
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.name} ditambah ke keranjang'), duration: const Duration(seconds: 1)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
