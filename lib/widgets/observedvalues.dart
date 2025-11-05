import 'dart:convert';
import 'package:pushtrial/models/observedvalues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class ObservedValuesScreen extends StatefulWidget {
  const ObservedValuesScreen({super.key});

  @override
  State<ObservedValuesScreen> createState() => _ObservedValuesState();
}

class _ObservedValuesState extends State<ObservedValuesScreen> {
  String studid = '0';
  int syid = 0;
  List<RatingValues> _ratingValues = [];
  List<Setup> _setup = [];
  List<StudentObservedValues> _studentObservedValues = [];

  var gradelevel = 0;
  String selectedYear = '';
  List<String> years = [];
  bool loading = true;
  List<EnrolledStud> enrolledstud = [];
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

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
  void initState() {
    getSchoolInfo();
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getUser();
    await getEnrolledStud();

    setState(() {
      loading = false;
    });
  }

  getEnrolledStud() async {
    await CallApi().getEnrolledStud(studid).then((response) {
      setState(() {
        var decodedJson = json.decode(response.body);

        if (decodedJson is Map<String, dynamic>) {
          Iterable list = decodedJson['enrolledstud_info'];
          enrolledstud = list
              .map((model) => EnrolledStud.fromJson(model))
              .toList();
          for (var element in enrolledstud) {
            years.add(element.sydesc);
          }
          Set<String> uniqueSet = years.toSet();
          years = uniqueSet.toList();

          var lastindex = enrolledstud[enrolledstud.length - 1];

          setState(() {
            selectedYear = lastindex.sydesc;
            gradelevel = lastindex.levelid;
            syid = lastindex.syid;

            getObservedValues();
          });
        }
      });
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        studid = json;
      });
    }
  }

  Future<void> getObservedValues() async {
    final response = await CallApi().getObservedValues(studid, syid);
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField2<String>(
                  decoration: const InputDecoration(
                    labelText: 'School Year',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  value: selectedYear.isNotEmpty ? selectedYear : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue!;

                      for (var yr in enrolledstud) {
                        if (yr.sydesc == selectedYear) {
                          syid = yr.syid;
                          getObservedValues();
                        }
                      }
                    });
                  },
                  items: years.map<DropdownMenuItem<String>>((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ),
              if (selectedYear.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/search1.png'),
                        const SizedBox(height: 10.0),
                        Text(
                          "Select School Year to fetch data.",
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
                )
              else
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
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
                                          getRatingValue(
                                            studentObserved.q1eval,
                                          ),
                                          softWrap: false,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          getRatingValue(
                                            studentObserved.q2eval,
                                          ),
                                          softWrap: false,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          getRatingValue(
                                            studentObserved.q3eval,
                                          ),
                                          softWrap: false,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          getRatingValue(
                                            studentObserved.q4eval,
                                          ),
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
  }
}
