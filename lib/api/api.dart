// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';

// class CallApi {
//   final String _mainDomain = "https://app-ldcu.essentiel.ph/";
//   // final String _mainDomain = "http://192.168.50.13:8000/";
//   // final String _mainDomain = "https://assure.essentiel.ph/";

//   final String _esDomain = "api/mobile/api_login";
//   final String _enrollmentInfo = "api/mobile/api_enrollmentinfo";
//   final String _enrollmentData = "api/mobile/api_enrollmentdata";
//   final String _billingInfo = "/api/mobile/api_billinginfo";
//   final String _studLedger = "/api/mobile/api_studledger";
//   final String _picUrl = "api/mobile/api_picurl";
//   final String _sf9Attendance = "api/mobile/api_sf9attendance";
//   final String _studGrade = "api/mobile/api_getgrade";
//   final String _getSchedule = "api/mobile/api_getschedule";
//   final String _events = "/api/mobile/api_get_events";
//   final String _attendance = "api/mobile/student_attendance";
//   final String _studeObservedValues = "api/mobile/student_observedvalues";
//   final String _schoolinfo = "api/mobile/schoolinfo";

//   final String _updatePushStatus = "api/mobile/api_update_pushstatus";
//   final String _transactions = "api/mobile/api_get_transactions";
//   final String _saveToken = "api/mobile/api_save_fcmtoken";
//   final String _deleteToken = "api/mobile/deleteFcmToken";
//   final String _onlinePaymentsOptions =
//       "api/mobile/api_get_onlinepaymentoptions";
//   final String _sendPayment = "api/mobile/api_send_payment";
//   final String _onlinePayments = "api/mobile/api_get_onlinepayments";
//   final String _smsBunker = "api/mobile/api_get_smsbunker";
//   final String _reportCardBE = "/api/mobile/api_enrollment_reportcard";
//   final String _studentAttendance = "/api/mobile/api_attendance";
//   final String _observedValues = "/api/mobile/api_observedvalues";
//   final String _scholarshipSetup = "/api/mobile/api_getscholarshipsetup";
//   final String _scholarhip = "/api/mobile/api_getscholarship";
//   final String _requirement = "/api/mobile/api_getrequirement";
//   final String _deleteScholarship = "/api/mobile/api_delscholarship";

//   getDeleteScholarship(id) async {
//     var fullUrl = '$_mainDomain$_deleteScholarship?id=$id';
//     return await http.post(
//       Uri.parse(fullUrl),
//     );
//   }

//   getRequirement(id) async {
//     var fullUrl = '$_mainDomain$_requirement?id=$id';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getScholarshipSetup() async {
//     var fullUrl = '$_mainDomain$_scholarshipSetup';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getScholarship(studid) async {
//     var fullUrl = '$_mainDomain$_scholarhip?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getObservedValues(studid) async {
//     var fullUrl = '$_mainDomain$_observedValues?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getStudentAttendance(studid) async {
//     var fullUrl = '$_mainDomain$_studentAttendance?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getReportCardBE(studid, syid) async {
//     var fullUrl = '$_mainDomain$_reportCardBE?studid=$studid&syid=$syid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getSchoolInfo() async {
//     var fullUrl = '$_mainDomain$_schoolinfo';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getSmsBunker(studid) async {
//     var fullUrl = '$_mainDomain$_smsBunker?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getOnlinePayments(sid) async {
//     var fullUrl = '$_mainDomain$_onlinePayments?sid=$sid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   Future<http.StreamedResponse> getSendPayment(
//     String studid,
//     String paymentType,
//     String amount,
//     String transDate,
//     String refNum,
//     String opcontact,
//     String syid,
//     String semid,
//     File? receiptImageFile,
//   ) async {
//     var fullUrl = Uri.parse('$_mainDomain$_sendPayment');

//     var request = http.MultipartRequest('POST', fullUrl);

//     request.fields['studid'] = studid;
//     request.fields['paymentType'] = paymentType;
//     request.fields['amount'] = amount;
//     request.fields['transDate'] = transDate;
//     request.fields['refNum'] = refNum;
//     request.fields['opcontact'] = opcontact;
//     request.fields['syid'] = syid;
//     request.fields['semid'] = semid;

//     if (receiptImageFile != null) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'recieptImage',
//         receiptImageFile.path,
//       ));
//     }

//     return await request.send();
//   }

//   getOnlinePaymentsOptions(id) async {
//     var fullUrl = '$_mainDomain$_onlinePaymentsOptions?id=$id';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getDeleteToken(studid, type, fcmtoken) async {
//     var fullUrl =
//         '$_mainDomain$_deleteToken?studid=$studid&type=$type&fcmtoken=$fcmtoken';
//     return await http.post(
//       Uri.parse(fullUrl),
//     );
//   }

//   getSaveToken(int studid, int type, String fcmtoken) async {
//     var fullUrl =
//         '$_mainDomain$_saveToken?studid=$studid&type=$type&fcmtoken=$fcmtoken';
//     return await http.post(
//       Uri.parse(fullUrl),
//     );
//   }

//   getUpdatePushStatus(id, studid, pushstatus) async {
//     var fullUrl =
//         '$_mainDomain$_updatePushStatus?id=$id&studid=$studid&pushstatus=$pushstatus';
//     return await http.post(
//       Uri.parse(fullUrl),
//     );
//   }

//   getTransactions(studid) async {
//     var fullUrl = '$_mainDomain$_transactions?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getAttendance(
//     studid,
//     syid,
//     levelid,
//   ) async {
//     var fullUrl =
//         '$_mainDomain$_attendance?studid=$studid&syid=$syid&levelid=$levelid&semid=1';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getStudentObservedValues(syid, studid, levelid) async {
//     var fullUrl =
//         '$_mainDomain$_studeObservedValues?syid=$syid&studid=$studid&levelid=$levelid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getEvents(syid) async {
//     var fullUrl = '$_mainDomain$_events?syid=$syid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getStudGrade(studid, gradelevel, syid, sectionid, strand, semid) async {
//     var fullUrl =
//         '$_mainDomain$_studGrade?studid=$studid&gradelevel=$gradelevel&syid=$syid&sectionid=$sectionid&strand=$strand&semid=$semid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getPicURL(studid) async {
//     var fullUrl = '$_mainDomain$_picUrl?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getSF9Attendance(studid, syid, gradelevel, sectionid, strand) async {
//     var fullUrl =
//         '$_mainDomain$_sf9Attendance?studid=$studid&syid=$syid&gradelevel=$gradelevel&sectionid=$sectionid&strand=$strand';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getStudLedger(studid, syid, semid) async {
//     var fullUrl =
//         '$_mainDomain$_studLedger?studid=$studid&syid=$syid&semid=$semid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getEnrollmentInfo(studid) async {
//     var fullUrl = '$_mainDomain$_enrollmentInfo?studid=$studid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getEnrollmentData(studid, syid, semid) async {
//     var fullUrl =
//         '$_mainDomain$_enrollmentData?studid=$studid&syid=$syid&semid=$semid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getBillingInfo(String studid) async {
//     var fullUrl =
//         '$_mainDomain$_billingInfo?studid=$studid&syid=1&semid=1&monthid=10';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getSchedule(
//     studid,
//     syid,
//     semid,
//     sectionid,
//     levelid,
//   ) async {
//     var fullUrl =
//         '$_mainDomain$_getSchedule?studid=$studid&syid=$syid&semid=$semid&sectionid=$sectionid&levelid=$levelid';
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }

//   getImage() {
//     return _mainDomain;
//   }

//   postData(data, apiUrl) async {}

//   login(username, pword) async {
//     var fullUrl = '$_mainDomain$_esDomain?&username=$username&pword=$pword';
//     return await http.get(Uri.parse(fullUrl));
//   }

//   getToken() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var token = localStorage.getString('token');
//     print('Retrieved token: $token');
//     return token;
//   }

//   getDomain() async {
//     return _mainDomain;
//   }

//   getPublicData(apiUrl) async {
//     var fullUrl = _esDomain + apiUrl;
//     return await http.get(
//       Uri.parse(fullUrl),
//     );
//   }
// }

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';

class CallApi {
  String? _mainDomain = '';

  final String _esDomain = "api/mobile/api_login";
  final String _enrollmentInfo = "/api/mobile/api_enrollmentinfo";
  final String _enrollmentData = "/api/mobile/api_enrollmentdata";
  final String _billingInfo = "/api/mobile/api_billinginfo";
  final String _studLedger = "/api/mobile/api_studledger";
  final String _picUrl = "/api/mobile/api_picurl";
  final String _sf9Attendance = "api/mobile/api_sf9attendance";
  final String _studGrade = "/api/mobile/api_getgrade";
  final String _getSchedule = "/api/mobile/api_getschedule";
  final String _events = "/api/mobile/api_get_events";
  final String _attendance = "/api/mobile/student_attendance";
  final String _studeObservedValues = "/api/mobile/student_observedvalues";
  final String _schoolinfo = "/api/mobile/schoolinfo";

  final String _updatePushStatus = "/api/mobile/api_update_pushstatus";
  final String _transactions = "/api/mobile/api_get_transactions";
  final String _saveToken = "/api/mobile/api_save_fcmtoken";
  final String _deleteToken = "/api/mobile/deleteFcmToken";
  final String _onlinePaymentsOptions =
      "/api/mobile/api_get_onlinepaymentoptions";
  final String _sendPayment = "/api/mobile/api_send_payment";
  final String _onlinePayments = "/api/mobile/api_get_onlinepayments";
  final String _smsBunker = "/api/mobile/api_get_smsbunker";
  final String _reportCardBE = "/api/mobile/api_enrollment_reportcard";
  final String _studentAttendance = "/api/mobile/api_attendance";
  final String _observedValues = "/api/mobile/api_observedvalues";
  final String _scholarshipSetup = "/api/mobile/api_getscholarshipsetup";
  final String _scholarhip = "/api/mobile/api_getscholarship";
  final String _requirement = "/api/mobile/api_getrequirement";
  final String _deleteScholarship = "/api/mobile/api_delscholarship";
  final String _saveScholarship = "/api/mobile/api_savescholarship";
  final String _uploadRequirement = "/api/mobile/api_uploadrequirement";
  final String _yearSem = "/api/mobile/api_sysem";
  final String _enrolledStud = "/api/mobile/api_enrolledstud";
  final String _tapHistory = "/api/mobile/api_get_taphistory";

  CallApi() {
    _initializeMainDomain();
    _ensureDomainInitialized();
  }

  Future<void> _initializeMainDomain() async {
    final prefs = await SharedPreferences.getInstance();
    _mainDomain = prefs.getString('selectedSchool');
  }

  Future<void> _ensureDomainInitialized() async {
    if (_mainDomain == null) {
      await _initializeMainDomain();
      if (_mainDomain == null) {
        print('Main domain not initialized');
      }
    }
  }

  getUploadRequirement(file) async {
    await _ensureDomainInitialized();
    var url = '$_mainDomain$_uploadRequirement';

    Dio dio = Dio();

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });

    var response = await dio.post(url, data: formData);
    return response;
  }

  getSaveScholarship(int scholarshipId, int semesterId, int studId,
      List<Map<String, dynamic>> requirementsArray, String remarks) async {
    await _ensureDomainInitialized();
    var url = '$_mainDomain$_saveScholarship';

    Map<String, dynamic> data = {
      'scholarship_id': scholarshipId.toString(),
      'semesterid': semesterId.toString(),
      'studid': studId.toString(),
      'requirementsArray': jsonEncode(requirementsArray),
      'remarks': remarks
    };

    return await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  getEnrolledStud(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_enrolledStud?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getYearandSem() async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_yearSem';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getDeleteScholarship(id) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_deleteScholarship?id=$id';
    return await http.post(
      Uri.parse(fullUrl),
    );
  }

  getRequirement(id) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_requirement?id=$id';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getScholarshipSetup() async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_scholarshipSetup';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getScholarship(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_scholarhip?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getObservedValues(studid, syid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_observedValues?studid=$studid&syid=$syid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudentAttendance(studid, syid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_studentAttendance?studid=$studid&syid=$syid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getReportCardBE(studid, syid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_reportCardBE?studid=$studid&syid=$syid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSchoolInfo() async {
    await _ensureDomainInitialized();
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_schoolinfo';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSmsBunker(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_smsBunker?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getOnlinePayments(sid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_onlinePayments?sid=$sid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  Future<http.StreamedResponse> getSendPayment(
    String studid,
    String paymentType,
    String amount,
    String transDate,
    String refNum,
    String opcontact,
    String syid,
    String semid,
    File? receiptImageFile,
  ) async {
    await _ensureDomainInitialized();
    var fullUrl = Uri.parse('$_mainDomain$_sendPayment');

    var request = http.MultipartRequest('POST', fullUrl);

    request.fields['studid'] = studid;
    request.fields['paymentType'] = paymentType;
    request.fields['amount'] = amount;
    request.fields['transDate'] = transDate;
    request.fields['refNum'] = refNum;
    request.fields['opcontact'] = opcontact;
    request.fields['syid'] = syid;
    request.fields['semid'] = semid;

    if (receiptImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'recieptImage',
        receiptImageFile.path,
      ));
    }

    return await request.send();
  }

  getOnlinePaymentsOptions(id) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_onlinePaymentsOptions?id=$id';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getDeleteToken(studid, type, fcmtoken) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_deleteToken?studid=$studid&type=$type&fcmtoken=$fcmtoken';
    return await http.post(
      Uri.parse(fullUrl),
    );
  }

  getSaveToken(int studid, int type, String fcmtoken) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_saveToken?studid=$studid&type=$type&fcmtoken=$fcmtoken';
    return await http.post(
      Uri.parse(fullUrl),
    );
  }

  getUpdatePushStatus(id, studid, pushstatus) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_updatePushStatus?id=$id&studid=$studid&pushstatus=$pushstatus';
    return await http.post(
      Uri.parse(fullUrl),
    );
  }

  getTransactions(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_transactions?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getAttendance(
    studid,
    syid,
    levelid,
  ) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_attendance?studid=$studid&syid=$syid&levelid=$levelid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudentObservedValues(syid, studid, levelid) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_studeObservedValues?syid=$syid&studid=$studid&levelid=$levelid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEvents(syid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_events?syid=$syid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getTapHistory(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_tapHistory?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudGrade(studid, gradelevel, syid, sectionid, strand, semid) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_studGrade?studid=$studid&gradelevel=$gradelevel&syid=$syid&sectionid=$sectionid&strand=$strand&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getPicURL(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_picUrl?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSF9Attendance(studid, syid, gradelevel, sectionid, strand) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_sf9Attendance?studid=$studid&syid=$syid&gradelevel=$gradelevel&sectionid=$sectionid&strand=$strand';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudLedger(studid, syid, semid) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_studLedger?studid=$studid&syid=$syid&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEnrollmentInfo(studid) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_enrollmentInfo?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEnrollmentData(studid, syid, semid) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_enrollmentData?studid=$studid&syid=$syid&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getBillingInfo(String studid) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_billingInfo?studid=$studid&syid=1&semid=1&monthid=10';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSchedule(
    studid,
    syid,
    semid,
    sectionid,
    levelid,
  ) async {
    await _ensureDomainInitialized();
    var fullUrl =
        '$_mainDomain$_getSchedule?studid=$studid&syid=$syid&semid=$semid&sectionid=$sectionid&levelid=$levelid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  // getImage() async {
  //   return _mainDomain;
  // }

  Future<String?> getImage() async {
    if (_mainDomain == null) {
      await _ensureDomainInitialized();
    }
    return _mainDomain;
  }

  postData(data, apiUrl) async {}

  login(username, pword) async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain$_esDomain?&username=$username&pword=$pword';

    print(fullUrl);
    return await http.get(Uri.parse(fullUrl));
  }

  getToken() async {
    await _ensureDomainInitialized();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    print('Retrieved token: $token');
    return token;
  }

  getDomain() async {
    await _ensureDomainInitialized();
    var fullUrl = '$_mainDomain';
    return fullUrl;
  }

  getPublicData(apiUrl) async {
    await _ensureDomainInitialized();
    var fullUrl = _esDomain + apiUrl;
    return await http.get(
      Uri.parse(fullUrl),
    );
  }
}
