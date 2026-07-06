import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/store_provider.dart';
import '../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final store  = context.watch<StoreProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isFav  = store.isFavorite(product.id);
    final cartItem = store.cart.firstWhere(
        (i) => i.product.id == product.id,
        orElse: () => CartItem(product: product, quantity: 0));
    final qty = cartItem.quantity;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: store,
            child: ProductDetailScreen(product: product),
          ),
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.image != null
                        ? CachedNetworkImage(
                            imageUrl: product.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.grey.shade100),
                            errorWidget: (_, __, ___) =>
                                Container(color: Colors.grey.shade100,
                                    child: const Icon(Icons.image, color: Colors.grey)),
                          )
                        : Container(color: Colors.grey.shade100,
                            child: const Icon(Icons.image)),
                  ),
                  // Badge
                  if (product.badge != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(product.badge!,
                            style: TextStyle(color: scheme.onPrimary,
                                fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Favorite button — absorbs tap so card doesn't navigate
                  Positioned(
                    top: 6, right: 6,
                    child: GestureDetector(
                      onTap: () => store.toggleFavorite(product),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.85),
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                          size: 18,
                          color: isFav ? Colors.red : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(children: [
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text('${product.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(' (${product.reviewCount})',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 3),
                  // Name
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  // Price + Add/Qty — absorb tap so card doesn't navigate
                  GestureDetector(
                    onTap: () {}, // absorb
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            if (product.originalPrice != null)
                              Text('\$${product.originalPrice!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        qty > 0
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _Btn(icon: Icons.remove,
                                        onTap: () => store.decrementQuantity(product.id)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('$qty',
                                          style: const TextStyle(fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                                    _Btn(icon: Icons.add,
                                        onTap: () => store.incrementQuantity(product.id)),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () => store.addToCart(product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('Add'),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Icon(icon, size: 14),
      ),
    );
  }
}
