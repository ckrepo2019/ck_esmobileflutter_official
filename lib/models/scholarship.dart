// class ScholarshipSetup {
//   final int id;
//   final String description;
//   final int isactive;
//   final String endofsubmission;

//   ScholarshipSetup({
//     required this.id,
//     required this.description,
//     required this.isactive,
//     required this.endofsubmission,
//   });

//   factory ScholarshipSetup.fromJson(Map json) {
//     return ScholarshipSetup(
//       id: json['id'] ?? 0,
//       description: json['description'] ?? '',
//       isactive: json['isactive'] ?? 0,
//       endofsubmission: json['endofsubmission'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'description': description,
//       'isactive': isactive,
//       'endofsubmission': endofsubmission,
//     };
//   }

//   @override
//   String toString() {
//     return 'ScholarshipSetup{id: $id, description: $description, isactive: $isactive, endofsubmission: $endofsubmission}';
//   }
// }

// class Scholarship {
//   final int id;
//   final String description;
//   final int studid;
//   final int syid;
//   final int semid;
//   final int scholarship_setup_id;
//   final String scholar_status;
//   int? deleted;
//   final String createddatetime;
//   final String studstatus;

//   Scholarship({
//     required this.id,
//     required this.description,
//     required this.studid,
//     required this.syid,
//     required this.semid,
//     required this.scholarship_setup_id,
//     required this.scholar_status,
//     required this.deleted,
//     required this.createddatetime,
//     required this.studstatus,
//   });

//   factory Scholarship.fromJson(Map json) {
//     return Scholarship(
//       id: json['id'] ?? 0,
//       description: json['description'] ?? '',
//       studid: json['studid'] ?? 0,
//       syid: json['syid'] ?? 0,
//       semid: json['semid'] ?? 0,
//       scholarship_setup_id: json['scholarship_setup_id'] ?? 0,
//       scholar_status: json['scholar_status'] ?? '',
//       deleted: json['deleted'] ?? 0,
//       createddatetime: json['createddatetime'] ?? '',
//       studstatus: json['studstatus'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'description': description,
//       'studid': studid,
//       'syid': syid,
//       'semid': semid,
//       'scholarship_setup_id': scholarship_setup_id,
//       'scholar_status': scholar_status,
//       'deleted': deleted,
//       'createddatetime': createddatetime,
//       'studstatus': studstatus,
//     };
//   }

//   @override
//   String toString() {
//     return 'Scholarship{id: $id, description: $description, studid: $studid, syid: $syid, semid: $semid, scholarship_setup_id: $scholarship_setup_id, scholar_status: $scholar_status, deleted: $deleted, createddatetime: $createddatetime, studstatus: $studstatus}';
//   }
// }

// class Requirement {
//   final int id;
//   final int scholarship_setup_id;
//   final String description;
//   final String fileurl;
//   final int isactive;

//   Requirement({
//     required this.id,
//     required this.scholarship_setup_id,
//     required this.description,
//     required this.fileurl,
//     required this.isactive,
//   });

//   factory Requirement.fromJson(Map json) {
//     return Requirement(
//       id: json['id'] ?? 0,
//       scholarship_setup_id: json['scholarship_setup_id'] ?? 0,
//       description: json['description'] ?? '',
//       fileurl: json['fileurl'] ?? '',
//       isactive: json['isactive'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'scholarship_setup_id': scholarship_setup_id,
//       'description': description,
//       'fileurl': fileurl,
//       'isactive': isactive,
//     };
//   }

//   @override
//   String toString() {
//     return 'Requirement{id: $id, scholarship_setup_id: $scholarship_setup_id, description: $description, fileurl: $fileurl, isactive: $isactive}';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class ScholarshipSetup {
  final int id;
  final String description;
  final int isactive;
  final String endofsubmission;

  ScholarshipSetup({
    required this.id,
    required this.description,
    required this.isactive,
    required this.endofsubmission,
  });

  factory ScholarshipSetup.fromJson(Map json) {
    return ScholarshipSetup(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      isactive: json['isactive'] ?? 0,
      endofsubmission: json['endofsubmission'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isactive': isactive,
      'endofsubmission': endofsubmission,
    };
  }

  @override
  String toString() {
    return 'ScholarshipSetup{id: $id, description: $description, isactive: $isactive, endofsubmission: $endofsubmission}';
  }
}

class Scholarship {
  final int id;
  final String description;
  final int studid;
  final int syid;
  final int semid;
  final int scholarship_setup_id;
  final String scholar_status;
  int? deleted;
  final String createddatetime;
  final String studstatus;

  Scholarship({
    required this.id,
    required this.description,
    required this.studid,
    required this.syid,
    required this.semid,
    required this.scholarship_setup_id,
    required this.scholar_status,
    required this.deleted,
    required this.createddatetime,
    required this.studstatus,
  });

  factory Scholarship.fromJson(Map json) {
    return Scholarship(
      id: parseInt(json['id']),
      description: json['description'] ?? '',
      studid: parseInt(json['studid']),
      syid: parseInt(json['syid']),
      semid: parseInt(json['semid']),
      scholarship_setup_id: parseInt(json['scholarship_setup_id']),
      scholar_status: json['scholar_status'] ?? '',
      deleted: parseInt(json['deleted']),
      createddatetime: json['createddatetime'] ?? '',
      studstatus: json['studstatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'studid': studid,
      'syid': syid,
      'semid': semid,
      'scholarship_setup_id': scholarship_setup_id,
      'scholar_status': scholar_status,
      'deleted': deleted,
      'createddatetime': createddatetime,
      'studstatus': studstatus,
    };
  }

  @override
  String toString() {
    return 'Scholarship{id: $id, description: $description, studid: $studid, syid: $syid, semid: $semid, scholarship_setup_id: $scholarship_setup_id, scholar_status: $scholar_status, deleted: $deleted, createddatetime: $createddatetime, studstatus: $studstatus}';
  }
}

class Requirement {
  final int id;
  final int scholarship_setup_id;
  final String description;
  final String fileurl;
  final int isactive;

  Requirement({
    required this.id,
    required this.scholarship_setup_id,
    required this.description,
    required this.fileurl,
    required this.isactive,
  });

  factory Requirement.fromJson(Map json) {
    return Requirement(
      id: parseInt(json['id']),
      scholarship_setup_id: parseInt(json['scholarship_setup_id']),
      description: json['description'] ?? '',
      fileurl: json['fileurl'] ?? '',
      isactive: parseInt(json['isactive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scholarship_setup_id': scholarship_setup_id,
      'description': description,
      'fileurl': fileurl,
      'isactive': isactive,
    };
  }

  @override
  String toString() {
    return 'Requirement{id: $id, scholarship_setup_id: $scholarship_setup_id, description: $description, fileurl: $fileurl, isactive: $isactive}';
  }
}
