import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/class_session.dart';
import '../theme/pastel_background.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String _dayEmoji(String code) {
    switch (code) {
      case 'Mon':
        return "🌞";
      case 'Tue':
        return "📘";
      case 'Wed':
        return "🧋";
      case 'Thu':
        return "📋";
      case 'Fri':
        return "📚";
      case 'Sat':
        return "☕";
      default:
        return "📅";
    }
  }

  String _dayLabel(String code) {
    switch (code) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: Scaffold(
        body: PastelBackground(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Class Schedule 🗓️📚",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      "View and manage your weekly classes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Weekly Timetable ✨",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Day sections
                      ...days.map((day) {
                        final sessions = appState.sessionsForDay(day);
                        return _DaySection(
                          day: day,
                          dayLabel: _dayLabel(day),
                          emoji: _dayEmoji(day),
                          sessions: sessions,
                        );
                      }),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF6C4BFF),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Add Class',
            style: TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () => _showClassDialog(context),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final String dayLabel;
  final String emoji;
  final List<ClassSession> sessions;

  const _DaySection({
    required this.day,
    required this.dayLabel,
    required this.emoji,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(4, 4),
            color: Color(0x22000000),
          ),
          BoxShadow(
            blurRadius: 12,
            offset: Offset(-4, -4),
            color: Color(0x22FFFFFF),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFF6C4BFF),
        collapsedIconColor: Colors.black54,
        title: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              dayLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        children: [
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "No classes yet ✨",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            )
          else
            ...sessions.map((s) => _ClassTile(session: s)),
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final ClassSession session;

  const _ClassTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          "${session.subject} 🎀",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          "${session.startTime} — ${session.endTime}"
              "${session.room.isNotEmpty ? " · ${session.room}" : ""}",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _showClassDialog(context, existing: session),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => appState.deleteClassSession(session.id),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showClassDialog(BuildContext context,
    {ClassSession? existing}) async {
  final isEditing = existing != null;

  String selectedDay = existing?.dayOfWeek ?? 'Mon';
  final subjectCtrl = TextEditingController(text: existing?.subject ?? '');
  final startCtrl = TextEditingController(text: existing?.startTime ?? '09:00');
  final endCtrl = TextEditingController(text: existing?.endTime ?? '10:00');
  final roomCtrl = TextEditingController(text: existing?.room ?? 'Room 101');

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(isEditing ? "Edit Class ✏️" : "Add Class 🌸"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: const [
                DropdownMenuItem(value: 'Mon', child: Text("Monday 🌞")),
                DropdownMenuItem(value: 'Tue', child: Text("Tuesday 📘")),
                DropdownMenuItem(value: 'Wed', child: Text("Wednesday 🧋")),
                DropdownMenuItem(value: 'Thu', child: Text("Thursday 📋")),
                DropdownMenuItem(value: 'Fri', child: Text("Friday 📚")),
                DropdownMenuItem(value: 'Sat', child: Text("Saturday ☕")),
              ],
              onChanged: (v) => selectedDay = v!,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: "Subject 🎀"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: "Start Time ⏰"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: "End Time 🕰️"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roomCtrl,
              decoration: const InputDecoration(labelText: "Room 🏫"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final appState = ctx.read<AppState>();

              if (isEditing) {
                await appState.updateClassSession(
                  existing!.copyWith(
                    subject: subjectCtrl.text.trim(),
                    dayOfWeek: selectedDay,
                    startTime: startCtrl.text.trim(),
                    endTime: endCtrl.text.trim(),
                    room: roomCtrl.text.trim(),
                  ),
                );
              } else {
                await appState.createClassSession(
                  subject: subjectCtrl.text.trim(),
                  dayOfWeek: selectedDay,
                  startTime: startCtrl.text.trim(),
                  endTime: endCtrl.text.trim(),
                  room: roomCtrl.text.trim(),
                );
              }

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEditing ? "Save ✏️" : "Add"),
          ),
        ],
      );
    },
  );
}
