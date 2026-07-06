import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_card.dart';

const _categories = ['All', 'Electronics', 'Clothing', 'Home & Kitchen', 'Sports', 'Beauty'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store  = context.watch<StoreProvider>();
    final auth   = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    final filtered = store.products.where((p) {
      final matchCat = _activeCategory == 'All' || p.category == _activeCategory;
      final matchQ   = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQ;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: scheme.primary, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.shopping_bag_rounded, color: scheme.onPrimary, size: 20),
          ),
          const SizedBox(width: 8),
          const Text('Aura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ]),
        actions: [
          // User avatar + sign out
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton(
              child: CircleAvatar(
                backgroundColor: scheme.primary,
                radius: 17,
                child: Text(
                  (auth.currentUser?.email ?? '?').substring(0, 2).toUpperCase(),
                  style: TextStyle(color: scheme.onPrimary,
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                PopupMenuItem<dynamic>(
                  enabled: false,
                  child: Text(auth.currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<dynamic>(
                  value: 'signout',
                  child: const Row(children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
              onSelected: (value) {
                if (value == 'signout') context.read<AuthProvider>().signOut();
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline banner
          if (store.isOffline)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('Offline mode — showing cached data',
                        style: TextStyle(fontSize: 12))),
                TextButton(
                    onPressed: store.loadProducts,
                    child: const Text('Retry', style: TextStyle(fontSize: 12))),
              ]),
            ),

          // Category chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: _categories.map((cat) {
                final active = cat == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: active,
                    onSelected: (_) => setState(() => _activeCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Header row
          if (!store.loading && store.error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeCategory == 'All' ? 'All Products' : _activeCategory,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('${filtered.length} items',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          // Grid
          Expanded(
            child: store.loading
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 12,
                        crossAxisSpacing: 12, childAspectRatio: 0.68),
                    itemCount: 8,
                    itemBuilder: (_, __) => const SkeletonCard(),
                  )
                : store.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('Could not load products'),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: store.loadProducts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 60, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('No products found'),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, mainAxisSpacing: 12,
                                crossAxisSpacing: 12, childAspectRatio: 0.68),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => ProductCard(product: filtered[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
