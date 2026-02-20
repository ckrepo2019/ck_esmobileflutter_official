import 'package:flutter/material.dart';
import 'payment_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/models/transactions.dart';
import 'package:pushtrial/api/api.dart';
import 'package:intl/intl.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/onlinepayments.dart';
import 'package:pushtrial/models/school_info.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/year_sem.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  User user = UserData.myUser;
  int syid = 0; // 0 means "All School Years"
  int semid = 1;
  int id = 0;
  String sid = '0';
  String amountpaid = '0.00';
  String selectedYear = '0'; // Default to "All"
  String selectedSem = '';
  List<Transactions> trans = [];
  List<Payments> payments = [];
  List<SchoolYear> schoolYear = [];
  List<Sem> schoolSem = [];

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
    super.initState();
    _initializeData();
    _tabController = TabController(length: 2, vsync: this);

    _tabController!.addListener(() {
      setState(() {});
    });
  }

  void _initializeDummyData() {
    // Initialize with dummy school year data
    schoolYear = [
      SchoolYear(id: 1, sydesc: '2024-2025', sdate: '2024-06-01', edate: '2025-03-31', isactive: 1),
      SchoolYear(id: 2, sydesc: '2023-2024', sdate: '2023-06-01', edate: '2024-03-31', isactive: 0),
      SchoolYear(id: 3, sydesc: '2022-2023', sdate: '2022-06-01', edate: '2023-03-31', isactive: 0),
    ];
  }

  Future<void> _initializeData() async {
    await getUser();
    await getYearandSem();
    getOnlinePayments();
    getSchoolInfo();
    getTransactions();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data in payment section screen: $user');

    setState(() {
      id = user.id;
      sid = user.sid!;
    });
  }

  Future<void> getYearandSem() async {
    try {
      final response = await CallApi().getYearandSem();
      final Map<String, dynamic> responseData = json.decode(response.body);

      schoolYear = (responseData['sy'] as List)
          .map((data) => SchoolYear.fromJson(data))
          .toList();
      schoolSem = (responseData['semester'] as List)
          .map((data) => Sem.fromJson(data))
          .toList();

      schoolYear.sort((a, b) => a.sydesc.compareTo(b.sydesc));

      setState(() {
        // Default to "All School Years" (syid = 0)
        selectedYear = '0';
        syid = 0;
      });

      print('School Year loaded with "All" selected by default');
    } catch (e) {
      print('Error loading school year and semester: $e');
      // Fallback to dummy data if API fails
      _initializeDummyData();
    }
  }

  getTransactions() async {
    final response = await CallApi().getTransactions(id);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('No Transactions found');
        return;
      }
      Iterable list = json.decode(response.body);

      List<Transactions> allTransactions = list
          .map((model) => Transactions.fromJson(model))
          .toList();

      // Filter transactions by selected school year (syid)
      // If syid is 0, show all transactions
      List<Transactions> filteredTransactions = syid == 0
          ? allTransactions
          : allTransactions
              .where((transaction) => transaction.syid == syid)
              .toList();

      filteredTransactions.sort(
        (a, b) =>
            DateTime.parse(b.transdate).compareTo(DateTime.parse(a.transdate)),
      );

      setState(() {
        trans = filteredTransactions;

        print("User ID: $id");
        print("Selected syid: $syid");
        print("Filter: ${syid == 0 ? 'All School Years' : 'School Year ID: $syid'}");
        print("Total transactions: ${filteredTransactions.length}");
      });
    }
  }

  getOnlinePayments() async {
    final response = await CallApi().getOnlinePayments(sid);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('No data returned');
        return;
      }
      Iterable list = json.decode(response.body);
      
      List<Payments> allPayments = list.map((model) => Payments.fromJson(model)).toList();
      
      // Filter payments by selected school year (syid)
      // If syid is 0, show all payments
      List<Payments> filteredPayments = syid == 0
          ? allPayments
          : allPayments
              .where((payment) => payment.syid == syid)
              .toList();
      
      setState(() {
        payments = filteredPayments;
      });

      print("Selected syid: $syid");
      print("Filter: ${syid == 0 ? 'All School Years' : 'School Year ID: $syid'}");
      print("Total payments: ${filteredPayments.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'PAYMENT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: schoolColor,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                height: 30,
                margin: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: schoolColor,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontSize: 12),
                  tabs: const [
                    Tab(text: 'Transactions'),
                    Tab(text: 'Uploaded Payment'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButtonFormField2<String>(
                value: selectedYear,
                hint: const Text(
                  'Select School Year',
                  style: TextStyle(fontSize: 10),
                ),
                items: [
                  // "All School Years" option
                  const DropdownMenuItem(
                    value: '0',
                    child: Text(
                      'All School Years',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  // Individual school years
                  ...schoolYear
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.id.toString(),
                          child: Text(
                            option.sydesc,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      )
                      .toList(),
                ]
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                      syid = int.parse(value);
                    });
                    print('Selected School Year: $selectedYear, syid: $syid');
                    // Fetch transactions and online payments for the selected year
                    getTransactions();
                    getOnlinePayments();
                  }
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildTransactionsTab(), _buildUploadedPaymentTab()],
              ),
            ),
          ],
        ),
        floatingActionButton: _tabController?.index == 1
            ? ClipOval(
                child: Material(
                  color: schoolColor,
                  child: InkWell(
                    splashColor: schoolColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentForm()),
                      );
                    },
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUploadedPaymentTab() {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final amountFormat = NumberFormat('#,##0.00', 'en_US');

    payments.sort(
      (a, b) => DateTime.parse(
        b.paymentDate,
      ).compareTo(DateTime.parse(a.paymentDate)),
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomRefreshIndicator(
        onRefresh: () async {
          await getOnlinePayments();
        },
        builder: (context, child, controller) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              if (controller.isLoading)
                const Positioned(top: 20.0, child: CircularProgressIndicator()),
              Transform.translate(
                offset: Offset(0, controller.value * 100),
                child: child,
              ),
            ],
          );
        },
        child: payments.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -80),
                      child: Image.asset('assets/payment.png'),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -100),
                      child: Text(
                        "No uploaded payments found.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: schoolColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  final formattedDate = dateFormat.format(
                    DateTime.parse(payment.paymentDate),
                  );
                  final double amountPaid = double.parse(payment.amount);
                  final formattedAmount = amountFormat.format(amountPaid);

                  return Card(
                    margin: const EdgeInsets.all(7.0),
                    color: Colors.white,
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: ClipOval(
                            child: payment.description == 'BANK'
                                ? Container(
                                    color: Colors.grey[200],
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(
                                      Icons.account_balance,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                                  )
                                : Image.asset(
                                    payment.description == 'GCASH'
                                        ? 'assets/gcash.jpg'
                                        : 'assets/palawan.png',
                                    height: 45,
                                    width: 45,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      payment.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Php $formattedAmount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RN: ${payment.refNum}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '(${payment.getStatus()})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');
    final amountFormat = NumberFormat('#,##0.00', 'en_US');

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomRefreshIndicator(
        onRefresh: () async {
          await getTransactions();
        },
        builder: (context, child, controller) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              if (controller.isLoading)
                const Positioned(top: 20.0, child: CircularProgressIndicator()),
              Transform.translate(
                offset: Offset(0, controller.value * 100),
                child: child,
              ),
            ],
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Expanded(
              child: trans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -80),
                            child: Image.asset('assets/payment.png'),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -100),
                            child: Text(
                              "No transactions found.",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: schoolColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: trans.length,
                      itemBuilder: (context, index) {
                        final transaction = trans[index];
                        final formattedDate = dateFormat.format(
                          DateTime.parse(transaction.transdate),
                        );
                        final double amountPaid = double.parse(
                          transaction.amountpaid,
                        );
                        final formattedAmount = amountFormat.format(amountPaid);

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(7.0),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: ClipOval(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      transaction.paytype == 'CASH'
                                          ? Icons.payments
                                          : Icons.credit_score,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${transaction.paytype} - OR#: ${transaction.ornum}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Php $formattedAmount',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
