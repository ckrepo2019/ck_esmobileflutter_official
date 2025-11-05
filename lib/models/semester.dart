// class Semester {
//   final int id;
//   final String semester;
//   final int isActive;
//   final int deleted;

//   Semester({
//     required this.id,
//     required this.semester,
//     required this.isActive,
//     required this.deleted,
//   });

//   factory Semester.fromJson(Map<String, dynamic> json) {
//     return Semester(
//       id: json['id'],
//       semester: json['semester'],
//       isActive: json['isactive'],
//       deleted: json['deleted'],
//     );
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Semester {
  final int id;
  final String semester;
  final int isActive;
  final int deleted;

  Semester({
    required this.id,
    required this.semester,
    required this.isActive,
    required this.deleted,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: parseInt(json['id']),
      semester: json['semester'],
      isActive: parseInt(json['isactive']),
      deleted: parseInt(json['deleted']),
    );
  }
}
