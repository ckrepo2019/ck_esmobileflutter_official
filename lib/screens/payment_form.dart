import 'dart:typed_data';
// import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/payments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/school_info.dart';
// import 'package:image/image.dart' as img;
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;

class PaymentForm extends StatefulWidget {
  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  User user = UserData.myUser;
  String? _selectedPaymentType;
  String? _selectedSY;
  String? _selectedSem;
  List<PaymentOptions> _paymentOptions = [];
  List<Bank> _bankOptions = [];
  List<SY> _syOptions = [];
  List<Semester> _semesterOptions = [];
  List<Contact> _contactOptions = [];
  int id = 0;
  Uint8List? _receiptImageBytes;
  File? _receiptImageFile;
  bool loading = true;
  List<SchoolInfo> schoolInfo = [];
  Color schoolColor = const Color.fromARGB(0, 255, 255, 255);

  final List<String> _messageReceiverOptions = [
    'Student',
    'Mother',
    'Father',
    'Guardian',
  ];

  String? getContactNumber(String receiver) {
    if (_contactOptions.isEmpty) return null;

    final contact = _contactOptions.first;
    switch (receiver) {
      case 'Student':
        return contact.contactno;
      case 'Mother':
        return contact.mcontactno;
      case 'Father':
        return contact.fcontactno;
      case 'Guardian':
        return contact.gcontactno;
      default:
        return null;
    }
  }

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _transactionDateController =
      TextEditingController();
  final TextEditingController _referenceNumberController =
      TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _messageReceiverController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

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
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getUser();
    await getOnlinePayments();
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
      id = user.id;
    });
  }

  Future<void> getOnlinePayments() async {
    final response = await CallApi().getOnlinePaymentsOptions(id);
    final Map<String, dynamic> responseData = json.decode(response.body);

    _paymentOptions = (responseData['onlinepaymentoptions'] as List)
        .map((data) => PaymentOptions.fromJson(data))
        .toList();

    _bankOptions = (responseData['bank'] as List)
        .map((data) => Bank.fromJson(data))
        .toList();

    _syOptions = (responseData['sy'] as List)
        .map((data) => SY.fromJson(data))
        .toList();

    _semesterOptions = (responseData['semester'] as List)
        .map((data) => Semester.fromJson(data))
        .toList();

    _contactOptions = (responseData['contact'] as List)
        .map((data) => Contact.fromJson(data))
        .toList();

    if (_paymentOptions.isNotEmpty) {
      _selectedPaymentType = _paymentOptions.first.description;
    }

    var activeYear = _syOptions.firstWhere((year) => year.isactive == 1);
    var activeSem = _semesterOptions.firstWhere((sem) => sem.isactive == 1);

    if (_syOptions.isNotEmpty && _semesterOptions.isNotEmpty) {
      _selectedSY = activeYear.sydesc;
      _selectedSem = activeSem.semester;
    }

    setState(() {});
  }

  Future<Uint8List?> pickImage() async {
    // Use file_picker for gallery access (Google Play compliant)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final imageFile = File(result.files.single.path!);
      return await imageFile.readAsBytes();
    }
    return null;
  }

  Future<void> _handlePickImage() async {
    // Use file_picker for image selection (Google Play compliant)
    File? imageFile;
    Uint8List? imageBytes;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        imageFile = File(result.files.single.path!);
        imageBytes = await imageFile.readAsBytes();

        setState(() {
          _receiptImageBytes = imageBytes;
          _receiptImageFile = imageFile;
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error selecting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_selectedPaymentType == null ||
        _transactionDateController.text.isEmpty ||
        _referenceNumberController.text.isEmpty ||
        _paymentAmountController.text.isEmpty ||
        _messageReceiverController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields.'),
          backgroundColor: schoolColor,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String amount = _paymentAmountController.text;
      String transDate = _transactionDateController.text;
      String refNum = _referenceNumberController.text;
      String opcontact = _contactNumberController.text;
      String syid = _syOptions
          .firstWhere((sy) => sy.sydesc == _selectedSY)
          .id
          .toString();
      String semid = _semesterOptions
          .firstWhere((sem) => sem.semester == _selectedSem)
          .id
          .toString();

      String? paymentType = _paymentOptions
          .firstWhere((option) => option.description == _selectedPaymentType)
          .id
          .toString();

      var response = await CallApi().getSendPayment(
        id.toString(),
        paymentType,
        amount,
        transDate,
        refNum,
        opcontact,
        syid,
        semid,
        _receiptImageFile,
      );

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        print('Response: $responseString');

        if (responseString.trim().startsWith('{')) {
          var responseData = json.decode(responseString);

          if (responseData['status'] == 0 &&
              responseData['message'] == 'Reference Number already exists') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reference Number already exists.'),
                backgroundColor: schoolColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment submitted successfully!'),
                backgroundColor: Color.fromARGB(255, 73, 136, 75),
              ),
            );
            _transactionDateController.clear();
            _referenceNumberController.clear();
            _paymentAmountController.clear();
            _messageReceiverController.clear();
            _contactNumberController.clear();
            _receiptImageFile = null;
            _receiptImageBytes = null;
            setState(() {
              _selectedPaymentType = null;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _transactionDateController.clear();
          _referenceNumberController.clear();
          _paymentAmountController.clear();
          _messageReceiverController.clear();
          _contactNumberController.clear();
          _receiptImageFile = null;
          _receiptImageBytes = null;
          setState(() {
            _selectedPaymentType = null;
          });
        }
      } else {
        final responseString = await response.stream.bytesToString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit payment: $responseString'),
            backgroundColor: schoolColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An error occurred. Please try again later.'),
          backgroundColor: schoolColor,
        ),
      );
    } finally {
      setState(() {
        loading = false;
        _receiptImageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ONLINE PAYMENT FORM',
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
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: DropdownButtonFormField2<String>(
                            value: _selectedSY,
                            items: _syOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.sydesc,
                                    child: Text(
                                      option.sydesc,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSY = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'School Year',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: DropdownButtonFormField2<String>(
                            value: _selectedSem,
                            items: _semesterOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.semester,
                                    child: Text(
                                      option.semester,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSem = value!;
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                      value: _selectedPaymentType,
                      items: _paymentOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option.description,
                              child: Text(
                                option.description,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      buttonStyleData: const ButtonStyleData(height: 20),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedPaymentType == 'BANK') ...[
                      DropdownButtonFormField2<String>(
                        items: _bankOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.optionDescription,
                                child: Text(
                                  option.optionDescription,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _bankNameController.text = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.account_balance,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _transactionDateController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Transaction Date',
                        hintText: "MM/DD/YYYY",
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.date_range, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _referenceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paymentAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.money, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                      items: _messageReceiverOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _messageReceiverController.text = value!;
                          _contactNumberController.text = getContactNumber(
                            value,
                          )!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Message Receiver',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.message, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _handlePickImage,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _receiptImageBytes != null
                                    ? 'Receipt image selected'
                                    : 'Select Receipt Image from Gallery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _receiptImageBytes != null
                                      ? Colors.green
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            if (_receiptImageBytes != null)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_receiptImageBytes != null)
                      Image.memory(
                        _receiptImageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: schoolColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit Payment',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
  }
}
