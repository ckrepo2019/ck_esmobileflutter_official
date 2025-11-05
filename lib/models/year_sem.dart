// class SchoolYear {
//   final int id;
//   final String sydesc;
//   final String sdate;
//   final String edate;
//   final int isactive;

//   SchoolYear({
//     required this.id,
//     required this.sydesc,
//     required this.sdate,
//     required this.edate,
//     required this.isactive,
//   });

//   factory SchoolYear.fromJson(Map<String, dynamic> json) {
//     return SchoolYear(
//       id: json['id'] ?? 0,
//       sydesc: json['sydesc'] ?? '',
//       sdate: json['sdate'] ?? '',
//       edate: json['edate'] ?? '',
//       isactive: json['isactive'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sydesc': sydesc,
//       'sdate': sdate,
//       'edate': edate,
//       'isactive': isactive,
//     };
//   }

//   @override
//   String toString() {
//     return 'SchoolYear{id: $id, sydesc: $sydesc, sdate: $sdate, edate: $edate, isactive: $isactive}';
//   }
// }

// class Sem {
//   final int id;
//   final String semester;
//   final int isactive;
//   final int deleted;

//   Sem({
//     required this.id,
//     required this.semester,
//     required this.isactive,
//     required this.deleted,
//   });

//   factory Sem.fromJson(Map<String, dynamic> json) {
//     return Sem(
//       id: json['id'] ?? 0,
//       semester: json['semester'] ?? '',
//       isactive: json['isactive'] ?? 0,
//       deleted: json['deleted'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'semester': semester,
//       'isactive': isactive,
//       'deleted': deleted,
//     };
//   }

//   @override
//   String toString() {
//     return 'Sem{id: $id, semester: $semester, isactive: $isactive, deleted: $deleted}';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  // Convert to JSON and back to Dart type to ensure consistent parsing
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class SchoolYear {
  final int id;
  final String sydesc;
  final String sdate;
  final String edate;
  final int isactive;

  SchoolYear({
    required this.id,
    required this.sydesc,
    required this.sdate,
    required this.edate,
    required this.isactive,
  });

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    return SchoolYear(
      id: parseInt(json['id']),
      sydesc: json['sydesc'] ?? '',
      sdate: json['sdate'] ?? '',
      edate: json['edate'] ?? '',
      isactive: parseInt(json['isactive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sydesc': sydesc,
      'sdate': sdate,
      'edate': edate,
      'isactive': isactive,
    };
  }

  @override
  String toString() {
    return 'SchoolYear{id: $id, sydesc: $sydesc, sdate: $sdate, edate: $edate, isactive: $isactive}';
  }
}

class Sem {
  final int id;
  final String semester;
  final int isactive;
  final int deleted;

  Sem({
    required this.id,
    required this.semester,
    required this.isactive,
    required this.deleted,
  });

  factory Sem.fromJson(Map<String, dynamic> json) {
    return Sem(
      id: parseInt(json['id']),
      semester: json['semester'] ?? '',
      isactive: parseInt(json['isactive']),
      deleted: parseInt(json['deleted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'isactive': isactive,
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return 'Sem{id: $id, semester: $semester, isactive: $isactive, deleted: $deleted}';
  }
}
