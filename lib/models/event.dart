// class Event {
//   final int id;
//   final String title;
//   final String venue;
//   final DateTime startTime;
//   final DateTime endTime;
//   final String time;

//   Event({
//     required this.id,
//     required this.title,
//     required this.venue,
//     required this.startTime,
//     required this.endTime,
//     required this.time,
//   });

//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       venue: json['venue'] ?? '',
//       startTime: DateTime.parse(json['startTime'] ?? ''),
//       endTime: DateTime.parse(json['endTime'] ?? ''),
//       time: json['time'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'venue': venue,
//       'startTime': startTime.toIso8601String(),
//       'endTime': endTime.toIso8601String(),
//       'time': time,
//     };
//   }

//   @override
//   String toString() {
//     return 'Event(id: $id, title: $title, venue: $venue, startTime: $startTime, endTime: $endTime, time: $time)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Event {
  final int id;
  final String title;
  final String venue;
  final DateTime startTime;
  final DateTime endTime;
  final String time;

  Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.time,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: parseInt(json['id']),
      title: json['title'] ?? '',
      venue: json['venue'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? ''),
      endTime: DateTime.parse(json['endTime'] ?? ''),
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'venue': venue,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'time': time,
    };
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, venue: $venue, startTime: $startTime, endTime: $endTime, time: $time)';
  }
}
