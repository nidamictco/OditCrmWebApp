import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyStaffModel {
  final String staffId;

  final String companyId;

  final String name;

  final String mobile;

  final String password;

  final String role;

  final List<String> permissions;

  final String status;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  const CompanyStaffModel({
    required this.staffId,
    required this.companyId,
    required this.name,
    required this.mobile,
    required this.password,
    required this.role,
    required this.permissions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "companyId": companyId,
      "name": name,
      "mobile": mobile,
      "passwordHash": password,
      "role": role,
      "permissions": permissions,
      "status": status,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}