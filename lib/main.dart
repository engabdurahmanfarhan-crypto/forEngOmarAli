import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/store_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kynttupugukrasrwiucm.supabase.co',
    anonKey: 'sb_publishable_g09KSAU8ORdbZnUyg4ZAzA_RQH4al0f',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, StoreProvider>(
          create: (_) => StoreProvider(),
          update: (_, auth, store) => (store ?? StoreProvider())
            ..onAuthChanged(auth.currentUser),
        ),
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const AppGate(),
    );
  }
}

/// Listens to Supabase auth state and routes accordingly
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.data?.session;
        if (session != null) return const MainScreen();
        return const AuthScreen();
      },
    );
  }
}
