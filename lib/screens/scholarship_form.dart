import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:pushtrial/models/scholarship.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ScholarshipFormScreen extends StatefulWidget {
  const ScholarshipFormScreen({super.key});
  @override
  State<ScholarshipFormScreen> createState() => ScholarshipFormScreenState();
}

class ScholarshipFormScreenState extends State<ScholarshipFormScreen> {
  User user = UserData.myUser;
  int studid = 0;
  List<ScholarshipSetup> _scholarshipSetup = [];
  List<Requirement> _requirement = [];
  int? selectedsetup;
  int? selectedSem;
  List<Map<String, dynamic>> _semesters = [
    {'id': 1, 'description': '1st Semester'},
    {'id': 2, 'description': '2nd Semester'},
  ];
  String? selectedrequirement;
  bool loading = true;
  Map<int, String?> selectedFiles = {};

  final TextEditingController _remarksController = TextEditingController();

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

  Future<void> selectFile(int requirementId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String fileName = result.files.single.path!;
      setState(() {
        selectedFiles[requirementId] = fileName;
      });
    } else {
      print('No file selected.');
    }
  }

  Future<void> _submitForm() async {
    try {
      List<Map<String, dynamic>> requirementsArray = [];

      for (var req in _requirement) {
        final filePath = selectedFiles[req.id];
        if (filePath != null) {
          File file = File(filePath);

          final response = await CallApi().getUploadRequirement(file);

          if (response.statusCode == 200) {
            final data = response.data;
            String fileUrl = data['url'];

            requirementsArray.add({'dataId': req.id, 'value': fileUrl});
          } else {
            throw Exception('Failed to upload file for requirement ${req.id}');
          }
        }
      }

      String remarks = _remarksController.text;

      final response = await CallApi().getSaveScholarship(
        selectedsetup!,
        selectedSem!,
        studid,
        requirementsArray,
        remarks,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scholarship form submitted successfully!'),
          ),
        );
      } else {
        throw Exception('Failed to submit scholarship form');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting form: $e')));
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
    await getUser();
    await getScholarshipSetup();
    getSchoolInfo();
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

  Future<void> getScholarshipSetup() async {
    final response = await CallApi().getScholarshipSetup();
    Iterable list = json.decode(response.body);
    setState(() {
      _scholarshipSetup = list
          .map((model) => ScholarshipSetup.fromJson(model))
          .toList();
    });
  }

  Future<void> getRequirement() async {
    final response = await CallApi().getRequirement(selectedsetup!);
    Iterable list = json.decode(response.body);
    setState(() {
      _requirement = list.map((model) => Requirement.fromJson(model)).toList();
    });
  }

  Future<void> _downloadFile(String relativeUrl) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          return;
        }
      }

      final baseUrl = await CallApi().getDomain();
      final fullUrl = '$baseUrl$relativeUrl';

      final fileExtension = fullUrl.split('.').last.toLowerCase();

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      Dio dio = Dio();
      Response<ResponseBody> response = await dio.get<ResponseBody>(
        fullUrl,
        options: Options(responseType: ResponseType.stream),
      );

      final file = File(filePath);
      final raf = file.openSync(mode: FileMode.write);
      response.data!.stream.listen(
        (List<int> chunk) {
          raf.writeFromSync(chunk);
        },
        onDone: () async {
          await raf.close();

          if (fileExtension == 'pdf') {
            await launchUrl(Uri.file(filePath));
          } else if (fileExtension == 'jpg' || fileExtension == 'png') {
            await launchUrl(Uri.file(filePath));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unsupported file type')),
            );
          }
        },
        onError: (e) {
          print('Error downloading file: $e');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCHOLARSHIP FORM',
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
              padding: const EdgeInsets.only(
                top: 20,
                left: 30,
                right: 30,
                bottom: 30,
              ),
              child: Column(
                children: [
                  DropdownButtonFormField2<int>(
                    value: selectedsetup,
                    items: _scholarshipSetup
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.id,
                            child: Text(
                              option.description,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedsetup = value;

                        getRequirement();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name of Scholarship Applied for',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedsetup != null && _requirement.isNotEmpty)
                    Card(
                      child: Column(
                        children: _requirement
                            .map(
                              (req) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Document Name:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      req.description,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    if (req.fileurl.isNotEmpty)
                                      InkWell(
                                        onTap: () {
                                          _downloadFile(req.fileurl);
                                        },
                                        child: const Text(
                                          'Download File Attachment',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => selectFile(req.id),
                                      child: const Text('Select File'),
                                    ),
                                    if (selectedFiles[req.id] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          ' ${selectedFiles[req.id]}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 15.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            controller: _remarksController,
                                            decoration: const InputDecoration(
                                              labelText: 'Remarks',
                                              labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (selectedsetup != null && _requirement.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField2<int>(
                          value: selectedSem,
                          items: _semesters
                              .map(
                                (sem) => DropdownMenuItem<int>(
                                  value: sem['id'],
                                  child: Text(
                                    sem['description'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSem = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: schoolColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'SUBMIT',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
