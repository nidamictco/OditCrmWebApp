import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

abstract class ISubCategoryRepository {
  Stream<List<LeadsModel>> watchSubCategories();
  Future<void> addSubCategory({required String name});
  Future<void> updateSubCategory({required String id, required String name});
  Future<void> deleteSubCategory({required String id});
}

class SubCategoryRepository implements ISubCategoryRepository {
  final String categoryId;

  // Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS CATEGORY')
          .doc(categoryId)
          .collection('SUB CATEGORY');

  SubCategoryRepository({
    required this.categoryId,
  });

  /// 🔹 Stream all subcategories ordered by creation date
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

  /// 🔹 Add a new subcategory
  @override
  Future<void> addSubCategory({
    required String name,
  }) async {
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

  /// 🔹 Update an existing subcategory's name
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
  }

  /// 🔹 Delete a subcategory
  @override
  Future<void> deleteSubCategory({required String id}) async {
    await _collection.doc(id).delete();
  }
}
