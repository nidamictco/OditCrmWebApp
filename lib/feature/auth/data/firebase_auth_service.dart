import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _staff =>
      _firestore.collection('STAFF');

  Future<StaffModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('[FirebaseAuthService] Querying STAFF where EMAIL == $email');

      final query = await _staff
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get(); 

      log('[FirebaseAuthService] Docs found: ${query.docs.length}');

      if (query.docs.isEmpty) {
        throw AuthException('No account found for "$email".');
      }

      final doc = query.docs.first;
      final data = doc.data();

      log('[FirebaseAuthService] Raw doc data: $data');

      final storedPassword = data['password'] as String? ?? '';

      if (storedPassword != password) {
        throw AuthException('Incorrect password.');
      }

      // ✅ Wrap fromMap in its own try so parse errors surface clearly
      try {
        final user = StaffModel.fromFirestore(doc);
        log('[FirebaseAuthService] UserModel built: $user');
        return user;
      } catch (e) { 
        log('[FirebaseAuthService] fromMap parse error: $e  |  raw data: $data');
        throw AuthException('Failed to parse user data: $e');
      }
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      log('[FirebaseAuthService] FirebaseException: ${e.message}');
      throw AuthException('Firebase error: ${e.message}');
    } catch (e, st) {
      log('[FirebaseAuthService] Unexpected: $e', stackTrace: st);
      throw AuthException('Unexpected error: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}