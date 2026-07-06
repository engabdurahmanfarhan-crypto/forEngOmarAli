import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store  = context.watch<StoreProvider>();
    final scheme = Theme.of(context).colorScheme;

    final shipping = store.cartTotal > 100 ? 0.0 : (store.cart.isEmpty ? 0.0 : 9.99);
    final total    = store.cartTotal + shipping;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${store.cart.length} ${store.cart.length == 1 ? 'item' : 'items'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: store.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.shopping_cart_outlined, size: 56, color: scheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Add products from the Home screen.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: store.cart.length,
                    itemBuilder: (_, i) {
                      final item = store.cart[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item.product.image != null
                                    ? Image.network(item.product.image!,
                                        width: 70, height: 70, fit: BoxFit.cover)
                                    : Container(
                                        width: 70, height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(item.product.category,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Qty control
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _QtyBtn(
                                                icon: Icons.remove,
                                                onTap: () => store.decrementQuantity(item.product.id),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text('${item.quantity}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                              _QtyBtn(
                                                icon: Icons.add,
                                                onTap: () => store.incrementQuantity(item.product.id),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Price
                                        Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Delete
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => store.removeFromCart(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Order summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: '\$${store.cartTotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'Shipping',
                        value: shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
                        valueColor: shipping == 0 ? Colors.green : null,
                      ),
                      if (store.cartTotal > 0 && store.cartTotal <= 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: scheme.primary.withOpacity(.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Add \$${(100 - store.cartTotal).toStringAsFixed(2)} more for free shipping',
                              style: TextStyle(fontSize: 12, color: scheme.primary),
                            ),
                          ),
                        ),
                      const Divider(height: 20),
                      _SummaryRow(
                        label: 'Total', value: '\$${total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showCheckoutDialog(context, store),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary),
                          child: const Text('Checkout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showCheckoutDialog(BuildContext context, StoreProvider store) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Order Placed!', textAlign: TextAlign.center),
        content: Text(
          'Thank you for your order!\nOrder #${DateTime.now().millisecondsSinceEpoch % 100000}',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () { store.clearCart(); Navigator.pop(context); },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value,
      this.isBold = false, this.valueColor});
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 17 : 14,
      color: isBold ? null : Colors.grey.shade700,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: valueColor)),
      ],
    );
  }
}
