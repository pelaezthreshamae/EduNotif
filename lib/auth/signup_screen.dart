import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/pastel_background.dart'; // Assuming you have a pastel background widget

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = SupabaseService.instance;

  String _email = "";
  String _fullName = "";
  String _password = "";
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    final error = await _supabase.signUpWithFullName(
      _email,
      _password,
      _fullName,
    );

    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created! Please log in.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFA019AA), // Purple color for the app bar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // This will take you back to the previous screen
            },
          ),
        ),
        backgroundColor: Color(0xFF121212), // Dark background color for consistency
        body: PastelBackground(  // Assuming you have a widget for pastel background
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading text with customized styling
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Sign Up 📝",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFAFAFA),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Create your beautiful account 🌸",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Full Name Field with a stylish design
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12, // Darker input background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? "Enter your full name" : null,
                    onSaved: (v) => _fullName = v!.trim(),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Email Field with smooth design
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (v) =>
                    v == null || !v.contains("@") ? "Invalid email" : null,
                    onSaved: (v) => _email = v!.trim(),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Password Field with stylish design
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (v) =>
                    v == null || v.length < 6 ? "Password too short" : null,
                    onSaved: (v) => _password = v!.trim(),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // Create Account Button with smooth animation and custom design
                  AnimatedScale(
                    scale: _loading ? 0.9 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C4BFF), // Custom background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
