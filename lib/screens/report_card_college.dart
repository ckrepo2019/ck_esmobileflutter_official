// import 'dart:convert';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:pushtrial/models/enrollment_info.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pushtrial/api/api.dart';
// import 'package:pushtrial/models/grades.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:pushtrial/models/school_info.dart';

// class ReportCardCollege extends StatefulWidget {
//   const ReportCardCollege({super.key});

//   @override
//   State<ReportCardCollege> createState() => _ReportCardCollegeState();
// }

// class _ReportCardCollegeState extends State<ReportCardCollege> {
//   Color mainClr = Colors.white;
//   @override
//   void initState() {
//     getUser();
//     getSchoolInfo();
//     super.initState();
//   }

//   var id = '0';
//   var studid = '0';
//   var syid = 0;
//   var semid = 1;
//   var gradelevel = 0;
//   var sectionid = 0;
//   var strand = 0;
//   String selectedYear = '';
//   String selectedSem = '';
//   List<String> years = [];
//   List<String> semesters = [];
//   List<String> sem = ['1st Sem', '2nd Sem'];
//   List<Grades> data = [];
//   List<Grades> finalGrade = [];
//   List<EnrollmentInfo> enInfoData = [];
//   List<Grades> concatenatedArray = [];
//   bool loading = true;

//   List<SchoolInfo> schoolInfo = [];
//   Color schoolColor = Color.fromARGB(0, 255, 255, 255);

//   Color hexToColor(String hexString) {
//     final buffer = StringBuffer();
//     if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
//     buffer.write(hexString.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }

//   Future<void> getSchoolInfo() async {
//     final response = await CallApi().getSchoolInfo();

//     final parsedResponse = json.decode(response.body);
//     if (parsedResponse is List) {
//       setState(() {
//         schoolInfo = parsedResponse
//             .map((model) => SchoolInfo.fromJson(model))
//             .toList()
//             .cast<SchoolInfo>();

//         schoolColor = hexToColor(schoolInfo[0].schoolcolor);
//       });
//     }
//   }

//   Future<void> getUser() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     final json = preferences.getString('studid');
//     if (json != null) {
//       setState(() {
//         id = json;
//         loading = true;
//       });
//       await getEnrollment();
//       await getGrades(1);
//     }
//     setState(() {
//       loading = false;
//     });
//   }

//   Future<void> getGrades(int index) async {
//     Iterable gdList = [];
//     Iterable gdFinal = [];

//     await CallApi()
//         .getStudGrade(id, gradelevel, syid, sectionid, strand, index)
//         .then((response) {
//       setState(() {
//         Iterable list = json.decode(response.body);

//         for (var gd in list) {
//           gdList = gd['grades'];

//           if (gradelevel < 17) {
//             gdFinal = gd['finalgrade'];
//           }
//         }

//         if (gradelevel < 17) {
//           data = gdList.map((model) {
//             return Grades.fromJson(model);
//           }).toList();
//         } else {
//           data = gdList.map((model) {
//             return Grades(
//               syid: model['syid'] ?? 0,
//               semid: model['semid'] ?? 0,
//               subjcode: model['subjcode']?.toString() ?? '',
//               subjdesc: model['subjdesc']?.toString() ?? '',
//               q1: model['prelemgrade']?.toString() ?? '0',
//               q2: model['midtermgrade']?.toString() ?? '0',
//               q3: model['prefigrade']?.toString() ?? '0',
//               q4: model['finalgrade']?.toString() ?? '0',
//               prelemgrade: model['prelemgrade']?.toString() ?? '',
//               midtermgrade: model['midtermgrade']?.toString() ?? '',
//               prefigrade: model['prefigrade']?.toString() ?? '',
//               finalgrade: model['finalgrade']?.toString() ?? '',
//               finalrating: model['finalgrade']?.toString() ?? '',
//               fg: model['fg']?.toString() ?? '',
//               fgremarks: model['fgremarks']?.toString() ?? '',
//               actiontaken: model['actiontaken']?.toString() ?? '',
//             );
//           }).toList();

//           // print('data: $data');
//         }

//         if (gradelevel == 14 || gradelevel == 15) {
//           finalGrade = gdFinal.map((ave) {
//             return ave['semid'].toString() == index.toString()
//                 ? Grades.parseAverage(ave)
//                 : Grades(
//                     syid: 0,
//                     semid: 0,
//                     subjcode: '',
//                     q1: '',
//                     q2: '',
//                     q3: '',
//                     q4: '',
//                     prelemgrade: '',
//                     midtermgrade: '',
//                     prefigrade: '',
//                     finalgrade: '',
//                     finalrating: '',
//                     fg: '',
//                     actiontaken: '',
//                     fgremarks: '',
//                     subjdesc: '');
//           }).toList();
//         }

//         semid = index;
//         concatenatedArray = [...data, ...finalGrade];
//         concatenatedArray = concatenatedArray
//             .where((grade) => grade.subjcode.isNotEmpty)
//             .toList();
//       });
//     });
//   }

//   getEnrollment() async {
//     await CallApi().getEnrollmentInfo(id).then((response) {
//       setState(() {
//         Iterable list = json.decode(response.body);

//         enInfoData = list.map((model) {
//           return EnrollmentInfo.fromJson(model);
//         }).toList();

//         for (var element in enInfoData) {
//           years.add(element.sydesc);
//           semesters.add(element.semester);
//         }
//         Set<String> uniqueSet = years.toSet();
//         years = uniqueSet.toList();
//         selectedYear = enInfoData[enInfoData.length - 1].sydesc;
//         selectedSem = semesters.isNotEmpty ? semesters[0] : '';
//         for (var yr in enInfoData) {
//           if (yr.sydesc == selectedYear) {
//             setState(() {
//               syid = yr.syid;
//               semid = yr.semid;
//               gradelevel = yr.levelid;
//               sectionid = yr.sectionid;
//             });
//             getGrades(1);
//             break;
//           }
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('REPORT CARD',
//             style: TextStyle(
//
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: schoolColor,
//             )),
//         centerTitle: true,
//       ),
//       body: loading
//           ? Center(
//               child: LoadingAnimationWidget.prograssiveDots(
//                 color: schoolColor,
//                 size: 100,
//               ),
//             )
//           : ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: selectedYear.isNotEmpty
//                           ? DropdownButtonFormField2<String>(
//                               decoration: InputDecoration(
//                                 labelText: 'School Year',
//                                 labelStyle: TextStyle(
//
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 border: OutlineInputBorder(),
//                               ),
//                               isExpanded: true,
//                               hint: Text(
//                                 'Choose a school year',
//                                 style: TextStyle(
//                                     fontSize: 11, fontFamily: 'Poppins'),
//                               ),
//                               value: selectedYear,
//                               onChanged: (String? newValue) {
//                                 setState(() {
//                                   selectedYear = newValue!;
//                                   for (var yr in enInfoData) {
//                                     if (yr.sydesc == selectedYear) {
//                                       syid = yr.syid;
//                                       selectedSem = yr.semester;
//                                       gradelevel = yr.levelid;
//                                       sectionid = yr.sectionid;
//                                       strand = yr.strandid;
//                                       getGrades(yr.semid);
//                                     }
//                                   }
//                                 });
//                               },
//                               items: years.map<DropdownMenuItem<String>>(
//                                 (String year) {
//                                   return DropdownMenuItem<String>(
//                                     value: year,
//                                     child: Text(
//                                       year,
//                                       style: TextStyle(
//
//                                         fontSize: 11,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ).toList(),
//                             )
//                           : const CircularProgressIndicator(),
//                     ),
//                     SizedBox(width: 10.0),
//                     if (gradelevel == 14 ||
//                         gradelevel == 15 ||
//                         gradelevel >= 17)
//                       Expanded(
//                         child: selectedSem.isNotEmpty
//                             ? DropdownButtonFormField2<String>(
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   labelText: 'Semester',
//                                   labelStyle: TextStyle(
//
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 isExpanded: true,
//                                 hint: const Text(
//                                   'Choose a semester',
//                                   style: TextStyle(
//                                       fontSize: 11, fontFamily: 'Poppins'),
//                                 ),
//                                 items: semesters
//                                     .map((semester) => DropdownMenuItem<String>(
//                                           value: semester,
//                                           child: Text(
//                                             semester,
//                                             style: const TextStyle(
//
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                         ))
//                                     .toList(),
//                                 value: semesters.contains(selectedSem)
//                                     ? selectedSem
//                                     : null,
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedSem = newValue ?? '';
//                                     for (var each in enInfoData) {
//                                       if (each.semester == newValue) {
//                                         semid = each.semid;
//                                         syid = each.syid;
//                                         getGrades(each.semid);
//                                         break;
//                                       }
//                                     }
//                                   });
//                                 },
//                               )
//                             : const CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     return SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minWidth: constraints.maxWidth,
//                         ),
//                         child: DataTable(
//                           columnSpacing: 30.0,
//                           columns: [
//                             const DataColumn(
//                                 label: Text(
//                               'Code',
//                               style: TextStyle(
//                                 fontSize: 11,
//                               ),
//                             )),
//                             DataColumn(
//                               label: MergeSemantics(
//                                 child: SizedBox(
//                                   width: 112,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       if (gradelevel >= 17 || gradelevel == 0)
//                                         const Text(
//                                           'Subject Description',
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'Prelim',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'Midterm',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'PreFinal',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'Final',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'Final\nGrade',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(
//                                 child: Text(
//                                   'Remarks',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                           ],
//                           rows: concatenatedArray.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final grade = entry.value;
//                             final isEvenRow = index % 2 == 0;
//                             final rowColor =
//                                 isEvenRow ? Colors.grey.shade200 : Colors.white;

//                             return DataRow(
//                                 color: WidgetStateColor.resolveWith(
//                                     (states) => rowColor),
//                                 cells: [
//                                   DataCell(
//                                     Container(
//                                       width: 80,
//                                       child: Text(
//                                         grade.subjcode,
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 3,
//                                       ),
//                                     ),
//                                   ),
//                                   DataCell(
//                                     Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         if (gradelevel >= 17)
//                                           Container(
//                                             width: 200,
//                                             child: Text(
//                                               grade.subjdesc,
//                                               style: TextStyle(
//                                                 fontSize: 10,
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 3,
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   DataCell(Text(
//                                     grade.prelemgrade.isNotEmpty
//                                         ? grade.prelemgrade
//                                         : '',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                     ),
//                                   )),
//                                   DataCell(Text(
//                                     grade.midtermgrade.isNotEmpty
//                                         ? grade.midtermgrade
//                                         : '',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                     ),
//                                   )),
//                                   DataCell(Text(
//                                       grade.prefigrade.isNotEmpty
//                                           ? grade.prefigrade
//                                           : '',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                       ))),
//                                   DataCell(Text(
//                                     grade.finalgrade.isNotEmpty
//                                         ? grade.finalgrade
//                                         : '',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                     ),
//                                   )),
//                                   DataCell(Text(
//                                     grade.fg.isNotEmpty ? grade.fg : '',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                     ),
//                                   )),
//                                   DataCell(
//                                     Text(
//                                       grade.fgremarks.toString().isNotEmpty
//                                           ? grade.fgremarks
//                                           : '',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                       ),
//                                     ),
//                                   ),
//                                 ]);
//                           }).toList(),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/grades.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/year_sem.dart';

class ReportCardCollege extends StatefulWidget {
  const ReportCardCollege({super.key});

  @override
  State<ReportCardCollege> createState() => _ReportCardCollegeState();
}

class _ReportCardCollegeState extends State<ReportCardCollege> {
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
  List<EnrollmentInfo> enInfoData = [];
  List<Grades> concatenatedArray = [];
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
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

    await getEnrollment();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');
    if (json != null) {
      setState(() {
        id = json;
      });
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

              // print('data: $data');
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
                .where((grade) => grade.subjcode.isNotEmpty)
                .toList();
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

        enInfoData.sort((a, b) {
          int yearComparison = b.syid.compareTo(a.syid);
          if (yearComparison != 0) return yearComparison;
          return b.semid.compareTo(a.semid);
        });

        if (enInfoData.isNotEmpty) {
          EnrollmentInfo mostRecent = enInfoData.first;
          syid = mostRecent.syid;
          semid = mostRecent.semid;
          gradelevel = mostRecent.levelid;
          sectionid = mostRecent.sectionid;
          strand = mostRecent.strandid;
          selectedYear = syid.toString();
          selectedSem = semid.toString();
        }

        print('Initial Enrollment info: ${enInfoData.first}');
        print('Initial Grade Level: $gradelevel');
      });

      getGrades(semid);
    });
  }

  void updateSelectedEnrollment(int selectedSyid, int selectedSemid) {
    EnrollmentInfo? selectedEnrollment = enInfoData.firstWhere(
      (info) => info.syid == selectedSyid && info.semid == selectedSemid,
      orElse: () => EnrollmentInfo(
        sydesc: '',
        levelname: '',
        sectionname: '',
        semid: 0,
        dateenrolled: '',
        syid: 0,
        levelid: 0,
        sectionid: 0,
        isactive: 0,
        strandid: 0,
        semester: '',
        strandcode: '',
        courseabrv: '',
        courseDesc: '',
      ),
    );

    setState(() {
      gradelevel = selectedEnrollment.levelid;
      sectionid = selectedEnrollment.sectionid;
      strand = selectedEnrollment.strandid;
      syid = selectedSyid;
      semid = selectedSemid;
    });

    print('Updated Enrollment info: $selectedEnrollment');
    print('Updated Grade Level: $gradelevel');

    getGrades(semid);
  }

  void _resetGradeData() {
    setState(() {
      concatenatedArray = [];
      data = [];
      finalGrade = [];
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
    await getEnrollment();

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
      body: loading
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        value: selectedYear.isNotEmpty ? selectedYear : null,
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
                          if (value != null) {
                            _resetGradeData();
                            setState(() {
                              selectedYear = value;
                              syid = int.parse(value);
                            });
                            updateSelectedEnrollment(syid, semid);
                          }
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
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        value: selectedSem.isNotEmpty ? selectedSem : null,
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
                ),
                Expanded(
                  child: concatenatedArray.isEmpty
                      ? Center(
                          child: Column(
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
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 20),
                            ...concatenatedArray.map(
                              (grade) => Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: const BoxDecoration(),
                                child: ClipRRect(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: schoolColor,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${grade.subjcode}: ',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text: grade.subjdesc,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
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
                                                        TextOverflow.ellipsis,
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Table(
                                                columnWidths: const {
                                                  0: FlexColumnWidth(1),
                                                  1: FlexColumnWidth(1.5),
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
                                                      color: schoolColor
                                                          .withOpacity(.2),
                                                    ),
                                                    children: const [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Prelim',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Midterm',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Pre\nFinal',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Final',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Final\nGrade',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          'Remarks',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Data row
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Text(
                                                          grade.prelemgrade,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
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
                                                          grade.midtermgrade,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
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
                                                          grade.prefigrade,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
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
                                                          grade.finalgrade,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
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
                                                          grade.fg,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
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
                                                          grade.fgremarks,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 12,
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
                        ),
                ),
              ],
            ),
    );
  }
}
