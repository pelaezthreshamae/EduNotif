import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  final client = Supabase.instance.client;

  // --------------------------
  // AUTH
  // --------------------------
  Future<String?> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message; // supabase error
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> signUpWithFullName(
      String email,
      String password,
      String fullName,
      ) async {
    try {
      await client.auth.signUp(
        email: email,
        password: password,
        data: {
          "full_name": fullName,
        },
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> createProfile(String uid, String fullName) async {
    try {
      await client.from('profiles').insert({
        'id': uid,
        'full_name': fullName,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // --------------------------
  // FETCH EVENTS
  // --------------------------
  Future<List<Event>> fetchEvents() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final data = await client
        .from('events')
        .select()
        .eq('user_id', user.id)
        .order('date_time');

    return data.map<Event>((row) => Event.fromMap(row)).toList();
  }

  // --------------------------
  // CREATE EVENT
  // --------------------------
  Future<void> createEvent(Event event) async {
    final user = client.auth.currentUser;

    if (user == null) {
      print("❌ ERROR: No logged-in user.");
      return;
    }

    final payload = event.toMap()..addAll({'user_id': user.id});

    print("🔍 Sending to Supabase:");
    print(payload);

    try {
      final response = await client.from('events').insert(payload);
      print("📥 Supabase response: $response");
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error inserting event: $e');
      rethrow;
    }
  }

  // --------------------------
  // UPDATE EVENT
  // --------------------------
  Future<void> updateEvent(Event event) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final payload = event.toMap();

    await client
        .from('events')
        .update(payload)
        .eq('id', event.id)
        .eq('user_id', user.id);
  }

  // --------------------------
  // DELETE EVENT
  // --------------------------
  Future<void> deleteEvent(String id) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await client
        .from('events')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
