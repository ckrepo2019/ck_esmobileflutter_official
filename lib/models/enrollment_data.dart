// class EnrollmentData {
//   final String levelname;
//   final String courseabrv;
//   final int sectionid;
//   final String studstatus;
//   final int levelid;
//   final String sydesc;
//   final int syid;
//   final int semid;
//   final String semdesc;
//   final String nationality;
//   final String courseDesc;

//   EnrollmentData({
//     required this.levelname,
//     required this.courseabrv,
//     required this.sectionid,
//     required this.studstatus,
//     required this.levelid,
//     required this.sydesc,
//     required this.syid,
//     required this.semid,
//     required this.semdesc,
//     required this.nationality,
//     required this.courseDesc,
//   });

//   factory EnrollmentData.fromJson(Map json) {
//     var levelname = json['levelname'] ?? '';
//     var courseabrv = json['courseabrv'] ?? '';
//     var sectionid = json['sectionid'] ?? 0;
//     var studstatus = json['studstatus'] ?? '';
//     var levelid = json['levelid'] ?? 0;
//     var sydesc = json['sydesc'] ?? '';
//     var syid = json['syid'] ?? 0;
//     var semid = json['semid'] ?? 0;
//     var semdesc = json['semdesc'] ?? '';
//     var nationality = json['nationality'] ?? '';
//     var courseDesc = json['courseDesc'] ?? '';

//     return EnrollmentData(
//       levelname: levelname,
//       courseabrv: courseabrv,
//       sectionid: sectionid,
//       studstatus: studstatus,
//       levelid: levelid,
//       sydesc: sydesc,
//       syid: syid,
//       semid: semid,
//       semdesc: semdesc,
//       nationality: nationality,
//       courseDesc: courseDesc,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'sydesc': sydesc,
//       'levelname': levelname,
//       'semid': semid,
//       'syid': syid,
//       'levelid': levelid,
//       'sectionid': sectionid,
//       'courseabrv': courseabrv,
//       'studstatus': studstatus,
//       'semdesc': semdesc,
//       'nationality': nationality,
//       'courseDesc': courseDesc,
//     };
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class EnrollmentData {
  final String levelname;
  final String courseabrv;
  final int sectionid;
  final String studstatus;
  final int levelid;
  final String sydesc;
  final int syid;
  final int semid;
  final String semdesc;
  final String nationality;
  final String courseDesc;

  EnrollmentData({
    required this.levelname,
    required this.courseabrv,
    required this.sectionid,
    required this.studstatus,
    required this.levelid,
    required this.sydesc,
    required this.syid,
    required this.semid,
    required this.semdesc,
    required this.nationality,
    required this.courseDesc,
  });

  factory EnrollmentData.fromJson(Map json) {
    var levelname = json['levelname'] ?? '';
    var courseabrv = json['courseabrv'] ?? '';
    var sectionid = parseInt(json['sectionid']);
    var studstatus = json['studstatus'] ?? '';
    var levelid = parseInt(json['levelid']);
    var sydesc = json['sydesc'] ?? '';
    var syid = parseInt(json['syid']);
    var semid = parseInt(json['semid']);
    var semdesc = json['semdesc'] ?? '';
    var nationality = json['nationality'] ?? '';
    var courseDesc = json['courseDesc'] ?? '';

    return EnrollmentData(
      levelname: levelname,
      courseabrv: courseabrv,
      sectionid: sectionid,
      studstatus: studstatus,
      levelid: levelid,
      sydesc: sydesc,
      syid: syid,
      semid: semid,
      semdesc: semdesc,
      nationality: nationality,
      courseDesc: courseDesc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sydesc': sydesc,
      'levelname': levelname,
      'semid': semid,
      'syid': syid,
      'levelid': levelid,
      'sectionid': sectionid,
      'courseabrv': courseabrv,
      'studstatus': studstatus,
      'semdesc': semdesc,
      'nationality': nationality,
      'courseDesc': courseDesc,
    };
  }
}
