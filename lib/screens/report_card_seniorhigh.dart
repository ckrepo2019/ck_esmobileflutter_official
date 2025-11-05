import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/grades.dart';
import '../widgets/studentattendance.dart';
import '../widgets/observedvalues.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class ReportCardSeniorHigh extends StatefulWidget {
  const ReportCardSeniorHigh({super.key});

  @override
  State<ReportCardSeniorHigh> createState() => _ReportCardSeniorHighState();
}

class _ReportCardSeniorHighState extends State<ReportCardSeniorHigh> {
  Color mainClr = Colors.white;

  var id = '0';
  var studid = '0';
  var syid = 1;
  var semid = 0;
  var gradelevel = 0;
  var sectionid = 0;
  var strand = 0;
  String selectedYear = '';
  String selectedSem = '1st Semester';
  List<String> years = [];
  List<String> sem = ['1st Semester', '2nd Semester'];
  List<Grades> data = [];
  List<Grades> finalGrade = [];
  List<EnrollmentInfo> enInfoData = [];
  List<Grades> concatenatedArray = [];
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
  List<EnrolledStud> enrolledstud = [];
  bool loading = true;

  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = const Color.fromARGB(0, 255, 255, 255);

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

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');
    if (json != null) {
      setState(() {
        id = json;
      });
      getEnrollment();
    }
  }

  Future<void> getGrades(int index) async {
    Iterable gdList = [];
    Iterable gdFinal = [];

    await CallApi()
        .getStudGrade(id, gradelevel, syid, sectionid, strand, index)
        .then((response) {
          setState(() {
            Iterable list = json.decode(response.body);

            for (var gd in list) {
              gdList = gd['grades'];
              if (gradelevel < 17) {
                gdFinal = gd['finalgrade'];
              }
            }

            if (gradelevel < 17) {
              data = gdList.map((model) {
                return Grades.fromJson(model);
              }).toList();

              // print(data);
            } else {
              data = gdList.map((model) {
                return Grades(
                  syid: model['syid'] ?? 0,
                  semid: model['semid'] ?? 0,
                  subjcode: model['subjcode'] ?? '',
                  subjdesc: model['subjdesc'] ?? '',
                  q1: model['prelemgrade'] ?? 0,
                  q2: model['midtermgrade'] ?? 0,
                  q3: model['prefigrade'] ?? 0,
                  q4: model['finalgrade'] ?? 0,
                  q1status: model['q1status']?.toString() ?? '',
                  q2status: model['q2status']?.toString() ?? '',
                  q3status: model['q3status']?.toString() ?? '',
                  q4status: model['q4status']?.toString() ?? '',
                  prelemgrade: model['prelemgrade'] ?? 0,
                  midtermgrade: model['midtermgrade'] ?? 0,
                  prefigrade: model['prefigrade'] ?? 0,
                  finalgrade: model['finalgrade'] ?? 0,
                  prelemstatus: model['prelemstatus']?.toString() ?? '',
                  midtermstatus: model['midtermstatus']?.toString() ?? '',
                  prefistatus: model['prefistatus']?.toString() ?? '',
                  finalstatus: model['finalstatus']?.toString() ?? '',
                  fg: model['fg'] ?? '',
                  finalrating: model['finalrating'] ?? '',
                  fgremarks: model['fgremarks'] ?? '',
                  actiontaken: model['actiontaken'] ?? '',
                );
              }).toList();
            }

            if (gradelevel == 14 || gradelevel == 15) {
              finalGrade = gdFinal.map((ave) {
                return ave['semid'].toString() == index.toString()
                    ? Grades.parseAverage(ave)
                    : Grades(
                        syid: 0,
                        semid: 0,
                        subjcode: '',
                        q1: '',
                        q2: '',
                        q3: '',
                        q4: '',
                        q1status: '',
                        q2status: '',
                        q3status: '',
                        q4status: '',
                        prelemgrade: '',
                        midtermgrade: '',
                        prefigrade: '',
                        finalgrade: '',
                        prelemstatus: '',
                        midtermstatus: '',
                        prefistatus: '',
                        finalstatus: '',
                        fg: '',
                        finalrating: '',
                        fgremarks: '',
                        actiontaken: '',
                        subjdesc: '',
                      );
              }).toList();
            }

            semid = index;
            concatenatedArray = [...data, ...finalGrade];
            concatenatedArray = concatenatedArray
                .where((grade) => grade.subjcode.isNotEmpty)
                .toList();
          });
        });
  }

  getYearandSem() async {
    final response = await CallApi().getYearandSem();
    final Map<String, dynamic> responseData = json.decode(response.body);

    schoolSem = (responseData['semester'] as List)
        .map((data) => Sem.fromJson(data))
        .toList();

    var activeSem = schoolSem.firstWhere((sem) => sem.isactive == 1);

    if (activeSem != null) {
      selectedSem = activeSem.id.toString();
    } else if (schoolSem.isNotEmpty) {
      selectedSem = schoolSem.first.id.toString();
    }

    await getEnrollment();

    setState(() {});
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
        }

        print('enrolledstud: $enrolledstud');
      });
    });
  }

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();

        var lastindex = enInfoData[enInfoData.length - 1];

        setState(() {
          gradelevel = lastindex.levelid;
          selectedYear = lastindex.sydesc;
          syid = lastindex.syid;
          sectionid = lastindex.sectionid;
          strand = lastindex.strandid;

          getGrades(int.parse(selectedSem));
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getUser();
    await getSchoolInfo();
    getYearandSem();
    await getEnrollment();
    getEnrolledStud();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REPORT CARD',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: schoolColor,
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(fontSize: 12),
                    tabs: const [
                      Tab(text: 'Grades'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Core Values'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [_buildGrades(), _buildAttendance(), _buildCoreValues()],
          ),
        ),
      ),
    );
  }

  Widget _buildGrades() {
    if (selectedYear.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/search1.png'),
            const SizedBox(height: 10),
            Text(
              "Select School Year and Semester to fetch data",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: schoolColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        Row(
          children: [
            Expanded(
              child: selectedYear.isNotEmpty
                  ? DropdownButtonFormField2<String>(
                      decoration: const InputDecoration(
                        labelText: 'School Year',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      value: selectedYear,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          for (var yr in enInfoData) {
                            if (yr.sydesc == selectedYear) {
                              syid = yr.syid;
                              gradelevel = yr.levelid;
                              sectionid = yr.sectionid;
                              strand = yr.strandid;

                              if (selectedSem.isNotEmpty) {
                                getGrades(int.parse(selectedSem));
                              }
                            }
                          }
                        });
                      },
                      items: years.map<DropdownMenuItem<String>>((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(
                            year,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    )
                  : const CircularProgressIndicator(),
            ),
            const SizedBox(width: 10.0),
            if (gradelevel >= 14)
              Expanded(
                child: DropdownButtonFormField2<String>(
                  value: selectedSem,
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
                    if (selectedYear.isNotEmpty && selectedSem.isNotEmpty) {
                      getGrades(int.parse(selectedSem));
                    }
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
        ...concatenatedArray
            .where((grade) => grade.subjdesc != 'GENERAL AVERAGE')
            .map(
              (grade) => Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: const BoxDecoration(),
                child: ClipRRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: schoolColor,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${grade.subjcode}: ',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: grade.subjdesc,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,

                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(1),
                                  5: FlexColumnWidth(1.5),
                                },
                                border: TableBorder.all(color: Colors.black12),
                                children: [
                                  // Header row
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: schoolColor.withOpacity(.2),
                                    ),
                                    children: [
                                      if (semid == 1 || semid == 0) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            'Q1',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            'Q2',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (semid == 2 || semid == 0) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            'Q3',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            'Q4',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          'Final\nRating',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          'Action\nTaken',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Data row
                                  TableRow(
                                    children: [
                                      if (semid == 1 || semid == 0) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            grade.q1 != "null"
                                                ? grade.q1
                                                : '  ',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            grade.q2 != "null"
                                                ? grade.q2
                                                : '  ',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (semid == 2 || semid == 0) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            grade.q3 != "null"
                                                ? grade.q3
                                                : '  ',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Text(
                                            grade.q4 != "null"
                                                ? grade.q4
                                                : '  ',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.finalrating != "null"
                                              ? grade.finalrating
                                              : '  ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.actiontaken,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: grade.actiontaken == 'PASSED'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildAttendance() {
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: StudentAttendanceScreen(),
    );
  }

  Widget _buildCoreValues() {
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: ObservedValuesScreen(),
    );
  }
}
