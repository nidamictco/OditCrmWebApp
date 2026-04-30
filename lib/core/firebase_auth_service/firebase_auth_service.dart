

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/auth/model/user_model.dart';

/// Handles user authentication against a Firestore [users] collection.
///
/// Expected Firestore document structure:
/// /users/{docId}
///   - username: String  (used as login identifier)
///   - password: String  (plain or hashed — hash recommended in prod)
///   - email: String?
///   - role: String?
///   - token: String?    (optional FCM / session token)
class FirebaseAuthService {
  FirebaseAuthService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('STAFF');

  /// Returns a [UserModel] if credentials match, otherwise throws.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('log : email : ${email}2222222   $_users');
      log('log : password : $password');
      final query = await _users
          .where('EMAIL', isEqualTo: email)
          .get();
      print(query.docs.isEmpty);
      if (query.docs.isEmpty) {
        throw AuthException('No account found for "$email".');
      }

      final doc = query.docs.first;
      final data = doc.data();

      log("data['PASSWORD'] ${data['PASSWORD']}");
      // ⚠️  In production use a hashed comparison (e.g. bcrypt via Cloud Function).
      // For now we compare stored value directly.
      final storedPassword = data['PASSWORD'] as String? ?? '';
      if (storedPassword != password) {
        throw AuthException('Incorrect password.');
      }

      return UserModel.fromMap(doc.id, data);
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthException('Firebase error: ${e.message}');
    } catch (e) {
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