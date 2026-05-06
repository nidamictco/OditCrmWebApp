import 'dart:convert';
import 'dart:developer';

import 'package:oxdo/feature/auth/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyIsLoggedIn = 'session_is_logged_in';
  static const _keyUser = 'session_user';

  Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
    log('[SessionService] Session saved for ${user.email}');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUser);
    log('[SessionService] Session cleared');
  }

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
      // toMap() saves as STAFF_ID — fromMap reads STAFF_ID ✅
      final docId = map['STAFF_ID'] as String? ?? '';
      return UserModel.fromMap(docId, map);
    } catch (e) {
      log('[SessionService] Corrupt session data, clearing: $e');
      await clearSession();
      return null;
    }
  }
}