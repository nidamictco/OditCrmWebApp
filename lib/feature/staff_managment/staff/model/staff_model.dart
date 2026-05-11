import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String? id;
  final String name;
  final String password;
  final String phone;
  final String? email;
  final String? designation;
  final String? staffType;
  final String? joiningDate;
  final String? salary;
  final String? openingBalance;
  final String? openingBalanceDate;
  final bool accessWhatsapp;
  final bool accessCallLog;
  final bool hasSalaryAccount;
  final bool hasPettyCash;
  final String? imageUrl;      // Firebase Storage URL after upload
  final String? documentName;
  final String? documentUrl;   // Firebase Storage URL after upload
  final String? accessibleUsers;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  const StaffModel({
    this.id,
    required this.name,
    required this.password,
    required this.phone,
    this.email,
    this.designation,
    this.staffType,
    this.joiningDate,
    this.salary,
    this.openingBalance,
    this.openingBalanceDate,
    this.accessWhatsapp = false,
    this.accessCallLog = false,
    this.hasSalaryAccount = true,
    this.hasPettyCash = false,
    this.imageUrl,
    this.documentName,
    this.documentUrl,
    this.accessibleUsers,
    this.createdAt,
    this.deletedAt,
  });

  // ─── copyWith ────────────────────────────────────────────────────────────

  StaffModel copyWith({
    String? id,
    String? name,
    String? password,
    String? phone,
    String? email,
    String? designation,
    String? staffType,
    String? joiningDate,
    String? salary,
    String? openingBalance,
    String? openingBalanceDate,
    bool? accessWhatsapp,
    bool? accessCallLog,
    bool? hasSalaryAccount,
    bool? hasPettyCash,
    String? imageUrl,
    String? documentName,
    String? documentUrl,
    String? accessibleUsers,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      staffType: staffType ?? this.staffType,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceDate: openingBalanceDate ?? this.openingBalanceDate,
      accessWhatsapp: accessWhatsapp ?? this.accessWhatsapp,
      accessCallLog: accessCallLog ?? this.accessCallLog,
      hasSalaryAccount: hasSalaryAccount ?? this.hasSalaryAccount,
      hasPettyCash: hasPettyCash ?? this.hasPettyCash,
      imageUrl: imageUrl ?? this.imageUrl,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      accessibleUsers: accessibleUsers ?? this.accessibleUsers,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // ─── Firestore ────────────────────────────────────────────────────────────

  factory StaffModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return StaffModel(
      id: doc.id,
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      designation: map['designation'],
      staffType: map['staffType'],
      joiningDate: map['joiningDate'],
      salary: map['salary'],
      openingBalance: map['openingBalance'],
      openingBalanceDate: map['openingBalanceDate'],
      accessWhatsapp: map['accessWhatsapp'] ?? false,
      accessCallLog: map['accessCallLog'] ?? false,
      hasSalaryAccount: map['hasSalaryAccount'] ?? true,
      hasPettyCash: map['hasPettyCash'] ?? false,
      imageUrl: map['imageUrl'],
      documentName: map['documentName'],
      documentUrl: map['documentUrl'],
      accessibleUsers: map['accessibleUsers'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'phone': phone,
      'email': email,
      'designation': designation,
      'staffType': staffType,
      'joiningDate': joiningDate,
      'salary': salary,
      'openingBalance': openingBalance,
      'openingBalanceDate': openingBalanceDate,
      'accessWhatsapp': accessWhatsapp,
      'accessCallLog': accessCallLog,
      'hasSalaryAccount': hasSalaryAccount,
      'hasPettyCash': hasPettyCash,
      'imageUrl': imageUrl,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'accessibleUsers': accessibleUsers,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'deletedAt': deletedAt != null
          ? Timestamp.fromDate(deletedAt!)
          : null,
    };
  }
}