class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final DateTime? reminderTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.reminderTime,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? reminderTime,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  /// Map used for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toUtc().toIso8601String(),
      'reminder_time': reminderTime?.toUtc().toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dateTime: DateTime.parse(map['date_time']).toLocal(),
      reminderTime: map['reminder_time'] != null
          ? DateTime.parse(map['reminder_time']).toLocal()
          : null,
    );
  }
}
