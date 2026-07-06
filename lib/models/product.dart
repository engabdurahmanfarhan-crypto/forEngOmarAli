class Product {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final String category;
  final double rating;
  final int reviewCount;
  final String? image;
  final String? badge;
  final bool inStock;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.image,
    this.badge,
    required this.inStock,
    this.description,
  });

  /// From Supabase products table row
  factory Product.fromRow(Map<String, dynamic> row) {
    return Product(
      id:            row['id'] as int,
      name:          row['name'] as String,
      price:         (row['price'] as num).toDouble(),
      originalPrice: row['original_price'] != null
          ? (row['original_price'] as num).toDouble()
          : null,
      category:     row['category'] as String,
      rating:       (row['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount:  (row['review_count'] as int?) ?? 10,
      image:        row['image'] as String?,
      badge:        row['badge'] as String?,
      inStock:      row['in_stock'] as bool? ?? true,
      description:  row['description'] as String?,
    );
  }

  /// From favorites.product_data JSONB column
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:            json['id'] as int,
      name:          json['name'] as String,
      price:         (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      category:     json['category'] as String,
      rating:       (json['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount:  (json['reviewCount'] as int?) ?? 10,
      image:        json['image'] as String?,
      badge:        json['badge'] as String?,
      inStock:      json['inStock'] as bool? ?? true,
      description:  json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
    'price':         price,
    'originalPrice': originalPrice,
    'category':      category,
    'rating':        rating,
    'reviewCount':   reviewCount,
    'image':         image,
    'badge':         badge,
    'inStock':       inStock,
    'description':   description,
  };

  /// Map to Supabase products table row
  Map<String, dynamic> toRow() => {
    'id':             id,
    'name':           name,
    'price':          price,
    'original_price': originalPrice,
    'category':       category,
    'rating':         rating,
    'review_count':   reviewCount,
    'image':          image,
    'badge':          badge,
    'in_stock':       inStock,
    'description':    description,
  };
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}
