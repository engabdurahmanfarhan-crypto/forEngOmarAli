import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool  get isLoggedIn  => currentUser != null;

  AuthProvider() {
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((event) {
      notifyListeners();
    });
  }

  /// Exercise 1 — Sign In with email & password
  Future<String?> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Exercise 1 — Sign Up with email & password
  Future<String?> signUp(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners();
  }
}
