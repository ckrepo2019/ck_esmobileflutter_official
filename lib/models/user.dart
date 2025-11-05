// class User {
//   int id;
//   int sectionid;
//   int userid;
//   String? lrn;
//   String? firstname;
//   String? middlename;
//   String? lastname;
//   String suffix;
//   String? sid;
//   String? fathername;
//   String? fcontactno;
//   String? foccupation;
//   String? mothername;
//   String? mcontactno;
//   String? moccupation;
//   String? guardianname;
//   String? gcontactno;
//   String? guardianrelation;
//   String? dob;
//   String? gender;
//   int? nationality;
//   String? contactno;
//   String? semail;
//   int? levelid;
//   String? picurl;
//   String? street;
//   String? barangay;
//   String? city;
//   String? province;
//   int ismothernum;
//   int isfathernum;
//   int isguardannum;
//   String? nationalityDesc;
//   String? courseDesc;

//   User({
//     this.id = 0,
//     this.sectionid = 0,
//     this.userid = 0,
//     this.lrn,
//     this.firstname,
//     this.middlename,
//     this.lastname,
//     this.suffix = '',
//     this.sid,
//     this.fathername,
//     this.fcontactno,
//     this.foccupation,
//     this.mothername,
//     this.mcontactno,
//     this.moccupation,
//     this.guardianname,
//     this.gcontactno,
//     this.guardianrelation,
//     this.dob,
//     this.gender,
//     this.nationality,
//     this.contactno,
//     this.semail,
//     this.levelid,
//     this.picurl,
//     this.street,
//     this.barangay,
//     this.city,
//     this.province,
//     this.ismothernum = 0,
//     this.isfathernum = 0,
//     this.isguardannum = 0,
//     this.nationalityDesc,
//     this.courseDesc,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] ?? 0,
//       sectionid: json['sectionid'] ?? 0,
//       userid: json['userid'] ?? 0,
//       lrn: json['lrn'] ?? '',
//       firstname: json['firstname'] ?? '',
//       middlename: json['middlename'] ?? '',
//       lastname: json['lastname'] ?? '',
//       suffix: json['suffix'] ?? '',
//       sid: json['sid'] ?? '',
//       fathername: json['fathername'] ?? '',
//       fcontactno: json['fcontactno'] ?? '',
//       foccupation: json['foccupation'] ?? '',
//       mothername: json['mothername'] ?? '',
//       mcontactno: json['mcontactno'] ?? '',
//       moccupation: json['moccupation'] ?? '',
//       guardianname: json['guardianname'] ?? '',
//       gcontactno: json['gcontactno'] ?? '',
//       guardianrelation: json['guardianrelation'] ?? '',
//       dob: json['dob'] ?? '',
//       gender: json['gender'],
//       nationality: json['nationality'] ?? 0,
//       contactno: json['contactno'] ?? '',
//       semail: json['semail'] ?? '',
//       levelid: json['levelid'] ?? 0,
//       picurl: json['picurl'] ?? '',
//       street: json['street'] ?? '',
//       barangay: json['barangay'] ?? '',
//       city: json['city'] ?? '',
//       province: json['province'] ?? '',
//       ismothernum: json['ismothernum'] ?? 0,
//       isfathernum: json['isfathernum'] ?? 0,
//       isguardannum: json['isguardannum'] ?? 0,
//       nationalityDesc: json['nationalityDesc'] ?? '',
//       courseDesc: json['courseDesc'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sectionid': sectionid,
//       'userid': userid,
//       'lrn': lrn,
//       'firstname': firstname,
//       'middlename': middlename,
//       'lastname': lastname,
//       'suffix': suffix,
//       'sid': sid,
//       'fathername': fathername,
//       'fcontactno': fcontactno,
//       'foccupation': foccupation,
//       'mothername': mothername,
//       'mcontactno': mcontactno,
//       'moccupation': moccupation,
//       'guardianname': guardianname,
//       'gcontactno': gcontactno,
//       'guardianrelation': guardianrelation,
//       'dob': dob,
//       'gender': gender,
//       'nationality': nationality,
//       'contactno': contactno,
//       'semail': semail,
//       'levelid': levelid,
//       'picurl': picurl,
//       'street': street,
//       'barangay': barangay,
//       'city': city,
//       'province': province,
//       'ismothernum': ismothernum,
//       'isfathernum': isfathernum,
//       'isguardannum': isguardannum,
//       'nationalityDesc': nationalityDesc,
//       'courseDesc': courseDesc,
//     };
//   }

//   String? getPrimaryContactName() {
//     if (isfathernum == 1) {
//       return fathername;
//     } else if (ismothernum == 1) {
//       return mothername;
//     } else if (isguardannum == 1) {
//       return guardianname;
//     } else {
//       return null;
//     }
//   }

//   @override
//   String toString() {
//     return 'User{id: $id, sectionid: $sectionid, userid: $userid, lrn: $lrn, firstname: $firstname, middlename: $middlename, lastname: $lastname, suffix: $suffix, sid: $sid, fathername: $fathername, fcontactno: $fcontactno, foccupation: $foccupation, mothername: $mothername, mcontactno: $mcontactno, moccupation: $moccupation, guardianname: $guardianname, gcontactno: $gcontactno, guardianrelation: $guardianrelation, dob: $dob, gender: $gender, nationality: $nationality, contactno: $contactno, semail: $semail, levelid: $levelid, picurl: $picurl, street: $street, barangay: $barangay, city: $city, province: $province, ismothernum: $ismothernum, isfathernum: $isfathernum, isguardannum: $isguardannum, nationalityDesc: $nationalityDesc, courseDesc: $courseDesc, primaryContactName: ${getPrimaryContactName()}}';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class User {
  int id;
  int sectionid;
  int userid;
  String? lrn;
  String? firstname;
  String? middlename;
  String? lastname;
  String suffix;
  String? sid;
  String? fathername;
  String? fcontactno;
  String? foccupation;
  String? mothername;
  String? mcontactno;
  String? moccupation;
  String? guardianname;
  String? gcontactno;
  String? guardianrelation;
  String? dob;
  String? gender;
  int? nationality;
  String? contactno;
  String? semail;
  int? levelid;
  String? picurl;
  String? street;
  String? barangay;
  String? city;
  String? province;
  int ismothernum;
  int isfathernum;
  int isguardannum;
  String? nationalityDesc;
  String? courseDesc;

  User({
    this.id = 0,
    this.sectionid = 0,
    this.userid = 0,
    this.lrn,
    this.firstname,
    this.middlename,
    this.lastname,
    this.suffix = '',
    this.sid,
    this.fathername,
    this.fcontactno,
    this.foccupation,
    this.mothername,
    this.mcontactno,
    this.moccupation,
    this.guardianname,
    this.gcontactno,
    this.guardianrelation,
    this.dob,
    this.gender,
    this.nationality,
    this.contactno,
    this.semail,
    this.levelid,
    this.picurl,
    this.street,
    this.barangay,
    this.city,
    this.province,
    this.ismothernum = 0,
    this.isfathernum = 0,
    this.isguardannum = 0,
    this.nationalityDesc,
    this.courseDesc,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseInt(json['id']),
      sectionid: parseInt(json['sectionid']),
      userid: parseInt(json['userid']),
      lrn: json['lrn'] ?? '',
      firstname: json['firstname'] ?? '',
      middlename: json['middlename'] ?? '',
      lastname: json['lastname'] ?? '',
      suffix: json['suffix'] ?? '',
      sid: json['sid'] ?? '',
      fathername: json['fathername'] ?? '',
      fcontactno: json['fcontactno'] ?? '',
      foccupation: json['foccupation'] ?? '',
      mothername: json['mothername'] ?? '',
      mcontactno: json['mcontactno'] ?? '',
      moccupation: json['moccupation'] ?? '',
      guardianname: json['guardianname'] ?? '',
      gcontactno: json['gcontactno'] ?? '',
      guardianrelation: json['guardianrelation'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'],
      nationality: parseInt(json['nationality']),
      contactno: json['contactno'] ?? '',
      semail: json['semail'] ?? '',
      levelid: parseInt(json['levelid']),
      picurl: json['picurl'] ?? '',
      street: json['street'] ?? '',
      barangay: json['barangay'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      ismothernum: parseInt(json['ismothernum']),
      isfathernum: parseInt(json['isfathernum']),
      isguardannum: parseInt(json['isguardannum']),
      nationalityDesc: json['nationalityDesc'] ?? '',
      courseDesc: json['courseDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionid': sectionid,
      'userid': userid,
      'lrn': lrn,
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'suffix': suffix,
      'sid': sid,
      'fathername': fathername,
      'fcontactno': fcontactno,
      'foccupation': foccupation,
      'mothername': mothername,
      'mcontactno': mcontactno,
      'moccupation': moccupation,
      'guardianname': guardianname,
      'gcontactno': gcontactno,
      'guardianrelation': guardianrelation,
      'dob': dob,
      'gender': gender,
      'nationality': nationality,
      'contactno': contactno,
      'semail': semail,
      'levelid': levelid,
      'picurl': picurl,
      'street': street,
      'barangay': barangay,
      'city': city,
      'province': province,
      'ismothernum': ismothernum,
      'isfathernum': isfathernum,
      'isguardannum': isguardannum,
      'nationalityDesc': nationalityDesc,
      'courseDesc': courseDesc,
    };
  }

  String? getPrimaryContactName() {
    if (isfathernum == 1) {
      return fathername;
    } else if (ismothernum == 1) {
      return mothername;
    } else if (isguardannum == 1) {
      return guardianname;
    } else {
      return null;
    }
  }

  @override
  String toString() {
    return 'User{id: $id, sectionid: $sectionid, userid: $userid, lrn: $lrn, firstname: $firstname, middlename: $middlename, lastname: $lastname, suffix: $suffix, sid: $sid, fathername: $fathername, fcontactno: $fcontactno, foccupation: $foccupation, mothername: $mothername, mcontactno: $mcontactno, moccupation: $moccupation, guardianname: $guardianname, gcontactno: $gcontactno, guardianrelation: $guardianrelation, dob: $dob, gender: $gender, nationality: $nationality, contactno: $contactno, semail: $semail, levelid: $levelid, picurl: $picurl, street: $street, barangay: $barangay, city: $city, province: $province, ismothernum: $ismothernum, isfathernum: $isfathernum, isguardannum: $isguardannum, nationalityDesc: $nationalityDesc, courseDesc: $courseDesc, primaryContactName: ${getPrimaryContactName()}}';
  }
}
