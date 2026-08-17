import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constant/firebase_const.dart';
import '../models/follow_up_activities_model.dart';

class ActivityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activitiesRef(String leadId) =>
      FirestorePath.companyCollection('LEADS').doc(leadId).collection('ACTIVITIES');

  /// Fetch all activities for a lead, newest first.
  Future<List<ActivityModel>> getActivities(String leadId) async {
    final snap = await _activitiesRef(
      leadId,
    ).orderBy('changedAt', descending: true).get();
    return snap.docs
        .map((d) => ActivityModel.fromFirestore(d.data(), d.id))
        .toList();
  }

  /// Write a single activity — call this inside a WriteBatch for atomicity.
  void writeActivityInBatch({
    required WriteBatch batch,
    required String leadId,
    required ActivityModel activity,
  }) {
    final ref = _activitiesRef(leadId).doc();
    batch.set(ref, activity.toFirestore());
  }

  /// Convenience: write one activity immediately (for lead creation).
  Future<void> logLeadCreated({
    required String leadId,
    required String staffName,
    required String staffId,
    required String assignedTo,
  }) async {
    await _activitiesRef(leadId).add(
      ActivityModel(
        id: '',
        type: ActivityType.leadCreated,
        changedBy: staffName,
        changedById: staffId,
        changedAt: DateTime.now(),
        description: 'Lead created. Assigned to $assignedTo.',
      ).toFirestore(),
    );
  }

  Future<List<ActivityModel>> getActivitiesByStaff(
    String staffId, {
       required DateTime selectedDate,
  DateTime? toDate,
    int limit = 20,
  }) async {
    // final snap = await _db
    //     .collectionGroup('ACTIVITIES')
    //     .where('changedById', isEqualTo: staffId)
    //     .orderBy('changedAt', descending: true)
    //     .limit(limit)
    //     .get();

     final start = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

 final end = toDate != null
      ? DateTime(
          toDate.year,
          toDate.month,
          toDate.day,
        ).add(const Duration(days: 1))
      : start.add(const Duration(days: 1));

  final snap = await _db
      .collectionGroup('ACTIVITIES')
      .where('changedById', isEqualTo: staffId)
      .where(
        'changedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(start),
      )
      .where(
        'changedAt',
        isLessThan: Timestamp.fromDate(end),
      )
      .orderBy('changedAt', descending: true)
      .limit(limit)
      .get();

    final activities = await Future.wait(
      snap.docs.map((d) async {
        final data = d.data();

        // Try stored leadId first, fall back to parent doc traversal
        final leadId =
            data['leadId'] as String? ??
            (() {
              final segments = d.reference.path.split('/');
              if (segments.length >= 4 && segments[2] == 'LEADS') {
                return segments[3];
              }
              return null;
            }());

        String? leadName;
        String? leadPhone;

        if (leadId != null) {
          final leadDoc = await FirestorePath.companyCollection('LEADS').doc(leadId).get();
          if (leadDoc.exists) {
            leadName = leadDoc.data()?['clientName'] as String?;
            leadPhone = leadDoc.data()?['contactNumber'] as String?;
          }
        }

        final activity = ActivityModel.fromFirestore(data, d.id);
        return ActivityModel(
          id: activity.id,
          type: activity.type,
          changedBy: activity.changedBy,
          changedById: activity.changedById,
          changedAt: activity.changedAt,
          previousValue: activity.previousValue,
          newValue: activity.newValue,
          description: activity.description,
          leadId: leadId,
          leadName: leadName ?? 'Unknown',
          leadPhone: leadPhone ?? '',
        );
      }),
    );

    return activities;
  }
}
