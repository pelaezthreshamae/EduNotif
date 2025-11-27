import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/class_session.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final _storage = LocalStorageService();
  final _notifications = NotificationService();


  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  List<ClassSession> _schedule = [];

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<ClassSession> get schedule => _schedule;

  Future<void> init() async {
    _events = await _storage.loadEvents();
    _schedule = await _storage.loadSchedule();

    if (_schedule.isEmpty) {
      _schedule = _generateSampleSchedule();
      await _storage.saveSchedule(_schedule);
    }

    notifyListeners();
  }



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

  Future<void> addEvent(Event event) async {
    final newEvent = event.copyWith(id: _newId());
    _events.add(newEvent);
    await _storage.saveEvents(_events);
    await _notifications.scheduleNotification(newEvent);
    notifyListeners();
  }

  Future<void> updateEvent(Event updated) async {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _events[index] = updated;
    await _storage.saveEvents(_events);
    await _notifications.cancelNotification(updated.id);
    await _notifications.scheduleNotification(updated);
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _storage.saveEvents(_events);
    await _notifications.cancelNotification(id);
    notifyListeners();
  }



  List<ClassSession> sessionsForDay(String dayOfWeek) {
    return _schedule.where((s) => s.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> createClassSession({
    required String subject,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
  }) async {
    final newSession = ClassSession(
      id: _newId(),
      subject: subject,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      room: room,
    );
    _schedule.add(newSession);
    await _storage.saveSchedule(_schedule);
    notifyListeners();
  }

  Future<void> updateClassSession(ClassSession updated) async {
    final index = _schedule.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    _schedule[index] = updated;
    await _storage.saveSchedule(_schedule);
    notifyListeners();
  }

  Future<void> deleteClassSession(String id) async {
    _schedule.removeWhere((s) => s.id == id);
    await _storage.saveSchedule(_schedule);
    notifyListeners();
  }

  List<ClassSession> _generateSampleSchedule() {
    return [
      ClassSession(
        id: _newId(),
        subject: 'Math',
        dayOfWeek: 'Mon',
        startTime: '09:00',
        endTime: '10:00',
        room: 'Room 101',
      ),
      ClassSession(
        id: _newId(),
        subject: 'English',
        dayOfWeek: 'Mon',
        startTime: '10:00',
        endTime: '11:00',
        room: 'Room 102',
      ),
      ClassSession(
        id: _newId(),
        subject: 'Science',
        dayOfWeek: 'Tue',
        startTime: '09:00',
        endTime: '10:00',
        room: 'Lab 1',
      ),
    ];
  }
}
