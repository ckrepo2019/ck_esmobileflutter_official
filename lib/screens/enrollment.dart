import 'package:flutter/material.dart';
import 'package:pushtrial/models/enrolled_stud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/enrollment_data.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/year_sem.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => EnrollmentScreenState();
}

class EnrollmentScreenState extends State<EnrollmentScreen> {
  User user = UserData.myUser;
  String id = '0';
  int syid = 0;
  String selectedYear = '';
  List<EnrollmentData> enData = [];
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);
  bool loading = true;
  List<SchoolYear> schoolYear = [];
  List<EnrolledStud> enrolledstud = [];

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
    setState(() {
      loading = false;
    });
  }

  Future<void> getYearandSem() async {
    final response = await CallApi().getYearandSem();
    final Map<String, dynamic> responseData = json.decode(response.body);

    schoolYear = (responseData['sy'] as List)
        .map((data) => SchoolYear.fromJson(data))
        .toList();

    schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

    var activeYear = schoolYear.firstWhere((year) => year.isactive == 1);

    if (schoolYear.isNotEmpty) {
      selectedYear = activeYear.id.toString();
      syid = int.parse(selectedYear);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ENROLLMENT INFORMATION',
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
              padding: const EdgeInsets.all(30.0),
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
                            setState(() {
                              selectedYear = value!;
                              syid = int.parse(selectedYear);
                            });
                            getEnrolledStud();
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
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child:
                        enrolledstud.any(
                          (enrollment) => enrollment.syid == syid,
                        )
                        ? ListView.builder(
                            itemCount: enrolledstud.length,
                            itemBuilder: (context, index) {
                              if (enrolledstud[index].syid == syid) {
                                final enrollment = enrolledstud[index];
                                return Card(
                                  color: schoolColor,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                          'School Year',
                                          enrollment.sydesc,
                                        ),
                                        if (enrollment.semester.isNotEmpty)
                                          _buildInfoRow(
                                            'Semester',
                                            enrollment.semester,
                                          ),
                                        _buildInfoRow(
                                          'Enrollment Status',
                                          enrollment.description,
                                        ),
                                        _buildInfoRow(
                                          'Grade Level',
                                          enrollment.levelname,
                                        ),
                                        if (enrollment.strandname.isNotEmpty)
                                          _buildInfoRow(
                                            'Strand',
                                            enrollment.strandname,
                                          ),
                                        if (enrollment.sectionname.isNotEmpty)
                                          _buildInfoRow(
                                            'Section',
                                            enrollment.sectionname,
                                          ),
                                        if (enrollment.courseDesc.isNotEmpty)
                                          _buildInfoRow(
                                            'Course',
                                            enrollment.courseDesc,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Image.asset('assets/search1.png'),
                                ),
                                Center(
                                  child: Text(
                                    'No data available for the selected year and semester',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: schoolColor,
                                    ),
                                  ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
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

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
      });
    }
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
      });
    });
  }
}
