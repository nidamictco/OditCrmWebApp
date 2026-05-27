// import 'dart:developer';
// import 'package:cloud_functions/cloud_functions.dart';

// class Msg91Service {
//   final _functions = FirebaseFunctions.instance;

//   // ─── Send OTP ──────────────────────────────────────────────────────────

//   Future<void> sendOtp(String phone) async {
//     final mobile = phone.startsWith('91') ? phone : '91$phone';
//     log('[MSG91] Sending OTP to $mobile');

//     try {
//       final callable = _functions.httpsCallable('sendOtp');
//       await callable.call({'mobile': mobile});
//       log('[MSG91] OTP sent successfully');
//     } on FirebaseFunctionsException catch (e) {
//       log('[MSG91] Function error: ${e.message}');
//       throw Msg91Exception(e.message ?? 'Failed to send OTP.');
//     } catch (e) {
//       log('[MSG91] Unexpected error: $e');
//       throw Msg91Exception('Failed to send OTP. Try again.');
//     }
//   }

//   // ─── Verify OTP ────────────────────────────────────────────────────────

//   Future<void> verifyOtp({
//     required String phone,
//     required String otp,
//   }) async {
//     final mobile = phone.startsWith('91') ? phone : '91$phone';
//     log('[MSG91] Verifying OTP for $mobile');

//     try {
//       final callable = _functions.httpsCallable('verifyOtp');
//       await callable.call({'mobile': mobile, 'otp': otp});
//       log('[MSG91] OTP verified successfully');
//     } on FirebaseFunctionsException catch (e) {
//       log('[MSG91] Verify error: ${e.message}');
//       throw Msg91Exception(
//         (e.message ?? '').toLowerCase().contains('invalid')
//             ? 'Invalid OTP. Please try again.'
//             : e.message ?? 'Verification failed.',
//       );
//     } catch (e) {
//       throw Msg91Exception('Verification failed. Try again.');
//     }
//   }

//   // ─── Resend OTP ────────────────────────────────────────────────────────

//   Future<void> resendOtp(String phone) async {
//     final mobile = phone.startsWith('91') ? phone : '91$phone';
//     log('[MSG91] Resending OTP to $mobile');

//     try {
//       final callable = _functions.httpsCallable('resendOtp');
//       await callable.call({'mobile': mobile});
//       log('[MSG91] OTP resent successfully');
//     } on FirebaseFunctionsException catch (e) {
//       throw Msg91Exception(e.message ?? 'Failed to resend OTP.');
//     } catch (e) {
//       throw Msg91Exception('Failed to resend OTP. Try again.');
//     }
//   }
// }

// class Msg91Exception implements Exception {
//   final String message;
//   const Msg91Exception(this.message);

//   @override
//   String toString() => message;
// }