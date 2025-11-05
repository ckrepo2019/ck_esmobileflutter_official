import 'package:flutter/material.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/ledger.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class BillingInformationPage extends StatefulWidget {
  const BillingInformationPage({super.key});

  @override
  State<BillingInformationPage> createState() => BillingInformationState();
}

class BillingInformationState extends State<BillingInformationPage> {
  String id = '0';
  int syid = 1;
  int semid = 1;
  int levelid = 0;
  String selectedYear = '';
  String selectedSem = '';
  List<String> years = [];
  List<Ledger> data = [];

  String syDesc = '';
  String sem = '';
  String totalBalance = 'Php 0.00';
  String totalPayment = 'Php 100.00';
  bool loading = true;
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
  List<EnrolledStud> enrolledstud = [];
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    getUser();
    getSchoolInfo();
    getYearandSem();

    print('levelid: $levelid');
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> getSchoolInfo() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'BILLING INFORMATION',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: DropdownButtonFormField2<String>(
                          value: selectedYear.isNotEmpty ? selectedYear : null,
                          items: schoolYear
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.id.toString(),
                                  child: Text(
                                    option.sydesc,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value!;
                              syid = int.parse(selectedYear);
                            });
                            if (selectedSem.isNotEmpty) getLedger();
                          },
                          decoration: const InputDecoration(
                            labelText: 'School Year',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      if (levelid >= 17)
                        Flexible(
                          flex: 1,
                          child: DropdownButtonFormField2<String>(
                            value: selectedSem.isNotEmpty ? selectedSem : null,
                            items: schoolSem
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.id.toString(),
                                    child: Text(
                                      option.semester,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSem = value!;
                                semid = int.parse(selectedSem);
                              });
                              if (selectedYear.isNotEmpty) getLedger();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Semester',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                                      "SY: ${schoolYear.firstWhere((year) => year.id.toString() == selectedYear).sydesc}"
                                      "${levelid > 13 ? "\nSem: ${schoolSem.firstWhere((sem) => sem.id.toString() == selectedSem).semester}" : ""}",
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Card(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.money, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Payments',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              totalPayment,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columnSpacing: constraints.maxWidth < 600
                                  ? 10.0
                                  : 20.0,
                              dividerThickness: 0,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Particulars',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Payments',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                              rows: data.map((ledger) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        width: 90,
                                        child: Text(
                                          ledger.particulars,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            ledger.amount,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            ledger.payment,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  getYearandSem() async {
    final response = await CallApi().getYearandSem();
    final Map<String, dynamic> responseData = json.decode(response.body);

    schoolYear = (responseData['sy'] as List)
        .map((data) => SchoolYear.fromJson(data))
        .toList();
    schoolSem = (responseData['semester'] as List)
        .map((data) => Sem.fromJson(data))
        .toList();

    schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

    var activeYear = schoolYear.firstWhere((year) => year.isactive == 1);
    var activeSem = schoolSem.firstWhere((sem) => sem.isactive == 1);

    if (activeYear != null && activeSem != null) {
      selectedYear = activeYear.id.toString();
      selectedSem = activeSem.id.toString();
    } else if (schoolYear.isNotEmpty && schoolSem.isNotEmpty) {
      selectedYear = schoolYear.last.id.toString();
      selectedSem = schoolSem.first.id.toString();
    }

    syid = int.parse(selectedYear);
    semid = int.parse(selectedSem);

    setState(() {
      getLedger();
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrollment();
      await getLedger();
    }
  }

  getEnrollment() async {
    final response = await CallApi().getEnrolledStud(id);
    final List<dynamic> enrollmentList = json.decode(
      response.body,
    )['enrolledstud_info'];

    setState(() {
      enrolledstud = enrollmentList
          .map((model) => EnrolledStud.fromJson(model))
          .toList();
      if (enrolledstud.isNotEmpty) {
        levelid = enrolledstud.last.levelid;
      }
    });
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
      totalPayment = 'Php ${totalLedger.payment}';

      loading = false;
    });
  }
}
