// class EnrollmentInfo {
//   final int syid;
//   final int levelid;
//   final int sectionid;
//   final String sydesc;
//   final String levelname;
//   final String sectionname;
//   final int semid;
//   final String dateenrolled;
//   final int isactive;
//   final int strandid;
//   final String semester;
//   final String strandcode;
//   final String courseabrv;
//   final String courseDesc;

//   EnrollmentInfo({
//     required this.levelid,
//     required this.sectionid,
//     required this.syid,
//     required this.sydesc,
//     required this.levelname,
//     required this.sectionname,
//     required this.semid,
//     required this.dateenrolled,
//     required this.isactive,
//     required this.strandid,
//     required this.semester,
//     required this.strandcode,
//     required this.courseabrv,
//     required this.courseDesc,
//   });

//   factory EnrollmentInfo.fromJson(Map json) {
//     var syid = json['syid'] ?? 0;
//     var levelid = json['levelid'] ?? 0;
//     var sectionid = json['sectionid'] ?? 0;
//     var sydesc = json['sydesc'] ?? '';
//     var levelname = json['levelname'] ?? '';
//     var sectionname = json['sectionname'] ?? '';
//     var semid = json['semid'] ?? 0;
//     var dateenrolled = json['dateenrolled'] ?? '';
//     var isactive = json['isactive'] ?? 0;
//     var strandid = json['strandid'] ?? 0;
//     var semester = json['semester'] ?? '';
//     var strandcode = json['strandcode'] ?? '';
//     var courseabrv = json['courseabrv'] ?? '';
//     var courseDesc = json['courseDesc'] ?? '';
//     return EnrollmentInfo(
//       syid: syid,
//       sydesc: sydesc,
//       levelname: levelname,
//       sectionname: sectionname,
//       semid: semid,
//       dateenrolled: dateenrolled,
//       levelid: levelid,
//       sectionid: sectionid,
//       isactive: isactive,
//       strandid: strandid,
//       semester: semester,
//       strandcode: strandcode,
//       courseabrv: courseabrv,
//       courseDesc: courseDesc,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'syid': syid,
//       'sydesc': sydesc,
//       'levelname': levelname,
//       'sectionname': sectionname,
//       'semid': semid,
//       'dateenrolled': dateenrolled,
//       'levelid': levelid,
//       'sectionid': sectionid,
//       'isactive': isactive,
//       'strandid': strandid,
//       'semester': semester,
//       'strandcode': strandcode,
//       'courseabrv': courseabrv,
//       'courseDesc': courseDesc,
//     };
//   }

//   @override
//   String toString() {
//     return 'EnrollmentInfo(syid: $syid,sydesc: $sydesc,levelname: $levelname, sectionname: $sectionname, semid: $semid, dateenrolled: $dateenrolled, levelid: $levelid, sectionid: $sectionid, isactive: $isactive, strandid: $strandid, semester: $semester, strandcode: $strandcode, courseabrv: $courseabrv, courseDesc: $courseDesc)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class EnrollmentInfo {
  final int syid;
  final int levelid;
  final int sectionid;
  final String sydesc;
  final String levelname;
  final String sectionname;
  final int semid;
  final String dateenrolled;
  final int isactive;
  final int strandid;
  final String semester;
  final String strandcode;
  final String courseabrv;
  final String courseDesc;

  EnrollmentInfo({
    required this.levelid,
    required this.sectionid,
    required this.syid,
    required this.sydesc,
    required this.levelname,
    required this.sectionname,
    required this.semid,
    required this.dateenrolled,
    required this.isactive,
    required this.strandid,
    required this.semester,
    required this.strandcode,
    required this.courseabrv,
    required this.courseDesc,
  });

  factory EnrollmentInfo.fromJson(Map json) {
    var syid = parseInt(json['syid']);
    var levelid = parseInt(json['levelid']);
    var sectionid = parseInt(json['sectionid']);
    var sydesc = json['sydesc'] ?? '';
    var levelname = json['levelname'] ?? '';
    var sectionname = json['sectionname'] ?? '';
    var semid = parseInt(json['semid']);
    var dateenrolled = json['dateenrolled'] ?? '';
    var isactive = parseInt(json['isactive']);
    var strandid = parseInt(json['strandid']);
    var semester = json['semester'] ?? '';
    var strandcode = json['strandcode'] ?? '';
    var courseabrv = json['courseabrv'] ?? '';
    var courseDesc = json['courseDesc'] ?? '';
    return EnrollmentInfo(
      syid: syid,
      sydesc: sydesc,
      levelname: levelname,
      sectionname: sectionname,
      semid: semid,
      dateenrolled: dateenrolled,
      levelid: levelid,
      sectionid: sectionid,
      isactive: isactive,
      strandid: strandid,
      semester: semester,
      strandcode: strandcode,
      courseabrv: courseabrv,
      courseDesc: courseDesc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syid': syid,
      'sydesc': sydesc,
      'levelname': levelname,
      'sectionname': sectionname,
      'semid': semid,
      'dateenrolled': dateenrolled,
      'levelid': levelid,
      'sectionid': sectionid,
      'isactive': isactive,
      'strandid': strandid,
      'semester': semester,
      'strandcode': strandcode,
      'courseabrv': courseabrv,
      'courseDesc': courseDesc,
    };
  }

  @override
  String toString() {
    return 'EnrollmentInfo(syid: $syid,sydesc: $sydesc,levelname: $levelname, sectionname: $sectionname, semid: $semid, dateenrolled: $dateenrolled, levelid: $levelid, sectionid: $sectionid, isactive: $isactive, strandid: $strandid, semester: $semester, strandcode: $strandcode, courseabrv: $courseabrv, courseDesc: $courseDesc)';
  }
}
