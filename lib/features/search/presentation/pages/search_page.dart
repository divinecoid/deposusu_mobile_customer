import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/product_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  bool _isSubmitted = false;

  // Simulated Data
  final List<String> _recentSearches = ['Aqua', 'Indomie', 'Ultra Milk'];
  final List<Map<String, String>> _popularSearches = [
    {'icon': '🥛', 'label': 'Susu UHT'},
    {'icon': '🍜', 'label': 'Indomie'},
    {'icon': '🥤', 'label': 'Teh Botol'},
    {'icon': '🧼', 'label': 'Rinso'},
  ];

  // Removed hardcoded products


  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Auto focus search bar
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _isSubmitted = false;
    });
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isEmpty) return;
    setState(() {
      _query = value.trim();
      _isSubmitted = true;
      // Add to recent if not exists
      if (!_recentSearches.contains(_query)) {
        _recentSearches.insert(0, _query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFilterOption('Harga Terendah'),
              _buildFilterOption('Harga Tertinggi'),
              _buildFilterOption('Promo'),
              _buildFilterOption('Terlaris'),
              const Divider(),
              _buildFilterOption('Brand'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () => Navigator.pop(context),
      visualDensity: VisualDensity.compact,
    );
  }

  List<Product> _getSearchResults() {
    return context.read<ProductProvider>().searchProducts(_query);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const BackButton(),
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari produk, brand, atau kategori...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  Navigator.pop(context); // Go back to home to see cart
                  // Ideally would switch tab, but going back is fine for now
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return _buildBeforeTypingState();
    } else if (!_isSubmitted) {
      return _buildAutocompleteState();
    } else {
      return _buildResultsState();
    }
  }

  Widget _buildBeforeTypingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const Text('Pencarian Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return InkWell(
                onTap: () {
                  _searchController.text = term;
                  _onSearchSubmitted(term);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(term, style: const TextStyle(fontSize: 14)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        
        const Text('Pencarian Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularSearches.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _popularSearches[index];
            return ListTile(
              leading: Text(item['icon']!, style: const TextStyle(fontSize: 24)),
              title: Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.trending_up, color: Colors.grey, size: 20),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _searchController.text = item['label']!;
                _onSearchSubmitted(item['label']!);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAutocompleteState() {
    final suggestions = _getSearchResults();
    if (suggestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Ketuk "Cari" di keyboard untuk melihat hasil', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.grey),
          title: Text(item.name),
          onTap: () {
            _searchController.text = item.name;
            _onSearchSubmitted(item.name);
          },
        );
      },
    );
  }

  Widget _buildResultsState() {
    final results = _getSearchResults();
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Produk tidak ditemukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Coba gunakan kata kunci lain.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dummy categories/brands based on results
        if (_query.toLowerCase() == 'aqua') ...[
          const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text('AQ', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
              title: const Text('Aqua'),
              trailing: const Icon(Icons.chevron_right),
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: const Icon(Icons.local_drink),
              ),
              title: const Text('Minuman'),
              trailing: const Icon(Icons.chevron_right),
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
        ],

        const Text('Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildProductCard(results[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final cart = context.read<CartProvider>(); // use read for callbacks

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
              child: const Center(
                child: Icon(Icons.image, color: Colors.grey, size: 40),
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
                  _currencyFormat.format(product.price),
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
                        qty: 1
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} ditambahkan ke keranjang'),
                        duration: const Duration(seconds: 1),
                      ));
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
