import 'dart:async';
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

  // ─── Live staff-status monitoring ─────────────────────────────────────────
  // Subscription to the logged-in staff/user document. Watches the `status`
  // field so we can force-logout the moment an admin deactivates the account,
  // even while the app is open and the user is mid-session.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _staffStatusSubscription;

  // Kept so the live listener (and forceLogout) can clear permissions without
  // needing the caller to thread a PermissionCubit through every callback.
  PermissionCubit? _permissionCubit;

  // ─── Check saved session on app start ────────────────────────────────────

  Future<void> checkSession({PermissionCubit? permissionCubit}) async {
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

          // ── NEW: Staff status check on session restore ──────────────────
          // Even if the locally cached session says the user is fine, the
          // admin may have deactivated them since the last app launch.
          // We re-verify against Firestore before trusting the cached user.
          final staffInactive = await _isCurrentStaffInactive(user);
          if (staffInactive) {
            log('[AuthCubit] Restored session blocked: staff inactive');
            await _forceLogout(
              message:
                  'Your account has been deactivated. Please contact your administrator.',
              permissionCubit: permissionCubit,
            );
            return;
          }

          // ✅ Restore permissions
          await permissionCubit?.loadPermissions(user.designationId);
          emit(Authenticated(user: user));

          // Start watching this staff document for future deactivation.
          _startStaffStatusListener(user, permissionCubit: permissionCubit);
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
    required PermissionCubit permissionCubit,
  }) async {
    log('[AuthCubit] login() CALLED — phone: $phoneNo');
    if (phoneNo.trim().isEmpty || password.isEmpty) {
      log('[AuthCubit] login() → emitting AuthError (empty fields)');
      emit(AuthError(message: 'Phone number and password are required.'));
      return;
    }
    log('[AuthCubit] login() → emitting AuthLoading');
    emit(AuthLoading());
    try {
      // FirebaseAuthService.login() now also validates staff `status` and
      // throws AuthException('Your account has been deactivated...') before
      // returning, so no extra check is needed here — see auth_service.
      final user = await _authService.login(
        phoneNo: phoneNo.trim(),
        password: password,
      );
      log(
        '[AuthCubit] Login success: ${user.phone} | designation: ${user.designation}',
      );
      await _sessionService.saveSession(user);

      await permissionCubit.loadPermissions(user.designationId);

      log('[AuthCubit] login() → emitting Authenticated');
      emit(Authenticated(user: user));

      // Start live monitoring immediately after a successful login so an
      // admin-side deactivation is caught in real time, not just on restart.
      _startStaffStatusListener(user, permissionCubit: permissionCubit);
    } on AuthException catch (e) {
      log('[AuthCubit] login() → AuthException — emitting AuthError: ${e.message}');
      emit(AuthError(message: e.message));
    } catch (e, st) {
      log('[AuthCubit] login() → unexpected error — emitting AuthError: $e', stackTrace: st);
      emit(AuthError(message: 'Login failed. Please try again.'));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout({PermissionCubit? permissionCubit}) async {
    emit(AuthLoading());
    _stopStaffStatusListener(); // always stop watching before clearing session
    await _sessionService.clearSession();
    (permissionCubit ?? _permissionCubit)?.clear();
    _permissionCubit = null;
    emit(AuthLoggedOut());
  }

  // ─── Refresh logged-in user's data from Firestore ─────────────────────────
  Future<void> refreshUser(String staffId) async {
    try {
      final updated = await _staffRepository.getStaff(staffId);
      if (updated == null) return;

      // ── NEW: Refresh must also respect deactivation ──────────────────────
      // If the admin deactivated the account between actions, a refresh
      // should force-logout instead of silently re-authenticating them.
      final inactive = await _isCurrentStaffInactive(updated);
      if (inactive) {
        log('[AuthCubit] refreshUser found staff inactive: $staffId');
        await _forceLogout(
          message:
              'Your account has been deactivated. Please contact your administrator.',
        );
        return;
      }

      await _sessionService.saveSession(updated);
      emit(Authenticated(user: updated));
      log('[AuthCubit] User refreshed: $staffId');
    } catch (e) {
      log('[AuthCubit] refreshUser error: $e');
    }
  }

  // ─── Staff status helpers (reusable, no duplicated Firestore queries) ────

  /// Fetches the latest staff/user document for [user] and returns whether
  /// the account is currently inactive. Used by both checkSession() and
  /// refreshUser() so the lookup + status logic lives in exactly one place.
  ///
  /// Fails OPEN on Firestore errors (transient network issues won't lock a
  /// legitimate user out). Flip the `return false` in the catch block to
  /// `rethrow` / fail-closed if your security requirements prefer that.
  Future<bool> _isCurrentStaffInactive(StaffModel user) async {
    try {
      final doc = await _authService.staffDocumentRef(user).get();
      if (!doc.exists) {
        // Missing document is treated as "don't block" — adjust if a
        // missing doc should itself count as deactivated in your app.
        return false;
      }
      return _authService.isInactiveStatus(doc.data()?['status']);
    } catch (e) {
      log('[AuthCubit] checkStaffStatus error: $e');
      return false;
    }
  }

  /// Starts (or restarts) a real-time listener on the logged-in staff
  /// document. If the `status` field flips to inactive while the listener
  /// is active, the user is force-logged-out immediately.
  void _startStaffStatusListener(
    StaffModel user, {
    PermissionCubit? permissionCubit,
  }) {
    // Guard against duplicate listeners (e.g. login() then checkSession()
    // firing in the same app lifecycle, or a hot-reload re-entry).
    _stopStaffStatusListener();

    // Remember which PermissionCubit to clear if the listener later fires.
    _permissionCubit = permissionCubit ?? _permissionCubit;

    late final DocumentReference<Map<String, dynamic>> ref;
    try {
      ref = _authService.staffDocumentRef(user);
    } catch (e) {
      log('[AuthCubit] Could not resolve staff doc for listener: $e');
      return;
    }

    _staffStatusSubscription = ref.snapshots().listen(
      (snapshot) {
        if (isClosed) return;
        if (!snapshot.exists) return;

        final inactive = _authService.isInactiveStatus(
          snapshot.data()?['status'],
        );
        if (inactive) {
          log('[AuthCubit] Live update: staff deactivated, forcing logout');
          _forceLogout(
            message:
                'Your account has been deactivated by the administrator.',
          );
        }
      },
      onError: (e) {
        log('[AuthCubit] Staff status listener error: $e');
        // Don't leave a broken/leaking subscription hanging around.
        _stopStaffStatusListener();
      },
    );
  }

  /// Cancels the live staff-status listener, if any. Safe to call
  /// unconditionally (before creating a new listener, on logout, on close).
  void _stopStaffStatusListener() {
    _staffStatusSubscription?.cancel();
    _staffStatusSubscription = null;
  }

  /// Centralized "kick the user out right now" routine used by session
  /// restore, live-listener deactivation, and refreshUser(). Ensures the
  /// listener is stopped BEFORE clearing state so we never react to our own
  /// teardown, and emits AuthLoggedOut followed by AuthError so the UI can
  /// both redirect to the login screen and surface the reason.
  Future<void> _forceLogout({
    required String message,
    PermissionCubit? permissionCubit,
  }) async {
    _stopStaffStatusListener();
    await _sessionService.clearSession();
    (permissionCubit ?? _permissionCubit)?.clear();
    _permissionCubit = null;

    if (isClosed) return;
    emit(AuthLoggedOut());

    if (isClosed) return;
    emit(AuthError(message: message));
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    // Prevent the listener from firing (or leaking) after this cubit is
    // disposed — e.g. on app teardown or hot restart.
    _stopStaffStatusListener();
    return super.close();
  }
}