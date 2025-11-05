import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';
import 'package:pushtrial/models/smsbunker.dart';
import 'package:pushtrial/models/login.dart';
import 'package:pushtrial/models/user_login.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pushtrial/models/school_info.dart';
import 'home.dart';
import 'dashboard.dart';

class NotificationsScreen extends StatefulWidget {
  // final VoidCallback onNotificationsViewed;

  // NotificationsScreen({required this.onNotificationsViewed});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  User user = UserData.myUser;
  Login userLogin = UserDataLogin.myUserLogin;
  int studid = 0;
  int type = 0;
  List<SMS> sms = [];
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

  @override
  void initState() {
    getSchoolInfo();
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    await getLogin();
    await getSMSBunker();

    setState(() {
      loading = false;
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));

    setState(() {
      studid = user.id;
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

  Future<void> getSMSBunker() async {
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
        }
      });

      print('Retrieved smsbunker for notifications: $sms');
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

  // Future<void> _showFCMTokenDialog() async {
  //   String? token = await PushNotifications.getFCMToken();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('FCM Token'),
  //         content: Text(token ?? 'Failed to retrieve FCM token'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<SMS> filteredData = sms
        .where((item) => item.pushstatus == 1 || item.pushstatus == 2)
        .toList();

    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');

    filteredData.sort((a, b) {
      int statusComparison = a.pushstatus.compareTo(b.pushstatus);
      if (statusComparison == 0) {
        return b.createddatetime.compareTo(a.createddatetime);
      }
      return statusComparison;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'NOTIFICATIONS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
            )
          : Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
              child: filteredData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/bell.png',
                            height: 200,
                            width: 200,
                          ),
                          const Text(
                            'No notifications available',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final notification = filteredData[index];
                        bool isReadStatus = notification.pushstatus == 2;

                        final formattedDate = dateFormat.format(
                          DateTime.parse(notification.createddatetime),
                        );

                        return SwipeActionCell(
                          key: ValueKey(notification.id),
                          trailingActions: isReadStatus
                              ? []
                              : [
                                  SwipeAction(
                                    content: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          65,
                                          187,
                                          54,
                                        ).withOpacity(0.75),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      padding: EdgeInsets.zero,
                                      margin: EdgeInsets.zero,
                                      height: 100.0,
                                      child: const Text(
                                        "Mark as Read",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: (CompletionHandler handler) async {
                                      await handler(true);
                                      await updateNotificationPushStatus(
                                        notification.id,
                                        studid,
                                        2,
                                      );
                                      setState(() {
                                        sms.sort((a, b) {
                                          int statusComparison = a.pushstatus
                                              .compareTo(b.pushstatus);
                                          if (statusComparison == 0) {
                                            return b.createddatetime.compareTo(
                                              a.createddatetime,
                                            );
                                          }
                                          return statusComparison;
                                        });
                                      });
                                    },
                                    color: Colors.transparent,
                                  ),
                                ],
                          child: Card(
                            color: isReadStatus ? Colors.white : Colors.white,
                            margin: const EdgeInsets.all(7.0),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isReadStatus)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  notification.message,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 13, 4, 20),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
