import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import '../providers/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedEvents = appState.eventsForDay(appState.selectedDay);
    final upcoming = appState.upcomingEvents.take(5).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        // ----------------- HEADER -------------------
        body: Column(
          children: [
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
                    "EDUNOTIF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Your daily planner at a glance",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // -------- Main Content Scrollable ---------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(context, appState),
                    const SizedBox(height: 20),

                    // ---------- Today's Events ----------
                    _SectionTitle(
                      title:
                      'Events on ${DateFormat.yMMMMd().format(appState.selectedDay)}',
                    ),
                    const SizedBox(height: 10),

                    if (selectedEvents.isEmpty)
                      _emptyMessage("No events for this day.")
                    else
                      ...selectedEvents.map((e) => _EventTile(event: e)),

                    const SizedBox(height: 24),

                    // ---------- Upcoming ----------
                    const _SectionTitle(title: 'Upcoming events'),
                    const SizedBox(height: 10),

                    if (upcoming.isEmpty)
                      _emptyMessage("No upcoming events.")
                    else
                      ...upcoming.map((e) => _EventTile(event: e)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  // --------------------- Calendar Widget -----------------------
  Widget _buildCalendar(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: appState.focusedDay,
        selectedDayPredicate: (day) => isSameDay(appState.selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) => appState.eventsForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          appState.setSelectedDay(selectedDay, focusedDay);
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF4753E3).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4753E3),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: Colors.redAccent),
          selectedTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// ---------------------- SECTION TITLE -------------------------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ---------------------- EVENT TILE -----------------------------
class _EventTile extends StatelessWidget {
  final Event event;
  const _EventTile({required this.event});

  Color _typeColor(EventType type) {
    switch (type) {
      case EventType.exam:
        return const Color(0xFFEF476F);
      case EventType.deadline:
        return const Color(0xFFF8961E);
      case EventType.activity:
        return const Color(0xFF06D6A0);
      default:
        return const Color(0xFF118AB2);
    }
  }

  IconData _typeIcon(EventType type) {
    switch (type) {
      case EventType.exam:
        return Icons.school;
      case EventType.deadline:
        return Icons.task_alt;
      case EventType.activity:
        return Icons.event;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final timeStr = DateFormat.jm().format(event.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _typeColor(event.type).withOpacity(0.15),
          child: Icon(
            _typeIcon(event.type),
            color: _typeColor(event.type),
            size: 22,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${event.subject ?? ''}${event.subject != null ? ' · ' : ''}$timeStr',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
              await appState.deleteEvent(event.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
