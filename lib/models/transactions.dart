// class Transactions {
//   final int id;
//   final String ornum;
//   final String transdate;
//   final String totalamount;
//   final String amountpaid;
//   final int studid;
//   final String studname;
//   final int semid;
//   final int syid;
//   final String paytype;

//   Transactions({
//     required this.id,
//     required this.ornum,
//     required this.transdate,
//     required this.totalamount,
//     required this.amountpaid,
//     required this.studid,
//     required this.semid,
//     required this.syid,
//     required this.studname,
//     required this.paytype,
//   });

//   factory Transactions.fromJson(Map<String, dynamic> json) {
//     return Transactions(
//       id: json['id'] ?? 0,
//       ornum: json['ornum'] ?? '',
//       transdate: json['transdate'] ?? '',
//       totalamount: json['totalamount'] ?? '',
//       amountpaid: json['amountpaid'] ?? '',
//       studid: json['studid'] ?? 0,
//       semid: json['semid'] ?? 0,
//       syid: json['syid'] ?? 0,
//       studname: json['studname'] ?? '',
//       paytype: json['paytype'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'ornum': ornum,
//       'transdate': transdate,
//       'totalamount': totalamount,
//       'amountpaid': amountpaid,
//       'studid': studid,
//       'semid': semid,
//       'syid': syid,
//       'studname': studname,
//       'paytype': paytype,
//     };
//   }

//   @override
//   String toString() {
//     return 'Transactions(id: $id, ornum: $ornum, transdate: $transdate, totalamount: $totalamount, amountpaid: $amountpaid, studid: $studid, semid: $semid, syid: $syid, studname: $studname, paytype: $paytype)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Transactions {
  final int id;
  final String ornum;
  final String transdate;
  final String totalamount;
  final String amountpaid;
  final int studid;
  final String studname;
  final int semid;
  final int syid;
  final String paytype;

  Transactions({
    required this.id,
    required this.ornum,
    required this.transdate,
    required this.totalamount,
    required this.amountpaid,
    required this.studid,
    required this.semid,
    required this.syid,
    required this.studname,
    required this.paytype,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      id: parseInt(json['id']),
      ornum: json['ornum'] ?? '',
      transdate: json['transdate'] ?? '',
      totalamount: json['totalamount'] ?? '',
      amountpaid: json['amountpaid'] ?? '',
      studid: parseInt(json['studid']),
      semid: parseInt(json['semid']),
      syid: parseInt(json['syid']),
      studname: json['studname'] ?? '',
      paytype: json['paytype'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ornum': ornum,
      'transdate': transdate,
      'totalamount': totalamount,
      'amountpaid': amountpaid,
      'studid': studid,
      'semid': semid,
      'syid': syid,
      'studname': studname,
      'paytype': paytype,
    };
  }

  @override
  String toString() {
    return 'Transactions(id: $id, ornum: $ornum, transdate: $transdate, totalamount: $totalamount, amountpaid: $amountpaid, studid: $studid, semid: $semid, syid: $syid, studname: $studname, paytype: $paytype)';
  }
}
