import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/store_provider.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'cart/cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Load products when main screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    final screens = const [
      HomeScreen(),
      FavoritesScreen(),
      CartScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: store.favorites.isNotEmpty,
              label: Text('${store.favorites.length}'),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: store.favorites.isNotEmpty,
              label: Text('${store.favorites.length}'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: store.cartCount > 0,
              label: Text('${store.cartCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: store.cartCount > 0,
              label: Text('${store.cartCount}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
