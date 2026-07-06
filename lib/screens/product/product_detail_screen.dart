import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product.dart';
import '../../providers/store_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final store  = context.watch<StoreProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isFav  = store.isFavorite(product.id);
    final cartItem = store.cart.firstWhere(
      (i) => i.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    final qty = cartItem.quantity;

    final discountPct = product.originalPrice != null
        ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100)
            .round()
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar with image ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_outline,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => store.toggleFavorite(product),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade100),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image,
                                color: Colors.grey, size: 60),
                          ),
                        )
                      : Container(color: Colors.grey.shade100),
                  // Badge
                  if (product.badge != null)
                    Positioned(
                      top: 56,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.badge!.toUpperCase(),
                          style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8),
                        ),
                      ),
                    ),
                  // Discount badge
                  if (discountPct > 0)
                    Positioned(
                      top: 56,
                      right: 16,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '-$discountPct%',
                          style: TextStyle(
                              color: scheme.onError,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + stock status
                  Row(children: [
                    Icon(Icons.label_outline,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(product.category ?? 'General',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    const Text('·', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    Icon(
                      product.inStock
                          ? Icons.inventory_2_outlined
                          : Icons.remove_shopping_cart_outlined,
                      size: 14,
                      color: product.inStock ? Colors.green : scheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.inStock ? Colors.green : scheme.error),
                    ),
                  ]),
                  const SizedBox(height: 10),

                  // Product name
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Rating row
                  Row(children: [
                    ...List.generate(5, (i) {
                      final filled = i < product.rating.round();
                      return Icon(
                        filled ? Icons.star : Icons.star_outline,
                        size: 18,
                        color: Colors.amber,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text('${product.rating}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(' (${product.reviewCount} reviews)',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),

                  // Price row
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary)),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough),
                          ),
                          Text(
                            'Save \$${(product.originalPrice! - product.price).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const Text('About this product',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(product.description!,
                        style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.6,
                            color: Colors.black87)),
                    const SizedBox(height: 24),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),

                  // Favorite + Add to cart
                  Row(children: [
                    // Favorite button
                    OutlinedButton(
                      onPressed: () => store.toggleFavorite(product),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        color: isFav ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add to cart or qty control
                    Expanded(
                      child: qty > 0
                          ? Container(
                              height: 52,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _RoundBtn(
                                    icon: Icons.remove,
                                    onTap: () => store
                                        .decrementQuantity(product.id),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text('$qty',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const Text('in cart',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  _RoundBtn(
                                    icon: Icons.add,
                                    onTap: () => store
                                        .incrementQuantity(product.id),
                                  ),
                                ],
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: product.inStock
                                  ? () => store.addToCart(product)
                                  : null,
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: Text(product.inStock
                                  ? 'Add to Cart'
                                  : 'Out of Stock'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(icon, size: 18),
      ),
    );
  }
}
