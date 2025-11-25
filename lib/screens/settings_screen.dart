import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        body: Column(
          children: [
            // ---------- HEADER ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4753E3), Color(0xFF6C78F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Customize your EDUNOTIF experience",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- BODY ----------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _settingsCard(
                    title: "Appearance",
                    children: const [
                      ListTile(
                        leading: Icon(Icons.light_mode_outlined),
                        title: Text("Theme"),
                        subtitle: Text("Light (minimal)"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _settingsCard(
                    title: "Notifications",
                    children: const [
                      ListTile(
                        leading: Icon(Icons.notifications_active_outlined),
                        title: Text("Reminders"),
                        subtitle: Text(
                          "Ensure notifications are allowed in system settings.",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _settingsCard(
                    title: "About",
                    children: const [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("About EDUNOTIF"),
                        subtitle: Text(
                          "A minimalist planner for students.\nBuilt with Flutter & Supabase.",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ---------- Sign Out ----------
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Sign out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        await supabaseService.signOut();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- REUSABLE SETTINGS CARD ------------------
  Widget _settingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 12, bottom: 6, right: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4753E3),
                ),
              ),
            ),
            const Divider(height: 0),
            ...children,
          ],
        ),
      ),
    );
  }
}
