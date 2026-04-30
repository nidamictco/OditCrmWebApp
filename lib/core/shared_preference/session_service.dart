import 'dart:convert';
import 'package:oxdo/feature/auth/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists authentication session using [SharedPreferences].
class SessionService {
  static const _keyIsLoggedIn = 'session_is_logged_in';
  static const _keyUser = 'session_user';

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUser);
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final uid = map['uid'] as String? ?? '';
      return UserModel.fromMap(uid, map);
    } catch (_) {
      // Corrupt data — wipe it.
      await clearSession();
      return null;
    }
  }
}