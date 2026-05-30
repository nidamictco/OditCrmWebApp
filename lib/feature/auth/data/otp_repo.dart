import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';

class OtpScreen {
  OtpScreen({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Holds the result after OTP is sent — needed for confirmOtp()
  ConfirmationResult? _confirmationResult;

  CollectionReference<Map<String, dynamic>> get _staff =>
      _firestore.collection('STAFF');

  // ─── Step 1: Send OTP (Web) ───────────────────────────────────────────────
  // Firebase will show reCAPTCHA popup automatically on web

  Future<void> sendOtp({required String phoneNo}) async {
    // Must be E.164 format: +91XXXXXXXXXX
    final formatted = phoneNo.startsWith('+') ? phoneNo : '+91$phoneNo';

    log('[OtpScreen] Sending OTP to $formatted');

    try {
      // signInWithPhoneNumber is the web method
      // Firebase auto-renders reCAPTCHA — no setup needed from your side
      _confirmationResult = await _auth.signInWithPhoneNumber(formatted);
      log('[OtpScreen] OTP sent successfully');
    } on FirebaseAuthException catch (e) {
      log('[OtpScreen] Send OTP error: ${e.code} - ${e.message}');
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      log('[OtpScreen] Unexpected sendOtp error: $e');
      throw AuthException('Failed to send OTP. Try again.');
    }
  }

  // ─── Step 2: Confirm OTP + Fetch Staff ────────────────────────────────────

  Future<StaffModel> confirmOtp({required String otp}) async {
    if (_confirmationResult == null) {
      throw const AuthException('Please request OTP first.');
    }

    try {
      // Verify the OTP
      final userCredential = await _confirmationResult!.confirm(otp);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) throw const AuthException('Sign-in failed.');

      final phone = firebaseUser.phoneNumber ?? '';
      log('[OtpScreen] Auth success. Phone: $phone');

      // Fetch staff record from Firestore using phone number
      final query = await _staff
          .where(
            'phone',
            isEqualTo: phone,
          ) // must be +91XXXXXXXXXX in Firestore
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        await _auth.signOut();
        throw AuthException('No staff account found for $phone.');
      }

      try {
        final user = StaffModel.fromFirestore(query.docs.first);
        log('[OtpScreen] Staff found: ${user.phone}');
        return user;
      } catch (e) {
        throw AuthException('Failed to parse user data: $e');
      }
    } on FirebaseAuthException catch (e) {
      log('[OtpScreen] Confirm OTP error: ${e.code}');
      throw AuthException(_mapFirebaseError(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _confirmationResult = null;
    await _auth.signOut();
  }

  // ─── Error Messages ───────────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Wrong OTP. Please try again.';
      case 'session-expired':
        return 'OTP expired. Please resend.';
      case 'too-many-requests':
        return 'Too many attempts. Try later.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'captcha-check-failed':
        return 'reCAPTCHA failed. Refresh and retry.';
      default:
        return 'Auth failed ($code). Try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
