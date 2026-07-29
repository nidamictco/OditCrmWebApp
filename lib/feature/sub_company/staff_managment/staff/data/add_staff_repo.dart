import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import '../model/note_model.dart';
import '../model/staff_model.dart';

import '../../../../../core/constant/firebase_collections.dart';
import '../../../../../core/constant/firebase_const.dart';

class StaffRepository {
  final FirebaseFirestore _firestore;

  StaffRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final cloudinary = CloudinaryPublic('dqwde64fn', 'profile_image');

  // ─── Collection references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('STAFF');

  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      FirestorePath.companyCollection('DELETED_STAFF');

  // CollectionReference<Map<String, dynamic>> get _collection =>
  //     _firestore.collection('STAFF');
  //
  // CollectionReference<Map<String, dynamic>> get _deletedCollection =>
  //     _firestore.collection('DELETED_STAFF');

  // ─── Upload file to Cloudinary ────────────────────────────────────────────

  Future<String> uploadFile({
    required File file,
    required String folder,
  }) async {
    try {
      final CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
        ),
      );
      return res.secureUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Upload from bytes — used on Flutter Web where dart:io File is unavailable.
Future<String> uploadFileBytes({
  required Uint8List bytes,
  required String folder,
  required String fileName,
}) async {
  try {
    final CloudinaryResponse res = await cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: fileName,
        folder: folder,
      ),
    );
    return res.secureUrl;
  } catch (e) {
    throw Exception('Upload failed: $e');
  }
}

  // ─── Add ──────────────────────────────────────────────────────────────────

  Future<String> addStaff(
  StaffModel staff, {
  File? imageFile,
  Uint8List? imageBytes,   // ← add
  String? imageFileName,  // ← add
  File? documentFile,
  Uint8List? documentBytes,   // ← add
  String? documentFileName,   // ← add
}) async {
  // Check if phone number already exists globally in USERS collection
  final existingUser = await _firestore
      .collection("USERS")
      .where("phone", isEqualTo: staff.phone.trim())
      .limit(1)
      .get();

  if (existingUser.docs.isNotEmpty) {
    throw Exception("Phone number already exists.");
  }

  String? imageUrl = staff.imageUrl;
  String? documentUrl = staff.documentUrl;

  if (kIsWeb) {
    if (imageBytes != null && imageFileName != null) {
      imageUrl = await uploadFileBytes(
        bytes: imageBytes,
        folder: 'staff_images',
        fileName: imageFileName,
      );
    }
    if (documentBytes != null && documentFileName != null) {
      documentUrl = await uploadFileBytes(
        bytes: documentBytes,
        folder: 'staff_docs',
        fileName: documentFileName,
      );
    }
  } else {
    if (imageFile != null) {
      imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
    }
    if (documentFile != null) {
      documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
    }
  }

  final data = staff.copyWith(
    imageUrl: imageUrl,
    documentUrl: documentUrl,
    createdAt: DateTime.now(),
  );

  final docRef = _collection.doc();               
final finalData = data.copyWith(id: docRef.id);  
await docRef.set(finalData.toMap()); 
  log('[StaffRepository] Staff added: ${docRef.id}');
  return docRef.id;
}
  // ─── Update ───────────────────────────────────────────────────────────────

Future<void> updateStaff(
  StaffModel staff, {
  File? imageFile,
  Uint8List? imageBytes,
  String? imageFileName,
  File? documentFile,
  Uint8List? documentBytes,
  String? documentFileName,
}) async {
  assert(staff.id != null, 'ID must not be null for update');

  String? imageUrl = staff.imageUrl;   // already null if user removed it
  String? documentUrl = staff.documentUrl;

  if (kIsWeb) {
    if (imageBytes != null && imageFileName != null) {
      imageUrl = await uploadFileBytes(bytes: imageBytes, folder: 'staff_images', fileName: imageFileName);
    }
    if (documentBytes != null && documentFileName != null) {
      documentUrl = await uploadFileBytes(bytes: documentBytes, folder: 'staff_docs', fileName: documentFileName);
    }
  } else {
    if (imageFile != null) {
      imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
    }
    if (documentFile != null) {
      documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
    }
  }

  // Preserve designation if it is Company_Admin
  final doc = await _collection.doc(staff.id).get();
  String? originalDesignation;
  String? originalDesignationId;
  String? originalStaffType;
  String? originalPhone;
  if (doc.exists) {
    originalDesignation = doc.data()?['designation'] as String?;
    originalDesignationId = doc.data()?['designationId'] as String?;
    originalStaffType = doc.data()?['staffType'] as String?;
    originalPhone = doc.data()?['phone'] as String?;
  }

  // If phone number has changed, perform global uniqueness check
  if (originalPhone != staff.phone) {
    final existingUser = await _firestore
        .collection("USERS")
        .where("phone", isEqualTo: staff.phone.trim())
        .get();

    for (var userDoc in existingUser.docs) {
      if (userDoc.id != staff.id) {
        throw Exception("Phone number already exists.");
      }
    }
  }

  final isCompanyAdmin = originalDesignation == "Company_Admin";
  final finalStaff = isCompanyAdmin
      ? staff.copyWith(
          designation: originalDesignation,
          designationId: originalDesignationId,
          staffType: originalStaffType,
        )
      : staff;

  // Use set with merge:false on only the changed fields, 
  // so null imageUrl is explicitly written to Firestore
  final updatedData = finalStaff
      .copyWith(imageUrl: imageUrl, documentUrl: documentUrl)
      .toMap()
    ..remove('createdAt');

  // ← explicitly null out imageUrl in Firestore if removed
  if (imageUrl == null) {
    updatedData['imageUrl'] = null;
  }

  await _collection.doc(staff.id).update(updatedData);
  log('[StaffRepository] Staff updated: ${staff.id}');
  // Fire the sync AFTER the staff doc write succeeds.
  // Errors inside are caught internally — they never bubble up here.
  await _syncStaffNameToLeadsAndFollowups(
    staffId: staff.id!,
    newStaffName: finalStaff.name,
  );
}

// ── Sync helper ──────────────────────────────────────────────────────────

  /// Propagates a staff name change to all LEADS, FOLLOW_UPS, and
  /// TRANSFER_LEADS documents that reference this staff member.
  ///
  /// - LEADS + FOLLOW_UPS: matched on `assignedStaffId`, updates
  ///   `assignedStaff`.
  /// - TRANSFER_LEADS: matched separately on `fromStaffId` (updates
  ///   `fromStaff`) and `toStaffId` (updates `toStaff`), since a transfer
  ///   doc can reference two different staff members.
  /// - Uses WriteBatch, chunked at 450 ops to stay under Firestore's 500
  ///   per-batch write limit.
  /// - Never throws: a sync failure must not surface as a staff-update
  ///   failure.
  Future<void> _syncStaffNameToLeadsAndFollowups({
    required String staffId,
    required String newStaffName,
  }) async {
    try {
      // final leadsSnap = await _collection.firestore
      //     .collection(_collection.path.replaceFirst('STAFF', 'LEADS'))
      //     .where('assignedStaffId', isEqualTo: staffId)
      //     .get();
      final leadsSnap = await FirestorePath.companyCollection('LEADS')
    .where('assignedStaffId', isEqualTo: staffId)
    .get();

    final leadCreatedSnap = await FirestorePath.companyCollection('LEADS')
    .where('createdById', isEqualTo: staffId)
    .get();

      final followUpsSnap = await _firestore
          .collectionGroup('FOLLOW_UPS')
          .where('assignedStaffId', isEqualTo: staffId)
          .get();

      final transferFromSnap = await _firestore
          .collectionGroup('TRANSFER_LEADS')
          .where('fromStaffId', isEqualTo: staffId)
          .get();

      final transferToSnap = await _firestore
          .collectionGroup('TRANSFER_LEADS')
          .where('toStaffId', isEqualTo: staffId)
          .get();

      final activitySnap = await _firestore.collectionGroup('ACTIVITIES')
      .where('changedById', isEqualTo: staffId)
      .get();


       final deletedLeadsSnap =
          await FirestorePath.companyCollection('DELETED_LEADS')
              .where('assignedStaffId', isEqualTo: staffId)
              .get();


       final leadSourceSnap =
          await FirestorePath.companyCollection('LEAD SOURCE')
              .where('idOfCreator', isEqualTo: staffId)
              .get();

        final leadsCategorySnap =
          await FirestorePath.companyCollection('LEADS CATEGORY')
              .where('idOfCreator', isEqualTo: staffId)
              .get();

      final leadsStageSnap =
          await FirestorePath.companyCollection('LEADS STAGE')
              .where('idOfCreator', isEqualTo: staffId)
              .get();

       final leadsTagSnap = await _firestore
          .collectionGroup('LEADS TAG')
          .where('idOfCreator', isEqualTo: staffId)
          .get();

      final subCategorySnap = await _firestore
          .collectionGroup('SUB CATEGORY')
          .where('idOfCreator', isEqualTo: staffId)
          .get();

      final updates = <(DocumentReference<Map<String, dynamic>>, String)>[
        ...leadsSnap.docs.map((d) => (d.reference, 'assignedStaff')),
        ...leadCreatedSnap.docs.map((d) => (d.reference, 'createdBy')),
        ...followUpsSnap.docs.map((d) => (d.reference, 'assignedStaff')),
        ...transferFromSnap.docs.map((d) => (d.reference, 'fromStaff')),
        ...transferToSnap.docs.map((d) => (d.reference, 'toStaff')),
        ...activitySnap.docs.map((d)=>(d.reference,'changedBy')),
         ...deletedLeadsSnap.docs.map((d) => (d.reference, 'assignedStaff')),
        ...leadSourceSnap.docs.map((d) => (d.reference, 'createdBy')),
        ...leadsCategorySnap.docs.map((d) => (d.reference, 'createdBy')),
        ...leadsStageSnap.docs.map((d) => (d.reference, 'createdBy')),
        ...leadsTagSnap.docs.map((d) => (d.reference, 'createdBy')),
        ...subCategorySnap.docs.map((d) => (d.reference, 'createdBy')),
      ];

      if (updates.isEmpty) {
        log('[StaffRepository] syncStaffName: no matching docs '
            'for staffId=$staffId');
        return;
      }

      const chunkSize = 450;
      for (var i = 0; i < updates.length; i += chunkSize) {
        final end =
            (i + chunkSize > updates.length) ? updates.length : i + chunkSize;
        final chunk = updates.sublist(i, end);

        final batch = _firestore.batch();
        for (final (ref, field) in chunk) {
          batch.update(ref, {field: newStaffName});
        }
        await batch.commit();

        log('[StaffRepository] syncStaffName: committed batch '
            '${(i ~/ chunkSize) + 1} (${chunk.length} docs) for staffId=$staffId');
      }

      log('[StaffRepository] syncStaffName: done — '
          '${leadsSnap.docs.length} leads, ${followUpsSnap.docs.length} followups, '
          '${transferFromSnap.docs.length + transferToSnap.docs.length} transfers '
          'updated for staffId=$staffId → "$newStaffName"');
    } catch (e, st) {
      log('[StaffRepository] syncStaffName ERROR for staffId=$staffId: $e\n$st');
    }
  }

  // ─── Update single field ──────────────────────────────────────────────────

  Future<void> updateStaffField(
      String id, Map<String, dynamic> fields) async {
    await _collection.doc(id).update(fields);
    log('[StaffRepository] Staff field updated: $id → $fields');
  }

  // ─── Soft delete (move to DELETED_STAFF) ─────────────────────────────────

Future<void> moveToDeleted(StaffModel staff) async {
  assert(staff.id != null, 'ID must not be null');

  final deletedStaff = staff.copyWith(deletedAt: DateTime.now());

  // 1. Write the parent doc at the same ID under DELETED_STAFF
  await _deletedCollection.doc(staff.id).set(deletedStaff.toMap());

  // 2. Carry the NOTES subcollection over with it
  await _moveSubcollection(
    fromDoc: _collection.doc(staff.id),
    toDoc: _deletedCollection.doc(staff.id),
    subcollection: 'NOTES',
  );

  // 3. Now it's safe to remove the original
  await _collection.doc(staff.id).delete();

  log('[StaffRepository] Staff moved to DELETED_STAFF: ${staff.id}');
}


/// Copies every document in [subcollection] from [fromDoc] to [toDoc],
/// preserving each doc's ID, then deletes the originals.
/// Used to carry NOTES along when a staff doc moves between
/// STAFF and DELETED_STAFF.
Future<void> _moveSubcollection({
  required DocumentReference<Map<String, dynamic>> fromDoc,
  required DocumentReference<Map<String, dynamic>> toDoc,
  required String subcollection,
}) async {
  final snap = await fromDoc.collection(subcollection).get();
  if (snap.docs.isEmpty) return;

  final batch = _firestore.batch();
  for (final doc in snap.docs) {
    batch.set(toDoc.collection(subcollection).doc(doc.id), doc.data());
    batch.delete(doc.reference);
  }
  await batch.commit();

  log('[StaffRepository] Moved ${snap.docs.length} "$subcollection" docs '
      '${fromDoc.path} → ${toDoc.path}');
}
  // ─── Hard delete ──────────────────────────────────────────────────────────

  Future<void> deleteStaff(String id) async {
    await _collection.doc(id).delete();
    log('[StaffRepository] Staff deleted: $id');
  }

Future<void> deleteStaffPermanently(String id) async {
  await _deletedCollection.doc(id).update({'isPurged': true});
  log('[StaffRepository] Staff purged (kept in Firestore, hidden from UI): $id');
}
  // ─── Fetch all ────────────────────────────────────────────────────────────

  Future<List<StaffModel>> fetchAll() async {
    final snap =
        await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs.map(StaffModel.fromFirestore).toList();
  }

  // ─── Real-time stream ─────────────────────────────────────────────────────

  Stream<List<StaffModel>> streamAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StaffModel.fromFirestore).toList());
  }

  // ─── Fetch single ─────────────────────────────────────────────────────────

  Future<StaffModel?> getStaff(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return StaffModel.fromFirestore(doc);
  }

  // ─── Restore from deleted ─────────────────────────────────────────────────
Future<String> restoreStaff(
  StaffModel staff, {
  File? imageFile,
  File? documentFile,
}) async {
  String? imageUrl = staff.imageUrl;
  String? documentUrl = staff.documentUrl;

  if (imageFile != null) {
    imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
  }
  if (documentFile != null) {
    documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
  }

  final finalStaff = staff.copyWith(
    imageUrl: imageUrl,
    documentUrl: documentUrl,
    // createdAt: DateTime.now(),
  );

  // 1. Write back to STAFF at the same ID
  await _collection.doc(staff.id).set(finalStaff.toMap());

  // 2. Carry NOTES back with it
  await _moveSubcollection(
    fromDoc: _deletedCollection.doc(staff.id),
    toDoc: _collection.doc(staff.id),
    subcollection: 'NOTES',
  );

  // 3. Now safe to remove from DELETED_STAFF
  await _deletedCollection.doc(staff.id).delete();

  log('[StaffRepository] Staff restored: ${staff.id}');
  return staff.id!;
}

Future<List<StaffModel>> fetchDeletedStaff() async {
  final snap = await _deletedCollection
      .orderBy('createdAt', descending: true)
      .get();
  return snap.docs
      .map(StaffModel.fromFirestore)
      .where((s) => !s.isPurged)
      .toList();
}

  // ─── Notes ────────────────────────────────────────────────────────────────

  String _generateNoteId() {
    final now = DateTime.now();
    return 'NOTE'
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> addNote(String staffId, NoteModel note) async {
    if (staffId.trim().isEmpty) {
      throw ArgumentError('Staff ID cannot be empty.');
    }

    final noteId = _generateNoteId();

    await _collection
        .doc(staffId)
        .collection('NOTES')
        .doc(noteId)
        .set(note.toFirestore());

    log('[StaffRepository] Note added for staff: $staffId → $noteId');
  }

  Future<List<NoteModel>> fetchNotes(String staffId) async {
    final snap = await _collection
        .doc(staffId)
        .collection('NOTES')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteNote(String staffId, String noteId) async {
    await _collection
        .doc(staffId)
        .collection('NOTES')
        .doc(noteId)
        .delete();
    log('[StaffRepository] Note deleted: $noteId');
  }



  // ─── One-time migration: backfill missing `id` field ─────────────────────

/// Adds the `id` field to any existing STAFF / DELETED_STAFF documents
/// that don't already have it (i.e. docs created before `toMap()` started
/// writing `id`).
///
/// Safe to run multiple times — docs that already have a matching `id`
/// are skipped, so it's idempotent.
Future<void> migrateMissingStaffIds() async {
  await _backfillIdsFor(_collection, label: 'STAFF');
  await _backfillIdsFor(_deletedCollection, label: 'DELETED_STAFF');
}

Future<void> _backfillIdsFor(
  CollectionReference<Map<String, dynamic>> collection, {
  required String label,
}) async {
  final snap = await collection.get();

  final toFix = snap.docs.where((doc) {
    final existingId = doc.data()['id'] as String?;
    return existingId == null || existingId != doc.id;
  }).toList();

  if (toFix.isEmpty) {
    log('[StaffRepository] migrateMissingStaffIds: $label already up to date '
        '(${snap.docs.length} docs checked)');
    return;
  }

  const chunkSize = 450;
  for (var i = 0; i < toFix.length; i += chunkSize) {
    final end = (i + chunkSize > toFix.length) ? toFix.length : i + chunkSize;
    final chunk = toFix.sublist(i, end);

    final batch = _firestore.batch();
    for (final doc in chunk) {
      batch.update(doc.reference, {'id': doc.id});
    }
    await batch.commit();

    log('[StaffRepository] migrateMissingStaffIds: $label batch '
        '${(i ~/ chunkSize) + 1} — ${chunk.length} docs updated');
  }

  log('[StaffRepository] migrateMissingStaffIds: $label done — '
      '${toFix.length}/${snap.docs.length} docs backfilled');
}
}


