import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../main.dart'; // for MainNavigation
import 'auth_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = SupabaseService();

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;

        if (session == null) {
          // Not logged in → show AuthScreen
          return const AuthScreen();
        }

        // Logged in → show main app
        return const MainNavigation();
      },
    );
  }
}
