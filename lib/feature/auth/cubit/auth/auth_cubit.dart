import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/auth/data/firebase_auth_service.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required FirebaseAuthService authService,
    required SessionService sessionService,
  })  : _authService = authService,
        _sessionService = sessionService,
        super(AuthInitial());

  final FirebaseAuthService _authService;
  final SessionService _sessionService;

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

   Future<void> checkSession({PermissionCubit? permissionCubit}) async {  // ← updated
    emit(AuthLoading());
    try {
      final loggedIn = await _sessionService.isLoggedIn();
      if (loggedIn) {
        final user = await _sessionService.getSavedUser();
        if (user != null) {
          log('[AuthCubit] Session restored for ${user.email}');
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

  // Future<void> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   if (email.trim().isEmpty || password.isEmpty) {
  //     emit(AuthError(message: 'Email and password are required.'));
  //     return;
  //   }

  //   emit(AuthLoading());

  //   try {
  //     final user = await _authService.login(
  //       email: email.trim(),
  //       password: password,
  //     );
  //     log('[AuthCubit] Login success: ${user.email} | role: ${user.designation}');
  //     await _sessionService.saveSession(user);
  //     emit(Authenticated(user: user));
  //   } on AuthException catch (e) {
  //     log('[AuthCubit] AuthException: ${e.message}');
  //     emit(AuthError(message: e.message));
  //   } catch (e, st) {
  //     log('[AuthCubit] Unexpected login error: $e', stackTrace: st);
  //     emit(AuthError(message: 'Login failed. Please try again.'));
  //   }
  // }

   Future<void> login({
    required String phoneNo,
    required String password,
    required PermissionCubit permissionCubit,  // ← NEW
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
      log('[AuthCubit] Login success: ${user.phone} | designation: ${user.designation}');
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
}

