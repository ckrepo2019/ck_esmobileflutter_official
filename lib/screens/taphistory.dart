import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/taphistory.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:pushtrial/api/api.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TapHistoryScreen extends StatefulWidget {
  const TapHistoryScreen({super.key});

  @override
  _TapHistoryScreenState createState() => _TapHistoryScreenState();
}

class _TapHistoryScreenState extends State<TapHistoryScreen> {
  int studid = 0;
  User user = UserData.myUser;
  List<SchoolInfo> schoolInfo = [];
  List<TapHistory> tapHistory = [];
  List<TapHistory> filteredTapHistory = [];
  String selectedMonth = 'ALL';
  String selectedWeek = 'ALL';
  String selectedState = 'ALL';
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void initState() {
    super.initState();
    getSchoolInfo();
    getUser();
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
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    studid = user.id;
    getTapHistory();
  }

  Future<void> getTapHistory() async {
    final response = await CallApi().getTapHistory(studid);
    final parsedResponse = json.decode(response.body);
    if (parsedResponse is List) {
      setState(() {
        tapHistory = parsedResponse
            .map((model) => TapHistory.fromJson(model))
            .toList()
            .cast<TapHistory>();
        filterTapHistory();
      });
    }
  }

  void filterTapHistory() {
    setState(() {
      filteredTapHistory = tapHistory.where((history) {
        bool matchesMonth =
            selectedMonth == 'ALL' ||
            DateFormat(
                  'MMMM',
                ).format(DateFormat('yyyy-MM-dd').parse(history.tdate)) ==
                selectedMonth;

        bool matchesState =
            selectedState == 'ALL' || history.tapstate == selectedState;

        bool matchesWeek = true;
        if (selectedWeek != 'ALL') {
          final date = DateFormat('yyyy-MM-dd').parse(history.tdate);
          int weekOfMonth = ((date.day - 1) / 7).floor() + 1;
          matchesWeek = selectedWeek == 'Week $weekOfMonth';
        }

        return matchesMonth && matchesState && matchesWeek;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredTapHistory.sort((a, b) => b.tdate.compareTo(a.tdate));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'TAP HISTORY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: tapHistory.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/search1.png'),
                    const SizedBox(height: 10.0),
                    Text(
                      "No tap records found",
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
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2<String>(
                          hint: const Text(
                            'Select Month',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: selectedMonth == 'ALL' ? null : selectedMonth,
                          items:
                              [
                                'ALL',
                                'January',
                                'February',
                                'March',
                                'April',
                                'May',
                                'June',
                                'July',
                                'August',
                                'September',
                                'October',
                                'November',
                                'December',
                              ].map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value!;
                              filterTapHistory();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: DropdownButtonFormField2<String>(
                          hint: const Text(
                            'Select State',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: selectedState == 'ALL' ? null : selectedState,
                          items: [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text(
                                'ALL',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'IN',
                              child: Text('IN', style: TextStyle(fontSize: 12)),
                            ),
                            DropdownMenuItem(
                              value: 'OUT',
                              child: Text(
                                'OUT',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedState = value!;
                              filterTapHistory();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'State',
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
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable(
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),

                          dividerThickness: 1.0,
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('STATE')),
                            DataColumn(label: Text('TIME')),
                            DataColumn(label: Text('DATE')),
                          ],
                          rows: filteredTapHistory.map((history) {
                            final date = DateFormat(
                              'yyyy-MM-dd',
                            ).parse(history.tdate);
                            final formattedDate = DateFormat(
                              'MMMM dd, yyyy',
                            ).format(date);
                            final time = DateFormat(
                              'HH:mm:ss',
                            ).parse(history.ttime);
                            final formattedTime = DateFormat(
                              'hh:mm a',
                            ).format(time);

                            return DataRow(
                              cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      history.tapstate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: history.tapstate == 'IN'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      formattedTime,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
