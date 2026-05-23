
import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  leadCreated,
  statusChanged,
  followupAdded,
  categoryChanged,
  priorityChanged,
  staffAssigned,
  costUpdated,
  remarkUpdated,
  leadDeleted,
  unknown,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String changedBy;       // staff name, not ID
  final String changedById;
  final DateTime changedAt;
  final String? previousValue;
  final String? newValue;
  final String description;     // human-readable sentence

  const ActivityModel({
    required this.id,
    required this.type,
    required this.changedBy,
    required this.changedById,
    required this.changedAt,
    this.previousValue,
    this.newValue,
    required this.description,
  });

  factory ActivityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      type: _parseType(data['type'] as String? ?? ''),
      changedBy: data['changedBy'] as String? ?? '',
      changedById: data['changedById'] as String? ?? '',
      changedAt: (data['changedAt'] as Timestamp).toDate(),
      previousValue: data['previousValue'] as String?,
      newValue: data['newValue'] as String?,
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'changedBy': changedBy,
    'changedById': changedById,
    'changedAt': Timestamp.fromDate(changedAt),
    'previousValue': previousValue,
    'newValue': newValue,
    'description': description,
  };

  static ActivityType _parseType(String raw) {
    return ActivityType.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => ActivityType.unknown,
    );
  }
}