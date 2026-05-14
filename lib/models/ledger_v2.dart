class V2StudentInfo {
  final int id;
  final String sid;
  final String fullname;
  final String firstname;
  final String middlename;
  final String lastname;
  final int levelid;
  final String levelname;
  final String? programName;
  final String sectionName;
  final String granteeDescription;
  final int studentStatus;
  final String picurl;

  V2StudentInfo({
    required this.id,
    required this.sid,
    required this.fullname,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.levelid,
    required this.levelname,
    this.programName,
    required this.sectionName,
    required this.granteeDescription,
    required this.studentStatus,
    required this.picurl,
  });

  factory V2StudentInfo.fromJson(Map<String, dynamic> json) {
    return V2StudentInfo(
      id: json['id'] ?? 0,
      sid: json['sid'] ?? '',
      fullname: json['fullname'] ?? '',
      firstname: json['firstname'] ?? '',
      middlename: json['middlename'] ?? '',
      lastname: json['lastname'] ?? '',
      levelid: json['levelid'] ?? 0,
      levelname: json['levelname'] ?? '',
      programName: json['program_name'],
      sectionName: json['section_name'] ?? '',
      granteeDescription: json['grantee_description'] ?? '',
      studentStatus: json['student_status'] ?? 0,
      picurl: json['picurl'] ?? '',
    );
  }
}

class V2NestedItem {
  final int itemid;
  final String particulars;
  final double amount;
  final double payment;
  final double balance;
  final int classid;

  V2NestedItem({
    required this.itemid,
    required this.particulars,
    required this.amount,
    required this.payment,
    required this.balance,
    required this.classid,
  });

  factory V2NestedItem.fromJson(Map<String, dynamic> json) {
    return V2NestedItem(
      itemid: json['itemid'] ?? 0,
      particulars: json['particulars'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      payment: (json['payment'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      classid: json['classid'] ?? 0,
    );
  }
}

class V2SchoolFeeItem {
  final String particulars;
  final double amount;
  final double payment;
  final double balance;
  final int classid;
  final int? paymentsetupdetailId;
  final List<V2NestedItem> nestedItems;

  V2SchoolFeeItem({
    required this.particulars,
    required this.amount,
    required this.payment,
    required this.balance,
    required this.classid,
    this.paymentsetupdetailId,
    required this.nestedItems,
  });

  factory V2SchoolFeeItem.fromJson(Map<String, dynamic> json) {
    final rawNested = json['nested_items'] as List<dynamic>? ?? [];
    return V2SchoolFeeItem(
      particulars: json['particulars'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      payment: (json['payment'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      classid: json['classid'] ?? 0,
      paymentsetupdetailId: json['paymentsetupdetail_id'],
      nestedItems: rawNested.map((e) => V2NestedItem.fromJson(e)).toList(),
    );
  }
}

class V2SchoolFee {
  final int classid;
  final String particulars;
  final double totalAmount;
  final double totalPaid;
  final double totalBalance;
  final List<V2SchoolFeeItem> items;

  V2SchoolFee({
    required this.classid,
    required this.particulars,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalBalance,
    required this.items,
  });

  factory V2SchoolFee.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return V2SchoolFee(
      classid: json['classid'] ?? 0,
      particulars: json['particulars'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      totalBalance: (json['total_balance'] ?? 0).toDouble(),
      items: rawItems.map((e) => V2SchoolFeeItem.fromJson(e)).toList(),
    );
  }
}

class V2MonthlyAssessment {
  final int paymentsetupdetailId;
  final String dueDate;
  final String assessmentLabel;
  final double totalDue;
  final double totalPaid;
  final double balance;
  final String status;

  V2MonthlyAssessment({
    required this.paymentsetupdetailId,
    required this.dueDate,
    required this.assessmentLabel,
    required this.totalDue,
    required this.totalPaid,
    required this.balance,
    required this.status,
  });

  factory V2MonthlyAssessment.fromJson(Map<String, dynamic> json) {
    return V2MonthlyAssessment(
      paymentsetupdetailId: json['paymentsetupdetail_id'] ?? 0,
      dueDate: json['due_date'] ?? '',
      assessmentLabel: json['assessment_label'] ?? '',
      totalDue: (json['total_due'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class V2LedgerResponse {
  final bool success;
  final V2StudentInfo studentInfo;
  final List<V2SchoolFee> schoolFees;
  final List<V2MonthlyAssessment> monthlyAssessments;

  V2LedgerResponse({
    required this.success,
    required this.studentInfo,
    required this.schoolFees,
    required this.monthlyAssessments,
  });

  factory V2LedgerResponse.fromJson(Map<String, dynamic> json) {
    final rawFees = json['school_fees'] as List<dynamic>? ?? [];
    final rawMonthly = json['monthly_assessments'] as List<dynamic>? ?? [];
    return V2LedgerResponse(
      success: json['success'] ?? false,
      studentInfo: V2StudentInfo.fromJson(json['student_info'] ?? {}),
      schoolFees: rawFees.map((e) => V2SchoolFee.fromJson(e)).toList(),
      monthlyAssessments:
          rawMonthly.map((e) => V2MonthlyAssessment.fromJson(e)).toList(),
    );
  }

  double get grandTotalBalance =>
      schoolFees.fold(0, (sum, f) => sum + f.totalBalance);

  double get grandTotalPaid =>
      schoolFees.fold(0, (sum, f) => sum + f.totalPaid);
}
