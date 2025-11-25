import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';
import '../models/class_session.dart';

class LocalStorageService {
  static const _eventsKey = 'events';
  static const _scheduleKey = 'schedule';

  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final list = events.map((e) => e.toMap()).toList();
    await prefs.setString(_eventsKey, jsonEncode(list));
  }

  Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_eventsKey);
    if (jsonStr == null) return [];
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveSchedule(List<ClassSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = sessions.map((s) => s.toMap()).toList();
    await prefs.setString(_scheduleKey, jsonEncode(list));
  }

  Future<List<ClassSession>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_scheduleKey);
    if (jsonStr == null) return [];
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => ClassSession.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
