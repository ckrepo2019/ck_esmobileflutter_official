import 'dart:convert';
import '../models/schools.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolsData {
  static late SharedPreferences _preferences;
  static const _keyUser = 'schools';

  static School myUserSchool = School(
    id: 0,
    eslink: '',
    schoolabrv: '',
    schoolname: '',
    schoollogo: '',
    anydesk: '',
  );

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(School user) async {
    final json = jsonEncode(user.toJson());

    await _preferences.setString(_keyUser, json);
  }

  static Future<School> getUser() async {
    _preferences = await SharedPreferences.getInstance();
    final json = _preferences.getString(_keyUser);

    return json == null ? myUserSchool : School.fromJson(jsonDecode(json));
  }
}
