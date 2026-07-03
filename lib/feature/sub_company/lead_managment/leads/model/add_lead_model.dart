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
  final DateTime? updatedAt;
  final String createdBy;
  final String createdById;
  final Map<String, String>? additionalFields;
  final DateTime? deletedAt;
  final List<FOLLOW-UPModel>? FOLLOW-UP;
  final DateTime? FOLLOW-UPDate;
  final DateTime? calledDate;
  final String? leadTag;
  final String? callResult;
  final List<TransferDetails>? transferLeads;

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
    this.updatedAt,
    required this.createdBy,
    required this.createdById,
    this.additionalFields,
    this.deletedAt,
    this.FOLLOW-UPDate,
    this.calledDate,

    this.FOLLOW-UP,
    this.leadTag = '',
    this.callResult = '',
    this.transferLeads,
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
      // 'updatedAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
      'additionalFields': additionalFields,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'nextFOLLOW-UPDate': FOLLOW-UPDate != null
          ? Timestamp.fromDate(FOLLOW-UPDate!)
          : null,
      'lastCalledDate': calledDate != null
          ? Timestamp.fromDate(calledDate!)
          : null,
      // 'FOLLOW-UP': FOLLOW-UP != null ? FOLLOW-UP!.map((e) => e.toFirestore()).toList() : [],
      'leadTag': leadTag,
      'callResult': callResult,
      'transferLeads': transferLeads != null
          ? transferLeads!.map((e) => e.toFirestore()).toList()
          : [],
    };
  }

  factory AddLeadModel.fromFirestore(Map<String, dynamic> data, String docId) {
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
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      additionalFields: data['additionalFields'] != null
          ? Map<String, String>.from(data['additionalFields'])
          : null,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      FOLLOW-UPDate: (data['nextFOLLOW-UPDate'] as Timestamp?)?.toDate(),
      calledDate: (data['lastCalledDate'] as Timestamp?)?.toDate(),
      FOLLOW-UP: data['FOLLOW-UP'] != null
          ? (data['FOLLOW-UP'] as List<dynamic>)
                .map((e) => FOLLOW-UPModel.fromFirestore(e, ''))
                .toList()
          : null,
      leadTag: data['leadTag'] ?? '',
      callResult: data['callResult'] ?? '',
      transferLeads: data['transferLeads'] != null
          ? (data['transferLeads'] as List<dynamic>)
                .map((e) => TransferDetails.fromFirestore(e, ''))
                .toList()
          : null,
    );
  }

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
    DateTime? updatedAt,
    String? createdBy,
    String? createdById,
    Map<String, String>? additionalFields,
    DateTime? deletedAt,
    DateTime? FOLLOW-UPDate,
    DateTime? calledDate,
    List<FOLLOW-UPModel>? FOLLOW-UP,
    String? leadTag,
    String? callResult,
    List<TransferDetails>? transferLeads,
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
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdById: createdById ?? this.createdById,
      additionalFields: additionalFields ?? this.additionalFields,
      deletedAt: deletedAt ?? this.deletedAt,
      FOLLOW-UPDate: FOLLOW-UPDate ?? this.FOLLOW-UPDate,
      calledDate: calledDate ?? this.calledDate,
      FOLLOW-UP: FOLLOW-UP ?? this.FOLLOW-UP,
      leadTag: leadTag ?? this.leadTag,
      callResult: callResult ?? this.callResult,
      transferLeads: transferLeads ?? this.transferLeads,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toFirestore();
    map.remove('createdAt');
    map.remove('createdById');
    map.remove('createdBy');
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }
}

class FOLLOW-UPModel {
  final String? id;
  final String leadId;
  final String leadName;
  final String leadWhatsappNo;
  final String leadWhatsappDialCode;
  final DateTime nextFOLLOW-UPDate;
  final String leadTag;
  final String calledStatus;
  final DateTime calledDate;
  final String leadStage;
  final String leadCategory;
  final String priority;
  final String remarks;
  final String adress;
  final String email;
  final String assignedStaff;
  final String assignedStaffId;

  final String createdById;
  final DateTime? createdAt;

  const FOLLOW-UPModel({
    this.id,
    required this.leadId,
    required this.leadName,
    required this.leadWhatsappNo,
    required this.leadWhatsappDialCode,
    required this.nextFOLLOW-UPDate,
    required this.leadTag,
    required this.calledStatus,
    required this.calledDate,
    required this.leadStage,
    required this.leadCategory,
    required this.priority,
    required this.remarks,
    required this.adress,
    required this.email,
    required this.assignedStaff,
    required this.assignedStaffId,
    required this.createdById,
    this.createdAt,
  });

  factory FOLLOW-UPModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FOLLOW-UPModel(
      id: docId,
      leadId: data['leadId'] ?? '',
      leadName: data['leadName'] ?? '',
      leadWhatsappNo: data['leadWhatsappNo'] ?? '',
      leadWhatsappDialCode: data['leadWhatsappDialCode'] ?? '',
      nextFOLLOW-UPDate:
          (data['nextFOLLOW-UPDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      leadTag: data['leadTag'] ?? '',
      calledStatus: data['calledStatus'] ?? '',
      calledDate:
          (data['calledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      leadStage: data['leadStage'] ?? '',
      leadCategory: data['leadCategory'] ?? '',
      priority: data['priority'] ?? '',
      remarks: data['remarks'] ?? '',
      adress: data['address'] ?? '',
      email: data['email'] ?? '',
      assignedStaff: data['assignedStaff'] ?? '',
      assignedStaffId: data['assignedStaffId'] ?? '',
      createdById: data['createdById'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'leadName': leadName,
      'leadWhatsappNo': leadWhatsappNo,
      'leadWhatsappDialCode': leadWhatsappDialCode,
      'nextFOLLOW-UPDate': Timestamp.fromDate(nextFOLLOW-UPDate),
      'leadTag': leadTag,
      'calledStatus': calledStatus,
      'calledDate': Timestamp.fromDate(calledDate),
      'leadStage': leadStage,
      'leadCategory': leadCategory,
      'priority': priority,
      'remarks': remarks,
      'address': adress,
      'email': email,
      'assignedStaff': assignedStaff,
      'assignedStaffId': assignedStaffId,
      'createdById': createdById,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  FOLLOW-UPModel copyWith({
    String? id,
    String? leadId,
    String? leadName,
    String? leadWhatsappNo,
    String? leadWhatsappDialCode,
    DateTime? nextFOLLOW-UPDate,
    String? leadTag,
    String? calledStatus,
    DateTime? calledDate,
    String? leadStage,
    String? leadCategory,
    String? priority,
    String? remarks,
    String? adress,
    String? email,
    String? assignedStaff,
    String? assignedStaffId,
    String? createdById,
    DateTime? createdAt,
  }) {
    return FOLLOW-UPModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      leadWhatsappNo: leadWhatsappNo ?? this.leadWhatsappNo,
      leadWhatsappDialCode: leadWhatsappDialCode ?? this.leadWhatsappDialCode,
      nextFOLLOW-UPDate: nextFOLLOW-UPDate ?? this.nextFOLLOW-UPDate,
      leadTag: leadTag ?? this.leadTag,
      calledStatus: calledStatus ?? this.calledStatus,
      calledDate: calledDate ?? this.calledDate,
      leadStage: leadStage ?? this.leadStage,
      leadCategory: leadCategory ?? this.leadCategory,
      priority: priority ?? this.priority,
      remarks: remarks ?? this.remarks,
      adress: adress ?? this.adress,
      email: email ?? this.email,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransferDetails {
  final String? id;
  final String leadId;
  final String leadName;
  final String contactNumber;
  final String leadCategory;
  final String leadStage;
  final String fromStaffId;
  final String fromStaff;
  final String toStaffId;
  final String toStaff;
  final DateTime? transferTime;

  const TransferDetails({
    this.id,
    required this.leadId,
    required this.leadName,
    required this.contactNumber,
    required this.leadCategory,
    required this.leadStage,
    required this.fromStaffId,
    required this.fromStaff,
    required this.toStaffId,
    required this.toStaff,
    this.transferTime,
  });

  factory TransferDetails.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return TransferDetails(
      id: docId,
      leadId: data['leadId'] ?? '',
      leadName: data['leadName'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      leadCategory: data['leadCategory'] ?? '',
      leadStage: data['leadStage'] ?? '',
      fromStaffId: data['fromStaffId'] ?? '',
      fromStaff: data['fromStaff'] ?? '',
      toStaffId: data['toStaffId'] ?? '',
      toStaff: data['toStaff'] ?? '',
      transferTime: (data['transferTime'] as Timestamp?)
          ?.toDate(), // ✅ safely nullable
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'leadName': leadName,
      'contactNumber': contactNumber,
      'leadCategory': leadCategory,
      'leadStage': leadStage,
      'fromStaffId': fromStaffId,
      'fromStaff': fromStaff,
      'toStaffId': toStaffId,
      'toStaff': toStaff,
      'transferTime': transferTime != null
          ? Timestamp.fromDate(transferTime!)
          : FieldValue.serverTimestamp(),
    };
  }

  TransferDetails copyWith({
    String? id,
    String? leadId,
    String? leadName,
    String? contactNumber,
    String? leadCategory,
    String? leadStage,
    String? fromStaffId,
    String? fromStaff,
    String? toStaffId,
    String? toStaff,
    DateTime? transferTime,
  }) {
    return TransferDetails(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      contactNumber: contactNumber ?? this.contactNumber,
      leadCategory: leadCategory ?? this.leadCategory,
      leadStage: leadStage ?? this.leadStage,
      fromStaffId: fromStaffId ?? this.fromStaffId,
      fromStaff: fromStaff ?? this.fromStaff,
      toStaffId: toStaffId ?? this.toStaffId,
      toStaff: toStaff ?? this.toStaff,
      transferTime: transferTime ?? this.transferTime,
    );
  }
}
