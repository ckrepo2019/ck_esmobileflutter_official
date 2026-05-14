import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/grades.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:pushtrial/models/attendance.dart';
import 'package:pushtrial/models/observedvalues.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  Color mainClr = Colors.white;

  var id = '0';
  var studid = '0';
  var syid = 0;
  var semid = 1;
  var gradelevel = 0;
  var sectionid = 0;
  var strand = 0;
  String selectedYear = '';
  String selectedSem = '';
  List<String> years = [];
  List<String> semesters = [];
  List<Grades> data = [];
  List<Grades> finalGrade = [];
  List<EnrolledStud> enrolledstud = [];
  List<Grades> concatenatedArray = [];
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
  List<Attendance> attendance = [];
  List<StudentObservedValues> _studentObservedValues = [];
  List<RatingValues> _ratingValues = [];
  List<Setup> _setup = [];
  bool loading = true;
  bool _isLoadingCoreValues = false;
  bool _isLoadingAttendance = false;

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

    if (schoolYear.isNotEmpty) {
      selectedYear = activeYear.id.toString();
    }

    if (schoolSem.isNotEmpty) {
      selectedSem = activeSem.id.toString();
    }

    setState(() {
      selectedYear = activeYear.id.toString();
      selectedSem = activeSem.id.toString();
      syid = activeYear.id;
      semid = activeSem.id;
    });

    await getEnrolledStud();
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');
    if (json != null) {
      setState(() {
        id = json;
      });
    }
  }

  getGrades(int index) async {
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
            } else {
              data = gdList.map((model) {
                return Grades(
                  syid: model['syid'] ?? 0,
                  semid: model['semid'] ?? 0,
                  subjcode: model['subjcode']?.toString() ?? '',
                  subjdesc: model['subjdesc']?.toString() ?? '',
                  q1: model['prelemgrade']?.toString() ?? '0',
                  q2: model['midtermgrade']?.toString() ?? '0',
                  q3: model['prefigrade']?.toString() ?? '0',
                  q4: model['finalgrade']?.toString() ?? '0',
                  q1status: model['q1status']?.toString() ?? '',
                  q2status: model['q2status']?.toString() ?? '',
                  q3status: model['q3status']?.toString() ?? '',
                  q4status: model['q4status']?.toString() ?? '',
                  prelemgrade: model['prelemgrade']?.toString() ?? '',
                  midtermgrade: model['midtermgrade']?.toString() ?? '',
                  prefigrade: model['prefigrade']?.toString() ?? '',
                  finalgrade: model['finalgrade']?.toString() ?? '',
                  prelemstatus: model['prelemstatus']?.toString() ?? '',
                  midtermstatus: model['midtermstatus']?.toString() ?? '',
                  prefistatus: model['prefistatus']?.toString() ?? '',
                  finalstatus: model['finalstatus']?.toString() ?? '',
                  finalrating: model['finalgrade']?.toString() ?? '',
                  fg: model['fg']?.toString() ?? '',
                  fgremarks: model['fgremarks']?.toString() ?? '',
                  actiontaken: model['actiontaken']?.toString() ?? '',
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
                        finalrating: '',
                        fg: '',
                        actiontaken: '',
                        fgremarks: '',
                        subjdesc: '',
                      );
              }).toList();
            }

            semid = index;
            concatenatedArray = [...data, ...finalGrade];
            concatenatedArray = concatenatedArray
                .where(
                  (grade) =>
                      grade.subjcode.isNotEmpty &&
                      grade.subjdesc != "GENERAL AVERAGE",
                )
                .toList();
          });
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

          enrolledstud.sort((a, b) {
            int yearComparison = b.syid.compareTo(a.syid);
            if (yearComparison != 0) return yearComparison;
            return b.semid.compareTo(a.semid);
          });

          if (enrolledstud.isNotEmpty) {
            EnrolledStud mostRecent = enrolledstud.first;
            syid = mostRecent.syid;
            semid = mostRecent.semid;
            gradelevel = mostRecent.levelid;
            sectionid = mostRecent.sectionid;
            strand = mostRecent.strandid;
            selectedYear = syid.toString();
            selectedSem = semid.toString();
          }
        }
      });

      getGrades(semid);
    });
  }

  void updateSelectedEnrollment(int selectedSyid, int selectedSemid) {
    EnrolledStud? selectedEnrollment = enrolledstud.firstWhere(
      (info) => info.syid == selectedSyid && info.semid == selectedSemid,
      orElse: () => EnrolledStud(
        id: 0,
        studid: 0,
        syid: 0,
        semid: 0,
        dateenrolled: '',
        levelid: 0,
        sectionid: 0,
        strandid: 0,
        studstatus: 0,
        levelname: '',
        strandname: '',
        description: '',
        courseDesc: '',
        semester: '',
        sectionname: '',
        sydesc: '',
      ),
    );

    setState(() {
      gradelevel = selectedEnrollment.levelid;
      sectionid = selectedEnrollment.sectionid;
      strand = selectedEnrollment.strandid;
      syid = selectedSyid;
      semid = selectedSemid;
    });

    getGrades(semid);
  }

  void _resetGradeData() {
    setState(() {
      concatenatedArray = [];
      data = [];
      finalGrade = [];
    });
  }

  getStudentAttendance() async {
    setState(() {
      _isLoadingAttendance = true;
    });

    final response = await CallApi().getStudentAttendance(id, selectedYear);

    if (response.body is List) {
      attendance = (response.body as List)
          .map((data) => Attendance.fromJson(data))
          .toList();
    } else if (response.body is String) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      attendance = (responseData['attendance_setup'] as List)
          .map((data) => Attendance.fromJson(data))
          .toList();
    }

    setState(() {
      _isLoadingAttendance = false;
    });
  }

  getObservedValues() async {
    setState(() {
      _isLoadingCoreValues = true;
    });
    final response = await CallApi().getObservedValues(id, selectedYear);
    final Map<String, dynamic> responseData = json.decode(response.body);

    _ratingValues = (responseData['ob_rv'] as List)
        .map((data) => RatingValues.fromJson(data))
        .toList();

    _setup = (responseData['ob_setup'] as List)
        .map((data) => Setup.fromJson(data))
        .toList();

    _studentObservedValues = (responseData['student_ob'] as List)
        .map((data) => StudentObservedValues.fromJson(data))
        .toList();

    setState(() {
      _isLoadingCoreValues = false;
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
    await getYearandSem();
    await getEnrolledStud();
    getStudentAttendance();

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'REPORT CARD-${gradelevel >= 17 ? 'COLLEGE' : (gradelevel == 14 || gradelevel == 15) ? 'SHS' : 'K-12'}',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 2.0,
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2<String>(
                          hint: Text(
                            enrolledstud[0].sydesc,
                            style: const TextStyle(fontSize: 10),
                          ),
                          items: schoolYear
                              .map(
                                (option) => DropdownMenuItem(
                                  child: Text(
                                    option.sydesc,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  value: option.id.toString(),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value!;
                              syid = int.parse(selectedYear);

                              EnrolledStud? selectedEnrollment = enrolledstud
                                  .firstWhere(
                                    (enrollment) => enrollment.syid == syid,
                                    orElse: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "No Schedule for this School Year",
                                          ),
                                          backgroundColor: schoolColor,
                                        ),
                                      );

                                      return EnrolledStud(
                                        id: 0,
                                        studid: 0,
                                        syid: 0,
                                        semid: 0,
                                        dateenrolled: '',
                                        levelid: 0,
                                        sectionid: 0,
                                        strandid: 0,
                                        studstatus: 0,
                                        levelname: '',
                                        strandname: '',
                                        description: '',
                                        courseDesc: '',
                                        semester: '',
                                        sectionname: '',
                                        sydesc: '',
                                      );
                                    },
                                  );

                              if (selectedEnrollment != null) {
                                gradelevel = selectedEnrollment.levelid;
                                sectionid = selectedEnrollment.sectionid;
                              } else {
                                gradelevel = 0;
                                sectionid = 0;
                              }

                              if (selectedYear.isNotEmpty &&
                                  selectedSem.isNotEmpty) {
                                getGrades(int.parse(semid.toString()));
                              }
                            });
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
                      // const SizedBox(width: 10.0),
                      if (gradelevel >= 14 && gradelevel != 16) ...[
                        Flexible(
                          child: DropdownButtonFormField2<String>(
                            hint: Text(
                              enrolledstud[0].semester,
                              style: const TextStyle(fontSize: 10),
                            ),
                            items: schoolSem
                                .map(
                                  (option) => DropdownMenuItem(
                                    child: Text(
                                      option.semester,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    value: option.id.toString(),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _resetGradeData();
                                setState(() {
                                  selectedSem = value;
                                  semid = int.parse(value);
                                });
                                updateSelectedEnrollment(syid, semid);
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: concatenatedArray.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/search1.png'),
                              const SizedBox(height: 10.0),
                              Text(
                                "No available grades for the selected year and semester",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: schoolColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : (gradelevel >= 17
                              ? ListView(
                                  children: [
                                    ...concatenatedArray.map(
                                      (grade) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16.0,
                                        ),
                                        decoration: const BoxDecoration(),
                                        child: ClipRRect(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (gradelevel >= 17)
                                                Container(
                                                  color: schoolColor,
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  2.0,
                                                                ),
                                                            child: Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${grade.subjcode}: ',
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: grade
                                                                        .subjdesc,
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (gradelevel >= 17)
                                                        Table(
                                                          columnWidths:
                                                              (schoolInfo
                                                                      .isNotEmpty &&
                                                                  schoolInfo[0]
                                                                          .abbreviation ==
                                                                      'DCC' &&
                                                                  gradelevel >=
                                                                      17)
                                                              ? const {
                                                                  0: FlexColumnWidth(
                                                                    2,
                                                                  ),
                                                                  1: FlexColumnWidth(
                                                                    2,
                                                                  ),
                                                                }
                                                              : const {
                                                                  0: FlexColumnWidth(
                                                                    1,
                                                                  ),
                                                                  1: FlexColumnWidth(
                                                                    1.5,
                                                                  ),
                                                                  2: FlexColumnWidth(
                                                                    1,
                                                                  ),
                                                                  3: FlexColumnWidth(
                                                                    1,
                                                                  ),
                                                                  4: FlexColumnWidth(
                                                                    1,
                                                                  ),
                                                                  5: FlexColumnWidth(
                                                                    1.5,
                                                                  ),
                                                                },
                                                          border:
                                                              TableBorder.all(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                          children: [
                                                            TableRow(
                                                              decoration: BoxDecoration(
                                                                color: schoolColor
                                                                    .withOpacity(
                                                                      .2,
                                                                    ),
                                                              ),
                                                              children:
                                                                  (schoolInfo
                                                                          .isNotEmpty &&
                                                                      schoolInfo[0]
                                                                              .abbreviation ==
                                                                          'DCC' &&
                                                                      gradelevel >=
                                                                          17)
                                                                  ? const [
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Final\nGrade',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Remarks',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ]
                                                                  : const [
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Prelim',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Midterm',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Pre\nFinal',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Final',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Final\nGrade',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          'Remarks',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                            ),
                                                            // Data row
                                                            TableRow(
                                                              children:
                                                                  (schoolInfo
                                                                          .isNotEmpty &&
                                                                      schoolInfo[0]
                                                                              .abbreviation ==
                                                                          'DCC' &&
                                                                      gradelevel >=
                                                                          17)
                                                                  ? [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.finalstatus ==
                                                                                  '4'
                                                                              ? grade.finalgrade
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.finalstatus ==
                                                                                  '4'
                                                                              ? grade.fgremarks
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                grade.fgremarks ==
                                                                                    'PASSED'
                                                                                ? Colors.green
                                                                                : Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ]
                                                                  : [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.prelemstatus ==
                                                                                  '4'
                                                                              ? grade.prelemgrade
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.midtermstatus ==
                                                                                  '4'
                                                                              ? grade.midtermgrade
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.prefistatus ==
                                                                                  '4'
                                                                              ? grade.prefigrade
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.finalstatus ==
                                                                                  '4'
                                                                              ? grade.finalgrade
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.prelemstatus ==
                                                                                      '4' &&
                                                                                  grade.midtermstatus ==
                                                                                      '4' &&
                                                                                  grade.prefistatus ==
                                                                                      '4' &&
                                                                                  grade.finalstatus ==
                                                                                      '4'
                                                                              ? grade.fg
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.0,
                                                                        ),
                                                                        child: Text(
                                                                          grade.prelemstatus ==
                                                                                      '4' &&
                                                                                  grade.midtermstatus ==
                                                                                      '4' &&
                                                                                  grade.prefistatus ==
                                                                                      '4' &&
                                                                                  grade.finalstatus ==
                                                                                      '4'
                                                                              ? grade.fgremarks
                                                                              : ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                grade.fgremarks ==
                                                                                    'PASSED'
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
                                )
                              : Container(
                                  child: ContainedTabBarView(
                                    tabs: [
                                      const Center(
                                        child: Text(
                                          'Grades',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'Attendance',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'Core Values',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                    views: [
                                      _buildTabContentGrades(),
                                      _buildTabContentAttendance(),
                                      _buildTabContentCoreValues(),
                                    ],
                                    onChange: (index) {
                                      if (index == 1) {
                                        getStudentAttendance();
                                      }
                                      if (index == 2) {
                                        getObservedValues();
                                      }
                                    },
                                  ),
                                )),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabContentGrades() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: concatenatedArray.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/search1.png'),
                const SizedBox(height: 10.0),
                Text(
                  "No available grades for the selected year and semester",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: schoolColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : ListView(
              children: [
                ...concatenatedArray.map(
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
                                  if (gradelevel == 14 || gradelevel == 15)
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(1),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                        3: FlexColumnWidth(1),
                                        4: FlexColumnWidth(1),
                                        5: FlexColumnWidth(1.5),
                                      },
                                      border: TableBorder.all(
                                        color: Colors.black12,
                                      ),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.q1 != "null" &&
                                                          grade.q1status == '4'
                                                      ? grade.q1
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.q2 != "null" &&
                                                          grade.q2status == '4'
                                                      ? grade.q2
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.finalrating != "null" &&
                                                          grade.q1status ==
                                                              '4' &&
                                                          grade.q2status == '4'
                                                      ? grade.finalrating
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child:
                                                    grade.q1status == '4' &&
                                                        grade.q2status == '4'
                                                    ? Text(
                                                        grade.actiontaken,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              grade.actiontaken ==
                                                                  'PASSED'
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                            ],
                                            if (semid == 2 || semid == 0) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.q3 != "null" &&
                                                          grade.q3status == '4'
                                                      ? grade.q3
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.q4 != "null" &&
                                                          grade.q4status == '4'
                                                      ? grade.q4
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  grade.finalrating != "null" &&
                                                          grade.q3status ==
                                                              '4' &&
                                                          grade.q4status == '4'
                                                      ? grade.finalrating
                                                      : '  ',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child:
                                                    grade.q3status == '4' &&
                                                        grade.q4status == '4'
                                                    ? Text(
                                                        grade.actiontaken,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              grade.actiontaken ==
                                                                  'PASSED'
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  if (gradelevel <= 13 || gradelevel == 16)
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(1),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                        3: FlexColumnWidth(1),
                                        4: FlexColumnWidth(1),
                                        5: FlexColumnWidth(1.5),
                                      },
                                      border: TableBorder.all(
                                        color: Colors.black12,
                                      ),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: schoolColor.withOpacity(.2),
                                          ),
                                          children: const [
                                            Padding(
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
                                            Padding(
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
                                            Padding(
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
                                            Padding(
                                              padding: EdgeInsets.symmetric(
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
                                            Padding(
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
                                            Padding(
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
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                grade.q1 != "null" &&
                                                        grade.q1status == '4'
                                                    ? grade.q1
                                                    : '  ',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                grade.q2 != "null" &&
                                                        grade.q2status == '4'
                                                    ? grade.q2
                                                    : '  ',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                grade.q3 != "null" &&
                                                        grade.q3status == '4'
                                                    ? grade.q3
                                                    : '  ',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                grade.q4 != "null" &&
                                                        grade.q4status == '4'
                                                    ? grade.q4
                                                    : '  ',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                grade.finalrating != "null" &&
                                                        grade.q1status == '4' &&
                                                        grade.q2status == '4' &&
                                                        grade.q3status == '4' &&
                                                        grade.q4status == '4'
                                                    ? grade.finalrating
                                                    : '  ',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child:
                                                  grade.q1status == '4' &&
                                                      grade.q2status == '4' &&
                                                      grade.q3status == '4' &&
                                                      grade.q4status == '4'
                                                  ? Text(
                                                      grade.actiontaken,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            grade.actiontaken ==
                                                                'PASSED'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
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
            ),
    );
  }

  Widget _buildTabContentAttendance() {
    int totalDays = attendance.fold(0, (sum, record) => sum + record.days);
    int totalPresent = attendance.fold(
      0,
      (sum, record) => sum + record.present,
    );
    int totalAbsent = attendance.fold(0, (sum, record) => sum + record.absent);

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: IntrinsicHeight(
                    child: _isLoadingAttendance
                        ? const Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Loading...',
                            ),
                          )
                        : DataTable(
                            columnSpacing: 20.0,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Months',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No. of\nSchool\nDays',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No. of\nDays\nPresent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No. of\nDays\nAbsent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            rows: [
                              ...attendance.map((Attendance record) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        record.monthdesc,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.days.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.present.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.absent.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              DataRow(
                                cells: [
                                  const DataCell(
                                    Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      totalDays.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      totalPresent.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      totalAbsent.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContentCoreValues() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RawScrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            thumbColor: Colors.grey,
            thickness: 8.0,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _isLoadingCoreValues
                      ? const Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Loading...',
                          ),
                        )
                      : DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Q1',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Q2',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Q3',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Q4',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                          rows: _setup.map((setup) {
                            final studentObserved = _studentObservedValues
                                .firstWhere(
                                  (obs) => obs.gsdid == setup.id,
                                  orElse: () => StudentObservedValues(
                                    gsdid: setup.id,
                                    q1eval: 0,
                                    q2eval: 0,
                                    q3eval: 0,
                                    q4eval: 0,
                                  ),
                                );

                            String getRatingValue(int evalId) {
                              return _ratingValues
                                  .firstWhere(
                                    (rating) => rating.id == evalId,
                                    orElse: () => RatingValues(
                                      id: 0,
                                      sort: '',
                                      gsid: 0,
                                      description: '',
                                      value: '',
                                    ),
                                  )
                                  .value;
                            }

                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    width: 300,
                                    child: Text(
                                      setup.description,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getRatingValue(studentObserved.q1eval),
                                    softWrap: false,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getRatingValue(studentObserved.q2eval),
                                    softWrap: false,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getRatingValue(studentObserved.q3eval),
                                    softWrap: false,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getRatingValue(studentObserved.q4eval),
                                    softWrap: false,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
