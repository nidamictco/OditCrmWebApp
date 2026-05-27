import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/follow_up_activities_model.dart';

class ActivityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activitiesRef(String leadId) =>
      _db.collection('LEADS').doc(leadId).collection('ACTIVITIES');

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
    int limit = 20,
  }) async {
    final snap = await _db
        .collectionGroup('ACTIVITIES')
        .where('changedById', isEqualTo: staffId)
        .orderBy('changedAt', descending: true)
        .limit(limit)
        .get();

    final activities = await Future.wait(
      snap.docs.map((d) async {
        final data = d.data();

        // Try stored leadId first, fall back to parent doc traversal
        final leadId =
            data['leadId'] as String? ??
            d.reference.parent.parent?.id; // ← fallback for old docs

        String? leadName;
        String? leadPhone;

        if (leadId != null) {
          final leadDoc = await _db.collection('LEADS').doc(leadId).get();
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
