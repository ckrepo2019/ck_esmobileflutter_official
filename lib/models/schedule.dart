import 'package:intl/intl.dart';

class ScheduleInfo {
  final String id;
  final String name;
  final List<SchedData> schedule;

  ScheduleInfo({required this.id, required this.name, required this.schedule});

  factory ScheduleInfo.fromJson(Map json) {
    var id = json['id'] ?? 0;
    var name = json['name'] ?? '';

    var ll = List.from(json['schedule']);

    List<SchedData> schDataList = ll.map((i) => SchedData.fromJson(i)).toList();
    return ScheduleInfo(id: id, name: name, schedule: schDataList);
  }
}

class SchedData {
  final String day;
  final List<SchedItem> sched;

  SchedData({required this.day, required this.sched});

  factory SchedData.fromJson(Map json) {
    var day = json['day'] ?? '';

    var ll = List.from(json['sched']);
    List<SchedItem> schDataList = ll.map((i) => SchedItem.fromJson(i)).toList();

    schDataList.sort((a, b) {
      DateTime startA = _parseTime(a.start);
      DateTime startB = _parseTime(b.start);

      int cmp = startA.compareTo(startB);
      if (cmp == 0) {
        return _parseTime(a.end).compareTo(_parseTime(b.end));
      }
      return cmp;
    });

    return SchedData(day: day, sched: schDataList);
  }
}

DateTime _parseTime(String time) {
  try {
    return DateFormat.jm().parse(time);
  } catch (e) {
    return DateTime(2000, 1, 1, 0, 0);
  }
}

class SchedItem {
  final String month;
  final String start;
  final String end;
  final String subject;
  final String room;
  final String teacher;

  SchedItem({
    required this.month,
    required this.start,
    required this.end,
    required this.subject,
    required this.room,
    required this.teacher,
  });

  factory SchedItem.fromJson(Map json) {
    var start = json['start'] ?? '';
    var end = json['end'] ?? '';
    var subject = json['subject'] ?? '';
    var room = json['room'] ?? '';
    var teacher = json['teacher'] ?? '';

    return SchedItem(
      start: start,
      end: end,
      subject: subject,
      room: room,
      teacher: teacher,
      month: '',
    );
  }

  @override
  String toString() {
    return 'SchedItem(month: $month, start: $start, end: $end, subject: $subject, room: $room, teacher: $teacher)';
  }
}
