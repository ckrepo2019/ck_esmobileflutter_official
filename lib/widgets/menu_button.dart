import 'package:flutter/material.dart';
import '../screens/school_calendar.dart';
import '../screens/clearance.dart';
import '../screens/enrollment.dart';
import '../screens/payment.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/api/api.dart';
import 'dart:convert';

class CustomFloatingMenu extends StatefulWidget {
  @override
  _CustomFloatingMenuState createState() => _CustomFloatingMenuState();
}

class _CustomFloatingMenuState extends State<CustomFloatingMenu> {
  bool _isMenuOpen = false;

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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _handleMenuAction(String label) {
    Navigator.pop(context);
    if (label == 'Scholarship Request') {
      // Handle Scholarship Request action
    } else if (label == 'School Calendar') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SchoolCalendar()),
      );
    } else if (label == 'Clearance') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClearanceScreen()),
      );
    } else if (label == 'Enrollment') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnrollmentScreen()),
      );
    } else if (label == 'Payment') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaymentPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getSchoolInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _toggleMenu();
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    height: 300,
                    child: Column(
                      children: [
                        _buildMenuRow(
                          iconData: [
                            Icons.school,
                            Icons.assessment,
                            Icons.calendar_today,
                          ],
                          labels: [
                            'Scholarship Request',
                            'Teacher Evaluation',
                            'School Calendar',
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        _buildMenuRow(
                          iconData: [
                            Icons.check_circle,
                            Icons.subscriptions,
                            Icons.payments,
                          ],
                          labels: ['Clearance', 'Enrollment', 'Payment'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: schoolColor,
              shape: const CircleBorder(),
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuRow({
    required List<IconData> iconData,
    required List<String> labels,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(iconData.length, (index) {
        return GestureDetector(
          onTap: () => _handleMenuAction(labels[index]),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: schoolColor,
                child: Icon(iconData[index], color: Colors.white, size: 30.0),
              ),
              const SizedBox(height: 8.0),
              Container(
                constraints: const BoxConstraints(maxWidth: 80.0),
                child: Text(
                  labels[index],
                  style: const TextStyle(
                    fontSize: 12.0,

                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
