import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/feature/sub_company/notification/model/notification_model.dart';

class NotificationRepo {
  final _db = FirebaseFirestore.instance;

  String _generateDateId(String prefix) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final id = now.millisecondsSinceEpoch.toString();
    return '$prefix-$datePart-$id';
  }

  Future<void> create({
    required String staffId,
    required String title,
    required String message,
  }) async {
    final String id = _generateDateId('NOTIF');
    await _db.collection('NOTIFICATIONS').doc(id).set({
      'staffId': staffId,
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
 Future<void> createForAdmins({
    required String title,
    required String message,
    String excludeStaffId = '',
  }) async {
    try {
      // Fetch all admin users
      final snapshot = await _db
          .collection('STAFFS')
          .where('staffType', isEqualTo: 'Admin')
          .get();

      for (final doc in snapshot.docs) {
        final adminId = doc.id;

        // Skip if this admin is already the assigned staff (already notified above)
        if (adminId == excludeStaffId) continue;

        final String id = _generateDateId('NOTIF');
        await _db.collection('NOTIFICATIONS').doc(id).set({
          'staffId': adminId,
          'title': title,
          'message': message,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      log('[NotificationRepo] createForAdmins error: $e');
    }
  }
 Stream<List<NotificationModel>> streamByStaff(String staffId) {
  return _db
      .collection('NOTIFICATIONS')
      .where('staffId', isEqualTo: staffId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList(),
      )
      .handleError((error) { 
        log('[NotificationRepo] streamByStaff error: $error');
      });
}

  // delete single notification by ID
  Future<void> deleteOne(String notificationId) async {
    await _db.collection('NOTIFICATIONS').doc(notificationId).delete();
  }

  // delete all notifications for a staff member
  Future<void> deleteAll(String staffId) async {
    final snapshot = await _db
        .collection('NOTIFICATIONS')
        .where('staffId', isEqualTo: staffId)
        .get();

    // batch delete for efficiency — Firestore batch limit is 500
    final batches = <WriteBatch>[];
    WriteBatch batch = _db.batch();
    int count = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;

      if (count == 500) {
        batches.add(batch);
        batch = _db.batch();
        count = 0;
      }
    }

    if (count > 0) batches.add(batch);

    for (final b in batches) {
      await b.commit();
    }
  }

   // in notification_repo.dart
Future<void> markAllRead(String staffId) async {
  final snapshot = await _db
      .collection('NOTIFICATIONS')
      .where('staffId', isEqualTo: staffId)
      .where('isRead', isEqualTo: false)
      .get();

  final batch = _db.batch();
  for (final doc in snapshot.docs) {
    batch.update(doc.reference, {'isRead': true});
  }
  await batch.commit();
}

}