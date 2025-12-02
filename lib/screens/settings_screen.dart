import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../theme/pastel_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PastelBackground(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Settings ⚙️",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Customize your EDUNOTIF experience 💜",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // ⭐ Developers Card
                    _glassCard(
                      title: "Developers 🧑‍💻",
                      children: const [
                        _SettingTile(icon: "🧑‍💻", text: "Michael Belencion"),
                        _SettingTile(icon: "👩‍💻", text: "Thresha Mae Pelaez"),
                        _SettingTile(icon: "👩‍💻", text: "Jerose Jean Guanga"),
                        _SettingTile(icon: "🧑‍💻", text: "Ej Violata"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ⭐ Test Notification Button
                    _glassButton(
                      icon: Icons.notifications_active,
                      color: Colors.purple,
                      title: "Test Notification 🔔",
                      subtitle: "Play your notification sound",
                      onTap: () async {
                        await NotificationService.showTestNotification();
                      },
                    ),

                    const SizedBox(height: 20),

                    // ⭐ Sign Out
                    _glassButton(
                      icon: Icons.logout,
                      color: Colors.red,
                      title: "Sign Out 🚪",
                      subtitle: "Sign out from your account",
                      onTap: () async {
                        await SupabaseService.instance.signOut();
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌸 Glass Card widget
  static Widget _glassCard({
    required String title,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 6),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6C4BFF),
                  ),
                ),
              ),
              const Divider(indent: 10, endIndent: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // 🌸 Glass Button
  static Widget _glassButton({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(4, 4),
                color: Color(0x22000000),
              ),
              BoxShadow(
                blurRadius: 14,
                offset: Offset(-4, -4),
                color: Color(0x22FFFFFF),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, size: 28, color: color),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String icon;
  final String text;

  const _SettingTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
    );
  }
}
