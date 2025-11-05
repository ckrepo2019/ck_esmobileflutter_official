// class SchoolInfo {
//   final String schoolid;
//   final String schoolname;
//   final String address;
//   final String picurl;
//   final String abbreviation;
//   final int admission;
//   final String schoolcolor;

//   SchoolInfo({
//     required this.schoolid,
//     required this.schoolname,
//     required this.address,
//     required this.picurl,
//     required this.abbreviation,
//     required this.admission,
//     required this.schoolcolor,
//   });

//   factory SchoolInfo.fromJson(Map<String, dynamic> json) {
//     return SchoolInfo(
//       schoolid: json['schoolid'] ?? '',
//       schoolname: json['schoolname'] ?? '',
//       address: json['address'] ?? '',
//       picurl: json['picurl'] ?? '',
//       abbreviation: json['abbreviation'] ?? '',
//       admission: json['admission'] ?? 0,
//       schoolcolor: json['schoolcolor'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'schoolid': schoolid,
//       'schoolname': schoolname,
//       'address': address,
//       'picurl': picurl,
//       'abbreviation': abbreviation,
//       'admission': admission,
//       'schoolcolor': schoolcolor,
//     };
//   }

//   @override
//   String toString() {
//     return 'SchoolInfo(schoolid: $schoolid,schoolname: $schoolname,address: $address,picurl: $picurl,abbreviation: $abbreviation,admission: $admission,schoolcolor: $schoolcolor)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class SchoolInfo {
  final String schoolid;
  final String schoolname;
  final String address;
  final String picurl;
  final String abbreviation;
  final int admission;
  final String schoolcolor;

  SchoolInfo({
    required this.schoolid,
    required this.schoolname,
    required this.address,
    required this.picurl,
    required this.abbreviation,
    required this.admission,
    required this.schoolcolor,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      schoolid: json['schoolid'] ?? '',
      schoolname: json['schoolname'] ?? '',
      address: json['address'] ?? '',
      picurl: json['picurl'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      admission: parseInt(json['admission']),
      schoolcolor: json['schoolcolor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolid': schoolid,
      'schoolname': schoolname,
      'address': address,
      'picurl': picurl,
      'abbreviation': abbreviation,
      'admission': admission,
      'schoolcolor': schoolcolor,
    };
  }

  @override
  String toString() {
    return 'SchoolInfo(schoolid: $schoolid,schoolname: $schoolname,address: $address,picurl: $picurl,abbreviation: $abbreviation,admission: $admission,schoolcolor: $schoolcolor)';
  }
}
