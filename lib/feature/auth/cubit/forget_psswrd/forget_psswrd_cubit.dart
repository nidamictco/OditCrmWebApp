// // import 'dart:developer';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:oxdo/feature/auth/data/msg91_service.dart';

// // part 'forget_psswrd_state.dart';

// // class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
// //   ForgotPasswordCubit()
// //       : _msg91 = Msg91Service(),
// //         _firestore = FirebaseFirestore.instance,
// //         super(ForgotPasswordInitial());

// //   final Msg91Service _msg91;
// //   final FirebaseFirestore _firestore;

// //   String? _verifiedPhone;

// //   // ─── Step 1: Send OTP ─────────────────────────────────────────────────

// //   Future<void> sendOtp(String phone) async {
// //     final trimmed = phone.trim();

// //     if (trimmed.isEmpty) {
// //       emit(ForgotPasswordError('Please enter your phone number.'));
// //       return;
// //     }
// //     if (trimmed.length < 10) {
// //       emit(ForgotPasswordError('Enter a valid 10-digit phone number.'));
// //       return;
// //     }

// //     emit(ForgotPasswordInitial(isLoading: true)); 

// //     try {
// //       // Check phone exists in Firestore first
// //       final query = await _firestore
// //           .collection('STAFF')
// //           .where('phone', isEqualTo: trimmed)
// //           .limit(1)
// //           .get();  

// //       if (query.docs.isEmpty) {
// //         emit(ForgotPasswordError('No account found for this phone number.'));
// //         return;
// //       }

// //       await _msg91.sendOtp(trimmed);
// //       _verifiedPhone = trimmed;
// //       log('[ForgotPassword] OTP sent to $trimmed');
// //       emit(OtpSent(phone: trimmed));
// //     } on Msg91Exception catch (e) {
// //       log('[ForgotPassword] MSG91 error: ${e.message}');
// //       emit(ForgotPasswordError(e.message));
// //     } catch (e) {
// //       log('[ForgotPassword] Unexpected error: $e');
// //       emit(ForgotPasswordError('Something went wrong. Please try again.'));
// //     }
// //   }

// //   // ─── Step 2: Verify OTP ───────────────────────────────────────────────

// //   Future<void> verifyOtp(String otp) async {
// //     if (_verifiedPhone == null) {
// //       emit(ForgotPasswordError('Session expired. Please resend OTP.'));
// //       return;
// //     }
// //     if (otp.trim().length != 6) {
// //       emit(ForgotPasswordError('Enter a valid 6-digit OTP.'));
// //       return;
// //     }

// //     emit(OtpSent(
// //   phone: _verifiedPhone!,
// //   isLoading: true,
// // ));

// //     try {
// //       await _msg91.verifyOtp(phone: _verifiedPhone!, otp: otp.trim());
// //       log('[ForgotPassword] OTP verified for $_verifiedPhone');
// //       emit(OtpVerified(phone: _verifiedPhone!));
// //     } on Msg91Exception catch (e) {
// //       log('[ForgotPassword] Verify error: ${e.message}');
// //       emit(ForgotPasswordError(e.message));
// //     } catch (e) {
// //       log('[ForgotPassword] Unexpected verify error: $e');
// //       emit(ForgotPasswordError('Verification failed. Try again.'));
// //     }
// //   }

// //   // ─── Step 2b: Resend OTP ──────────────────────────────────────────────

// //   Future<void> resendOtp() async {
// //     if (_verifiedPhone == null) {
// //       emit(ForgotPasswordError('Session expired. Please start over.'));
// //       return;
// //     }

// //     emit(OtpSent(
// //   phone: _verifiedPhone!,
// //   isLoading: true,
// // ));

// //     try {
// //       await _msg91.resendOtp(_verifiedPhone!);
// //       log('[ForgotPassword] OTP resent to $_verifiedPhone');
// //       emit(OtpSent(phone: _verifiedPhone!));
// //     } on Msg91Exception catch (e) {
// //       emit(ForgotPasswordError(e.message));
// //     } catch (e) {
// //       emit(ForgotPasswordError('Failed to resend OTP. Try again.'));
// //     }
// //   }

// //   // ─── Step 3: Reset Password ───────────────────────────────────────────

// //   Future<void> resetPassword({
// //     required String newPassword,
// //     required String confirmPassword,
// //   }) async {
// //     if (newPassword.isEmpty || confirmPassword.isEmpty) {
// //       emit(ForgotPasswordError('Please fill in all fields.'));
// //       return;
// //     }
// //     if (newPassword.length < 4) {
// //       emit(ForgotPasswordError('Password must be at least 4 characters.'));
// //       return;
// //     }
// //     if (newPassword != confirmPassword) {
// //       emit(ForgotPasswordError('Passwords do not match.'));
// //       return;
// //     }
// //     if (_verifiedPhone == null) {
// //       emit(ForgotPasswordError('Session expired. Please start over.'));
// //       return;
// //     }

// //     emit(OtpVerified(
// //   phone: _verifiedPhone!,
// //   isLoading: true,
// // ));
// //     try {
// //       final query = await _firestore
// //           .collection('STAFF')
// //           .where('phone', isEqualTo: _verifiedPhone)
// //           .limit(1)
// //           .get();

// //       if (query.docs.isEmpty) {
// //         emit(ForgotPasswordError('User not found.'));
// //         return;
// //       }

// //       await query.docs.first.reference.update({'password': newPassword});
// //       log('[ForgotPassword] Password updated for $_verifiedPhone');
// //       emit(PasswordResetSuccess());
// //     } catch (e) {
// //       log('[ForgotPassword] Reset error: $e');
// //       emit(ForgotPasswordError('Failed to reset password. Try again.'));
// //     }
// //   }

// //   void resetState() {
// //     _verifiedPhone = null;
// //     emit(ForgotPasswordInitial());
// //   }
// // }


// import 'dart:developer';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:oxdo/feature/auth/data/firebase_auth_service.dart';
// import 'package:oxdo/core/shared_preference/session_service.dart';
// import 'package:oxdo/feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
// import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';

// part 'auth_state.dart';

// class OtpCubit extends Cubit<AuthState> {
//   OtpCubit({
//     required FirebaseAuthService authService,
//     required SessionService sessionService,
//   })  : _authService = authService,
//         _sessionService = sessionService,
//         super(AuthInitial());

//   final FirebaseAuthService _authService;
//   final SessionService _sessionService;

//   // ─── Check Session ────────────────────────────────────────────────────────

//   Future<void> checkSession({PermissionCubit? permissionCubit}) async {
//     emit(AuthLoading());
//     try {
//       final loggedIn = await _sessionService.isLoggedIn();
//       if (loggedIn) {
//         final user = await _sessionService.getSavedUser();
//         if (user != null) {
//           await permissionCubit?.loadPermissions(user.designationId);
//           emit(Authenticated(user: user));
//           return;
//         }
//       }
//       emit(AuthLoggedOut());
//     } catch (e) {
//       emit(AuthLoggedOut());
//     }
//   }

//   // ─── Send OTP ─────────────────────────────────────────────────────────────

//   Future<void> sendOtp({required String phoneNo}) async {
//     if (phoneNo.trim().isEmpty) {
//       emit(AuthError(message: 'Phone number is required.'));
//       return;
//     }
//     emit(AuthLoading());
//     try {
//       await _authService.sendOtp(phoneNo: phoneNo.trim());
//       emit(OtpSent()); // ← UI will now show OTP field
//     } on AuthException catch (e) {
//       emit(AuthError(message: e.message));
//     } catch (e) {
//       emit(AuthError(message: 'Failed to send OTP.'));
//     }
//   }

//   // ─── Confirm OTP ──────────────────────────────────────────────────────────

//   Future<void> confirmOtp({
//     required String otp,
//     required PermissionCubit permissionCubit,
//   }) async {
//     if (otp.trim().length < 6) {
//       emit(AuthError(message: 'Enter the 6-digit OTP.'));
//       emit(OtpSent()); // stay on OTP screen
//       return;
//     }
//     emit(AuthLoading());
//     try {
//       final user = await _authService.confirmOtp(otp: otp.trim());
//       await _sessionService.saveSession(user);
//       await permissionCubit.loadPermissions(user.designationId);
//       emit(Authenticated(user: user));
//     } on AuthException catch (e) {
//       emit(AuthError(message: e.message));
//       emit(OtpSent()); // stay on OTP screen after error
//     } catch (e) {
//       emit(AuthError(message: 'Verification failed.'));
//       emit(OtpSent());
//     }
//   }

//   // ─── Logout ───────────────────────────────────────────────────────────────

//   Future<void> logout({PermissionCubit? permissionCubit}) async {
//     emit(AuthLoading());
//     await _authService.signOut();
//     await _sessionService.clearSession();
//     permissionCubit?.clear();
//     emit(AuthLoggedOut());
//   }
// }