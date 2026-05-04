// lib/features/lead_category/data/repositories/lead_category_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/model/user_model.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/model/lead_category_model.dart';

abstract class ILeadSourceRepository {
  Stream<List<LeadsModel>> watchSource();
  Future<void> addSource({required String name, });
  Future<void> updateSource({required String id, required String name});
  Future<void> deleteSource({required String id});
}

class LeadSourceRepository implements ILeadSourceRepository {
  final FirebaseFirestore _firestore;

  // Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('LEAD SOURCE');

  LeadSourceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🔹 Stream all categories ordered by creation date
  // In lead_category_repository.dart
@override
Stream<List<LeadsModel>> watchSource() {
  return _collection
      .orderBy('createdAt', descending: false) 
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
            .toList(), // already creates a new list, but be explicit:
      );
}

  /// 🔹 Add a new category
  @override
  Future<void> addSource({
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Lead Source name cannot be empty.');
    }
    final UserModel? user = await SessionService().getSavedUser();
    await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name, 
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } 

  /// 🔹 Update an existing category's name
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
  }

  /// 🔹 Delete a category
  @override
  Future<void> deleteSource({required String id}) async {
    await _collection.doc(id).delete();
  }
}