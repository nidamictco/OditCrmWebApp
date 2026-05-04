import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oxdo/feature/staff_managment/add_staff/model/staff_model.dart';

class StaffRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  StaffRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ─── Collection reference ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('STAFF');

  // ─── Upload file to Firebase Storage ─────────────────────────────────────

  /// Uploads [file] to Storage under [folder]/[fileName].
  /// Returns the public download URL.
  Future<String> _uploadFile({ 
    required File file,
    required String folder,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('$folder/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  // ─── Add ──────────────────────────────────────────────────────────────────

  /// Saves a new staff member. Optionally uploads [imageFile] and [documentFile].
  /// Returns the new Firestore document ID.
  Future<String> addStaff(
    StaffModel staff, {
    File? imageFile,
    File? documentFile,
  }) async {
    String? imageUrl;
    String? documentUrl;

    // Upload image if provided
    if (imageFile != null) {
      final ext = imageFile.path.split('.').last;
      final fileName = 'staff_${DateTime.now().millisecondsSinceEpoch}.$ext';
      imageUrl = await _uploadFile(
        file: imageFile,
        folder: 'staff_images',
        fileName: fileName,
      );
      log('[StaffRepository] Image uploaded: $imageUrl');
    }

    // Upload document if provided
    if (documentFile != null) {
      final ext = documentFile.path.split('.').last;
      final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.$ext';
      documentUrl = await _uploadFile(
        file: documentFile,
        folder: 'staff_documents',
        fileName: fileName,
      );
      log('[StaffRepository] Document uploaded: $documentUrl');
    }

    final finalStaff = staff.copyWith(
      imageUrl: imageUrl,
      documentUrl: documentUrl,
      createdAt: DateTime.now(),
    );

    final doc = await _collection.add(finalStaff.toMap());
    log('[StaffRepository] Staff added: ${doc.id}');
    return doc.id;
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  /// Updates an existing staff document. Optionally re-uploads files.
  Future<void> updateStaff(
    StaffModel staff, {
    File? imageFile,
    File? documentFile,
  }) async {
    assert(staff.id != null, 'ID must not be null for update');

    String? imageUrl = staff.imageUrl;
    String? documentUrl = staff.documentUrl;

    if (imageFile != null) {
      final ext = imageFile.path.split('.').last;
      final fileName = 'staff_${staff.id}.$ext';
      imageUrl = await _uploadFile(
        file: imageFile,
        folder: 'staff_images',
        fileName: fileName,
      );
    }

    if (documentFile != null) {
      final ext = documentFile.path.split('.').last;
      final fileName = 'doc_${staff.id}.$ext';
      documentUrl = await _uploadFile(
        file: documentFile,
        folder: 'staff_documents',
        fileName: fileName,
      );
    }

    final updatedStaff = staff.copyWith(
      imageUrl: imageUrl,
      documentUrl: documentUrl,
    );

    await _collection.doc(staff.id).update(updatedStaff.toMap());
    log('[StaffRepository] Staff updated: ${staff.id}');
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteStaff(String id) async {
    await _collection.doc(id).delete();
    log('[StaffRepository] Staff deleted: $id');
  }

  // ─── Fetch single ─────────────────────────────────────────────────────────

  Future<StaffModel?> getStaff(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return StaffModel.fromFirestore(doc);
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
}