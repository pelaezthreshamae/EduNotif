import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import '../providers/app_state.dart';
import 'add_event_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final selectedEvents = appState.eventsForDay(appState.selectedDay);
    final upcomingEvents = appState.upcomingEvents;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        // ---------------- FAB BUTTON (RIGHT SIDE) ----------------
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4753E3),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),

        body: Column(
          children: [
            // Header
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(context, appState),
                    const SizedBox(height: 20),

                    // Selected day events
                    Text(
                      "Events on ${_formatDate(appState.selectedDay)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (selectedEvents.isEmpty)
                      const Text(
                        "No events for this day.",
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      ...selectedEvents.map(_buildEventTile),

                    const SizedBox(height: 25),

                    // Upcoming events
                    const Text(
                      "Upcoming events",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (upcomingEvents.isEmpty)
                      const Text(
                        "No upcoming events.",
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      ...upcomingEvents.map(_buildEventTile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calendar Widget
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
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

  // Event card UI
  Widget _buildEventTile(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD8DF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.redAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${event.subject ?? 'No subject'} • ${_formatTime(event.dateTime)}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Time formatter
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  // Date formatter
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
