import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = SupabaseService();

  bool _isSignIn = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  void _toggleMode() {
    setState(() => _isSignIn = !_isSignIn);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    String? error;

    if (_isSignIn) {
      error = await _supabase.signInWithEmail(_email, _password);
    } else {
      if (_password != _confirmPassword) {
        error = "Passwords do not match";
      } else {
        error = await _supabase.signUpWithEmail(_email, _password);
      }
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignIn ? 'Signed in successfully!' : 'Account created!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignIn ? "Welcome Back" : "Create Account";
    final subtitle = _isSignIn
        ? "Sign in to continue using EDUNOTIF"
        : "Register to get started";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          // Header Design
          Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4753E3), Color(0xFF6C78F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            padding: const EdgeInsets.only(top: 70, left: 30),
            child: const Text(
              "EDUNOTIF",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          // Login Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(top: 180),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Email Input
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: "Email",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!val.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (val) => _email = val!.trim(),
                          ),

                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: "Password",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Password too short';
                              }
                              return null;
                            },
                            onSaved: (val) => _password = val!.trim(),
                          ),

                          // Confirm Password (Sign-up only)
                          if (!_isSignIn) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_reset),
                                labelText: "Confirm Password",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'Password too short';
                                }
                                return null;
                              },
                              onSaved: (val) =>
                              _confirmPassword = val!.trim(),
                            ),
                          ],

                          const SizedBox(height: 25),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4753E3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ))
                                  : Text(
                                _isSignIn
                                    ? "Sign in"
                                    : "Create account",
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Toggle Mode
                          GestureDetector(
                            onTap: _toggleMode,
                            child: Text(
                              _isSignIn
                                  ? "Don’t have an account? Sign up"
                                  : "Already have an account? Sign in",
                              style: const TextStyle(
                                color: Color(0xFF4753E3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
