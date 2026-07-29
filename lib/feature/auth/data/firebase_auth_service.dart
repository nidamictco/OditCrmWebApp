import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constant/firebase_collections.dart';
import '../../../core/constant/firebase_const.dart';
import '../../sub_company/staff_managment/staff/model/staff_model.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // CollectionReference<Map<String, dynamic>> get _staff =>
  //     _firestore.collection('STAFF');

  CollectionReference<Map<String, dynamic>> get staff =>
      FirestorePath.companyCollection(DBCollections.staff);

  static CollectionReference<Map<String, dynamic>> get users =>
      FirebaseFirestore.instance.collection(DBCollections.users);

  Future<StaffModel> login({
    required String phoneNo,
    required String password,
  }) async {
    try {
      // ====================================================
      // 1. CHECK USERS COLLECTION
      // ====================================================

      final userQuery = await users
          .where('phone', isEqualTo: phoneNo.trim())
          .limit(1)
          .get();

      StaffModel? userModel;

      if (userQuery.docs.isNotEmpty) {
        final doc = userQuery.docs.first;
        final data = doc.data();

        if ((data['password'] ?? '') != password) {
          throw AuthException('Incorrect password.');
        }

        if (isInactiveStatus(data['status'])) {
          throw const AuthException(
            'Your account has been deactivated. Please contact your administrator.',
          );
        }

        userModel = StaffModel.fromFirestore(doc);
        if (userModel.companyId != null && userModel.companyId!.isNotEmpty) {
          FirestorePath.initializeCompany(userModel.companyId!);
          log(
            'Company initialized from USERS document: ${userModel.companyId}',
          );
        }
      } else {
        // ====================================================
        // 2. CHECK ALL STAFF SUBCOLLECTIONS
        // ====================================================

        final staffQuery = await _firestore
            .collectionGroup(DBCollections.staff)
            .where('phone', isEqualTo: phoneNo.trim())
            .limit(1)
            .get();

        if (staffQuery.docs.isEmpty) {
          throw AuthException(
            'No account found. Check mobile number and password.',
          );
        }

        final doc = staffQuery.docs.first;
        final data = doc.data();

        if ((data['password'] ?? '') != password) {
          throw AuthException('Incorrect password.');
        }

        if (isInactiveStatus(data['status'])) {
          throw const AuthException(
            'Your account has been deactivated. Please contact your administrator.',
          );
        }

        // ====================================================
        // 3. EXTRACT COMPANY ID
        // ====================================================

        final segments = doc.reference.path.split('/');
        if (segments.length < 2 || segments[0] != 'COMPANY') {
          throw AuthException('Invalid company document structure.');
        }
        final companyId = segments[1];

        FirestorePath.initializeCompany(companyId);

        log('Company initialized: $companyId');

        userModel = StaffModel.fromFirestore(doc);
      }

      // ====================================================
      // 4. CHECK COMPANY STATUS
      // ====================================================
      final companyId = userModel.companyId;
      if (userModel.companyType != 'mother_company' &&
          companyId != null &&
          companyId.isNotEmpty) {
        final compDoc = await _firestore
            .collection('COMPANY')
            .doc(companyId)
            .get();
        if (compDoc.exists) {
          final compStatus = (compDoc.data()?['status'] as String? ?? 'PENDING')
              .toUpperCase();
          if (compStatus == 'SUSPENDED') {
            throw const AuthException(
              'Account is suspended. Need to upgrade plan.',
            );
          } else if (compStatus == 'PENDING') {
            throw const AuthException(
              'Account is pending. Need to purchase plan. Contact admin',
            );
          }
          userModel = userModel.copyWith(companyStatus: compStatus);
        }
      }

      return userModel;
    } catch (e) {
      rethrow;
      // log("errorrrrrrr $e");
      // throw AuthException('Incorrect passwordddddddddddddddd.');
    }
  }

  bool isInactiveStatus(dynamic statusValue) {
    if (statusValue == null) return false;
    if (statusValue is bool) return statusValue == false;
    if (statusValue is String) return statusValue.toUpperCase() == 'INACTIVE';
    return false;
  }

  DocumentReference<Map<String, dynamic>> staffDocumentRef(StaffModel user) {
    if (user.companyType == 'mother_company') {
      return users.doc(user.id);
    }

    if (user.companyId == null || user.companyId!.isEmpty) {
      throw const AuthException(
        'Missing company context for staff status lookup.',
      );
    }

    // companyCollection() reads from FirestorePath's already-initialized
    // company context. initializeCompany() is idempotent-safe to call again
    // here in case this is invoked before AuthCubit has done so itself.
    FirestorePath.initializeCompany(user.companyId!);
    return FirestorePath.companyCollection(DBCollections.staff).doc(user.id);
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
