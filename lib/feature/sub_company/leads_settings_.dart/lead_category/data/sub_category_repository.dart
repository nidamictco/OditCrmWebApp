import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

import 'dart:developer';

abstract class ISubCategoryRepository {
  Stream<List<LeadsModel>> watchSubCategories();
  Future<void> addSubCategory({required String name});
  Future<void> updateSubCategory({required String id, required String name});
  Future<void> deleteSubCategory({required String id});
}

class SubCategoryRepository implements ISubCategoryRepository {
  final String categoryId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS CATEGORY')
          .doc(categoryId)
          .collection('SUB CATEGORY');

  SubCategoryRepository({
    required this.categoryId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeadsModel>> watchSubCategories() {
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
  Future<void> addSubCategory({required String name}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Sub Category name cannot be empty.');
    }
    final StaffModel? user = await SessionService().getSavedUser();
    await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name,
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Update an existing subcategory's name, then propagate the new name
  /// to every Lead/Followup document referencing it via leadSubCategoryId.
  @override
  Future<void> updateSubCategory({
    required String id,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Sub Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});

    await _syncSubCategoryNameToLeadsAndFollowups(
      subCategoryId: id,
      newSubCategoryName: trimmedName,
    );
  }

  @override
  Future<void> deleteSubCategory({required String id}) async {
    await _collection.doc(id).delete();
  }

  // ── Sync helper ────────────────────────────────────────────────────────

  /// Propagates a sub-category rename to Lead + Followup docs referencing
  /// it via leadSubCategoryId. Firestore auto-generated doc IDs are globally
  /// unique, so matching purely on leadSubCategoryId (without also
  /// constraining by parent categoryId) is safe and sufficient.
  Future<void> _syncSubCategoryNameToLeadsAndFollowups({
    required String subCategoryId,
    required String newSubCategoryName,
  }) async {
    try {
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
          .where('leadSubCategoryId', isEqualTo: subCategoryId)
          .get();

      // Requires a collection-group index on FOLLOW_UPS.leadSubCategoryId.
      final followUpsSnap = await _firestore
          .collectionGroup('FOLLOW_UPS')
          .where('leadSubCategoryId', isEqualTo: subCategoryId)
          .get();

      final transferLeadsSnap = await _firestore
          .collectionGroup('TRANSFER_LEADS')
          .where('leadSubCategoryId', isEqualTo: subCategoryId)
          .get();

      final allRefs = <DocumentReference<Map<String, dynamic>>>[
        ...leadsSnap.docs.map((d) => d.reference),
        ...followUpsSnap.docs.map((d) => d.reference),
        ...transferLeadsSnap.docs.map((d) => d.reference),
      ];

      if (allRefs.isEmpty) {
        log('[SubCategoryRepository] syncSubCategoryName: no matching docs '
            'for subCategoryId=$subCategoryId');
        return;
      }

      const chunkSize = 450;
      for (var i = 0; i < allRefs.length; i += chunkSize) {
        final end = (i + chunkSize > allRefs.length) ? allRefs.length : i + chunkSize;
        final chunk = allRefs.sublist(i, end);

        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.update(ref, {'leadSubCategory': newSubCategoryName});
        }
        await batch.commit();
      }

      log('[SubCategoryRepository] syncSubCategoryName: done — '
          '${leadsSnap.docs.length} leads, ${followUpsSnap.docs.length} followups '
          'updated for subCategoryId=$subCategoryId → "$newSubCategoryName"');
    } catch (e, st) {
      log('[SubCategoryRepository] syncSubCategoryName ERROR for '
          'subCategoryId=$subCategoryId: $e\n$st');
    }
  }
}

// abstract class ISubCategoryRepository {
//   Stream<List<LeadsModel>> watchSubCategories();
//   Future<void> addSubCategory({required String name});
//   Future<void> updateSubCategory({required String id, required String name});
//   Future<void> deleteSubCategory({required String id});
// }

// class SubCategoryRepository implements ISubCategoryRepository {
//   final String categoryId;

//   // Firestore collection reference
//   CollectionReference<Map<String, dynamic>> get _collection =>
//       FirestorePath.companyCollection('LEADS CATEGORY')
//           .doc(categoryId)
//           .collection('SUB CATEGORY');

//   SubCategoryRepository({
//     required this.categoryId,
//   });

//   /// 🔹 Stream all subcategories ordered by creation date
//   @override
//   Stream<List<LeadsModel>> watchSubCategories() {
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
//   Future<void> addSubCategory({
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Sub Category name cannot be empty.');
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
//   Future<void> updateSubCategory({
//     required String id,
//     required String name,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Sub Category name cannot be empty.');
//     }

//     await _collection.doc(id).update({'name': trimmedName});
//   }

//   /// 🔹 Delete a subcategory
//   @override
//   Future<void> deleteSubCategory({required String id}) async {
//     await _collection.doc(id).delete();
//   }
// }
