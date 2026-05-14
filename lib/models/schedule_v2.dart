class V2ScheduleSlot {
  final String day;
  final String start;
  final String end;
  final String room;
  final String type;

  V2ScheduleSlot({
    required this.day,
    required this.start,
    required this.end,
    required this.room,
    required this.type,
  });

  factory V2ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return V2ScheduleSlot(
      day: json['day']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class V2Subject {
  final String subjdesc;
  final String subjcode;
  final String? lastname;
  final String? firstname;
  final List<V2ScheduleSlot> schedule;

  V2Subject({
    required this.subjdesc,
    required this.subjcode,
    this.lastname,
    this.firstname,
    required this.schedule,
  });

  String get teacherName {
    final l = lastname?.trim() ?? '';
    final f = firstname?.trim() ?? '';
    if (l.isEmpty && f.isEmpty) return '';
    if (l.isEmpty) return f;
    if (f.isEmpty) return l;
    return '$l, $f';
  }

  factory V2Subject.fromJson(Map<String, dynamic> json) {
    final rawSched = json['schedule'];
    final slots = (rawSched is List)
        ? rawSched.map((e) => V2ScheduleSlot.fromJson(e)).toList()
        : <V2ScheduleSlot>[];

    return V2Subject(
      subjdesc: json['subjdesc']?.toString() ?? '',
      subjcode: json['subjcode']?.toString() ?? '',
      lastname: json['lastname']?.toString(),
      firstname: json['firstname']?.toString(),
      schedule: slots,
    );
  }
}
