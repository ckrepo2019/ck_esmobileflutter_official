// class PaymentOptions {
//   final int id;
//   final String description;

//   PaymentOptions({
//     required this.id,
//     required this.description,
//   });

//   factory PaymentOptions.fromJson(Map<String, dynamic> json) {
//     return PaymentOptions(
//       id: json['id'] ?? 0,
//       description: json['description'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'description': description,
//     };
//   }

//   @override
//   String toString() {
//     return 'PaymentOptions(id: $id,description: $description)';
//   }
// }

// class Bank {
//   final int paymenttype;
//   final String optionDescription;

//   Bank({
//     required this.paymenttype,
//     required this.optionDescription,
//   });

//   factory Bank.fromJson(Map<String, dynamic> json) {
//     return Bank(
//       paymenttype: json['paymenttype'] ?? 0,
//       optionDescription: json['optionDescription'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'paymenttype': paymenttype,
//       'optionDescription': optionDescription,
//     };
//   }

//   @override
//   String toString() {
//     return 'Bank(paymenttype: $paymenttype,optionDescription: $optionDescription)';
//   }
// }

// class SY {
//   final int id;
//   final String sydesc;
//   final int isactive;

//   SY({
//     required this.id,
//     required this.sydesc,
//     required this.isactive,
//   });

//   factory SY.fromJson(Map<String, dynamic> json) {
//     return SY(
//       id: json['id'] ?? 0,
//       sydesc: json['sydesc'] ?? '',
//       isactive: json['isactive'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sydesc': sydesc,
//       'isactive': isactive,
//     };
//   }

//   @override
//   String toString() {
//     return 'SY(id: $id,sydesc: $sydesc, isactive: $isactive)';
//   }
// }

// class Semester {
//   final int id;
//   final String semester;
//   final int isactive;

//   Semester({
//     required this.id,
//     required this.semester,
//     required this.isactive,
//   });

//   factory Semester.fromJson(Map<String, dynamic> json) {
//     return Semester(
//       id: json['id'] ?? 0,
//       semester: json['semester'] ?? '',
//       isactive: json['isactive'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'semester': semester,
//       'isactive': isactive,
//     };
//   }

//   @override
//   String toString() {
//     return 'Semester(id: $id,semester: $semester ,isactive: $isactive)';
//   }
// }

// class Contact {
//   final String contactno;
//   final String mcontactno;
//   final String fcontactno;
//   final String gcontactno;

//   Contact({
//     required this.contactno,
//     required this.mcontactno,
//     required this.fcontactno,
//     required this.gcontactno,
//   });

//   factory Contact.fromJson(Map<String, dynamic> json) {
//     return Contact(
//       contactno: json['contactno'] ?? '',
//       mcontactno: json['mcontactno'] ?? '',
//       fcontactno: json['fcontactno'] ?? '',
//       gcontactno: json['gcontactno'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'contactno': contactno,
//       'mcontactno': mcontactno,
//       'fcontactno': fcontactno,
//       'gcontactno': gcontactno,
//     };
//   }

//   @override
//   String toString() {
//     return 'Student(contactno: $contactno,mcontactno: $mcontactno,fcontactno: $fcontactno,gcontactno: $gcontactno)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class PaymentOptions {
  final int id;
  final String description;

  PaymentOptions({
    required this.id,
    required this.description,
  });

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    return PaymentOptions(
      id: parseInt(json['id']),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'PaymentOptions(id: $id,description: $description)';
  }
}

class Bank {
  final int paymenttype;
  final String optionDescription;

  Bank({
    required this.paymenttype,
    required this.optionDescription,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      paymenttype: parseInt(json['paymenttype']),
      optionDescription: json['optionDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymenttype': paymenttype,
      'optionDescription': optionDescription,
    };
  }

  @override
  String toString() {
    return 'Bank(paymenttype: $paymenttype,optionDescription: $optionDescription)';
  }
}

class SY {
  final int id;
  final String sydesc;
  final int isactive;

  SY({
    required this.id,
    required this.sydesc,
    required this.isactive,
  });

  factory SY.fromJson(Map<String, dynamic> json) {
    return SY(
      id: parseInt(json['id']),
      sydesc: json['sydesc'] ?? '',
      isactive: parseInt(json['isactive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sydesc': sydesc,
      'isactive': isactive,
    };
  }

  @override
  String toString() {
    return 'SY(id: $id,sydesc: $sydesc, isactive: $isactive)';
  }
}

class Semester {
  final int id;
  final String semester;
  final int isactive;

  Semester({
    required this.id,
    required this.semester,
    required this.isactive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: parseInt(json['id']),
      semester: json['semester'] ?? '',
      isactive: parseInt(json['isactive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'isactive': isactive,
    };
  }

  @override
  String toString() {
    return 'Semester(id: $id,semester: $semester ,isactive: $isactive)';
  }
}

class Contact {
  final String contactno;
  final String mcontactno;
  final String fcontactno;
  final String gcontactno;

  Contact({
    required this.contactno,
    required this.mcontactno,
    required this.fcontactno,
    required this.gcontactno,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactno: json['contactno'] ?? '',
      mcontactno: json['mcontactno'] ?? '',
      fcontactno: json['fcontactno'] ?? '',
      gcontactno: json['gcontactno'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactno': contactno,
      'mcontactno': mcontactno,
      'fcontactno': fcontactno,
      'gcontactno': gcontactno,
    };
  }

  @override
  String toString() {
    return 'Student(contactno: $contactno,mcontactno: $mcontactno,fcontactno: $fcontactno,gcontactno: $gcontactno)';
  }
}
