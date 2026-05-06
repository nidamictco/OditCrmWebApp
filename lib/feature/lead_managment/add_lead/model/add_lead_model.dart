// lib/feature/lead_managment/add_lead/data/add_lead_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AddLeadModel {
  final String? id;
  final String clientName;
  final String contactNumber;
  final String contactDialCode;
  final String whatsappNumber;
  final String whatsappDialCode;
  final String email;
  final String address;
  final String pinCode;
  final String postOffice;
  final String state;
  final String district;
  final String assignedStaff;
  final String assignedStaffId;
  final String leadCategory;
  final String leadSource;
  final String priority;
  final String leadStage;
  final String remarks;
  final DateTime? createdAt;
  final String createdBy;
  final String createdById;
  final Map<String, String>? additionalFields;

  const AddLeadModel({
    this.id,
    required this.clientName,
    required this.contactNumber,
    required this.contactDialCode,
    this.whatsappNumber = '',
    this.whatsappDialCode = '+91',
    this.email = '',
    this.address = '',
    this.pinCode = '',
    this.postOffice = '',
    this.state = '',
    this.district = '',
    required this.assignedStaff,
    required this.assignedStaffId,
    this.leadCategory = '',
    this.leadSource = '',
    this.priority = '',
    this.leadStage = '',
    this.remarks = '',
    this.createdAt,
    required this.createdBy,
    required this.createdById,  this.additionalFields,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName.trim(),
      'contactNumber': contactNumber.trim(),
      'contactDialCode': contactDialCode,
      'whatsappNumber': whatsappNumber.trim(),
      'whatsappDialCode': whatsappDialCode,
      'email': email.trim(),
      'address': address.trim(),
      'pinCode': pinCode.trim(),
      'postOffice': postOffice.trim(),
      'state': state,
      'district': district,
      'assignedStaff': assignedStaff,
      'assignedStaffId': assignedStaffId,
      'leadCategory': leadCategory.toString().toUpperCase(),
      'leadSource': leadSource.toString().toUpperCase(),
      'priority': priority,
      'leadStage': leadStage.toString().toUpperCase(),
      'remarks': remarks.trim(),
      'createdBy': createdBy,
      'createdById': createdById,
      'createdAt': FieldValue.serverTimestamp(),
      'additionalFields': additionalFields,
    };
  }

  factory AddLeadModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return AddLeadModel(
      id: docId,
      clientName: data['clientName'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      contactDialCode: data['contactDialCode'] ?? '+91',
      whatsappNumber: data['whatsappNumber'] ?? '',
      whatsappDialCode: data['whatsappDialCode'] ?? '+91',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      pinCode: data['pinCode'] ?? '',
      postOffice: data['postOffice'] ?? '',
      state: data['state'] ?? '',
      district: data['district'] ?? '',
      assignedStaff: data['assignedStaff'] ?? '',
      assignedStaffId: data['assignedStaffId'] ?? '',
      leadCategory: data['leadCategory'] ?? '',
      leadSource: data['leadSource'] ?? '',
      priority: data['priority'] ?? '',
      leadStage: data['leadStage'] ?? '',
      remarks: data['remarks'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdById: data['createdById'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      additionalFields: Map<String, String>.from(data['additionalFields'] ?? {}),
    );
  }

  // Add this method inside AddLeadModel class

AddLeadModel copyWith({
  String? id,
  String? clientName,
  String? contactNumber,
  String? contactDialCode,
  String? whatsappNumber,
  String? whatsappDialCode,
  String? email,
  String? address,
  String? pinCode,
  String? postOffice,
  String? state,
  String? district,
  String? assignedStaff,
  String? assignedStaffId,
  String? leadCategory,
  String? leadSource,
  String? priority,
  String? leadStage,
  String? remarks,
  DateTime? createdAt,
  String? createdBy,
  String? createdById,
}) {
  return AddLeadModel(
    id: id ?? this.id,
    clientName: clientName ?? this.clientName,
    contactNumber: contactNumber ?? this.contactNumber,
    contactDialCode: contactDialCode ?? this.contactDialCode,
    whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    whatsappDialCode: whatsappDialCode ?? this.whatsappDialCode,
    email: email ?? this.email,
    address: address ?? this.address,
    pinCode: pinCode ?? this.pinCode,
    postOffice: postOffice ?? this.postOffice,
    state: state ?? this.state,
    district: district ?? this.district,
    assignedStaff: assignedStaff ?? this.assignedStaff,
    assignedStaffId: assignedStaffId ?? this.assignedStaffId,
    leadCategory: leadCategory ?? this.leadCategory,
    leadSource: leadSource ?? this.leadSource,
    priority: priority ?? this.priority,
    leadStage: leadStage ?? this.leadStage,
    remarks: remarks ?? this.remarks,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    createdById: createdById ?? this.createdById,
  );
}
}