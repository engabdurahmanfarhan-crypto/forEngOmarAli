import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

const _dummyApi = 'https://dummyjson.com/products?limit=30';

const _categoryMap = {
  'smartphones': 'Electronics', 'laptops': 'Electronics',
  'mobile-accessories': 'Electronics', 'tablets': 'Electronics',
  'mens-shirts': 'Clothing', 'womens-tops': 'Clothing',
  'womens-dresses': 'Clothing', 'mens-shoes': 'Clothing',
  'womens-shoes': 'Clothing', 'womens-bags': 'Clothing',
  'womens-jewellery': 'Clothing', 'sunglasses': 'Clothing', 'tops': 'Clothing',
  'furniture': 'Home & Kitchen', 'home-decoration': 'Home & Kitchen',
  'kitchen-accessories': 'Home & Kitchen',
  'sports-accessories': 'Sports', 'motorcycle': 'Sports', 'vehicle': 'Sports',
  'beauty': 'Beauty', 'fragrances': 'Beauty',
  'skin-care': 'Beauty', 'groceries': 'Beauty',
};

class StoreProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  // ── Real-time stream subscriptions ───────────────────────────────────────
  StreamSubscription<List<Map<String, dynamic>>>? _productsStream;
  StreamSubscription<List<Map<String, dynamic>>>? _favoritesStream;

  List<Product>  _products  = [];
  List<Product>  _favorites = [];
  List<CartItem> _cart      = [];
  bool    _loading   = false;
  bool    _isOffline = false;
  String? _error;

  List<Product>  get products  => List.unmodifiable(_products);
  List<Product>  get favorites => List.unmodifiable(_favorites);
  List<CartItem> get cart      => List.unmodifiable(_cart);
  bool    get loading   => _loading;
  bool    get isOffline => _isOffline;
  String? get error     => _error;

  double get cartTotal =>
      _cart.fold(0, (sum, item) => sum + item.total);
  int    get cartCount =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  // Called by ProxyProvider in main.dart when auth state changes
  void onAuthChanged(User? user) {
    if (user == null) {
      _favoritesStream?.cancel();
      _favoritesStream = null;
      _favorites = [];
      notifyListeners();
    } else {
      _subscribeToFavorites(user.id);
    }
  }

  // ── Exercise 2: Load from API + Real-time stream from Supabase ───────────
  Future<void> loadProducts() async {
    _loading = true;
    _error   = null;
    notifyListeners();

    // Step 1 — Start real-time stream first so UI reacts immediately
    _subscribeToProducts();

    // Step 2 — Fetch fresh data from API and upsert into Supabase
    try {
      final res = await http
          .get(Uri.parse(_dummyApi))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body  = jsonDecode(res.body) as Map<String, dynamic>;
        final items = (body['products'] as List<dynamic>)
            .asMap()
            .entries
            .map((e) => _mapDummy(e.value, e.key))
            .toList();

        // Upsert → triggers the real-time stream above automatically
        await _client.from('products').upsert(
          items.map((p) => p.toRow()).toList(),
          onConflict: 'id',
        );
        _isOffline = false;
      }
    } catch (_) {
      // API failed — the stream will still show cached data from Supabase
      _isOffline = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Exercise 2 — Real-time stream: products table → updates UI automatically
  void _subscribeToProducts() {
    _productsStream?.cancel();
    _productsStream = _client
        .from('products')
        .stream(primaryKey: ['id'])
        .listen(
          (rows) {
            if (rows.isNotEmpty) {
              _products = rows.map((r) => Product.fromRow(r)).toList();
              _loading  = false;
              notifyListeners();
            }
          },
          onError: (_) {
            _isOffline = true;
            notifyListeners();
          },
        );
  }

  // ── Exercise 3: Real-time favorites per user ─────────────────────────────

  /// Exercise 3 — Real-time stream: users/{uid}/favorites → live sync
  void _subscribeToFavorites(String uid) {
    _favoritesStream?.cancel();
    _favoritesStream = _client
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .listen(
          (rows) {
            _favorites = rows
                .map((r) =>
                    Product.fromJson(r['product_data'] as Map<String, dynamic>))
                .toList();
            notifyListeners();
          },
          onError: (_) {},
        );
  }

  bool isFavorite(int productId) =>
      _favorites.any((p) => p.id == productId);

  /// Exercise 3 — Add/remove from favorites, synced to Supabase in real-time
  Future<void> toggleFavorite(Product product) async {
    final uid    = _client.auth.currentUser?.id;
    final wasFav = isFavorite(product.id);

    // Optimistic local update for instant UI feedback
    if (wasFav) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();

    if (uid == null) return;

    try {
      if (!wasFav) {
        // add() equivalent — upsert to users/{uid}/favorites
        await _client.from('favorites').upsert({
          'user_id':      uid,
          'product_id':   product.id,
          'product_data': product.toJson(),
        }, onConflict: 'user_id,product_id');
      } else {
        // remove() equivalent
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', uid)
            .eq('product_id', product.id);
      }
      // The real-time stream will confirm the change automatically
    } catch (_) {
      // Rollback optimistic update on error
      if (!wasFav) {
        _favorites.removeWhere((p) => p.id == product.id);
      } else {
        _favorites.add(product);
      }
      notifyListeners();
    }
  }

  // ── Cart operations ────────────────────────────────────────────────────────
  void addToCart(Product product) {
    final idx = _cart.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cart[idx].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void incrementQuantity(int productId) {
    final idx = _cart.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) { _cart[idx].quantity++; notifyListeners(); }
  }

  void decrementQuantity(int productId) {
    final idx = _cart.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (_cart[idx].quantity <= 1) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity--;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _productsStream?.cancel();
    _favoritesStream?.cancel();
    super.dispose();
  }

  // ── Helper: map dummyjson product to Product model ─────────────────────────
  Product _mapDummy(dynamic p, int index) {
    final disc  = (p['discountPercentage'] as num?)?.toDouble() ?? 0.0;
    final orig  = (p['price'] as num).toDouble();
    final price = disc > 0 ? orig * (1 - disc / 100) : orig;
    String? badge;
    if (disc >= 15)    badge = 'Sale';
    else if ((p['stock'] as int? ?? 10) < 20) badge = 'Hot';
    else if (index < 4) badge = 'New';
    return Product(
      id:            p['id'] as int,
      name:          p['title'] as String,
      price:         double.parse(price.toStringAsFixed(2)),
      originalPrice: disc > 0 ? orig : null,
      category:      _categoryMap[p['category']] ?? 'Other',
      rating:        (p['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount:   (p['reviews'] as List?)?.length ?? 10,
      image:         p['thumbnail'] as String?,
      badge:         badge,
      inStock:       (p['stock'] as int? ?? 1) > 0,
      description:   p['description'] as String?,
    );
  }
}
