import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/app_state.dart';
import '../theme/pastel_background.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String? _description;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  Duration? _reminder;

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final appState = context.read<AppState>();

    // actual event datetime
    final eventDateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    // Compute reminderTime from dropdown
    final reminderTime = (_reminder != null)
        ? eventDateTime.subtract(_reminder!)
        : null;

    // Create event (AppState will replace id)
    final event = Event(
      id: 'temp',
      title: _title,
      description: _description ?? '',
      dateTime: eventDateTime,
      reminderTime: reminderTime,
    );

    await appState.addEvent(event);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event added successfully! 🎉')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final eventsForDate =
    appState.eventsForDay(DateUtils.dateOnly(_date));

    return SafeArea(
      child: Scaffold(
        body: PastelBackground(
          child: Column(
            children: [
              // ---------------- HEADER ----------------
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      "Add Event",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      "Organize your day beautifully",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- BODY ----------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventForm(),
                      const SizedBox(height: 20),

                      Text(
                        "Events on ${DateFormat.yMMMMd().format(_date)} 📅",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (eventsForDate.isEmpty)
                        const Text(
                          "No events yet for this day 💭",
                          style: TextStyle(color: Colors.black54),
                        )
                      else
                        ...eventsForDate.map((e) => _EventTile(event: e)),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Save Button
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF6C4BFF),
          label: const Text("Save Event 💾"),
          icon: const Icon(Icons.save),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: _saveEvent,
        ),
      ),
    );
  }

  // ---------------- FORM WIDGET ----------------
  Widget _buildEventForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInput("Title 🎀", "Enter event title"),
            const SizedBox(height: 14),

            _buildInput("Description (optional)", "Details...",
                save: (v) => _description = v),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 10),
                Expanded(child: _buildTimePicker()),
              ],
            ),

            const SizedBox(height: 14),

            _buildReminderDropdown(),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------
  Widget _buildInput(String label, String hint,
      {void Function(String?)? save}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.event, color: Color(0xFF6C4BFF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: label.contains("optional")
          ? null
          : (v) => v == null || v.isEmpty ? "Required" : null,
      onSaved: save ?? (v) => _title = v!.trim(),
    );
  }

  // ---------------- DATE PICKER ----------------
  Widget _buildDatePicker() {
    final formatted = DateFormat.yMMMd().format(_date);
    return OutlinedButton(
      style: _pickerButtonStyle(),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: _pickerContent("Date 📅", formatted),
    );
  }

  // ---------------- TIME PICKER ----------------
  Widget _buildTimePicker() {
    final formatted = _time.format(context);
    return OutlinedButton(
      style: _pickerButtonStyle(),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _time,
        );
        if (picked != null) setState(() => _time = picked);
      },
      child: _pickerContent("Time ⏰", formatted),
    );
  }

  ButtonStyle _pickerButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      side: const BorderSide(color: Color(0xFF6C4BFF), width: 1),
    );
  }

  Widget _pickerContent(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ---------------- REMINDER DROPDOWN ----------------
  Widget _buildReminderDropdown() {
    return DropdownButtonFormField<Duration?>(
      value: _reminder,
      decoration: InputDecoration(
        labelText: "Reminder 🔔",
        prefixIcon:
        const Icon(Icons.notifications, color: Color(0xFF6C4BFF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text("No reminder 💭")),
        DropdownMenuItem(
            value: Duration(minutes: 10),
            child: Text("10 minutes before ⏰")),
        DropdownMenuItem(
            value: Duration(hours: 1),
            child: Text("1 hour before 🕐")),
        DropdownMenuItem(
            value: Duration(days: 1),
            child: Text("1 day before 📌")),
      ],
      onChanged: (val) => setState(() => _reminder = val),
    );
  }
}

// ---------------- EVENT PREVIEW TILE ----------------
class _EventTile extends StatelessWidget {
  final Event event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(event.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Text("🪄", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
