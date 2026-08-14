import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

abstract class ILeadTagRepository {
  Stream<List<LeadsModel>> watchLeadTags();
  Future<void> addLeadTag({required String name});
  Future<void> updateLeadTag({required String id, required String name});
  Future<void> deleteLeadTag({required String id});
}

class LeadTagRepository implements ILeadTagRepository {
  final String tagId; // parent LEADS STAGE doc id
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS STAGE')
          .doc(tagId)
          .collection('LEADS TAG');

  LeadTagRepository({
    required this.tagId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeadsModel>> watchLeadTags() {
    return _collection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> addLeadTag({required String name}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Lead Tag name cannot be empty.');
    }
    final StaffModel? user = await SessionService().getSavedUser();
    await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name,
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Update an existing tag's name, then propagate the new name to every
  /// Lead/Followup document referencing this specific tag document via
  /// leadTagId. `id` here is the tag document's own ID — not `tagId`
  /// (the parent stage), which is a different value entirely.
  @override
  Future<void> updateLeadTag({
    required String id,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Lead Tag name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});

    await _syncTagNameToLeadsAndFollowups(
      tagDocId: id,
      newTagName: trimmedName,
    );
  }

  @override
  Future<void> deleteLeadTag({required String id}) async {
    await _collection.doc(id).delete();
  }

  // ── Sync helper ────────────────────────────────────────────────────────

  /// Propagates a tag rename to Lead + Followup docs referencing it via
  /// leadTagId (the tag document's own ID, not the parent stage's ID).
  Future<void> _syncTagNameToLeadsAndFollowups({
    required String tagDocId,
    required String newTagName,
  }) async {
    try {
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
          .where('leadTagId', isEqualTo: tagDocId)
          .get();

      // Requires a collection-group index on FOLLOW_UPS.leadTagId.
      final followUpsSnap = await _firestore
          .collectionGroup('FOLLOW_UPS')
          .where('leadTagId', isEqualTo: tagDocId)
          .get();

      final allRefs = <DocumentReference<Map<String, dynamic>>>[
        ...leadsSnap.docs.map((d) => d.reference),
        ...followUpsSnap.docs.map((d) => d.reference),
      ];

      if (allRefs.isEmpty) {
        log('[LeadTagRepository] syncTagName: no matching docs for tagDocId=$tagDocId');
        return;
      }

      const chunkSize = 450;
      for (var i = 0; i < allRefs.length; i += chunkSize) {
        final end = (i + chunkSize > allRefs.length) ? allRefs.length : i + chunkSize;
        final chunk = allRefs.sublist(i, end);

        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.update(ref, {'leadTag': newTagName});
        }
        await batch.commit();
      }

      log('[LeadTagRepository] syncTagName: done — '
          '${leadsSnap.docs.length} leads, ${followUpsSnap.docs.length} followups '
          'updated for tagDocId=$tagDocId → "$newTagName"');
    } catch (e, st) {
      log('[LeadTagRepository] syncTagName ERROR for tagDocId=$tagDocId: $e\n$st');
    }
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:Odit_CRM/core/constant/firebase_const.dart';
// import 'package:Odit_CRM/core/shared_preference/session_service.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

// abstract class ILeadTagRepository {
//   Stream<List<LeadsModel>> watchLeadTags();
//   Future<void> addLeadTag({required String name});
//   Future<void> updateLeadTag({required String id, required String name});
//   Future<void> deleteLeadTag({required String id});
// }

// class LeadTagRepository implements ILeadTagRepository {
//   final String tagId;

//   // Firestore collection reference 
//   CollectionReference<Map<String, dynamic>> get _collection =>
//       FirestorePath.companyCollection('LEADS STAGE')
//           .doc(tagId)
//           .collection('LEADS TAG');

//   LeadTagRepository({
//     required this.tagId,
//   });

//   /// 🔹 Stream all subcategories ordered by creation date
//   @override
//   Stream<List<LeadsModel>> watchLeadTags() {
//     return _collection
//         .orderBy('createdAt', descending: false)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
//               .toList(),
//         );
//   }

//   /// 🔹 Add a new subcategory
//   @override
//   Future<void> addLeadTag({
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Lead Tag name cannot be empty.');
//     }
//     final StaffModel? user = await SessionService().getSavedUser();
//     await _collection.add({
//       'name': trimmedName,
//       'createdBy': user?.name,
//       'idOfCreator': user?.id,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// 🔹 Update an existing subcategory's name
//   @override
//   Future<void> updateLeadTag({
//     required String id,
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Lead Tag name cannot be empty.');
//     }

//     await _collection.doc(id).update({'name': trimmedName});
//   }

//   /// 🔹 Delete a subcategory
//   @override
//   Future<void> deleteLeadTag({required String id}) async {
//     await _collection.doc(id).delete();
//   }
// }
