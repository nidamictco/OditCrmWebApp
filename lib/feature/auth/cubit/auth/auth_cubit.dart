import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase_auth_service.dart';
import '../../../../core/shared_preference/session_service.dart';

import '../../../sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import '../../../sub_company/staff_managment/staff/data/add_staff_repo.dart';
import '../../../sub_company/staff_managment/staff/model/staff_model.dart';
import '../../../../core/constant/firebase_const.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required FirebaseAuthService authService,
    required SessionService sessionService,
    StaffRepository? staffRepository,
  }) : _authService = authService,
       _sessionService = sessionService,
       _staffRepository = staffRepository ?? StaffRepository(),
       super(AuthInitial());

  final FirebaseAuthService _authService;
  final SessionService _sessionService;
  final StaffRepository _staffRepository;

  // ─── Check saved session on app start ────────────────────────────────────

  // Future<void> checkSession() async {
  //   emit(AuthLoading());
  //   try {
  //     final loggedIn = await _sessionService.isLoggedIn();
  //     if (loggedIn) {
  //       final user = await _sessionService.getSavedUser();
  //       if (user != null) {
  //         log('[AuthCubit] Session restored for ${user.email}');
  //         emit(Authenticated(user: user));
  //         return;
  //       }
  //     }
  //     emit(AuthLoggedOut());
  //   } catch (e) {
  //     log('[AuthCubit] checkSession error: $e');
  //     emit(AuthLoggedOut());
  //   }
  // }

  Future<void> checkSession({PermissionCubit? permissionCubit}) async {
    // ← updated
    emit(AuthLoading());
    try {
      final loggedIn = await _sessionService.isLoggedIn();
      if (loggedIn) {
        final user = await _sessionService.getSavedUser();
        if (user != null) {
          // log('[AuthCubit] Session restored for ${user.email}');

          if (user.companyId != null && user.companyId!.isNotEmpty) {
            FirestorePath.initializeCompany(user.companyId!);
            // log('[AuthCubit] Company context restored: ${user.companyId}');

            // Check company status live in database
            if (user.companyType != 'mother_company') {
              final compDoc = await FirebaseFirestore.instance
                  .collection('COMPANY')
                  .doc(user.companyId)
                  .get();
              if (compDoc.exists) {
                final compStatus =
                    (compDoc.data()?['status'] as String? ?? 'PENDING')
                        .toUpperCase();
                if (compStatus == 'SUSPENDED' || compStatus == 'PENDING') {
                  log(
                    '[AuthCubit] Restored session blocked: company suspended/pending',
                  );
                  await _sessionService.clearSession();
                  emit(
                    AuthError(
                      message: 'Account is suspended. Need to upgrade plan.',
                    ),
                  );
                  return;
                }
              }
            }
          }

          // ✅ Restore permissions
          await permissionCubit?.loadPermissions(user.designationId);
          emit(Authenticated(user: user));
          return;
        }
      }
      emit(AuthLoggedOut());
    } catch (e) {
      log('[AuthCubit] checkSession error: $e');
      emit(AuthLoggedOut());
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> login({
    required String phoneNo,
    required String password,
    required PermissionCubit permissionCubit, // ← NEW
  }) async {
    if (phoneNo.trim().isEmpty || password.isEmpty) {
      emit(AuthError(message: 'Phone number and password are required.'));
      return;
    }
    emit(AuthLoading());
    try {
      final user = await _authService.login(
        phoneNo: phoneNo.trim(),
        password: password,
      );
      log(
        '[AuthCubit] Login success: ${user.phone} | designation: ${user.designation}',
      );
      await _sessionService.saveSession(user);

      await permissionCubit.loadPermissions(user.designationId);

      emit(Authenticated(user: user));
    } on AuthException catch (e) {
      log('[AuthCubit] AuthException: ${e.message}');
      emit(AuthError(message: e.message));
    } catch (e, st) {
      log('[AuthCubit] Unexpected login error: $e', stackTrace: st);
      emit(AuthError(message: 'Login failed. Please try again.'));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout({PermissionCubit? permissionCubit}) async {
    emit(AuthLoading());
    await _sessionService.clearSession();
    permissionCubit?.clear();
    emit(AuthLoggedOut());
  }

  // ─── Refresh logged-in user's data from Firestore ─────────────────────────
  Future<void> refreshUser(String staffId) async {
    try {
      final updated = await _staffRepository.getStaff(staffId);
      if (updated != null) {
        await _sessionService.saveSession(
          updated,
        ); // ← also update session cache
        emit(Authenticated(user: updated));
        log('[AuthCubit] User refreshed: $staffId');
      }
    } catch (e) {
      log('[AuthCubit] refreshUser error: $e');
    }
  }
}
