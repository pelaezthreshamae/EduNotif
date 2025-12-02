class ClassSession {
  final String id;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;

  ClassSession({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

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

  factory ClassSession.fromMap(Map<String, dynamic> map) {
    return ClassSession(
      id: map['id'],
      subject: map['subject'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      room: map['room'] ?? '',
    );
  }
}
