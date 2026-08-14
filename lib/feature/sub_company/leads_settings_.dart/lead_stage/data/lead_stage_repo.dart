
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';


import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

abstract class ILeadStageRepository {
  Stream<List<LeadsModel>> watchCategories();
  Future<void> addCategory({required String name, required bool tagMandatory});
  Future<void> updateCategory({required String id, required String name});
  Future<void> updateTagMandatory({required String id, required bool tagMandatory});
  Future<void> deleteCategory({required String id});
}

class LeadStageRepository implements ILeadStageRepository {
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS STAGE');

  LeadStageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<LeadsModel>> watchCategories() {
    _checkAndSeedDefaultStages();
    return _collection.snapshots().map((snapshot) {
      final stages = snapshot.docs
          .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
          .toList();

      const List<String> defaultStagesOrder = [
        'NEW', 'FOLLOWUP', 'CLOSED', 'REJECTED', 'TRANSFERRED'
      ];

      stages.sort((a, b) {
        final aUpper = a.name.toUpperCase();
        final bUpper = b.name.toUpperCase();
        final aIsDefault = a.isDefault || defaultStagesOrder.contains(aUpper);
        final bIsDefault = b.isDefault || defaultStagesOrder.contains(bUpper);

        if (aIsDefault && bIsDefault) {
          final aIdx = defaultStagesOrder.indexOf(aUpper);
          final bIdx = defaultStagesOrder.indexOf(bUpper);
          final normalizedAIdx = aIdx == -1 ? 99 : aIdx;
          final normalizedBIdx = bIdx == -1 ? 99 : bIdx;
          return normalizedAIdx.compareTo(normalizedBIdx);
        } else if (aIsDefault) {
          return -1;
        } else if (bIsDefault) {
          return 1;
        } else {
          return a.createdAt.compareTo(b.createdAt);
        }
      });
      return stages;
    });
  }

  Future<void> _checkAndSeedDefaultStages() async {
    try {
      final snapshot = await _collection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        final defaultStages = ['New', 'Followup', 'Closed', 'Rejected', 'Transferred'];
        for (var stageName in defaultStages) {
          final docRef = _collection.doc();
          batch.set(docRef, {
            'name': stageName,
            'createdBy': 'System',
            'idOfCreator': 'system',
            'createdAt': FieldValue.serverTimestamp(),
            'isDefault': true,
          });
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  @override
  Future<void> addCategory({
    required String name,
    required bool tagMandatory,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    final StaffModel? user = await SessionService().getSavedUser();
    await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name,
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
      'isDefault': false,
      'tagMandatory': tagMandatory,
    });
  }

  /// 🔹 Update an existing stage's name, then propagate the new name to
  /// every Lead/Followup document that references this stage via
  /// leadStageId. Default stages are already blocked from renaming above,
  /// so sync only ever fires for custom stages.
  @override
  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final isDefault = doc.data()?['isDefault'] as bool? ?? false;
      if (isDefault) {
        throw Exception('This is a default lead stage and cannot be edited or deleted.');
      }
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});

    // Propagate after the stage doc write succeeds. Silent on failure —
    // never surfaces as a rename failure.
    await _syncStageNameToLeadsAndFollowups(
      stageId: id,
      newStageName: trimmedName,
    );
  }

  @override
  Future<void> updateTagMandatory({
    required String id,
    required bool tagMandatory,
  }) async {
    await _collection.doc(id).update({'tagMandatory': tagMandatory});
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final isDefault = doc.data()?['isDefault'] as bool? ?? false;
      if (isDefault) {
        throw Exception('This is a default lead stage and cannot be edited or deleted.');
      }
    }
    await _collection.doc(id).delete();
  }

  // ── Sync helper ────────────────────────────────────────────────────────

  /// Propagates a stage rename to all Lead + Followup documents referencing
  /// it via leadStageId. Only `leadStage` is touched — leadStageId and all
  /// other fields untouched. WriteBatch, chunked at 450, never throws.
  Future<void> _syncStageNameToLeadsAndFollowups({
    required String stageId,
    required String newStageName,
  }) async {
    try {
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
          .where('leadStageId', isEqualTo: stageId)
          .get();

      // Requires a collection-group index on FOLLOW_UPS.leadStageId.
      final followUpsSnap = await _firestore
          .collectionGroup('FOLLOW_UPS')
          .where('leadStageId', isEqualTo: stageId)
          .get();

      final transferLeadsSnap = await _firestore
          .collectionGroup('TRANSFER_LEADS')
          .where('leadStageId', isEqualTo: stageId)
          .get();

      final allRefs = <DocumentReference<Map<String, dynamic>>>[
        ...leadsSnap.docs.map((d) => d.reference),
        ...followUpsSnap.docs.map((d) => d.reference),
        ...transferLeadsSnap.docs.map((d) => d.reference),
      ];

      if (allRefs.isEmpty) {
        log('[LeadStageRepository] syncStageName: no matching docs for stageId=$stageId');
        return;
      }

      const chunkSize = 450;
      for (var i = 0; i < allRefs.length; i += chunkSize) {
        final end = (i + chunkSize > allRefs.length) ? allRefs.length : i + chunkSize;
        final chunk = allRefs.sublist(i, end);

        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.update(ref, {'leadStage': newStageName});
        }
        await batch.commit();
      }

      log('[LeadStageRepository] syncStageName: done — '
          '${leadsSnap.docs.length} leads, ${followUpsSnap.docs.length} followups '
          'updated for stageId=$stageId → "$newStageName"');
    } catch (e, st) {
      log('[LeadStageRepository] syncStageName ERROR for stageId=$stageId: $e\n$st');
    }
  }
}






// abstract class ILeadStageRepository {
//   Stream<List<LeadsModel>> watchCategories();
//   Future<void> addCategory({required String name, required bool tagMandatory });
//   Future<void> updateCategory({required String id, required String name});
//    Future<void> updateTagMandatory({required String id, required bool tagMandatory});
//   Future<void> deleteCategory({required String id});
// }

// class LeadStageRepository implements ILeadStageRepository {
//   final FirebaseFirestore _firestore;

//   // Firestore collection reference
//   CollectionReference<Map<String, dynamic>> get _collection =>
//       FirestorePath.companyCollection('LEADS STAGE');

//   LeadStageRepository({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance;

//   /// 🔹 Stream all categories ordered by creation date (with default stages first in specific order)
//   @override
//   Stream<List<LeadsModel>> watchCategories() {
//     _checkAndSeedDefaultStages();
//     return _collection
//         .snapshots()
//         .map(
//           (snapshot) {
//             final stages = snapshot.docs
//                 .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
//                 .toList();

//             const List<String> defaultStagesOrder = [
//               'NEW',
//               'FOLLOWUP',
//               'CLOSED',
//               'REJECTED',
//               'TRANSFERRED'
//             ];

//             stages.sort((a, b) {
//               final aUpper = a.name.toUpperCase();
//               final bUpper = b.name.toUpperCase();
//               final aIsDefault = a.isDefault || defaultStagesOrder.contains(aUpper);
//               final bIsDefault = b.isDefault || defaultStagesOrder.contains(bUpper);

//               if (aIsDefault && bIsDefault) {
//                 final aIdx = defaultStagesOrder.indexOf(aUpper);
//                 final bIdx = defaultStagesOrder.indexOf(bUpper);
//                 final normalizedAIdx = aIdx == -1 ? 99 : aIdx;
//                 final normalizedBIdx = bIdx == -1 ? 99 : bIdx;
//                 return normalizedAIdx.compareTo(normalizedBIdx);
//               } else if (aIsDefault) {
//                 return -1;
//               } else if (bIsDefault) {
//                 return 1;
//               } else {
//                 return a.createdAt.compareTo(b.createdAt);
//               }
//             });
//             return stages;
//           },
//         );
//   }

//   Future<void> _checkAndSeedDefaultStages() async {
//     try {
//       final snapshot = await _collection.limit(1).get();
//       if (snapshot.docs.isEmpty) {
//         final batch = _firestore.batch();
//         final defaultStages = ['New', 'Followup', 'Closed', 'Rejected', 'Transferred'];
//         for (var stageName in defaultStages) {
//           final docRef = _collection.doc();
//           batch.set(docRef, {
//             'name': stageName,
//             'createdBy': 'System',
//             'idOfCreator': 'system',
//             'createdAt': FieldValue.serverTimestamp(),
//             'isDefault': true,
//           });
//         }
//         await batch.commit();
//       }
//     } catch (_) {}
//   }

//   /// 🔹 Add a new category
//   @override
//   Future<void> addCategory({
//     required String name,
//     required bool tagMandatory,
//   }) async {
//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Category name cannot be empty.');
//     }
//     final StaffModel? user = await SessionService().getSavedUser();
//     await _collection.add({
//       'name': trimmedName,
//       'createdBy': user?.name, 
//       'idOfCreator': user?.id,
//       'createdAt': FieldValue.serverTimestamp(),
//       'isDefault': false,
//       'tagMandatory': tagMandatory,
//     });
//   } 

//   /// 🔹 Update an existing category's name
//   @override
//   Future<void> updateCategory({
//     required String id,
//     required String name,
//   }) async {
//     final doc = await _collection.doc(id).get();
//     if (doc.exists) {
//       final isDefault = doc.data()?['isDefault'] as bool? ?? false;
//       if (isDefault) {
//         throw Exception('This is a default lead stage and cannot be edited or deleted.');
//       }
//     }

//     final trimmedName = name.trim();
//     if (trimmedName.isEmpty) {
//       throw ArgumentError('Category name cannot be empty.');
//     }

//     await _collection.doc(id).update({'name': trimmedName});
//   }

//   @override
// Future<void> updateTagMandatory({
//   required String id,
//   required bool tagMandatory,
// }) async {
//   await _collection.doc(id).update({'tagMandatory': tagMandatory});
// }

//   /// 🔹 Delete a category
//   @override
//   Future<void> deleteCategory({required String id}) async {
//     final doc = await _collection.doc(id).get();
//     if (doc.exists) {
//       final isDefault = doc.data()?['isDefault'] as bool? ?? false;
//       if (isDefault) {
//         throw Exception('This is a default lead stage and cannot be edited or deleted.');
//       }
//     }
//     await _collection.doc(id).delete();
//   }
// }