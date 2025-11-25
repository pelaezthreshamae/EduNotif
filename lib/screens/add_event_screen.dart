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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: const Text('Add Event'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
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
                          'New Event',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add exams, deadlines or activities to your planner.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.title_outlined),
                            labelText: 'Title',
                            hintText: 'e.g. Math Quiz, Research deadline',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSaved: (val) => _title = val!.trim(),
                          validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Subject
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.book_outlined),
                            labelText: 'Subject (optional)',
                            hintText: 'e.g. Math, English',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSaved: (val) => _subject =
                          val?.trim().isEmpty ?? true ? null : val!.trim(),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        TextFormField(
                          maxLines: 2,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.notes_outlined),
                            labelText: 'Description (optional)',
                            hintText: 'e.g. Coverage, materials to bring, etc.',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSaved: (val) => _description =
                          val?.trim().isEmpty ?? true ? null : val!.trim(),
                        ),
                        const SizedBox(height: 12),

                        // Type dropdown
                        _buildTypeDropdown(),
                        const SizedBox(height: 12),

                        // Date & Time row
                        Row(
                          children: [
                            Expanded(child: _buildDatePicker(context)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildTimePicker(context)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Reminder dropdown
                        _buildReminderDropdown(),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              _formKey.currentState!.save();

                              final dateTime = DateTime(
                                _date.year,
                                _date.month,
                                _date.day,
                                _time.hour,
                                _time.minute,
                              );

                              final event = Event(
                                id: 'temp', // will be replaced in addEvent
                                title: _title,
                                description: _description,
                                subject: _subject,
                                type: _type,
                                dateTime: dateTime,
                                reminderBefore: _reminder,
                              );

                              await appState.addEvent(event);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Event added'),
                                  ),
                                );
                                // Optional: clear form after save
                                _formKey.currentState!.reset();
                                setState(() {
                                  _type = EventType.other;
                                  _date = DateTime.now();
                                  _time = TimeOfDay.now();
                                  _reminder = null;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4753E3),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                            ),
                            label: const Text(
                              'Save Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<EventType>(
      value: _type,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined),
        labelText: 'Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items: const [
        DropdownMenuItem(
          value: EventType.exam,
          child: Text('Exam'),
        ),
        DropdownMenuItem(
          value: EventType.deadline,
          child: Text('Deadline / Assignment'),
        ),
        DropdownMenuItem(
          value: EventType.activity,
          child: Text('Activity / Event'),
        ),
        DropdownMenuItem(
          value: EventType.other,
          child: Text('Other'),
        ),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _type = val);
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final formatted = DateFormat.yMMMd().format(_date);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() => _date = picked);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            formatted,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    final formatted = _time.format(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _time,
        );
        if (picked != null) {
          setState(() => _time = picked);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            formatted,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderDropdown() {
    return DropdownButtonFormField<Duration?>(
      value: _reminder,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.notifications_active_outlined),
        labelText: 'Reminder',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items: const [
        DropdownMenuItem(
          value: null,
          child: Text('No reminder'),
        ),
        DropdownMenuItem(
          value: Duration(minutes: 10),
          child: Text('10 minutes before'),
        ),
        DropdownMenuItem(
          value: Duration(hours: 1),
          child: Text('1 hour before'),
        ),
        DropdownMenuItem(
          value: Duration(days: 1),
          child: Text('1 day before'),
        ),
      ],
      onChanged: (val) {
        setState(() => _reminder = val);
      },
    );
  }
}
