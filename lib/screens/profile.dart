import 'package:flutter/material.dart';
import 'package:pushtrial/models/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/api/api.dart';
import '../auth/login.dart';

import 'dart:convert';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/login.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/enrolled_stud.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  User user = UserData.myUser;
  Login userLogin = UserDataLogin.myUserLogin;
  String id = '0';
  String selectedYear = '';

  String syDesc = '';
  String sem = '';
  Future<String?> host = CallApi().getImage();
  bool isValid = false;
  bool loading = true;
  String? pic;
  String? picurl;
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = Color.fromARGB(0, 255, 255, 255);
  List<EnrolledStud> enrolledstud = [];

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

  Future<String?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedSchool');
  }

  Future<void> _loadSelectedSchool() async {
    String? selectedSchool = await getSchool();

    if (selectedSchool != null) {
      print('Loaded school eslink: $selectedSchool');
    } else {
      print('No school found in preferences.');
    }

    pic = selectedSchool;
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
    await getUserInfo();
    await getSchoolInfo();
    await getEnrolledStud();
    await _loadSelectedSchool();

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'PROFILE',
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
          : Column(
              children: [
                _buildProfileHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSectionHeader('ENROLLMENT INFORMATION'),
                          _buildInfoRow(
                            'Grade Level:',
                            _getGradeLevel(),
                            icon: Icons.grade,
                          ),
                          if (_getStrand().isNotEmpty)
                            _buildInfoRow(
                              'Strand:',
                              _getStrand(),
                              icon: Icons.school,
                            ),
                          if (_getCourse().isNotEmpty)
                            _buildInfoRow(
                              'Course:',
                              _getCourse(),
                              icon: Icons.school,
                            ),
                          if (widget.user.lrn != null &&
                              widget.user.lrn!.isNotEmpty)
                            _buildInfoRow(
                              'LRN:',
                              widget.user.lrn ?? '',
                              icon: Icons.confirmation_number,
                            ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('PERSONAL INFORMATION'),
                          _buildInfoRow(
                            'First Name:',
                            widget.user.firstname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Middle Name:',
                            widget.user.middlename ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Last Name:',
                            widget.user.lastname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Suffix:',
                            widget.user.suffix,
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Student ID:',
                            widget.user.sid ?? '',
                            icon: Icons.tag,
                          ),
                          _buildInfoRow(
                            'Date of Birth:',
                            widget.user.dob ?? '',
                            icon: Icons.calendar_month,
                          ),
                          _buildInfoRow(
                            'Gender:',
                            widget.user.gender ?? '',
                            icon: Icons.man,
                          ),
                          _buildInfoRow(
                            'Nationality:',
                            widget.user.nationalityDesc ?? '',
                            icon: Icons.map,
                          ),
                          _buildInfoRow(
                            'Mobile Number:',
                            widget.user.contactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Email Address:',
                            widget.user.semail ?? '',
                            icon: Icons.mail,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('PARENT/GUARDIAN INFORMATION'),
                          _buildInfoRow(
                            'Father\'s Full Name:',
                            widget.user.fathername ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Father\'s Occupation:',
                            widget.user.foccupation ?? '',
                            icon: Icons.work,
                          ),
                          _buildInfoRow(
                            'Father\'s Contact Number:',
                            widget.user.fcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Mother\'s Full Maiden Name:',
                            widget.user.mothername ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Mother\'s Occupation:',
                            widget.user.moccupation ?? '',
                            icon: Icons.work,
                          ),
                          _buildInfoRow(
                            'Mother\'s Contact Number:',
                            widget.user.mcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Full Name:',
                            widget.user.guardianname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Relationship:',
                            widget.user.guardianrelation ?? '',
                            icon: Icons.supervised_user_circle,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Contact Number:',
                            widget.user.gcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('IN CASE ON EMERGENCY'),
                          _buildInfoRow(
                            'Emergency\'s Full Name:',
                            widget.user.getPrimaryContactName() ??
                                'No primary contact available',
                            icon: Icons.badge,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _logout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: schoolColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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

  Widget _buildProfileHeader() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  (user.picurl != null && user.picurl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: "$pic${user.picurl}",
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: imageProvider,
                              ),
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                radius: 70,
                                backgroundImage: AssetImage(
                                  "assets/anonymous.jpg",
                                ),
                              ),
                        )
                      : const CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage("assets/anonymous.jpg"),
                        ),
                ],
              ),
            ),
          ),
          Text(
            widget.user.firstname ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.user.lastname ?? '',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  getUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');

    setState(() {
      user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));

      picurl = user.picurl;

      print('User data: $user');
    });
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Returns the level name of the student's latest enrollment info or 'Not Available'
  /// if there is no enrolled student info.
  /*******  0719f279-07f4-473e-bf7c-cf4ed0ae6b5b  *******/
  String _getGradeLevel() {
    final latestInfo = getSelectedEnrolledStud();
    return latestInfo?.levelname ?? 'Not Available';
  }

  String _getStrand() {
    final latestInfo = getSelectedEnrolledStud();
    return latestInfo?.strandname ?? 'Not Available';
  }

  String _getCourse() {
    final latestInfo = getSelectedEnrolledStud();
    return latestInfo?.courseDesc ?? '';
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

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
      });
    }
    setState(() {});
  }

  getEnrolledStud() async {
    final response = await CallApi().getEnrolledStud(id);
    setState(() {
      var decodedJson = json.decode(response.body);

      if (decodedJson is Map<String, dynamic>) {
        Iterable list = decodedJson['enrolledstud_info'];
        enrolledstud = list
            .map((model) => EnrolledStud.fromJson(model))
            .toList();

        if (enrolledstud.isNotEmpty) {
          selectedYear = enrolledstud.last.sydesc;
          syDesc = selectedYear;

          var latestInfo = enrolledstud.firstWhere(
            (element) => element.sydesc == selectedYear,
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
          sem = latestInfo.semester;
        }
      }
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final userLoginJson = prefs.getString('userlogin');
    if (userJson != null) {
      final user = User.fromJson(jsonDecode(userJson));
      final studid = user.id;
      final userLogin = Login.fromJson(jsonDecode(userLoginJson!));
      final type = userLogin.type;

      final fcmtoken = await _firebaseMessaging.getToken();

      try {
        final response = await CallApi().getDeleteToken(studid, type, fcmtoken);

        if (response.statusCode == 200) {
          print('FCM Token deleted successfully');
        } else {
          print('Failed to delete FCM Token');
        }
      } catch (e) {
        print('Exception occurred while deleting FCM token: $e');
      }
    }

    await prefs.remove('user');
    await prefs.remove('userlogin');
    await prefs.remove('studid');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }
}
