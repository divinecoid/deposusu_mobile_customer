import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/address_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import '../../../account/presentation/pages/add_address_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../cart/presentation/pages/checkout_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<Map<String, String>> categories = [
    {'key': 'semua', 'label': 'Semua', 'icon': '🔍'},
    {'key': 'buah', 'label': 'Buah', 'icon': '🍎'},
    {'key': 'protein', 'label': 'Protein', 'icon': '🍗'},
    {'key': 'siap_saji', 'label': 'Siap Saji', 'icon': '🍱'},
    {'key': 'sayur', 'label': 'Sayur', 'icon': '🥬'},
    {'key': 'susu', 'label': 'Susu & Dairy', 'icon': '🥛'},
    {'key': 'frozen_food', 'label': 'Frozen Food', 'icon': '❄️'},
    {'key': 'minuman_ringan', 'label': 'Minuman', 'icon': '🥤'},
    {'key': 'makanan_ringan', 'label': 'Snack', 'icon': '🍪'},
    {'key': 'bumbu_saus', 'label': 'Bumbu Dapur', 'icon': '🧂'},
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Prepare 12 slots for the grid (10 filled, 2 empty)
    final List<Map<String, String>?> filledCategories = List.from(categories);
    while (filledCategories.length < 12) {
      filledCategories.add(null);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 90, // Increased height to fit logo and slogan
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
        title: Consumer<AddressProvider>(
          builder: (context, provider, child) {
            final activeAddress = provider.activeAddress;
            return GestureDetector(
              onTap: () {
                _showAddressBottomSheet(context, provider);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DEPOSUSU',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 22, // slightly larger
                            fontWeight: FontWeight.w900, // much thicker
                            letterSpacing: 1.0, // extra spacing
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                activeAddress != null ? lang.t(activeAddress.label == 'Rumah' ? 'location_home' : activeAddress.label == 'Kantor' ? 'location_office' : 'location_other') : lang.t('location_choose'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchPage()),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: lang.t('search_hint'),
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Banner Promo
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          lang.t('shortcut_promo'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Shortcuts
                    Row(
                      children: [
                        Expanded(
                          child: _buildLargeShortcut(context, '🔥', lang.t('shortcut_promo'), Colors.orange),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLargeShortcut(context, '⭐', lang.t('shortcut_best_seller'), Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Category Grid 4x3 (12 slots)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0, // Square
                      ),
                      itemCount: filledCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filledCategories[index];
                        if (cat == null) {
                          return const SizedBox.shrink(); // Empty slot
                        }
                        return _buildCategoryChip(context, cat['key']!, cat['icon']!, cat['label']!);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Belanja Lagi
                    _buildSectionTitle(lang.t('section_shop_again'), lang.t('see_all')),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (context, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) => _buildSmallProductCard(context),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Produk Populer
                    _buildSectionTitle(lang.t('section_popular'), lang.t('see_all')),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (context, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) => SizedBox(
                          width: 160, // Fixed width for horizontal scrolling list
                          child: _buildStandardProductCard(context, 'popular_$index', 'Susu Segar $index Liter', 25000, 10, cart),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Diskon Hari Ini Title
                    _buildSectionTitle(lang.t('section_discount'), lang.t('see_all')),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // Diskon Hari Ini Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     childAspectRatio: 0.70,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildStandardProductCard(context, 'discount_$index', 'Promo Produk $index', 15000, 5, cart);
                    },
                    childCount: 6,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Padding for floating cart
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutPage()),
                  );
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
                      Text(
                        lang.t('cart_checkout'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildSectionTitle(String title, String seeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          seeAll,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLargeShortcut(BuildContext context, String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String id, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(initialCategory: id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.w600, 
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallProductCard(BuildContext context) {
    return Container(
      width: 120,
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
                child: Icon(Icons.image, color: Colors.grey, size: 30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Susu Segar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp 25.000',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardProductCard(BuildContext context, String id, String name, int price, int stock, CartProvider cart) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
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
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(price),
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
                      cart.addToCart(id, name, price, stock, qty: 1);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name ditambahkan ke keranjang')));
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
                    child: Text(Provider.of<LanguageProvider>(context).t('btn_add'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context, AddressProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lang = Provider.of<LanguageProvider>(context);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.t('address_select_title'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              if (provider.addresses.isEmpty) ...[
                Center(
                  child: Text(lang.t('address_empty'), style: const TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 16),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = provider.addresses[index];
                    final isActive = address.id == provider.activeAddress?.id;
                    return ListTile(
                      leading: Icon(
                        address.label == 'Rumah' ? Icons.home : 
                        address.label == 'Kantor' ? Icons.business : Icons.place,
                        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      title: Row(
                        children: [
                          Text(address.label, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                          if (address.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(lang.t('address_primary'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(address.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: isActive ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                      onTap: () {
                        provider.setActiveAddress(address.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage()));
                  },
                  icon: const Icon(Icons.add),
                  label: Text(lang.t('address_add_btn')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
