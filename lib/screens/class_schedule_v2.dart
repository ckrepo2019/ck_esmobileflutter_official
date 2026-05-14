import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrolled_stud.dart';
import 'package:pushtrial/models/schedule_v2.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/year_sem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassScheduleV2Screen extends StatefulWidget {
  const ClassScheduleV2Screen({super.key});

  @override
  State<ClassScheduleV2Screen> createState() => _ClassScheduleV2ScreenState();
}

class _ClassScheduleV2ScreenState extends State<ClassScheduleV2Screen> {
  User user = UserData.myUser;
  String studid = '0';

  List<V2Subject> subjects = [];
  List<EnrolledStud> enrolledstud = [];
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];
  List<SchoolInfo> schoolInfo = [];

  Color schoolColor = const Color.fromARGB(255, 14, 19, 29);

  int syid = 0;
  int semid = 0;
  int levelid = 0;
  String selectedYear = '';
  String selectedSem = '';

  bool loading = true;

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    studid = prefs.getString('studid') ?? '0';
    final userJson = prefs.getString('user');
    if (userJson != null) user = User.fromJson(jsonDecode(userJson));

    await _loadSchoolInfo();
    await _loadYearAndSem();
    await _loadEnrolledStud();
    await _loadSchedule();

    setState(() => loading = false);
  }

  Future<void> _loadSchoolInfo() async {
    try {
      final response = await CallApi().getSchoolInfo();
      final parsed = json.decode(response.body);
      if (parsed is List && parsed.isNotEmpty && mounted) {
        setState(() {
          schoolInfo = parsed.map((e) => SchoolInfo.fromJson(e)).toList();
          schoolColor = hexToColor(schoolInfo[0].schoolcolor);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadYearAndSem() async {
    try {
      final response = await CallApi().getYearandSem();
      final data = json.decode(response.body) as Map<String, dynamic>;

      schoolYear = (data['sy'] as List)
          .map((e) => SchoolYear.fromJson(e))
          .toList()
        ..sort((a, b) => a.sydesc.compareTo(b.sydesc));
      schoolSem = (data['semester'] as List)
          .map((e) => Sem.fromJson(e))
          .toList();
    } catch (_) {}
  }

  Future<void> _loadEnrolledStud() async {
    try {
      final response = await CallApi().getEnrolledStud(user.id);
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        final list = decoded['enrolledstud_info'] as List;
        enrolledstud = list.map((e) => EnrolledStud.fromJson(e)).toList();
        enrolledstud.sort((a, b) {
          final y = b.syid.compareTo(a.syid);
          return y != 0 ? y : b.semid.compareTo(a.semid);
        });

        if (enrolledstud.isNotEmpty) {
          final latest = enrolledstud.first;
          syid = latest.syid;
          semid = latest.semid;
          levelid = latest.levelid;
          selectedYear = syid.toString();
          selectedSem = semid.toString();
        }
      }
    } catch (_) {}
  }

  Future<void> _loadSchedule() async {
    if (syid == 0) return;
    setState(() => loading = true);
    try {
      final response = await CallApi().getV2ClassSchedule(studid, syid, semid);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List && mounted) {
          setState(() {
            subjects = decoded.map((e) => V2Subject.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      print('V2 schedule error: $e');
    }
    if (mounted) setState(() => loading = false);
  }

  void _onYearChanged(String value) {
    setState(() {
      selectedYear = value;
      syid = int.parse(value);

      final enrolled = enrolledstud.firstWhere(
        (e) => e.syid == syid,
        orElse: () => enrolledstud.first,
      );
      semid = enrolled.semid;
      levelid = enrolled.levelid;
      selectedSem = semid.toString();
      subjects = [];
    });
    _loadSchedule();
  }

  void _onSemChanged(String value) {
    setState(() {
      selectedSem = value;
      semid = int.parse(value);
      subjects = [];
    });
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField2<String>(
                          value: selectedYear.isNotEmpty ? selectedYear : null,
                          hint: const Text('School Year', style: TextStyle(fontSize: 12)),
                          items: schoolYear
                              .map((y) => DropdownMenuItem(
                                    value: y.id.toString(),
                                    child: Text(y.sydesc, style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) { if (v != null) _onYearChanged(v); },
                          decoration: const InputDecoration(
                            labelText: 'School Year',
                            labelStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (levelid == 14 || levelid == 15 || levelid >= 17) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            value: selectedSem.isNotEmpty ? selectedSem : null,
                            hint: const Text('Semester', style: TextStyle(fontSize: 12)),
                            items: schoolSem
                                .map((s) => DropdownMenuItem(
                                      value: s.id.toString(),
                                      child: Text(s.semester, style: const TextStyle(fontSize: 12)),
                                    ))
                                .toList(),
                            onChanged: (v) { if (v != null) _onSemChanged(v); },
                            decoration: const InputDecoration(
                              labelText: 'Semester',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (subjects.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No subjects found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: schoolColor,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subj = subjects[index];
                          return _buildSubjectCard(subj);
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubjectCard(V2Subject subj) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: schoolColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subj.subjdesc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subj.subjcode.isNotEmpty)
                  Text(
                    subj.subjcode,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subj.teacherName.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 15, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        subj.teacherName,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                if (subj.teacherName.isNotEmpty) const SizedBox(height: 6),
                if (subj.schedule.isEmpty)
                  Row(
                    children: const [
                      Icon(Icons.schedule, size: 15, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'No schedule assigned',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  ...subj.schedule.map((slot) => _buildSlot(slot)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(V2ScheduleSlot slot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slot.day.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(slot.day, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          if (slot.start.isNotEmpty || slot.end.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${slot.start} - ${slot.end}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ],
          if (slot.room.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(slot.room, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
          if (slot.type.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.label_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(slot.type, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
