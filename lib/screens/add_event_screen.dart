import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/app_state.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String? _description;
  String? _subject;
  EventType _type = EventType.other;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  Duration? _reminder;

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final appState = context.read<AppState>();

    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final event = Event(
      id: 'temp',
      title: _title,
      description: _description,
      subject: _subject,
      type: _type,
      dateTime: dateTime,
      reminderBefore: _reminder,
    );

    await appState.addEvent(event);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event added')),
    );

    _formKey.currentState!.reset();
    setState(() {
      _title = '';
      _description = null;
      _subject = null;
      _type = EventType.other;
      _reminder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final eventsForSelectedDate = List<Event>.from(
      appState.eventsForDay(DateUtils.dateOnly(_date)),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveEvent,
          backgroundColor: const Color(0xFF4753E3),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Add event', style: TextStyle(color: Colors.white)),
        ),

        body: Column(
          children: [
            // ---------------- HEADER WITH BACK BUTTON ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4753E3), Color(0xFF6C78F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button Row
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Add Event",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Add exams, deadlines or activities to your planner",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ---------------- FORM + EVENTS LIST ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormCard(),
                        const SizedBox(height: 20),

                        Text(
                          'Events on ${DateFormat.yMMMMd().format(_date)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (eventsForSelectedDate.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              'No events for this date.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        else
                          ...eventsForSelectedDate.map((e) => _EventTile(event: e)),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM CARD ----------------
  Widget _buildFormCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                decoration: _input("Title", "e.g. Math quiz, Research deadline", Icons.title_outlined),
                validator: (val) =>
                val == null || val.trim().isEmpty ? 'Title is required' : null,
                onSaved: (val) => _title = val!.trim(),
              ),
              const SizedBox(height: 12),

              // Subject
              TextFormField(
                decoration: _input("Subject (optional)", "e.g. Math, English", Icons.book_outlined),
                onSaved: (val) =>
                _subject = (val != null && val.trim().isNotEmpty) ? val.trim() : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                maxLines: 2,
                decoration: _input("Description (optional)", "Coverage, things to bring, etc.", Icons.notes_outlined),
                onSaved: (val) =>
                _description = (val != null && val.trim().isNotEmpty) ? val.trim() : null,
              ),
              const SizedBox(height: 12),

              _buildTypeDropdown(),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 12),

              _buildReminderDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- INPUT DECORATION ----------------
  InputDecoration _input(String label, String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ---------------- DROPDOWNS ----------------
  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<EventType>(
      value: _type,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined),
        labelText: 'Type',
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: EventType.exam, child: Text('Exam')),
        DropdownMenuItem(value: EventType.deadline, child: Text('Deadline / Assignment')),
        DropdownMenuItem(value: EventType.activity, child: Text('Activity / Event')),
        DropdownMenuItem(value: EventType.other, child: Text('Other')),
      ],
      onChanged: (val) => setState(() => _type = val!),
    );
  }

  Widget _buildDatePicker() {
    final formatted = DateFormat.yMMMd().format(_date);
    return OutlinedButton(
      style: _pickerStyle(),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: const [
            Icon(Icons.calendar_today_outlined, size: 18),
            SizedBox(width: 8),
            Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
          ]),
          Text(formatted, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    final formatted = _time.format(context);
    return OutlinedButton(
      style: _pickerStyle(),
      onPressed: () async {
        final picked = await showTimePicker(context: context, initialTime: _time);
        if (picked != null) setState(() => _time = picked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: const [
            Icon(Icons.access_time, size: 18),
            SizedBox(width: 8),
            Text('Time', style: TextStyle(fontWeight: FontWeight.w500)),
          ]),
          Text(formatted, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  ButtonStyle _pickerStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildReminderDropdown() {
    return DropdownButtonFormField<Duration?>(
      value: _reminder,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.notifications_active_outlined),
        labelText: 'Reminder',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('No reminder')),
        DropdownMenuItem(value: Duration(minutes: 10), child: Text('10 minutes before')),
        DropdownMenuItem(value: Duration(hours: 1), child: Text('1 hour before')),
        DropdownMenuItem(value: Duration(days: 1), child: Text('1 day before')),
      ],
      onChanged: (val) => setState(() => _reminder = val),
    );
  }
}

// ---------------- EVENT TILE ----------------
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
          child: Icon(_typeIcon(event.type), color: _typeColor(event.type), size: 22),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
