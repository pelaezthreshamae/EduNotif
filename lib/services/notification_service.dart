import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ----------------------------------------------------------
  // ⭐ TEST NOTIFICATION — REQUIRED BY SettingsScreen
  // ----------------------------------------------------------
  static Future<void> showTestNotification() async {
    final now = DateTime.now().add(const Duration(seconds: 3));
    final scheduled = tz.TZDateTime.from(now, tz.local);

    await NotificationService.instance._plugin.zonedSchedule(
      999001, // unique ID
      "Test Notification 🔔",
      "Your EDUNOTIF test alert is working!",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      payload: "test",
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ----------------------------------------------------------
  // ⭐ EVENT NOTIFICATIONS — used by AppState
  // ----------------------------------------------------------
  Future<void> scheduleNotificationForEvent(Event event) async {
    if (event.reminderTime == null ||
        event.reminderTime!.isBefore(DateTime.now())) {
      return;
    }

    final id = _safeId(event.id);
    final scheduled = tz.TZDateTime.from(event.reminderTime!, tz.local);

    await _plugin.zonedSchedule(
      id,
      event.title,
      event.description,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      payload: event.id,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(String eventId) async {
    final id = _safeId(eventId);
    await _plugin.cancel(id);
  }

  // ----------------------------------------------------------
  // Helper for safe notification ID
  // ----------------------------------------------------------
  int _safeId(String id) {
    final digits = id.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 6) {
      return int.parse(digits.substring(digits.length - 6));
    }

    return int.tryParse(digits) ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }
}
