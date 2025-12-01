import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/pastel_background.dart';

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

  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
    final title = _isSignIn ? "Welcome Back 👋" : "Create Account ✨";
    final subtitle = _isSignIn
        ? "Sign in to continue using EDUNOTIF 📘"
        : "Register to get started 🌸";

    return Scaffold(
      body: PastelBackground(
        child: Stack(
          children: [
            // 🌸 HEADER TITLE (Black & White color change)
            Positioned(
              top: 80,
              left: 32,
              child: Text(
                "EDUNOTIF ❤️",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changed to black
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),

            // 🌸 AUTH CARD (Glassmorphic)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            spreadRadius: 2,
                            color: Colors.black.withOpacity(0.06),
                            offset: const Offset(4, 6),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🌸 TITLE
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // 📧 EMAIL FIELD
                            _styledField(
                              label: "Email ✉️",
                              icon: Icons.email_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Email is required";
                                }
                                if (!val.contains("@")) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                              onSaved: (val) => _email = val!.trim(),
                            ),

                            const SizedBox(height: 16),

                            // 🔒 PASSWORD FIELD
                            _styledField(
                              label: "Password 🔒",
                              icon: Icons.lock_outline,
                              obscure: !_showPassword,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
                                icon: Text(
                                  _showPassword ? "🙈" : "👁️",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return "Password too short";
                                }
                                return null;
                              },
                              onSaved: (val) => _password = val!.trim(),
                            ),

                            // 🔑 CONFIRM PASSWORD (SIGN UP ONLY)
                            if (!_isSignIn) ...[
                              const SizedBox(height: 16),
                              _styledField(
                                label: "Confirm Password 🔑",
                                icon: Icons.lock_reset,
                                obscure: !_showConfirmPassword,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() =>
                                    _showConfirmPassword = !_showConfirmPassword);
                                  },
                                  icon: Text(
                                    _showConfirmPassword ? "🙈" : "👁️",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.length < 6) {
                                    return "Password too short";
                                  }
                                  return null;
                                },
                                onSaved: (val) =>
                                _confirmPassword = val!.trim(),
                              )
                            ],

                            const SizedBox(height: 26),

                            // 🌸 SUBMIT BUTTON (Updated color)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set button background to black
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  _isSignIn
                                      ? "Sign In"
                                      : "Create Account",
                                  style: const TextStyle(color: Colors.white), // Text color white
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 🔄 TOGGLE SIGN IN / SIGN UP (Updated color)
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isSignIn
                                    ? "Don't have an account? Sign up 🌸"
                                    : "Already have an account? Sign in 👋",
                                style: const TextStyle(
                                  color: Colors.black, // Set toggle text color to black
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
            )
          ],
        ),
      ),
    );
  }

  // 🌸 UNIFIED TEXT FIELD STYLE
  Widget _styledField({
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      obscureText: obscure,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black), // Change icon color to black
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.75),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
