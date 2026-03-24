import 'package:ehnama3ak/core/models/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("UserModel.fromJson - Full JSON: $json");
    
    String roleStr = 'patient';
    if (json['role'] != null) {
      roleStr = json['role'].toString();
    } else if (json['roles'] != null) {
      // Handle ASP.NET Identity style ["Doctor"]
      final roles = json['roles'];
      if (roles is List && roles.isNotEmpty) {
        roleStr = roles.first.toString();
      }
    }
    
    // Extract ID from various possible keys
    String id = '';
    if (json['id'] != null && json['id'].toString().isNotEmpty) {
      id = json['id'].toString();
    } else if (json['userId'] != null && json['userId'].toString().isNotEmpty) {
      id = json['userId'].toString();
    } else if (json['uid'] != null && json['uid'].toString().isNotEmpty) {
      id = json['uid'].toString();
    }
    
    // Extract email
    String email = '';
    if (json['email'] != null && json['email'].toString().isNotEmpty) {
      email = json['email'].toString();
    } else if (json['userName'] != null && json['userName'].toString().isNotEmpty) {
      email = json['userName'].toString();
    }
    
    // Extract name
    String name = json['name']?.toString() ?? '';
    
    print("UserModel - Extracted: id=$id, email=$email, name=$name, role=$roleStr");

    return UserModel(
      id: id,
      email: email,
      name: name,
      role: UserRole.fromString(roleStr),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
    };
  }
}
