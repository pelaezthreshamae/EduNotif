import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/class_session.dart';

import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  final _notify = NotificationService.instance;
  final _supabase = SupabaseService.instance;

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  List<ClassSession> _schedule = [];

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<ClassSession> get schedule => _schedule;

  // -----------------------------
  // INIT — Load only from Supabase
  // -----------------------------
  Future<void> init() async {
    try {
      _events = await _supabase.fetchEvents();

      // Reschedule all notifications
      for (final e in _events) {
        if (e.reminderTime != null &&
            e.reminderTime!.isAfter(DateTime.now())) {
          await _notify.scheduleNotificationForEvent(e);
        }
      }
    } catch (e) {
      print("ERROR loading events: $e");
    }

    notifyListeners();
  }

  // -----------------------------
  // Events for a selected day
  // -----------------------------
  List<Event> eventsForDay(DateTime day) {
    return _events
        .where((e) =>
    e.dateTime.year == day.year &&
        e.dateTime.month == day.month &&
        e.dateTime.day == day.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Event> get upcomingEvents {
    final now = DateTime.now();
    final list = _events.where((e) => e.dateTime.isAfter(now)).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  void setSelectedDay(DateTime selected, DateTime focused) {
    _selectedDay = selected;
    _focusedDay = focused;
    notifyListeners();
  }

  // -----------------------------
  // ADD EVENT
  // -----------------------------
  Future<void> addEvent(Event event) async {
    final newEvent = event.copyWith(id: _newId());
    _events.add(newEvent);
    notifyListeners();

    try {
      await _supabase.createEvent(newEvent);
      await _notify.scheduleNotificationForEvent(newEvent);
    } catch (e) {
      print("AddEvent ERROR: $e");
    }
  }

  // -----------------------------
  // UPDATE EVENT
  // -----------------------------
  Future<void> updateEvent(Event updated) async {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;

    _events[index] = updated;
    notifyListeners();

    try {
      await _supabase.updateEvent(updated);
      await _notify.cancelNotification(updated.id);
      await _notify.scheduleNotificationForEvent(updated);
    } catch (e) {
      print("UpdateEvent ERROR: $e");
    }
  }

  // -----------------------------
  // DELETE EVENT
  // -----------------------------
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await _supabase.deleteEvent(id);
      await _notify.cancelNotification(id);
    } catch (e) {
      print("DeleteEvent ERROR: $e");
    }
  }

  // -----------------------------
  // Schedule (You can remove this too if using Supabase)
  // -----------------------------
  // -----------------------------
// CREATE CLASS SESSION
// -----------------------------
  Future<void> createClassSession({
    required String subject,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
  }) async {
    final session = ClassSession(
      id: _newId(),
      subject: subject,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      room: room,
    );

    _schedule.add(session);
    notifyListeners();
  }

// -----------------------------
// UPDATE CLASS SESSION
// -----------------------------
  Future<void> updateClassSession(ClassSession updated) async {
    final index = _schedule.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;

    _schedule[index] = updated;
    notifyListeners();
  }

// -----------------------------
// DELETE CLASS SESSION
// -----------------------------
  Future<void> deleteClassSession(String id) async {
    _schedule.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<ClassSession> sessionsForDay(String day) {
    return _schedule
        .where((s) => s.dayOfWeek == day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
