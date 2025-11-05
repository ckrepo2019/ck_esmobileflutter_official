import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/event.dart';
import 'package:intl/intl.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class SchoolCalendar extends StatefulWidget {
  const SchoolCalendar({super.key});

  @override
  State<SchoolCalendar> createState() => _SchoolCalendarState();
}

class _SchoolCalendarState extends State<SchoolCalendar> {
  var id = '0';
  var syid = 0;
  String selectedYear = '';
  List<String> years = [];
  List<Event> events = [];

  late List<Appointment> _appointments = [];
  bool loading = true;
  List<EnrolledStud> enrolledstud = [];
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

  @override
  void initState() {
    getUser();
    getSchoolInfo();
    super.initState();
  }

  List<Appointment> _getAppointments() {
    return events.map((event) {
      return Appointment(
        startTime: event.startTime,
        endTime: event.endTime,
        subject: event.title,
        color: Colors.blue,
      );
    }).toList();
  }

  List<TimeRegion> _getSpecialRegions() {
    List<TimeRegion> specialRegions = [];

    for (Appointment appointment in _appointments) {
      specialRegions.add(
        TimeRegion(
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          enablePointerInteraction: false,
          textStyle: const TextStyle(color: Colors.white),
          color: Colors.blue,
        ),
      );
    }

    return specialRegions;
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrolledStud();
      await getEvents();
    }
    setState(() {
      loading = false;
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

          for (var element in enrolledstud) {
            years.add(element.sydesc);
          }
          Set<String> uniqueSet = years.toSet();
          years = uniqueSet.toList();
          selectedYear = enrolledstud[enrolledstud.length - 1].sydesc;
          for (var yr in enrolledstud) {
            if (yr.sydesc == selectedYear) {
              syid = yr.syid;
              getEvents();
            }
          }
        }
      });
    });
  }

  getEvents() async {
    await CallApi().getEvents(syid).then((response) {
      setState(() {
        Iterable ll = jsonDecode(response.body);
        events = (ll as List<dynamic>).map((e) {
          return Event(
            id: e['id'] ?? 0,
            title: e['title'] ?? '',
            venue: e['venue'] ?? '',
            startTime:
                (e['startTime'] != null &&
                    e['startTime'].isNotEmpty &&
                    e['startTime'] != '0')
                ? DateTime.parse(e['startTime'])
                : DateTime(0),
            endTime:
                (e['endTime'] != null &&
                    e['endTime'].isNotEmpty &&
                    e['endTime'] != '0')
                ? DateTime.parse(e['endTime'])
                : DateTime(0),
            time: e['time'] ?? '',
          );
        }).toList();
        _appointments = _getAppointments();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'SCHOOL CALENDAR',
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
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      labelText: 'School Year',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                    ),
                    isExpanded: true,
                    value: selectedYear.isNotEmpty ? selectedYear : null,
                    hint: const Text(
                      'Choose a school year',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                        for (var yr in enrolledstud) {
                          if (yr.sydesc == selectedYear) {
                            syid = yr.syid;
                            getEvents();
                          }
                        }
                      });
                    },
                    items: years.map<DropdownMenuItem<String>>((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(
                          year,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }).toList(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20.0),
                  events.isNotEmpty
                      ? Expanded(
                          flex: 2,
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialSelectedDate: DateTime.now(),
                            dataSource: _AppointmentDataSource(_appointments),
                            appointmentBuilder: appointmentBuilder,
                            onTap: onTapCalendarCell,
                            specialRegions: _getSpecialRegions(),
                          ),
                        )
                      : Expanded(
                          flex: 2,
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialSelectedDate: DateTime.now(),
                            dataSource: _AppointmentDataSource(_appointments),
                            appointmentBuilder: appointmentBuilder,
                            onTap: onTapCalendarCell,
                            specialRegions: _getSpecialRegions(),
                          ),
                        ),
                  events.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              List<Event> sortedEvents = List.from(events)
                                ..sort(
                                  (a, b) => b.startTime.compareTo(a.startTime),
                                );

                              Event event = sortedEvents[index];
                              String formattedDate = DateFormat(
                                'MMMM d, yyyy',
                              ).format(event.startTime);

                              return Card(
                                color: schoolColor,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      if (event.venue.isNotEmpty)
                                        Text(
                                          event.venue,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        event.time,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void onTapCalendarCell(CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          List<Event> events2 = details.appointments!.map((appointment) {
            return events.firstWhere(
              (event) =>
                  event.title == appointment.subject &&
                  event.startTime == appointment.startTime &&
                  event.endTime == appointment.endTime,
            );
          }).toList();

          return AlertDialog(
            title: const Center(child: Text('Event Details')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: events2.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (event.venue.isNotEmpty) Text(event.venue),
                      const SizedBox(height: 4),
                      Text(event.time),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  Widget appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    if (details.appointments.length == 1) {
      return Container(
        decoration: BoxDecoration(
          color: details.appointments.first.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            details.appointments.first.subject,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (details.appointments.length > 1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '+${details.appointments.length}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
