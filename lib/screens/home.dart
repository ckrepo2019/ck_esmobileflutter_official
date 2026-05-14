import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import '../widgets/carousel_card.dart';
import 'package:pushtrial/models/smsbunker.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/login.dart';
import 'package:pushtrial/models/user_login.dart';
import 'package:pushtrial/api/api.dart';
import 'notifications.dart';
import 'payment.dart';
import 'clearance.dart';
import 'enrollment.dart';
import 'scholarship_request.dart';
import 'teacher_evaluation.dart';
import 'billing_information.dart';
import 'billing_information_v2.dart';
import 'reportcard.dart';
import 'class_schedule.dart';
import 'class_schedule_v2.dart';
import 'package:pushtrial/models/school_info.dart';
import 'dart:convert';
import 'dart:async';
import '../widgets/school_utils.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.calendar_month_outlined, 'label': 'Class Schedule'},
    {'icon': Icons.credit_card_outlined, 'label': 'Report Card'},
    {'icon': Icons.receipt_long_outlined, 'label': 'Billing Information'},
    {'icon': Icons.file_present_outlined, 'label': 'Clearance'},
    {'icon': Icons.compare_arrows, 'label': 'Payment Transaction'},
    {'icon': Icons.school_outlined, 'label': 'Scholarship Request'},
    {'icon': Icons.insert_drive_file_outlined, 'label': 'Teacher Evaluation'},
    {'icon': Icons.payments_outlined, 'label': 'Enrollment'},
  ];

  int _carouselRefreshKey = 0;
  late AnimationController _animationController;
  int _notificationCount = 0;
  User user = UserData.myUser;
  late Future<void> _checkAndNotifyFuture;
  int studid = 0;
  int id = 0;
  String userFirstName = '';

  String? notificationMessage;
  List<String> notifications = [];
  List<SMS> sms = [];
  Login userLogin = UserDataLogin.myUserLogin;
  int type = 0;

  bool loading = true;
  String schoolVersion = 'v1';
  Future<String?> host = CallApi().getImage();
  String? picurl;
  String? pic;

  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = const Color.fromARGB(0, 255, 255, 255);

  Future<void> _loadSchoolInfo() async {
    final result = await SchoolUtils.getSchoolInfoData();
    setState(() {
      schoolColor = result['schoolColor'];
      picurl = result['picurl'];
      schoolInfo = result['schoolInfo'];
    });
  }

  Future<void> _loadSelectedSchool() async {
    pic = await SchoolUtils.loadSelectedSchool();
  }

  @override
  void initState() {
    super.initState();

    _checkAndNotifyFuture = _initializeData();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSchoolInfo();
    await _loadSelectedSchool();
    setState(() {
      loading = true;
      _carouselRefreshKey++; // Increment key to rebuild CarouselCard
    });
    await getUser();
    await getLogin();
    await getSMSBunker();

    setState(() {
      loading = false;
    });
  }

  Future<void> getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('userlogin');
    userLogin = json == null
        ? UserDataLogin.myUserLogin
        : Login.fromJson(jsonDecode(json));
    // print('User login data in notifications: $userLogin');

    type = userLogin.type;
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    final version = preferences.getString('schoolVersion') ?? 'v1';
    setState(() {
      schoolVersion = version;
    });
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data: $user');
    {
      setState(() {
        studid = user.id;
        userFirstName = user.firstname!;
      });
    }
  }

  Future<void> getSMSBunker() async {
    try {
      final response = await CallApi().getSmsBunker(studid);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('No data returned');
          return;
        }

        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          if (userLogin.type == 7) {
            final smsbunkerStudent = (data['smsbunkerstudent'] as List)
                .map((model) => SMS.fromJson(model))
                .toList();

            final smsbunkertextblastStudent =
                (data['smsbunkertextblaststudent'] as List)
                    .map((model) => SMS.fromJson(model))
                    .toList();

            sms = [...smsbunkerStudent, ...smsbunkertextblastStudent];

            _notificationCount = sms.where((tap) => tap.pushstatus == 1).length;
          } else if (userLogin.type == 9) {
            final smsbunkerParents = (data['smsbunkerparents'] as List)
                .map((model) => SMS.fromJson(model))
                .toList();
            final tapbunkerParents = (data['tapbunkerparents'] as List)
                .map((model) => SMS.fromJson(model))
                .toList();
            final smsbunkertextblastParents =
                (data['smsbunkertextblastsparents'] as List)
                    .map((model) => SMS.fromJson(model))
                    .toList();

            sms = [
              ...smsbunkerParents,
              ...tapbunkerParents,
              ...smsbunkertextblastParents,
            ];
            _notificationCount = sms.where((tap) => tap.pushstatus == 1).length;
          }
        });

        // print('Retrieved smsbunker for home: $sms');
      } else {
        print('Failed to load smsbunker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> updateNotificationPushStatus(id, studid, newStatus) async {
    final response = await CallApi().getUpdatePushStatus(id, studid, newStatus);

    if (response.statusCode == 200) {
      print('Notification push status updated successfully.');
    } else {
      print(
        'Failed to update notification push status. Status code: ${response.statusCode}',
      );
    }
  }

  void _handleNotification(String message) {
    setState(() {
      notifications.add(message);
      _notificationCount = notifications.length;
    });
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstname', user.firstname ?? '');
    await prefs.setString('middlename', user.middlename ?? '');
    await prefs.setString('lastname', user.lastname ?? '');
    await prefs.setString('sid', user.sid ?? '');
    await prefs.setString('fathername', user.fathername ?? '');
  }

  Future<User> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return User(
      firstname: prefs.getString('firstname') ?? '',
      middlename: prefs.getString('middlename') ?? '',
      lastname: prefs.getString('lastname') ?? '',
      sid: prefs.getString('sid') ?? '',
      fathername: prefs.getString('fathername') ?? '',
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initializeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationsScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: schoolColor,
                                size: 30,
                              ),
                              if (_notificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        14,
                                        19,
                                        29,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$_notificationCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'Hello!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${user.firstname} ${user.lastname}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      CarouselCard(key: ValueKey(_carouselRefreshKey)),
                      const SizedBox(height: 24),
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            switch (index) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => schoolVersion == 'v2'
                                        ? const ClassScheduleV2Screen()
                                        : ClassScheduleScreen(),
                                  ),
                                );
                                break;
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReportCardScreen(),
                                  ),
                                );
                                break;
                              case 2:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => schoolVersion == 'v2'
                                        ? const BillingInformationV2Page()
                                        : BillingInformationPage(),
                                  ),
                                );
                                break;
                              case 3:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClearanceScreen(),
                                  ),
                                );
                                break;
                              case 4:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(),
                                  ),
                                );
                                break;
                              case 5:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScholarshipRequestScreen(),
                                  ),
                                );
                                break;
                              case 6:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TeacherEvaluationScreen(),
                                  ),
                                );
                                break;
                              case 7:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EnrollmentScreen(),
                                  ),
                                );
                                break;
                              default:
                                break;
                            }
                          },
                          child: Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              feature['icon'],
                              size: 26,
                              color: schoolColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feature['label'].toString().replaceAll(' ', '\n'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
