import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/class_session.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

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
        backgroundColor: const Color(0xFFF4F6FA),
        body: Column(
          children: [

            Container
              (
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
                    "Class Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "View and edit your weekly timetable",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly timetable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...days.map((day) {
                      final sessions = appState.sessionsForDay(day);
                      return _DaySection(
                        day: day,
                        dayLabel: _dayLabel(day),
                        sessions: sessions,
                      );
                    }),
                    const SizedBox(height: 70), // space above FAB
                  ],
                ),
              ),
            ),
          ],
        ),


        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showClassDialog(context);
          },
          backgroundColor: const Color(0xFF4753E3),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add class',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final String dayLabel;
  final List<ClassSession> sessions;

  const _DaySection({
    required this.day,
    required this.dayLabel,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4753E3).withOpacity(0.1),
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4753E3),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              dayLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        childrenPadding:
        const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
        children: [
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No classes',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ...sessions.map(
                  (s) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Text(
                    s.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${s.startTime} – ${s.endTime}'
                        '${s.room.isNotEmpty ? " · ${s.room}" : ""}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          _showClassDialog(context, existing: s);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final appState = context.read<AppState>();
                          await appState.deleteClassSession(s.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



Future<void> _showClassDialog(BuildContext context,
    {ClassSession? existing}) async {
  final isEditing = existing != null;


  String selectedDay = existing?.dayOfWeek ?? 'Mon';
  final subjectController =
  TextEditingController(text: existing?.subject ?? '');
  final startController =
  TextEditingController(text: existing?.startTime ?? '09:00');
  final endController =
  TextEditingController(text: existing?.endTime ?? '10:00');
  final roomController =
  TextEditingController(text: existing?.room ?? 'Room 101');

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(isEditing ? 'Edit class' : 'Add class'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day of week',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Mon', child: Text('Monday')),
                      DropdownMenuItem(value: 'Tue', child: Text('Tuesday')),
                      DropdownMenuItem(value: 'Wed', child: Text('Wednesday')),
                      DropdownMenuItem(value: 'Thu', child: Text('Thursday')),
                      DropdownMenuItem(value: 'Fri', child: Text('Friday')),
                      DropdownMenuItem(value: 'Sat', child: Text('Saturday')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedDay = val);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: startController,
                    decoration: const InputDecoration(
                      labelText: 'Start time (e.g. 09:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: endController,
                    decoration: const InputDecoration(
                      labelText: 'End time (e.g. 10:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final subject = subjectController.text.trim();
                  final start = startController.text.trim();
                  final end = endController.text.trim();
                  final room = roomController.text.trim();

                  if (subject.isEmpty || start.isEmpty || end.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in subject, start, and end time.',
                        ),
                      ),
                    );
                    return;
                  }

                  final appState = ctx.read<AppState>();

                  if (isEditing) {
                    final updated = existing!.copyWith(
                      subject: subject,
                      dayOfWeek: selectedDay,
                      startTime: start,
                      endTime: end,
                      room: room,
                    );
                    await appState.updateClassSession(updated);
                  } else {
                    await appState.createClassSession(
                      subject: subject,
                      dayOfWeek: selectedDay,
                      startTime: start,
                      endTime: end,
                      room: room,
                    );
                  }

                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(isEditing ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
