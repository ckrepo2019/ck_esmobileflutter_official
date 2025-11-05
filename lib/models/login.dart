// class Login {
//   final int id;
//   final String name;
//   final String email;
//   final int type;

//   Login({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.type,
//   });

//   factory Login.fromJson(Map<String, dynamic> json) {
//     return Login(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       type: json['type'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'type': type,
//     };
//   }

//   @override
//   String toString() {
//     return 'login(id: $id, name: $name, email: $email, type: $type)';
//   }
// }

import 'dart:convert';

int parseInt(dynamic value) {
  final jsonValue = jsonDecode(jsonEncode(value));
  return jsonValue is int ? jsonValue : int.tryParse(jsonValue.toString()) ?? 0;
}

class Login {
  final int id;
  final String name;
  final String email;
  final int type;

  Login({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: parseInt(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Login(id: $id, name: $name, email: $email, type: $type)';
  }
}
