import 'dart:convert';

enum EventType { exam, deadline, activity, other }

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String? subject;
  final EventType type;
  final Duration? reminderBefore;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.subject,
    this.type = EventType.other,
    this.reminderBefore,
    this.imageUrl,
  });



  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? subject,
    EventType? type,
    Duration? reminderBefore,
    String? imageUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      reminderBefore: reminderBefore ?? this.reminderBefore,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'subject': subject,
      'type': type.index,
      'reminderMinutes': reminderBefore?.inMinutes,
      'imageUrl': imageUrl,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
      subject: map['subject'] as String?,
      type: EventType.values[(map['type'] as int?) ?? 3],
      reminderBefore: map['reminderMinutes'] != null
          ? Duration(minutes: map['reminderMinutes'] as int)
          : null,
      imageUrl: map['imageUrl'] as String?,
    );
  }



  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) =>
      Event.fromMap(json.decode(source) as Map<String, dynamic>);



  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'subject': subject,
      'type': type.index,
      'date_time': dateTime.toUtc().toIso8601String(),
      'reminder_minutes': reminderBefore?.inMinutes,
      'image_url': imageUrl,
    };
  }

  factory Event.fromSupabase(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      type: EventType.values[map['type'] ?? 3],
      dateTime: DateTime.parse(map['date_time']).toLocal(),
      reminderBefore: map['reminder_minutes'] != null
          ? Duration(minutes: map['reminder_minutes'])
          : null,
      imageUrl: map['image_url'],
    );
  }
}
