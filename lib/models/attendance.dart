// class Attendance {
//   final int id;
//   final int syid;
//   final int month;
//   final int days;
//   final String year;
//   final int semid;
//   final int levelid;
//   final String sydesc;
//   final String sort;
//   final int isactive;
//   final String monthdesc;
//   final List<String> dates;
//   final int present;
//   final int absent;

//   Attendance({
//     required this.id,
//     required this.syid,
//     required this.month,
//     required this.days,
//     required this.year,
//     required this.semid,
//     required this.levelid,
//     required this.sydesc,
//     required this.sort,
//     required this.isactive,
//     required this.monthdesc,
//     required this.dates,
//     required this.present,
//     required this.absent,
//   });

//   factory Attendance.fromJson(Map<String, dynamic> json) {
//     return Attendance(
//       id: json['id'] ?? 0,
//       syid: json['syid'] ?? 0,
//       month: json['month'] ?? 0,
//       days: json['days'] ?? 0,
//       year: json['year'] ?? '',
//       semid: json['semid'] ?? 0,
//       levelid: json['levelid'] ?? 0,
//       sydesc: json['sydesc'] ?? '',
//       sort: json['sort'] ?? '',
//       isactive: json['isactive'] ?? 0,
//       monthdesc: json['monthdesc'] ?? '',
//       dates: List<String>.from(json['dates'] ?? []),
//       present: json['present'] ?? 0,
//       absent: json['absent'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'syid': syid,
//       'month': month,
//       'days': days,
//       'year': year,
//       'semid': semid,
//       'levelid': levelid,
//       'sydesc': sydesc,
//       'sort': sort,
//       'isactive': isactive,
//       'monthdesc': monthdesc,
//       'dates': dates,
//       'present': present,
//       'absent': absent,
//     };
//   }

//   @override
//   String toString() {
//     return 'Attendance(id: $id, syid: $syid, month: $month, days: $days, year: $year, semid: $semid, levelid: $levelid, sydesc: $sydesc, sort: $sort,isactive: $isactive, monthdesc: $monthdesc, dates: $dates, present: $present, absent: $absent)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Attendance {
  final int id;
  final int syid;
  final int month;
  final int days;
  final String year;
  final int semid;
  final int levelid;
  final String sydesc;
  final String sort;
  final int isactive;
  final String monthdesc;
  final List<String> dates;
  final int present;
  final int absent;

  Attendance({
    required this.id,
    required this.syid,
    required this.month,
    required this.days,
    required this.year,
    required this.semid,
    required this.levelid,
    required this.sydesc,
    required this.sort,
    required this.isactive,
    required this.monthdesc,
    required this.dates,
    required this.present,
    required this.absent,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: parseInt(json['id']),
      syid: parseInt(json['syid']),
      month: parseInt(json['month']),
      days: parseInt(json['days']),
      year: json['year'] ?? '',
      semid: parseInt(json['semid']),
      levelid: parseInt(json['levelid']),
      sydesc: json['sydesc'] ?? '',
      sort: json['sort'] ?? '',
      isactive: parseInt(json['isactive']),
      monthdesc: json['monthdesc'] ?? '',
      dates: List<String>.from(json['dates'] ?? []),
      present: parseInt(json['present']),
      absent: parseInt(json['absent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syid': syid,
      'month': month,
      'days': days,
      'year': year,
      'semid': semid,
      'levelid': levelid,
      'sydesc': sydesc,
      'sort': sort,
      'isactive': isactive,
      'monthdesc': monthdesc,
      'dates': dates,
      'present': present,
      'absent': absent,
    };
  }

  @override
  String toString() {
    return 'Attendance(id: $id, syid: $syid, month: $month, days: $days, year: $year, semid: $semid, levelid: $levelid, sydesc: $sydesc, sort: $sort,isactive: $isactive, monthdesc: $monthdesc, dates: $dates, present: $present, absent: $absent)';
  }
}
