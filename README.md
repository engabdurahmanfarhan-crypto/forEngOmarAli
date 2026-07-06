# Aura — Flutter E-Commerce App

تطبيق تجارة إلكترونية مبني بـ Flutter + Supabase يغطي التمارين الثلاثة.

---

## التمارين المُنجزة

| # | التمرين | الملف |
|---|---------|-------|
| 1 | Auth بالبريد وكلمة المرور | `lib/screens/auth/auth_screen.dart` + `lib/providers/auth_provider.dart` |
| 2 | قراءة المنتجات من Supabase `products` | `lib/providers/store_provider.dart` → `loadProducts()` |
| 3 | مفضلة خاصة بكل مستخدم `users/{uid}/favorites` | `lib/providers/store_provider.dart` → `loadFavorites()` / `toggleFavorite()` |

---

## طريقة تشغيل المشروع

### 1. المتطلبات
- Flutter SDK 3.x مثبّت
- VS Code أو Android Studio
- جهاز أو محاكي متصل

### 2. تثبيت الحزم
```bash
cd flutter_ecommerce
flutter pub get
```

### 3. تشغيل التطبيق
```bash
flutter run
```

---

## إعداد Supabase (مطلوب أولاً)

افتح مشروعك على [supabase.com](https://supabase.com) ← **SQL Editor** وشغّل:

```sql
-- Exercise 2: Products table
CREATE TABLE IF NOT EXISTS products (
  id             INTEGER PRIMARY KEY,
  name           TEXT           NOT NULL,
  price          DECIMAL(10,2)  NOT NULL,
  original_price DECIMAL(10,2),
  category       TEXT           NOT NULL,
  rating         DECIMAL(3,1)   DEFAULT 4.0,
  review_count   INTEGER        DEFAULT 10,
  image          TEXT,
  badge          TEXT,
  in_stock       BOOLEAN        DEFAULT TRUE,
  description    TEXT,
  created_at     TIMESTAMPTZ    DEFAULT NOW()
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read products"  ON products FOR SELECT USING (true);
CREATE POLICY "Anon insert products"  ON products FOR INSERT WITH CHECK (true);

-- Exercise 3: Favorites per user
CREATE TABLE IF NOT EXISTS favorites (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID          REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  product_id   INTEGER       NOT NULL,
  product_data JSONB         NOT NULL,
  created_at   TIMESTAMPTZ   DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own"   ON favorites FOR SELECT USING  (auth.uid() = user_id);
CREATE POLICY "Users insert own" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users delete own" ON favorites FOR DELETE USING  (auth.uid() = user_id);
```

ثم فعّل **Email/Password** في:
`Authentication → Providers → Email → Enable Email provider ✓`

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
