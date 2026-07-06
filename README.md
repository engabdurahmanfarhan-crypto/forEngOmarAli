# Aura — Flutter E-Commerce App

تطبيق تجارة إلكترونية مبني بـ Flutter + Supabase يغطي التمارين الأربعة

---

## التمارين المُنجزة

| # | التمرين | الملف |
|---|---------|-------|
| 1 | Auth بالبريد وكلمة المرور | `lib/screens/auth/auth_screen.dart` + `lib/providers/auth_provider.dart` |
| 2 | قراءة المنتجات من Supabase `products` | `lib/providers/store_provider.dart` → `loadProducts()` |
| 3 | مفضلة خاصة بكل مستخدم `users/{uid}/favorites` | `lib/providers/store_provider.dart` → `loadFavorites()` / `toggleFavorite()` |

---

## 

---

## 
---

## هيكل الملفات

```
lib/
├── main.dart                   # نقطة البداية + AppGate (auth listener)
├── models/
│   └── product.dart            # Product + CartItem models
├── providers/
│   ├── auth_provider.dart      # Exercise 1: signIn / signUp / signOut
│   └── store_provider.dart     # Exercise 2 & 3: products + favorites
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart    # Sign In / Sign Up screen
│   ├── main_screen.dart        # Bottom navigation
│   ├── home/
│   │   └── home_screen.dart    # Product grid + search + filter
│   ├── favorites/
│   │   └── favorites_screen.dart
│   └── cart/
│       └── cart_screen.dart
└── widgets/
    ├── product_card.dart       # Product card + heart + add to cart
    └── skeleton_card.dart      # Shimmer loading placeholder
```
