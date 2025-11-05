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

class ReportCard extends StatefulWidget {
  const ReportCard({super.key});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
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

    schoolYear = (responseData['sy'] as List)
        .map((data) => SchoolYear.fromJson(data))
        .toList();
    schoolSem = (responseData['semester'] as List)
        .map((data) => Sem.fromJson(data))
        .toList();

    schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

    if (schoolYear.isNotEmpty) {
      selectedYear =
          schoolYear.any((year) => year.id.toString() == selectedYear)
          ? selectedYear
          : schoolYear.first.id.toString();
    }

    if (schoolSem.isNotEmpty) {
      selectedSem = schoolSem.any((sem) => sem.id.toString() == selectedSem)
          ? selectedSem
          : schoolSem.first.id.toString();
    }

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

        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        var lastindex = enInfoData[enInfoData.length - 1];

        setState(() {
          gradelevel = lastindex.levelid;
        });

        print('Enrollement Data: $enInfoData');
        // getGrades(1);
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
                      value: null,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          for (var yr in enInfoData) {
                            if (yr.sydesc == selectedYear) {
                              syid = yr.syid;
                              selectedSem = sem[0];
                              gradelevel = yr.levelid;
                              sectionid = yr.sectionid;
                              strand = yr.strandid;
                              getGrades(yr.semid);
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
                  value: null,
                  items: schoolSem
                      .map(
                        (option) => DropdownMenuItem(
                          child: Text(
                            option.semester,
                            style: TextStyle(fontSize: 10),
                          ),
                          value: option.id.toString(),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSem = value!;
                      semid = int.parse(selectedSem);
                    });
                    if (selectedYear.isNotEmpty) {
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
                decoration: BoxDecoration(),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.q1 != "null" ? grade.q1 : '  ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.q2 != "null" ? grade.q2 : '  ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.q3 != "null" ? grade.q3 : '  ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          grade.q4 != "null" ? grade.q4 : '  ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('REPORT CARD',
  //           style: TextStyle(
  //
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: schoolColor,
  //           )),
  //       centerTitle: true,
  //     ),
  //     body: loading
  //         ? Center(
  //             child: LoadingAnimationWidget.prograssiveDots(
  //               color: schoolColor,
  //               size: 100,
  //             ),
  //           )
  //         : ListView(
  //             padding: const EdgeInsets.all(20),
  //             children: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: selectedYear.isNotEmpty
  //                         ? DropdownButtonFormField2<String>(
  //                             decoration: InputDecoration(
  //                               labelText: 'School Year',
  //                               labelStyle: TextStyle(
  //
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             isExpanded: true,
  //                             hint: Text(
  //                               'Choose a school year',
  //                               style: TextStyle(
  //                                   fontSize: 11, fontFamily: 'Poppins'),
  //                             ),
  //                             value: selectedYear,
  //                             onChanged: (String? newValue) {
  //                               setState(() {
  //                                 selectedYear = newValue!;
  //                                 for (var yr in enInfoData) {
  //                                   if (yr.sydesc == selectedYear) {
  //                                     syid = yr.syid;
  //                                     selectedSem = yr.semester;
  //                                     gradelevel = yr.levelid;
  //                                     sectionid = yr.sectionid;
  //                                     strand = yr.strandid;
  //                                     getGrades(yr.semid);
  //                                   }
  //                                 }
  //                               });
  //                             },
  //                             items: years.map<DropdownMenuItem<String>>(
  //                               (String year) {
  //                                 return DropdownMenuItem<String>(
  //                                   value: year,
  //                                   child: Text(
  //                                     year,
  //                                     style: TextStyle(
  //
  //                                       fontSize: 11,
  //                                     ),
  //                                   ),
  //                                 );
  //                               },
  //                             ).toList(),
  //                           )
  //                         : const CircularProgressIndicator(),
  //                   ),
  //                   SizedBox(width: 10.0),
  //                   if (gradelevel == 14 ||
  //                       gradelevel == 15 ||
  //                       gradelevel >= 17)
  //                     Expanded(
  //                       child: selectedSem.isNotEmpty
  //                           // ? DropdownButtonFormField2<String>(
  //                           //     decoration: InputDecoration(
  //                           //       labelText: 'Semester',
  //                           //       labelStyle: TextStyle(
  //                           //
  //                           //         fontSize: 12,
  //                           //         fontWeight: FontWeight.w500,
  //                           //       ),
  //                           //       border: OutlineInputBorder(),
  //                           //     ),
  //                           //     isExpanded: true,
  //                           //     value: selectedSem,
  //                           //     hint: const Text('Select Sem'),
  //                           //     onChanged: (String? newValue) {
  //                           //       setState(() {
  //                           //         selectedSem = newValue!;
  //                           //         var index = sem.indexOf(selectedSem) + 1;
  //                           //         getGrades(index);
  //                           //       });
  //                           //     },
  //                           //     items: sem.map<DropdownMenuItem<String>>(
  //                           //       (String semes) {
  //                           //         return DropdownMenuItem<String>(
  //                           //           value: semes,
  //                           //           child: Text(
  //                           //             semes,
  //                           //             style: TextStyle(
  //                           //
  //                           //               fontSize: 12,
  //                           //             ),
  //                           //           ),
  //                           //         );
  //                           //       },
  //                           //     ).toList(),
  //                           //   )
  //                           // : const CircularProgressIndicator(),

  //                           ? DropdownButtonFormField2<String>(
  //                               decoration: InputDecoration(
  //                                 border: OutlineInputBorder(),
  //                                 labelText: 'Semester',
  //                                 labelStyle: TextStyle(
  //
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.w500,
  //                                 ),
  //                               ),
  //                               isExpanded: true,
  //                               hint: const Text(
  //                                 'Choose a semester',
  //                                 style: TextStyle(
  //                                     fontSize: 11, fontFamily: 'Poppins'),
  //                               ),
  //                               items: semesters
  //                                   .map((semester) => DropdownMenuItem<String>(
  //                                         value: semester,
  //                                         child: Text(
  //                                           semester,
  //                                           style: const TextStyle(
  //
  //                                             fontSize: 10,
  //                                           ),
  //                                         ),
  //                                       ))
  //                                   .toList(),
  //                               value: semesters.contains(selectedSem)
  //                                   ? selectedSem
  //                                   : null,
  //                               onChanged: (String? newValue) {
  //                                 setState(() {
  //                                   selectedSem = newValue ?? '';
  //                                   for (var each in enInfoData) {
  //                                     if (each.semester == newValue) {
  //                                       semid = each.semid;
  //                                       syid = each.syid;
  //                                       getGrades(each.semid);
  //                                       break;
  //                                     }
  //                                   }
  //                                 });
  //                               },
  //                             )
  //                           : const CircularProgressIndicator(),
  //                     ),
  //                 ],
  //               ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               LayoutBuilder(
  //                 builder: (context, constraints) {
  //                   return SingleChildScrollView(
  //                     scrollDirection: Axis.horizontal,
  //                     child: ConstrainedBox(
  //                       constraints: BoxConstraints(
  //                         minWidth: constraints.maxWidth,
  //                       ),
  //                       child: DataTable(
  //                         columnSpacing: 30.0,
  //                         columns: [
  //                           const DataColumn(
  //                               label: Text(
  //                             'Code',
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                             ),
  //                           )),
  //                           DataColumn(
  //                             label: MergeSemantics(
  //                               child: SizedBox(
  //                                 width: 112,
  //                                 child: Column(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     if (gradelevel >= 17 || gradelevel == 0)
  //                                       const Text(
  //                                         'Subject Description',
  //                                         style: TextStyle(
  //                                           fontSize: 11,
  //                                         ),
  //                                         overflow: TextOverflow.ellipsis,
  //                                         maxLines: 2,
  //                                       ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'Prelim',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'Midterm',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'PreFinal',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'Final',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'Final\nGrade',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           const DataColumn(
  //                             label: Expanded(
  //                               child: Text(
  //                                 'Remarks',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                         rows: concatenatedArray.asMap().entries.map((entry) {
  //                           final index = entry.key;
  //                           final grade = entry.value;
  //                           final isEvenRow = index % 2 == 0;
  //                           final rowColor =
  //                               isEvenRow ? Colors.grey.shade200 : Colors.white;

  //                           return DataRow(
  //                               color: WidgetStateColor.resolveWith(
  //                                   (states) => rowColor),
  //                               cells: [
  //                                 DataCell(
  //                                   Container(
  //                                     width: 80,
  //                                     child: Text(
  //                                       grade.subjcode,
  //                                       style: TextStyle(
  //                                         fontSize: 10,
  //                                       ),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       maxLines: 3,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 DataCell(
  //                                   Column(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.center,
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: [
  //                                       if (gradelevel >= 17)
  //                                         Container(
  //                                           width: 200,
  //                                           child: Text(
  //                                             grade.subjdesc,
  //                                             style: TextStyle(
  //                                               fontSize: 10,
  //                                             ),
  //                                             overflow: TextOverflow.ellipsis,
  //                                             maxLines: 3,
  //                                           ),
  //                                         ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 DataCell(Text(
  //                                   grade.prelemgrade.isNotEmpty
  //                                       ? grade.prelemgrade
  //                                       : '',
  //                                   style: TextStyle(
  //                                     fontSize: 11,
  //                                   ),
  //                                 )),
  //                                 DataCell(Text(
  //                                   grade.midtermgrade.isNotEmpty
  //                                       ? grade.midtermgrade
  //                                       : '',
  //                                   style: TextStyle(
  //                                     fontSize: 11,
  //                                   ),
  //                                 )),
  //                                 DataCell(Text(
  //                                     grade.prefigrade.isNotEmpty
  //                                         ? grade.prefigrade
  //                                         : '',
  //                                     style: TextStyle(
  //                                       fontSize: 11,
  //                                     ))),
  //                                 DataCell(Text(
  //                                   grade.finalgrade.isNotEmpty
  //                                       ? grade.finalgrade
  //                                       : '',
  //                                   style: TextStyle(
  //                                     fontSize: 11,
  //                                   ),
  //                                 )),
  //                                 DataCell(Text(
  //                                   grade.fg.isNotEmpty ? grade.fg : '',
  //                                   style: TextStyle(
  //                                     fontSize: 11,
  //                                   ),
  //                                 )),
  //                                 DataCell(
  //                                   Text(
  //                                     grade.fgremarks.toString().isNotEmpty
  //                                         ? grade.fgremarks
  //                                         : '',
  //                                     style: TextStyle(
  //                                       fontSize: 11,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ]);
  //                         }).toList(),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //   );
  // }

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
