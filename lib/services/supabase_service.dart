import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event.dart';
import '../models/class_session.dart';

class SupabaseService {

  static const String supabaseUrl = 'https://shwefzvwqjqupskfnxso.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNod2VmenZ3cWpxdXBza2ZueHNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MDgwNjUsImV4cCI6MjA3NzI4NDA2NX0.ERYshPXD_OVMch7o8Rh0RijLHTaQv_af1zIiekWfAo4';

  final SupabaseClient client = Supabase.instance.client;



  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        return null;
      }
      return 'Sign up failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.session != null) {
        return null;
      }
      return 'Sign in failed. Please check your credentials.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;



  Future<List<Event>> fetchEvents() async {
    final user = currentUser;
    if (user == null) return [];

    final res = await client
        .from('events')
        .select()
        .eq('user_id', user.id)
        .order('date_time', ascending: true);

    final list = res as List<dynamic>;

    return list.map((row) {
      return Event(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String?,
        subject: row['subject'] as String?,
        type: EventType.values[(row['type'] as int?) ?? 3],
        dateTime: DateTime.parse(row['date_time'] as String).toLocal(),
        reminderBefore: row['reminder_minutes'] != null
            ? Duration(minutes: row['reminder_minutes'] as int)
            : null,
      );
    }).toList();
  }

  Future<void> createEvent(Event event) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('events').insert({
      'id': event.id,
      'user_id': user.id,
      'title': event.title,
      'description': event.description,
      'subject': event.subject,
      'type': event.type.index,
      'date_time': event.dateTime.toUtc().toIso8601String(),
      'reminder_minutes': event.reminderBefore?.inMinutes,
    });
  }

  Future<void> updateEventRow(Event event) async {
    final user = currentUser;
    if (user == null) return;

    await client
        .from('events')
        .update({
      'title': event.title,
      'description': event.description,
      'subject': event.subject,
      'type': event.type.index,
      'date_time': event.dateTime.toUtc().toIso8601String(),
      'reminder_minutes': event.reminderBefore?.inMinutes,
    })
        .eq('id', event.id)
        .eq('user_id', user.id);
  }

  Future<void> deleteEventRow(String id) async {
    final user = currentUser;
    if (user == null) return;

    await client
        .from('events')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }



  Future<void> upsertClassSessions(List<ClassSession> sessions) async {
    final user = currentUser;
    if (user == null) return;

    final rows = sessions.map((s) {
      return {
        'id': s.id,
        'user_id': user.id,
        'subject': s.subject,
        'day_of_week': s.dayOfWeek,
        'start_time': s.startTime,
        'end_time': s.endTime,
        'room': s.room,
      };
    }).toList();

    await client.from('class_sessions').upsert(rows);
  }
}
