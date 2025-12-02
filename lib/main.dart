import 'package:edunotif/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_state.dart';
import 'services/notification_service.dart';

import 'package:provider/provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezones for notifications
  tz.initializeTimeZones();

  // Initialize local notifications
  await NotificationService.instance.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://glkahnrejybtvxxlpamr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdsa2FobnJlanlidHZ4eGxwYW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1OTExNjEsImV4cCI6MjA4MDE2NzE2MX0.52NY2ovGhBertIFvZCr2F2wRoEiygaFvqaC6HrRT24c',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edunotif',
        home: const AuthGate(),
      ),
    );
  }
}



