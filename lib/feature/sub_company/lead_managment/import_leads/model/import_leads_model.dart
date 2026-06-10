
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImportLeadModel {
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
  final String createdBy;
  final String createdById;
  final DateTime? createdAt;

  const ImportLeadModel({
    this.id,
    this.clientName = '',
    this.contactNumber = '',
    this.contactDialCode = '+91',
    this.whatsappNumber = '',
    this.whatsappDialCode = '+91',
    this.email = '',
    this.address = '',
    this.pinCode = '',
    this.postOffice = '',
    this.state = '',
    this.district = '',
    this.assignedStaff = '',
    this.assignedStaffId = '',
    this.leadCategory = '',
    this.leadSource = '',
    this.priority = '',
    this.leadStage = '',
    this.remarks = '',
    this.createdBy = '',
    this.createdById = '',
    this.createdAt,
  });

  ImportLeadModel copyWith({
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
    String? createdBy,
    String? createdById,
    DateTime? createdAt,
  }) {
    return ImportLeadModel(
      id:               id               ?? this.id,
      clientName:       clientName       ?? this.clientName,
      contactNumber:    contactNumber    ?? this.contactNumber,
      contactDialCode:  contactDialCode  ?? this.contactDialCode,
      whatsappNumber:   whatsappNumber   ?? this.whatsappNumber,
      whatsappDialCode: whatsappDialCode ?? this.whatsappDialCode,
      email:            email            ?? this.email,
      address:          address          ?? this.address,
      pinCode:          pinCode          ?? this.pinCode,
      postOffice:       postOffice       ?? this.postOffice,
      state:            state            ?? this.state,
      district:         district         ?? this.district,
      assignedStaff:    assignedStaff    ?? this.assignedStaff,
      assignedStaffId:  assignedStaffId  ?? this.assignedStaffId,
      leadCategory:     leadCategory     ?? this.leadCategory,
      leadSource:       leadSource       ?? this.leadSource,
      priority:         priority         ?? this.priority,
      leadStage:        leadStage        ?? this.leadStage,
      remarks:          remarks          ?? this.remarks,
      createdBy:        createdBy        ?? this.createdBy,
      createdById:      createdById      ?? this.createdById,
      createdAt:        createdAt        ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientName':       clientName,
      'contactNumber':    contactNumber,
      'contactDialCode':  contactDialCode,
      'whatsappNumber':   whatsappNumber,
      'whatsappDialCode': whatsappDialCode,
      'email':            email,
      'address':          address,
      'pinCode':          pinCode,
      'postOffice':       postOffice,
      'state':            state,
      'district':         district,
      'assignedStaff':    assignedStaff,
      'assignedStaffId':  assignedStaffId,
      'leadCategory':     leadCategory,
      'leadSource':       leadSource,
      'priority':         priority,
      'leadStage':        leadStage,
      'remarks':          remarks,
      'createdBy':        createdBy,
      'createdById':      createdById,
      'createdAt':        FieldValue.serverTimestamp(),
    };
  }

  factory ImportLeadModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ImportLeadModel(
      id:               id,
      clientName:       data['clientName']       ?? '',
      contactNumber:    data['contactNumber']    ?? '',
      contactDialCode:  data['contactDialCode']  ?? '+91',
      whatsappNumber:   data['whatsappNumber']   ?? '',
      whatsappDialCode: data['whatsappDialCode'] ?? '+91',
      email:            data['email']            ?? '',
      address:          data['address']          ?? '',
      pinCode:          data['pinCode']          ?? '',
      postOffice:       data['postOffice']       ?? '',
      state:            data['state']            ?? '',
      district:         data['district']         ?? '',
      assignedStaff:    data['assignedStaff']    ?? '',
      assignedStaffId:  data['assignedStaffId']  ?? '',
      leadCategory:     data['leadCategory']     ?? '',
      leadSource:       data['leadSource']       ?? '',
      priority:         data['priority']         ?? '',
      leadStage:        data['leadStage']        ?? '',
      remarks:          data['remarks']          ?? '',
      createdBy:        data['createdBy']        ?? '',
      createdById:      data['createdById']      ?? '',
      createdAt:        (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Build a model from one CSV row using field-position mapping.
  /// [row]       — list of cell values from a single CSV row
  /// [positions] — map of fieldName → column index (0-based)
  /// [defaults]  — pre-filled values from the form (category, source, etc.)
  ///
  /// ✅ FIX: removed the invalid nested `_cell` local function inside a factory.
  ///         Replaced with a top-level helper [_csvCell] defined below.
  factory ImportLeadModel.fromCsvRow({
    required List<String> row,
    required Map<String, int> positions,
    required ImportLeadModel defaults,
  }) {
    final name    = _csvCell('clientName', row, positions);
    final phone   = _csvCell('phone',      row, positions);
    final address = _csvCell('address',    row, positions);

    return defaults.copyWith(
      clientName:    name.isNotEmpty    ? name    : defaults.clientName,
      contactNumber: phone.isNotEmpty   ? phone   : defaults.contactNumber,
      address:       address.isNotEmpty ? address : defaults.address,
    );
  }
}

// ── Top-level CSV cell helper ─────────────────────────────────────────────────

/// ✅ FIX: extracted from factory so Dart is happy (no nested functions in
///         factory constructors when they reference outer params).
String _csvCell(String field, List<String> row, Map<String, int> positions) {
  final idx = positions[field];
  if (idx == null || idx < 0 || idx >= row.length) return '';
  log('[ImportLeadsRepo] CSV cell: $field → ${row[idx].trim()}');
  return row[idx].trim();
}

// ── Field-position model (for the FieldPositionDialog) ───────────────────────

class FieldPosition {
  final String fieldName;
  final int position;

  const FieldPosition({required this.fieldName, required this.position});

  FieldPosition copyWith({String? fieldName, int? position}) {
    return FieldPosition(
      fieldName: fieldName ?? this.fieldName,
      position:  position  ?? this.position,
    );
  }

  Map<String, int> toMap() => {fieldName: position};
}