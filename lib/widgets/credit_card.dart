import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';

import 'package:pushtrial/models/enrolled_stud.dart';
import 'package:pushtrial/models/ledger.dart';
import 'dart:convert';
import 'package:pushtrial/models/school_info.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({super.key});

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  String id = '0';
  int syid = 1;
  int semid = 1;
  String selectedYear = '';
  String selectedSem = '';
  List<String> years = [];
  List<Ledger> data = [];

  String syDesc = '';
  String sem = '';
  String totalBalance = 'Php 0.00';
  List<EnrolledStud> enrolledstud = [];
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  getSchoolInfo() async {
    final response = await CallApi().getSchoolInfo();

    final parsedResponse = json.decode(response.body);
    if (parsedResponse is List) {
      setState(() {
        schoolInfo = parsedResponse
            .map((model) => SchoolInfo.fromJson(model))
            .toList()
            .cast<SchoolInfo>();

        schoolColor = hexToColor(schoolInfo[0].schoolcolor);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getSchoolInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(255, 14, 19, 29),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Text(
                        "SY: $syDesc${sem.isNotEmpty ? "\nSem: $sem" : ""}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        "Total Balance",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: schoolColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalBalance,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
      });
      getEnrolledStud();
    }
  }

  Future<void> getLedger() async {
    final response = await CallApi().getStudLedger(id, syid, semid);
    setState(() {
      Iterable list = json.decode(response.body);
      data = list.map((model) => Ledger.fromJson(model)).toList();

      Ledger? totalLedger = data.firstWhere(
        (item) => item.particulars.startsWith('TOTAL:'),
      );

      totalBalance = 'Php ${totalLedger.balance}';
    });
  }

  getEnrolledStud() async {
    await CallApi().getEnrolledStud(id).then((response) {
      setState(() {
        var decodedJson = json.decode(response.body);
        if (decodedJson is Map<String, dynamic>) {
          Iterable list = decodedJson['enrolledstud_info'];
          enrolledstud = list
              .map((model) => EnrolledStud.fromJson(model))
              .toList();

          years = enrolledstud.map((e) => e.sydesc).toSet().toList();

          if (enrolledstud.isNotEmpty) {
            var latestYear = enrolledstud.lastWhere(
              (enrollment) => enrollment.syid == enrolledstud.last.syid,
            );

            selectedYear = latestYear.sydesc;
            syid = latestYear.syid;

            var latestSemester = enrolledstud
                .where((enrollment) => enrollment.syid == syid)
                .last;

            semid = latestSemester.semid;
            selectedSem = latestSemester.semester;

            if (semid == 0 || semid == null || selectedSem.isEmpty) {
              semid = 1;
              selectedSem = "";
            }

            syDesc = selectedYear;
            sem = selectedSem;

            getLedger();
          }
        }
      });
    });
  }
}
