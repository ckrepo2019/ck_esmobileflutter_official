import 'package:flutter/material.dart';
import 'package:pushtrial/schools/api/school_api.dart';
import 'package:pushtrial/schools/models/schools.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pushtrial/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SchoolScreen extends StatefulWidget {
  @override
  _SchoolScreenState createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  List<School> schoolNames = [];
  List<School> filteredSchoolNames = [];
  String? selectedSchool;
  String host = SchoolApi().getImage();
  TextEditingController searchController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    searchController.addListener(_filterSchools);
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getSchools();

    setState(() {
      loading = false;
    });
  }

  Future<void> getSchools() async {
    // final response = await SchoolApi().getSchoolList();

    var dummyList = [
      // {
      //   "id": 85,
      //   "schoolabrv": "BCC",
      //   "schoolname": "BINALBAGAN CATHOLIC COLLEGE, INC.",
      //   "eslink": "http://10.0.0.192:8000/",
      //   "github_repo": null,
      //   "deleted": 0,
      //   "createdby": 0,
      //   "updatedby": 0,
      //   "deletedby": 0,
      //   "createddatetime": "2024-10-30 10:21:38",
      //   "updateddatetime": "2026-01-30 14:58:10",
      //   "deleteddatetime": null,
      //   "schoollogo": "/schoollistlogo/1734413588.png",
      //   "withSync": 0,
      //   "projectsetup": 1,
      //   "withmobile": 0,
      //   "anydesk": null,
      //   "withps": 1,
      //   "withgs": 1,
      //   "withhs": 1,
      //   "withshs": 1,
      //   "withcollege": 1,
      //   "tapping": "1 990 799 740 (1516512695-new) (Main-1) 1 260 203 013 (Main-2) 1 526 421 65 7 (Main-3) 1823508370(Annex)",
      //   "anydesk_ip": null,
      //   "tapping_ip": null
      // },
      {
        "id": 37,
        "schoolabrv": "DCC",
        "schoolname": "DAVAO CENTRAL COLLEGE",
        // "eslink": "https://dcc-essentiel.ckgroup.ph/",
         "eslink": "http://10.0.0.192:8000/",
        "github_repo": null,
        "deleted": 0,
        "createdby": 0,
        "updatedby": 0,
        "deletedby": 0,
        "createddatetime": "2022-11-22 11:29:25",
        "updateddatetime": "2025-08-11 08:02:06",
        "deleteddatetime": null,
        "schoollogo": "/schoollistlogo/1752106534.png",
        "withSync": 0,
        "projectsetup": 2,
        "withmobile": 0,
        "anydesk": "1336189654",
        "withps": 1,
        "withgs": 1,
        "withhs": 1,
        "withshs": 1,
        "withcollege": 1,
        "tapping": "836559086 (Main) 659496857 (updated) / (Rasay) new(674109763)",
        "anydesk_ip": "1336189654 1488330847 (old server)",
        "tapping_ip": "192.168.103.240 (main)"
      },
    ];

    // Iterable list = json.decode(response.body.toString());
    Iterable list = dummyList.map((item) => item as Map<String, dynamic>);

    setState(() {
      schoolNames = list.map((model) => School.fromJson(model)).toList();
      schoolNames.sort((a, b) => a.schoolname.compareTo(b.schoolname));
      filteredSchoolNames = schoolNames;
    });
  }

  void _filterSchools() {
    setState(() {
      filteredSchoolNames = schoolNames
          .where(
            (school) => school.schoolname.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  Future<void> _storeSelectedSchool(String eslink) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSchool', eslink);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: height * 0.4,
                width: double.infinity,
                color: Colors.white,
                child: Image.asset('assets/2.webp', fit: BoxFit.contain),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: filteredSchoolNames.length,
                      itemBuilder: (context, index) {
                        final school = filteredSchoolNames[index];
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedSchool = school.eslink;
                            });

                            if (selectedSchool != null &&
                                selectedSchool!.isNotEmpty) {
                              await _storeSelectedSchool(selectedSchool!);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            } else {
                              print('Selected school is null or empty.');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: "$host${school.schoollogo}",
                                    width: 80,
                                    height: 80,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          'assets/cklogo.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  school.schoolname,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: height * 0.4 - 30,
            left: 30,
            right: 30,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search School',
                    labelStyle: TextStyle(fontSize: 12),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
