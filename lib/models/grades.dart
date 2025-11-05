// class Grades {
//   final int syid;
//   final int semid;
//   final String subjcode;
//   final String subjdesc;
//   final String q1;
//   final String q2;
//   final String q3;
//   final String q4;
//   final String prelemgrade;
//   final String midtermgrade;
//   final String prefigrade;
//   final String finalgrade;
//   final String fg;
//   final String finalrating;
//   final String fgremarks;
//   final String actiontaken;

//   Grades({
//     required this.syid,
//     required this.semid,
//     required this.subjcode,
//     required this.subjdesc,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.prelemgrade,
//     required this.midtermgrade,
//     required this.prefigrade,
//     required this.finalgrade,
//     required this.fg,
//     required this.finalrating,
//     required this.fgremarks,
//     required this.actiontaken,
//   });

//   factory Grades.fromJson(Map json) {
//     var syid = json['syid'] ?? 0;
//     var semid = json['semid'] ?? 0;
//     var subjcode = json['subjcode'] ?? '';
//     var subjdesc = json['subjdesc'] ?? '';
//     var q1 = json['q1'].toString();
//     var q2 = json['q2'].toString();
//     var q3 = json['q3'].toString();
//     var q4 = json['q4'].toString();
//     var prelemgrade = json['prelemgrade'].toString();
//     var midtermgrade = json['midtermgrade'].toString();
//     var prefigrade = json['prefigrade'].toString();
//     var finalgrade = json['finalgrade'].toString();
//     var fg = json['fg'].toString();
//     var finalrating = json['finalrating'].toString();
//     var fgremarks = json['fgremarks'].toString();
//     var actiontaken = json['actiontaken'] ?? '';
//     return Grades(
//         syid: syid,
//         semid: semid,
//         subjcode: subjcode,
//         q1: q1,
//         q2: q2,
//         q3: q3,
//         q4: q4,
//         prelemgrade: prelemgrade,
//         midtermgrade: midtermgrade,
//         prefigrade: prefigrade,
//         finalgrade: finalgrade,
//         fg: fg,
//         finalrating: finalrating,
//         fgremarks: fgremarks,
//         actiontaken: actiontaken,
//         subjdesc: subjdesc);
//   }

//   factory Grades.parseAverage(Map json) {
//     var syid = json['syid'] ?? 0;
//     var semid = json['semid'] ?? 0;
//     var subjcode = json['subjdesc'] ?? '';
//     var q1 = json['q1'].toString();
//     var q2 = json['q2'].toString();
//     var q3 = json['q3'].toString();
//     var q4 = json['q4'].toString();
//     var prelemgrade = json['prelemgrade'].toString();
//     var midtermgrade = json['midtermgrade'].toString();
//     var prefigrade = json['prefigrade'].toString();
//     var finalgrade = json['finalgrade'].toString();
//     var fg = json['fg'].toString();
//     var finalrating = json['finalrating'].toString();
//     var fgremarks = json['fgremarks'].toString();
//     var actiontaken = json['actiontaken'] ?? '';
//     return Grades(
//         syid: syid,
//         semid: semid,
//         subjcode: subjcode,
//         q1: q1,
//         q2: q2,
//         q3: q3,
//         q4: q4,
//         prelemgrade: prelemgrade,
//         midtermgrade: midtermgrade,
//         prefigrade: prefigrade,
//         finalgrade: finalgrade,
//         fg: fg,
//         finalrating: finalrating,
//         fgremarks: fgremarks,
//         actiontaken: actiontaken,
//         subjdesc: subjcode);
//   }

//   @override
//   String toString() {
//     return 'Grades(syid: $syid, semid: $semid, subjcode: $subjcode, subjdesc: $subjdesc, q1: $q1, q2: $q2, q3: $q3, q4: $q4, pelemgrade: $prelemgrade, midtermgrade: $midtermgrade, prefigrade: $prefigrade, finalgrade: $finalgrade,fg: $fg, finalrating: $finalrating,fgremarks: $fgremarks, actiontaken: $actiontaken)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Grades {
  final int syid;
  final int semid;
  final String subjcode;
  final String subjdesc;
  final String q1;
  final String q2;
  final String q3;
  final String q4;
  final String q1status;
  final String q2status;
  final String q3status;
  final String q4status;
  final String prelemgrade;
  final String midtermgrade;
  final String prefigrade;
  final String finalgrade;
  final String prelemstatus;
  final String midtermstatus;
  final String prefistatus;
  final String finalstatus;
  final String fg;
  final String finalrating;
  final String fgremarks;
  final String actiontaken;

  Grades({
    required this.syid,
    required this.semid,
    required this.subjcode,
    required this.subjdesc,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q1status,
    required this.q2status,
    required this.q3status,
    required this.q4status,
    required this.prelemgrade,
    required this.midtermgrade,
    required this.prefigrade,
    required this.finalgrade,
    required this.prelemstatus,
    required this.midtermstatus,
    required this.prefistatus,
    required this.finalstatus,
    required this.fg,
    required this.finalrating,
    required this.fgremarks,
    required this.actiontaken,
  });

  factory Grades.fromJson(Map json) {
    var syid = parseInt(json['syid']);
    var semid = parseInt(json['semid']);
    var subjcode = json['subjcode'] ?? '';
    var subjdesc = json['subjdesc'] ?? '';
    var q1 = json['q1'].toString();
    var q2 = json['q2'].toString();
    var q3 = json['q3'].toString();
    var q4 = json['q4'].toString();
    var q1status = json['q1status'].toString();
    var q2status = json['q2status'].toString();
    var q3status = json['q3status'].toString();
    var q4status = json['q4status'].toString();
    var prelemgrade = json['prelemgrade'].toString();
    var midtermgrade = json['midtermgrade'].toString();
    var prefigrade = json['prefigrade'].toString();
    var finalgrade = json['finalgrade'].toString();
    var prelemstatus = json['prelemstatus'].toString();
    var midtermstatus = json['midtermstatus'].toString();
    var prefistatus = json['prefistatus'].toString();
    var finalstatus = json['finalstatus'].toString();
    var fg = json['fg'].toString();
    var finalrating = json['finalrating'].toString();
    var fgremarks = json['fgremarks'].toString();
    var actiontaken = json['actiontaken'] ?? '';
    return Grades(
        syid: syid,
        semid: semid,
        subjcode: subjcode,
        q1: q1,
        q2: q2,
        q3: q3,
        q4: q4,
        q1status: q1status,
        q2status: q2status,
        q3status: q3status,
        q4status: q4status,
        prelemgrade: prelemgrade,
        midtermgrade: midtermgrade,
        prefigrade: prefigrade,
        finalgrade: finalgrade,
        prelemstatus: prelemstatus,
        midtermstatus: midtermstatus,
        prefistatus: prefistatus,
        finalstatus: finalstatus,
        fg: fg,
        finalrating: finalrating,
        fgremarks: fgremarks,
        actiontaken: actiontaken,
        subjdesc: subjdesc);
  }

  factory Grades.parseAverage(Map json) {
    var syid = parseInt(json['syid']);
    var semid = parseInt(json['semid']);
    var subjcode = json['subjdesc'] ?? '';
    var q1 = json['q1'].toString();
    var q2 = json['q2'].toString();
    var q3 = json['q3'].toString();
    var q4 = json['q4'].toString();
    var q1status = json['q1status'].toString();
    var q2status = json['q2status'].toString();
    var q3status = json['q3status'].toString();
    var q4status = json['q4status'].toString();
    var prelemgrade = json['prelemgrade'].toString();
    var midtermgrade = json['midtermgrade'].toString();
    var prefigrade = json['prefigrade'].toString();
    var finalgrade = json['finalgrade'].toString();
    var prelemstatus = json['prelemstatus'].toString();
    var midtermstatus = json['midtermstatus'].toString();
    var prefistatus = json['prefistatus'].toString();
    var finalstatus = json['finalstatus'].toString();
    var fg = json['fg'].toString();
    var finalrating = json['finalrating'].toString();
    var fgremarks = json['fgremarks'].toString();
    var actiontaken = json['actiontaken'] ?? '';
    return Grades(
        syid: syid,
        semid: semid,
        subjcode: subjcode,
        q1: q1,
        q2: q2,
        q3: q3,
        q4: q4,
        q1status: q1status,
        q2status: q2status,
        q3status: q3status,
        q4status: q4status,
        prelemgrade: prelemgrade,
        midtermgrade: midtermgrade,
        prefigrade: prefigrade,
        finalgrade: finalgrade,
        prelemstatus: prelemstatus,
        midtermstatus: midtermstatus,
        prefistatus: prefistatus,
        finalstatus: finalstatus,
        fg: fg,
        finalrating: finalrating,
        fgremarks: fgremarks,
        actiontaken: actiontaken,
        subjdesc: subjcode);
  }

  @override
  String toString() {
    return 'Grades(syid: $syid, semid: $semid, subjcode: $subjcode, subjdesc: $subjdesc, q1: $q1, q2: $q2, q3: $q3, q4: $q4, q1status: $q1status, q2status: $q2status, q3status: $q3status, q4status: $q4status, pelemgrade: $prelemgrade, midtermgrade: $midtermgrade, prefigrade: $prefigrade, finalgrade: $finalgrade,fg: $fg, prelemstatus: $prelemstatus, midtermstatus: $midtermstatus, prefistatus: $prefistatus, finalstatus: $finalstatus, finalrating: $finalrating,fgremarks: $fgremarks, actiontaken: $actiontaken)';
  }
}
