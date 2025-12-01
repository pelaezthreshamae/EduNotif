import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import '../providers/app_state.dart';
import 'add_event_screen.dart';
import '../theme/pastel_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final selectedEvents = appState.eventsForDay(appState.selectedDay);
    final upcomingEvents = appState.upcomingEvents;

    return SafeArea(
      child: Scaffold(
        body: PastelBackground(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Home 🏠",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Plan your day beautifully 🌸",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Body content (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendar(context, appState),
                      const SizedBox(height: 22),

                      // Events section
                      Text(
                        "Events on ${_formatDate(appState.selectedDay)} 📅",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (selectedEvents.isEmpty)
                        const Text(
                          "No events for this date ✨",
                          style: TextStyle(color: Colors.black54),
                        )
                      else
                        ...selectedEvents.map(_buildEventTile),

                      const SizedBox(height: 26),

                      const Text(
                        "Upcoming Events ⏳",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (upcomingEvents.isEmpty)
                        const Text(
                          "Nothing coming up yet 🧋",
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

        // Floating action button
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6C4BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventScreen()),
            );
          },
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(4, 4),
            color: Color(0x22000000),
          ),
          BoxShadow(
            blurRadius: 16,
            offset: Offset(-4, -4),
            color: Color(0x22FFFFFF),
          ),
        ],
      ),
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: appState.focusedDay,
        selectedDayPredicate: (day) =>
            isSameDay(appState.selectedDay, day),
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        eventLoader: (day) => appState.eventsForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          appState.setSelectedDay(selectedDay, focusedDay);
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF6C4BFF).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF6C4BFF),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: Colors.black54),
          selectedTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventTile(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
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
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC7B8FF),
              shape: BoxShape.circle,
            ),
            child: const Text("📘", style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${event.subject ?? 'No subject'} • ${_formatTime(event.dateTime)}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
