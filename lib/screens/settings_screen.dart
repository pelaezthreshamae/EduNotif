import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/pastel_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return SafeArea(
      child: Scaffold(
        body: PastelBackground(
          child: Column(
            children: [
              // 🌸 HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Settings ⚙️",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A3A3A),
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            offset: Offset(2, 2),
                            color: Color(0x22000000),
                          )
                        ],
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

              // ⭐ MAIN CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 🌟 Developer card
                      _buildGlassCard(
                        title: "Developers 🧑‍💻",
                        children: const [
                          _SettingTile(icon: "🧑‍💻️", text: "Michael Belencion"),
                          _SettingTile(icon: "👩‍💻", text: "Thresha Mae Pelaez"),
                          _SettingTile(icon: "👩‍💻‍", text: "Jerose Jean Guanga"),
                          _SettingTile(icon: "🧑‍💻️‍", text: "Ej Violata"),
                        ],
                      ),

                      const SizedBox(height: 20),



                      // 🌟 Sign Out Button
                      ClipRRect(
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
                              leading: const Text("🚪",
                                  style: TextStyle(fontSize: 24)),
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
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🌸 Glass Card Wrapper
  Widget _buildGlassCard({
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
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
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
              const Divider(indent: 10, endIndent: 10, height: 0.5),

              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// 🌸 Single row item tile (with emoji)
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
