import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

abstract class ILeadSourceRepository {
  Stream<List<LeadsModel>> watchSource();
  Future<String> addSource({required String name});
  Future<void> updateSource({required String id, required String name});
  Future<void> deleteSource({required String id});
}

class LeadSourceRepository implements ILeadSourceRepository {
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEAD SOURCE');

  LeadSourceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeadsModel>> watchSource() {
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
  Future<String> addSource({required String name}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Lead Source name cannot be empty.');
    }
    final StaffModel? user = await SessionService().getSavedUser();
    final docRef = await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name,
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// 🔹 Update an existing source's name, then propagate the new name to
  /// every Lead document referencing it via leadSourceId. Followups don't
  /// store source at all (no `leadSource`/`leadSourceId` field on
  /// FollowUpModel), so this never touches FOLLOW_UPS.
  @override
  Future<void> updateSource({
    required String id,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});

    await _syncSourceNameToLeads(
      sourceId: id,
      newSourceName: trimmedName,
    );
  }

  @override
  Future<void> deleteSource({required String id}) async {
    await _collection.doc(id).delete();
  }

  // ── Sync helper ────────────────────────────────────────────────────────

  /// Propagates a source rename to Lead docs referencing it via
  /// leadSourceId. No FOLLOW_UPS pass — FollowUpModel has no source field.
  Future<void> _syncSourceNameToLeads({
    required String sourceId,
    required String newSourceName,
  }) async {
    try {
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
          .where('leadSourceId', isEqualTo: sourceId)
          .get();

      if (leadsSnap.docs.isEmpty) {
        log('[LeadSourceRepository] syncSourceName: no matching leads for sourceId=$sourceId');
        return;
      }

      const chunkSize = 450;
      final docs = leadsSnap.docs;
      for (var i = 0; i < docs.length; i += chunkSize) {
        final end = (i + chunkSize > docs.length) ? docs.length : i + chunkSize;
        final chunk = docs.sublist(i, end);

        final batch = _firestore.batch();
        for (final doc in chunk) {
          batch.update(doc.reference, {'leadSource': newSourceName});
        }
        await batch.commit();
      }

      log('[LeadSourceRepository] syncSourceName: done — '
          '${leadsSnap.docs.length} leads updated for sourceId=$sourceId → "$newSourceName"');
    } catch (e, st) {
      log('[LeadSourceRepository] syncSourceName ERROR for sourceId=$sourceId: $e\n$st');
    }
  }
}









/// ── ONE-TIME MIGRATION ───────────────────────────────────────────────────
/// Backfills leadCategoryId / leadSubCategoryId / leadStageId on existing
/// TRANSFER_LEADS subcollection docs that were written before these ID
/// fields existed on TransferDetails. Resolves the old raw name strings
/// (leadCategory / leadSubCategory / leadStage) against the current
/// LEADS CATEGORY, SUB CATEGORY, and LEADS STAGE collections.
///
/// Safe to re-run: any doc that already has a non-empty leadCategoryId
/// is skipped entirely (no re-write, no re-lookup).
///
/// Run this once, manually, from a debug button or a one-off script —
/// not on every app start.
Future<void> migrateTransferLeadsCategoryIds() async {
  final db = FirebaseFirestore.instance;

  // ── 1. Preload category name → id map (case-insensitive) ────────────────
  final categorySnap =
      await FirestorePath.companyCollection('LEADS CATEGORY').get();
  final Map<String, String> categoryNameToId = {
    for (final doc in categorySnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 2. Preload stage name → id map (case-insensitive) ───────────────────
  final stageSnap =
      await FirestorePath.companyCollection('LEADS STAGE').get();
  final Map<String, String> stageNameToId = {
    for (final doc in stageSnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 3. Sub-category lookups are scoped per-category — cache lazily ──────
  // categoryId -> { subCategoryNameUpper -> subCategoryId }
  final Map<String, Map<String, String>> subCategoryCachePerCategory = {};

  Future<Map<String, String>> getSubCategoryMap(String categoryId) async {
    if (subCategoryCachePerCategory.containsKey(categoryId)) {
      return subCategoryCachePerCategory[categoryId]!;
    }
    final subSnap = await FirestorePath.companyCollection('LEADS CATEGORY')
        .doc(categoryId)
        .collection('SUB CATEGORY')
        .get();
    final map = {
      for (final doc in subSnap.docs)
        (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
    };
    subCategoryCachePerCategory[categoryId] = map;
    return map;
  }

  // ── 4. Walk every Lead's TRANSFER_LEADS subcollection ────────────────────
  final leadsSnap = await FirestorePath.companyCollection('LEADS').get();

  int scanned = 0;
  int updated = 0;
  int skippedAlreadyDone = 0;
  int unresolvedCategory = 0;
  int unresolvedStage = 0;

  final List<DocumentReference<Map<String, dynamic>>> pendingRefs = [];
  final List<Map<String, dynamic>> pendingUpdates = [];

  for (final leadDoc in leadsSnap.docs) {
    final transferSnap = await leadDoc.reference
        .collection('TRANSFER_LEADS')
        .get();

    for (final transferDoc in transferSnap.docs) {
      scanned++;
      final data = transferDoc.data();

      // Skip if already backfilled.
      final existingCategoryId = (data['leadCategoryId'] as String? ?? '');
      if (existingCategoryId.isNotEmpty) {
        skippedAlreadyDone++;
        continue;
      }

      final rawCategory =
          (data['leadCategory'] as String? ?? '').trim().toUpperCase();
      final rawSubCategory =
          (data['leadSubCategory'] as String? ?? '').trim().toUpperCase();
      final rawStage =
          (data['leadStage'] as String? ?? '').trim().toUpperCase();

      final resolvedCategoryId = categoryNameToId[rawCategory] ?? '';
      final resolvedStageId = stageNameToId[rawStage] ?? '';

      String resolvedSubCategoryId = '';
      if (resolvedCategoryId.isNotEmpty && rawSubCategory.isNotEmpty) {
        final subMap = await getSubCategoryMap(resolvedCategoryId);
        resolvedSubCategoryId = subMap[rawSubCategory] ?? '';
      }

      if (rawCategory.isNotEmpty && resolvedCategoryId.isEmpty) {
        unresolvedCategory++;
        log('[migrateTransferLeadsCategoryIds] Could not resolve category '
            '"$rawCategory" for transfer doc ${transferDoc.id} '
            '(lead ${leadDoc.id}) — likely renamed/deleted since. Leaving blank.');
      }
      if (rawStage.isNotEmpty && resolvedStageId.isEmpty) {
        unresolvedStage++;
        log('[migrateTransferLeadsCategoryIds] Could not resolve stage '
            '"$rawStage" for transfer doc ${transferDoc.id} '
            '(lead ${leadDoc.id}) — likely renamed/deleted since. Leaving blank.');
      }

      // Only write if we resolved at least one ID — no point writing all-blank.
      if (resolvedCategoryId.isEmpty &&
          resolvedSubCategoryId.isEmpty &&
          resolvedStageId.isEmpty) {
        continue;
      }

      pendingRefs.add(transferDoc.reference);
      pendingUpdates.add({
        if (resolvedCategoryId.isNotEmpty) 'leadCategoryId': resolvedCategoryId,
        if (resolvedSubCategoryId.isNotEmpty)
          'leadSubCategoryId': resolvedSubCategoryId,
        if (resolvedStageId.isNotEmpty) 'leadStageId': resolvedStageId,
      });
    }
  }

  // ── 5. Batch-write in chunks of 450 ──────────────────────────────────────
  const chunkSize = 450;
  for (var i = 0; i < pendingRefs.length; i += chunkSize) {
    final end =
        (i + chunkSize > pendingRefs.length) ? pendingRefs.length : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      batch.update(pendingRefs[j], pendingUpdates[j]);
    }
    await batch.commit();
    updated += (end - i);
    log('[migrateTransferLeadsCategoryIds] Committed batch '
        '${(i ~/ chunkSize) + 1} (${end - i} docs)');
  }

  log('[migrateTransferLeadsCategoryIds] DONE — '
      'scanned:$scanned updated:$updated '
      'skippedAlreadyDone:$skippedAlreadyDone '
      'unresolvedCategory:$unresolvedCategory unresolvedStage:$unresolvedStage');
}






// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:Odit_CRM/core/constant/firebase_const.dart';
// import 'package:Odit_CRM/core/shared_preference/session_service.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

// abstract class ILeadSourceRepository {
//   Stream<List<LeadsModel>> watchSource();
//   Future<String> addSource({required String name, });
//   Future<void> updateSource({required String id, required String name});
//   Future<void> deleteSource({required String id});
// }

// class LeadSourceRepository implements ILeadSourceRepository {
//   final FirebaseFirestore _firestore;

//   // Firestore collection reference
//   CollectionReference<Map<String, dynamic>> get _collection =>
//       FirestorePath.companyCollection('LEAD SOURCE');

//   LeadSourceRepository({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance;

//   /// 🔹 Stream all categories ordered by creation date
//   // In lead_category_repository.dart
// @override
// Stream<List<LeadsModel>> watchSource() {
//   return _collection
//       .orderBy('createdAt', descending: false) 
//       .snapshots()
//       .map(
//         (snapshot) => snapshot.docs
//             .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
//             .toList(), // already creates a new list, but be explicit:
//       );
// }

//   /// 🔹 Add a new category
//   @override
//   Future<String> addSource({
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Lead Source name cannot be empty.');
//     }
//     final StaffModel? user = await SessionService().getSavedUser();
//    final docRef= await _collection.add({
//       'name': trimmedName,
//       'createdBy': user?.name, 
//       'idOfCreator': user?.id,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//     return docRef.id;
//   } 

//   /// 🔹 Update an existing category's name
//   @override
//   Future<void> updateSource({
//     required String id,
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Category name cannot be empty.');
//     }

//     await _collection.doc(id).update({'name': trimmedName});
//   }

//   /// 🔹 Delete a category
//   @override
//   Future<void> deleteSource({required String id}) async {
//     await _collection.doc(id).delete();
//   }
// }