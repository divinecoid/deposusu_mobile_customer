import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../orders/presentation/pages/order_history_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';

import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> _buildPages(LanguageProvider lang) {
    return [
      const HomePage(),
      const CartPage(),
      const OrderHistoryPage(),
      const AccountPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _buildPages(provider)[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: provider.t('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart),
                label: provider.t('nav_cart'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long),
                label: provider.t('nav_orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: provider.t('nav_account'),
              ),
            ],
          ),
        );
      },
    );
  }
}
