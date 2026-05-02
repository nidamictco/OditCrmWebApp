import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/firebase_auth_service/firebase_auth_service.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/model/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required FirebaseAuthService authService,
    required SessionService sessionService,
  }) : _authService = authService,
       _sessionService = sessionService,
       super(AuthInitial());

  final FirebaseAuthService _authService;
  final SessionService _sessionService;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Called on app start — restores session from SharedPreferences if valid.
  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      print('Checking session...'); // Add logs
      final loggedIn = await _sessionService.isLoggedIn();
      print('Logged in: $loggedIn');
      if (loggedIn) {
        final user = await _sessionService.getSavedUser();
        print('User: $user');
        if (user != null) {
          emit(Authenticated(user: user));
          return;
        }
      }
      emit(AuthLoggedOut());
    } catch (e) {
      print('Session check error: $e'); // Log error
      emit(AuthLoggedOut());
    }
  }

  /// Validates credentials against Firestore and persists session.
  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(AuthError(message: 'Email and password are required.'));
      return;
    }

    emit(AuthLoading());

    try {
      print("hhhhhhhhhhhhhhhhh");
      final user = await _authService.login(
        email: email.trim(),
        password: password,
      );
      log('log : user : $user');
      await _sessionService.saveSession(user);
      emit(Authenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      log('log : error : $e');
      emit(AuthError(message: 'Login failed. Please try again.'));
    }
  }

  /// Clears session and returns to logged-out state.
  Future<void> logout() async {
    emit(AuthLoading());
    await _sessionService.clearSession();
    emit(AuthLoggedOut());
  }
}
