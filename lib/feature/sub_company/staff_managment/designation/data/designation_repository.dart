import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/designation_model.dart';
import '../../../../../core/constant/firebase_const.dart';

class DesignationRepository {
  final FirebaseFirestore _firestore;

  DesignationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('DESIGNATIONS');

  /// Add a new designation, returns the new document ID
  Future<String> addDesignation(DesignationModel designation) async {
    final doc = await _collection.add(designation.toMap());
    return doc.id;
  }

  /// Update an existing designation
  Future<void> updateDesignation(DesignationModel designation) async {
    assert(designation.id != null, 'ID must not be null for update');
    await _collection.doc(designation.id).update(designation.toMap());
  }

  /// Delete a designation by ID
  Future<void> deleteDesignation(String id) async {
    await _collection.doc(id).delete();
  }

  /// Fetch a single designation
  Future<DesignationModel?> getDesignation(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return DesignationModel.fromFirestore(doc);
  }

  /// Stream all designations (real-time)
  Stream<List<DesignationModel>> streamAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DesignationModel.fromFirestore).toList());
  }

  /// One-time fetch of all designations
  Future<List<DesignationModel>> fetchAll() async {
    final snap =
        await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs.map(DesignationModel.fromFirestore).toList();
  }
}