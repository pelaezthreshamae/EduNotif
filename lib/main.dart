import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/app_state.dart';
import 'auth/auth_gate.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    anonKey: SupabaseService.supabaseAnonKey,
  );

  // MUST be here
  if (!kIsWeb) {
    await NotificationService().init();
  }

  runApp(const EduNotifApp());
}


class EduNotifApp extends StatelessWidget {
  const EduNotifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'EDUNOTIF',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,

          // 💜 MAIN COLOR SCHEME (Purple + Lavender)
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD000FF), // Royal Purple
            brightness: Brightness.light,
          ),

          // 💜 Background (Lavender tint)
          scaffoldBackgroundColor: const Color(0xFFF3ECFF),

          // 💜 TEXT COLORS
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF2A2A2A),
            ),
          ),

          // 💜 Inputs
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: Colors.black45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),

          // 💜 Filled Buttons
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
              const MaterialStatePropertyAll(Color(0xFF6C4BFF)),
              foregroundColor:
              const MaterialStatePropertyAll(Colors.white),
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // 🧭 Emoji Bottom Navigation Bar
          navigationBarTheme: const NavigationBarThemeData(
            height: 72,
            backgroundColor: Colors.purpleAccent,
            indicatorColor: Color(0x336C4BFF), // soft purple highlight
            labelTextStyle: MaterialStatePropertyAll(
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

// 🔮 MAIN NAVIGATION WITH EMOJI LABELS
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Text("🏠", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("🏠", style: TextStyle(fontSize: 26)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Text("🗓️", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("🗓️", style: TextStyle(fontSize: 26)),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Text("⚙️", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("⚙️", style: TextStyle(fontSize: 26)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
