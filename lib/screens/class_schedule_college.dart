import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrolled_stud.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/schedule.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/year_sem.dart';

class ClassScheduleCollegeScreen extends StatefulWidget {
  const ClassScheduleCollegeScreen({super.key});

  @override
  State<ClassScheduleCollegeScreen> createState() =>
      _ClassScheduleCollegeScreenState();
}

class _ClassScheduleCollegeScreenState
    extends State<ClassScheduleCollegeScreen> {
  User user = UserData.myUser;
  String id = '0';
  List<String> semesters = [];
  int syid = 0;
  int sectionid = 0;
  String sectionname = '';
  int levelid = 0;
  int semid = 0;
  String? selectedDay = '';
  String selectedMonth = '';
  String selectedYear = '';
  String selectedSem = '';
  List<String> months = [];
  List<String> years = [];
  List<SchedData> listOfSched = [];
  List<SchedItem> listOfItem2 = [];
  List<SchedItem> listOfItem3 = [];
  List<EnrolledStud> enrolledstud = [];

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

  // getSchedByMonth() {
  //   Set<String> uniqueSet = months.toSet();
  //   months = uniqueSet.toList();
  //   if (selectedMonth.isEmpty) {
  //     return;
  //   } else {
  //     listOfItem3.clear();
  //     for (var element in listOfItem2) {
  //       if (element.month.contains(selectedMonth)) {
  //         setState(() {
  //           listOfItem3.add(
  //             SchedItem(
  //               month: element.month,
  //               start: element.start,
  //               end: element.end,
  //               subject: element.subject,
  //               room: element.room,
  //               teacher: element.teacher,
  //             ),
  //           );
  //         });
  //       }
  //     }
  //   }
  // }

  getSchedByMonth() {
    Set<String> uniqueSet = months.toSet();
    months = uniqueSet.toList();

    listOfItem3.clear();

    if (selectedMonth == 'All') {
      setState(() {
        listOfItem3.addAll(listOfItem2);
      });
    } else if (selectedMonth.isEmpty) {
      return;
    } else {
      for (var element in listOfItem2) {
        if (element.month.contains(selectedMonth)) {
          setState(() {
            listOfItem3.add(
              SchedItem(
                month: element.month,
                start: element.start,
                end: element.end,
                subject: element.subject,
                room: element.room,
                teacher: element.teacher,
              ),
            );
          });
        }
      }
    }
  }

  getStudSchedule(int index) async {
    months.clear();
    selectedMonth = '';
    listOfItem2.clear();
    List<SchedItem> listOfItem = [];
    await CallApi().getSchedule(user.id, syid, index, sectionid, levelid).then((
      response,
    ) {
      Iterable list = json.decode(response.body);

      setState(() {
        for (var element in list) {
          var ll = element['schedule'];

          for (var el in ll) {
            listOfItem.clear();
            if (el['day'] != null && el['sched'] != null) {
              var sched = el['sched'];

              if (sched.isNotEmpty || sched != null) {
                for (var item in sched) {
                  if (item['start'] != null) {
                    var start = item['start'] ?? '';
                    var end = item['end'] ?? '';
                    var subject = item['subject'] ?? '';
                    var room = item['room'] ?? '';
                    var teacher = item['teacher'] ?? '';
                    listOfItem.add(
                      SchedItem(
                        month: el['day'],
                        start: start,
                        end: end,
                        subject: subject,
                        room: room,
                        teacher: teacher,
                      ),
                    );
                    listOfItem2.add(
                      SchedItem(
                        month: el['day'],
                        start: start,
                        end: end,
                        subject: subject,
                        room: room,
                        teacher: teacher,
                      ),
                    );
                  }
                }
                months.add(el['day']);
              }
            }
            listOfSched.add(SchedData(day: el['day'], sched: listOfItem));
          }

          semid = index;

          selectedMonth = listOfSched[0].day;

          getSchedByMonth();
        }
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

    final activeYear = schoolYear.firstWhere(
      (year) => year.isactive == 1,
      orElse: () => schoolYear.first,
    );
    final activeSem = schoolSem.firstWhere(
      (sem) => sem.isactive == 1,
      orElse: () => schoolSem.first,
    );

    selectedYear = activeYear.id.toString();
    selectedSem = activeSem.id.toString();

    setState(() {});
  }

  getEnrolledStud() async {
    await CallApi().getEnrolledStud(user.id).then((response) {
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
            levelid = mostRecent.levelid;
            sectionid = mostRecent.sectionid;

            selectedYear = syid.toString();
            selectedSem = semid.toString();
          }

          print('Initial Enrollment info: ${enrolledstud.first}');
          print('Initial Grade Level: $levelid');
        }
      });

      getStudSchedule(semid);
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
      levelid = selectedEnrollment.levelid;
      sectionid = selectedEnrollment.sectionid;

      syid = selectedSyid;
      semid = selectedSemid;
    });

    print('Updated Enrollment info: $selectedEnrollment');
    print('Updated Grade Level: $levelid');

    getStudSchedule(semid);
  }

  void _resetScheduleData() {
    setState(() {
      listOfItem3 = [];
    });
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');

    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
  }

  EnrolledStud? getSelectedEnrolledStud() {
    if (selectedYear.isEmpty) return null;

    return enrolledstud.firstWhere(
      (enrollment) => enrollment.sydesc.contains(selectedYear),
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
    getSchedByMonth();

    setState(() {
      loading = false;
    });

    print('Selected year: $selectedYear');
    print('Selected sem: $selectedSem');
  }

  Map<String, List<SchedItem>> _groupItemsByDay(List<SchedItem> items) {
    Map<String, List<SchedItem>> groupedItems = {};

    for (var item in items) {
      if (!groupedItems.containsKey(item.month)) {
        groupedItems[item.month] = [];
      }
      groupedItems[item.month]!.add(item);
    }

    return groupedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CLASS SCHEDULE',
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
              padding: const EdgeInsets.only(
                left: 30.0,
                top: 10.0,
                right: 30.0,
                bottom: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
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
                            if (value != null) {
                              _resetScheduleData();
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
                                  value: option.id.toString(),
                                  child: Text(
                                    option.semester,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _resetScheduleData();
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
                  const SizedBox(height: 20.0),
                  if (selectedYear.isNotEmpty &&
                      selectedSem.isNotEmpty &&
                      levelid != 0)
                    // DropdownButtonFormField2<String>(
                    //   decoration: const InputDecoration(
                    //     labelText: 'Select Day',
                    //     labelStyle: TextStyle(
                    //
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    //   isExpanded: true,
                    //   value: selectedMonth,
                    //   hint: const Text(
                    //     'Choose a day',
                    //     style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                    //   ),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       selectedMonth = newValue!;
                    //       getSchedByMonth();
                    //     });
                    //   },
                    //   items: months.map<DropdownMenuItem<String>>(
                    //     (String month) {
                    //       return DropdownMenuItem<String>(
                    //         value: month,
                    //         child: Text(
                    //           month.toUpperCase(),
                    //           style: const TextStyle(
                    //
                    //             color: Colors.black,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ).toList(),
                    // ),
                    DropdownButtonFormField2<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Day',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      isExpanded: true,
                      value:
                          selectedMonth != null &&
                              months.contains(selectedMonth)
                          ? selectedMonth
                          : null,
                      hint: const Text(
                        'Choose a day',
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMonth = newValue!;
                          getSchedByMonth();
                        });
                      },
                      items: ['All', ...months].map<DropdownMenuItem<String>>((
                        String month,
                      ) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(
                            month.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,

                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: selectedMonth == 'All' && listOfItem3.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: _groupItemsByDay(listOfItem2).entries.map((
                                entry,
                              ) {
                                return Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            entry.key.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: schoolColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        ...entry.value.map((item) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.subject,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(height: 4.0),
                                              if (item.room.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.meeting_room,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      item.room,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4.0),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Text(
                                                    '${item.start} - ${item.end}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4.0),
                                              if (item.teacher.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      item.teacher,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 25.0),
                                            ],
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : listOfItem3.isNotEmpty
                        ? ListView.builder(
                            itemCount: listOfItem3.length,
                            itemBuilder: (context, index) {
                              final item = listOfItem3[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        color: schoolColor,
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
                                                  child: Text(
                                                    '${item.subject}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              if (item.teacher.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      item.teacher,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              if (item.room.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.meeting_room,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      item.room,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Text(
                                                    '${item.start} - ${item.end}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: selectedYear == '' || selectedSem == ''
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/search1.png'),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        "Select School Year and Semester\nto fetch data.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: schoolColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/search1.png'),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        "No available schedule",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: schoolColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
