import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceState();
}

class _AttendanceState extends State<AttendanceScreen> {
  var id = '0';
  var syid = 0;
  var levelid = 0;
  String selectedYear = '';
  List<String> years = [];
  List<CustomEvent> events = [];
  List<EnrollmentInfo> enInfoData = [];
  List<EnrolledStud> enrolledstud = [];
  late CustomEvent selectedEvent = CustomEvent(
    isPresent: 0,
    subject: '',
    startTime: DateTime.now(),
    endTime: DateTime.now(),
    color: Colors.white,
  );

  @override
  void initState() {
    getUser();
    super.initState();
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

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(id).then((response) {
      setState(() {
        Iterable list = jsonDecode(response.body);
        // print(list);
        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();

        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        for (var yr in enInfoData) {
          if (yr.sydesc == selectedYear) {
            // print("has match");
            syid = yr.syid;
            levelid = yr.levelid;
            getAttendance();
          }
        }
      });
    });
  }

  getAttendance() async {
    await CallApi().getAttendance(id, syid, levelid).then((response) {
      if (mounted) {
        setState(() {
          events.clear();
          selectedEvent = CustomEvent(
            isPresent: 0,
            subject: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            color: Colors.white,
          );
          Iterable ll = jsonDecode(response.body);
          // print(ll);
          events = ll.map((data) {
            String tdate = data['tdate'];
            DateTime dateTime = DateTime.parse(tdate);

            return CustomEvent(
              isPresent: data['present'],
              subject: data['attday'],
              startTime: dateTime,
              endTime: dateTime.add(const Duration(days: 1)),
              color: Colors.blue,
            );
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          selectedYear.isNotEmpty
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
                  hint: const Text('Select Year'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue!;
                      for (var yr in enInfoData) {
                        if (yr.sydesc == selectedYear) {
                          syid = yr.syid;
                          levelid = yr.levelid;
                          getAttendance();
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
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20.0),
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: _AppointmentDataSource(events),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  DateTime tappedDate = details.date!;
                  selectedEvent = events.firstWhere(
                    (event) =>
                        event.startTime.year == tappedDate.year &&
                        event.startTime.month == tappedDate.month &&
                        event.startTime.day == tappedDate.day,
                    orElse: () => CustomEvent(
                      subject: 'subject',
                      startTime: DateTime.now(),
                      endTime: DateTime.now(),
                      color: Colors.grey,
                      isPresent: 0,
                    ),
                  );
                  setState(() {});
                }
              },
            ),
          ),
          if (selectedEvent.subject.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              color: const Color.fromARGB(255, 14, 19, 29),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedEvent.isPresent == 1 ? 'Present' : 'Absent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedEvent.isPresent == 1
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMMM d, yyyy',
                      ).format(selectedEvent.startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomEvent extends Appointment {
  final int isPresent;
  CustomEvent({
    required this.isPresent,
    required String subject,
    required DateTime startTime,
    required DateTime endTime,
    required Color color,
  }) : super(
         startTime: startTime,
         endTime: endTime,
         subject: subject,
         color: color,
       );
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
