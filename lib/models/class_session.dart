class ClassSession {
  final String id;
  final String subject;
  final String dayOfWeek; // e.g. "Mon", "Tue"
  final String startTime; // "09:00"
  final String endTime;   // "10:00"
  final String room;

  ClassSession({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  // Create a modified copy of the object
  ClassSession copyWith({
    String? id,
    String? subject,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return ClassSession(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }

  // Convert to map for saving locally
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
    };
  }

  // Create object from local map
  factory ClassSession.fromMap(Map<String, dynamic> map) {
    return ClassSession(
      id: map['id'] as String,
      subject: map['subject'] as String,
      dayOfWeek: map['dayOfWeek'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      room: map['room'] as String,
    );
  }

  // Convert to map for Supabase (column names must match your SQL)
  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
    };
  }

  // Create object from Supabase response
  factory ClassSession.fromSupabase(Map<String, dynamic> map) {
    return ClassSession(
      id: map['id'],
      subject: map['subject'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      room: map['room'] ?? '',
    );
  }
}
