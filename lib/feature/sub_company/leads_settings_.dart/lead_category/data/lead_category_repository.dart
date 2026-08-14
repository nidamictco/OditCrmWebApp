// lib/features/lead_category/data/repositories/lead_category_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'dart:developer';



abstract class ILeadCategoryRepository {
  Stream<List<LeadsModel>> watchCategories();
  Future<String> addCategory({required String name});
  Future<void> updateCategory({required String id, required String name});
  Future<void> deleteCategory({required String id});
}

class LeadCategoryRepository implements ILeadCategoryRepository {
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS CATEGORY');

  LeadCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeadsModel>> watchCategories() {
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
  Future<String> addCategory({required String name}) async {
    final trimmedName = name.trim().toUpperCase();
    if (trimmedName.isEmpty) throw ArgumentError('Category name cannot be empty.');
    final StaffModel? user = await SessionService().getSavedUser();
    final docRef = await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name,
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// 🔹 Update an existing category's name, then propagate the new name
  /// to every Lead/Followup document that references this category via
  /// categoryId. The propagation is best-effort: if it fails, the rename
  /// itself is NOT rolled back and NOT reported as a failure to the caller —
  /// only logged. This matches the existing "sync failures are silent"
  /// pattern already used for the batch category-rename sync.
  @override
  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    // ── Normalize to match how the name is stored everywhere else ──────────
    // addCategory() uppercases; Lead/Followup toFirestore() uppercases
    // leadCategory before writing. Keeping this consistent prevents the
    // same case-mismatch bug already logged for inline "add category" dialogs.
    final trimmedName = name.trim().toUpperCase();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});

    // Fire the sync AFTER the category doc write succeeds, as required.
    // Errors inside are caught internally — they never bubble up here.
    await _syncCategoryNameToLeadsAndFollowups(
      categoryId: id,
      newCategoryName: trimmedName,
    );
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    await _collection.doc(id).delete();
  }

  // ── Sync helper ────────────────────────────────────────────────────────

  /// Propagates a category rename to all Lead + Followup documents that
  /// reference it via categoryId. Only the `leadCategory` display field is
  /// touched — categoryId and every other field are left untouched.
  ///
  /// - Uses WriteBatch, chunked at 450 ops to stay under Firestore's 500
  ///   per-batch write limit.
  /// - Leads are matched by a direct query on the LEADS collection.
  /// - Followups are matched via collectionGroup('FOLLOW_UPS'), which
  ///   requires a composite/collection-group index on leadCategoryId
  ///   (same index already required for the batch-rename design — verify
  ///   it's deployed in the Firestore console under Indexes > Collection
  ///   Group).
  /// - Never throws: a sync failure must not surface as a rename failure.
  Future<void> _syncCategoryNameToLeadsAndFollowups({
    required String categoryId,
    required String newCategoryName,
  }) async {
    try {
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
          .where('leadCategoryId', isEqualTo: categoryId)
          .get();

      final followUpsSnap = await _firestore
          .collectionGroup('FOLLOW_UPS')
          .where('leadCategoryId', isEqualTo: categoryId)
          .get();

      final transferLeadsSnap = await _firestore
          .collectionGroup('TRANSFER_LEADS')
          .where('leadCategoryId', isEqualTo: categoryId)
          .get();

      final allRefs = <DocumentReference<Map<String, dynamic>>>[
        ...leadsSnap.docs.map((d) => d.reference),
        ...followUpsSnap.docs.map((d) => d.reference),
        ...transferLeadsSnap.docs.map((d) => d.reference),
      ];

      if (allRefs.isEmpty) {
        log('[LeadCategoryRepository] syncCategoryName: no matching docs '
            'for categoryId=$categoryId');
        return;
      }

      const chunkSize = 450;
      for (var i = 0; i < allRefs.length; i += chunkSize) {
        final end = (i + chunkSize > allRefs.length) ? allRefs.length : i + chunkSize;
        final chunk = allRefs.sublist(i, end);

        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.update(ref, {'leadCategory': newCategoryName});
        }
        await batch.commit();

        log('[LeadCategoryRepository] syncCategoryName: committed batch '
            '${(i ~/ chunkSize) + 1} (${chunk.length} docs) for categoryId=$categoryId');
      }

      log('[LeadCategoryRepository] syncCategoryName: done — '
          '${leadsSnap.docs.length} leads, ${followUpsSnap.docs.length} followups '
          'updated for categoryId=$categoryId → "$newCategoryName"');
    } catch (e, st) {
      log('[LeadCategoryRepository] syncCategoryName ERROR for '
          'categoryId=$categoryId: $e\n$st');
    }
  }
} 