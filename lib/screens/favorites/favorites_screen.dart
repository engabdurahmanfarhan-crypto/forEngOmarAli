import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${store.favorites.length} saved items',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: store.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.favorite_outline,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No favorites yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68),
              itemCount: store.favorites.length,
              itemBuilder: (_, i) => ProductCard(product: store.favorites[i]),
            ),
    );
  }
}
