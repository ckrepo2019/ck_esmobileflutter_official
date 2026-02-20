import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/push_notifications.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import '../models/user.dart';
import '../models/login.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../schools/screens/schools.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final CallApi _callApi = CallApi();
  String? picurl;
  String? pic;
  bool _obscureText = true;
  Future<String?> host = CallApi().getImage();
  List<SchoolInfo> schoolInfo = [];

  bool loading = true;

  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> getSchoolInfo() async {
    try {
      final response = await CallApi().getSchoolInfo();
      print("Response body: ${response.body}");
      final parsedResponse = json.decode(response.body);
      if (parsedResponse is List) {
        setState(() {
          schoolInfo = parsedResponse
              .map((model) => SchoolInfo.fromJson(model))
              .toList()
              .cast<SchoolInfo>();
          schoolColor = hexToColor(schoolInfo[0].schoolcolor);
          picurl = schoolInfo[0].picurl;
        });
      }
    } catch (e) {
      print("Error fetching school info: $e");
      _showErrorDialog(
        'Thank you for your patience. This school is currently undergoing setup and is not accessible at this time. Please choose another school to proceed.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Unavailable')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SchoolScreen()),
                );
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        final response = await _callApi.login(username, password);
        // print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);

            if (responseData['stud'] != null &&
                responseData['userlogin'] != null) {
              final User user = User.fromJson(responseData['stud']);
              final Login userLogin = Login.fromJson(responseData['userlogin']);
              final prefs = await SharedPreferences.getInstance();

              await prefs.setString('user', jsonEncode(user.toJson()));
              await prefs.setString(
                'studid',
                responseData['stud']['id'].toString(),
              );
              await prefs.setString(
                'userlogin',
                jsonEncode(userLogin.toJson()),
              );

              String? token = await PushNotifications.getFCMToken();
              if (token != null) {
                await _callApi.getSaveToken(user.id, userLogin.type, token);
              }

              Navigator.pushReplacementNamed(context, '/home', arguments: user);
            } else {
              _showSnackBar('Incorrect username or password');
            }
          } else {
            _showSnackBar('Invalid username or password');
          }
        } else if (response.statusCode == 400) {
          _showSnackBar('Bad request. Please check your input.');
        } else if (response.statusCode == 401) {
          _showSnackBar('Unauthorized. Please check your credentials.');
        } else {
          _showSnackBar('Failed to login. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        _showSnackBar('An error occurred. Please try again.');
      }
    }
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
    await getSchoolInfo();
    await _loadSelectedSchool();

    setState(() {
      loading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: <Widget>[
                          const SizedBox(height: 5),
                          (picurl != null && picurl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: "$pic$picurl",
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 70),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                )
                              : const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Icon(Icons.error),
                                ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'STUDENT PORTAL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: schoolColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: schoolColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: schoolColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchoolScreen(),
                              ),
                            );
                          },
                          splashColor: schoolColor.withOpacity(0.3),
                          child: Text(
                            'Select School',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              color: schoolColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
