import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/school_info.dart';
import '../widgets/menu_button.dart';

class RemedialClassScreen extends StatefulWidget {
  const RemedialClassScreen({super.key});

  @override
  _RemedialClassScreenState createState() => _RemedialClassScreenState();
}

class _RemedialClassScreenState extends State<RemedialClassScreen> {
  List<SchoolInfo> schoolInfo = [];
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REMEDIAL CLASS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: schoolColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/robot.png', height: 200, width: 200),
                  const SizedBox(height: 20),
                  Text(
                    'Sorry, this page is unavailable right now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: schoolColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We are working on making this feature available soon. Please check back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: schoolColor),
                  ),
                ],
              ),
            ),
          ),
          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: CustomFloatingMenu(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
