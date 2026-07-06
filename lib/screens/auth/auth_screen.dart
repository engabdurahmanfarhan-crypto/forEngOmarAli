import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading      = false;
  bool _showPassword = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _error = null; _success = null; });
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _loading = true);
    final auth  = context.read<AuthProvider>();
    final error = _isSignIn
        ? await auth.signIn(email, password)
        : await auth.signUp(email, password);
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else if (!_isSignIn) {
      setState(() {
        _success  = 'Account created! Check your email, then sign in.';
        _isSignIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final isWide  = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: isWide ? _wideLayout(scheme) : _narrowLayout(scheme),
    );
  }

  // ── Desktop / Tablet layout (split) ──────────────────────────────────────
  Widget _wideLayout(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: scheme.primary,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.shopping_bag_rounded,
                        size: 56, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 24),
                  Text('Aura',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimary)),
                  const SizedBox(height: 12),
                  Text('Your personal shopping experience,\npowered by the cloud.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: scheme.onPrimary.withOpacity(.8))),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: ['30 Products', 'Cloud Favorites', 'Real-time Sync', 'Secure Auth']
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(f,
                                  style: TextStyle(
                                      color: scheme.onPrimary,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _formContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile layout (full screen) ───────────────────────────────────────────
  Widget _narrowLayout(ColorScheme scheme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.shopping_bag_rounded,
                  size: 36, color: scheme.onPrimary),
            ),
            const SizedBox(height: 12),
            Text('Aura',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary)),
            const SizedBox(height: 32),
            _formContent(),
          ],
        ),
      ),
    );
  }

  // ── Shared form ───────────────────────────────────────────────────────────
  Widget _formContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_isSignIn ? 'Welcome back' : 'Create an account',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          _isSignIn
              ? 'Sign in to access your personal favorites.'
              : 'Sign up to sync favorites across devices.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),

        // Email
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
              hintText: 'you@example.com'),
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: _passwordCtrl,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            hintText: _isSignIn ? 'Your password' : 'Min 6 characters',
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Error
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ]),
          ),

        // Success
        if (_success != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_success!, style: TextStyle(color: Colors.green.shade700)),
          ),

        const SizedBox(height: 20),

        // Submit button
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isSignIn ? 'Sign In' : 'Create Account',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 20),

        // Toggle mode
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isSignIn ? "Don't have an account? " : 'Already have an account? ',
                style: TextStyle(color: Colors.grey.shade600)),
            GestureDetector(
              onTap: () => setState(() {
                _isSignIn = !_isSignIn;
                _error    = null;
                _success  = null;
              }),
              child: Text(
                _isSignIn ? 'Sign Up' : 'Sign In',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
