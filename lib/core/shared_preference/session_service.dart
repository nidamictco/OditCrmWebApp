import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../feature/sub_company/staff_managment/staff/model/staff_model.dart';

class SessionService {
  static const _keyIsLoggedIn = 'session_is_logged_in';
  static const _keyUser = 'session_user';
  static const _keyUserId = 'session_user_id';

  Future<void> saveSession(StaffModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    // await prefs.setString(_keyUser, jsonEncode(user.toMap()));
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    // Save id separately since toMap() doesn't include it
    await prefs.setString(_keyUserId, user.id ?? '');
    log('[SessionService] Session saved for ${user.email}');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    log('[SessionService] Session cleared and all shared preferences cleared');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Future<StaffModel?> getSavedUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final raw = prefs.getString(_keyUser);
  //   if (raw == null) return null;

  //   try {
  //     final map = jsonDecode(raw) as Map<String, dynamic>;
  //     final savedId = prefs.getString(_keyUserId) ?? '';

  //     return StaffModel(
  //       id: savedId.isEmpty ? null : savedId,
  //       name: map['name'] ?? '',
  //       password: map['password'] ?? '',
  //       phone: map['phone'] ?? '',
  //       email: map['email'],
  //       designation: map['designation'],
  //       staffType: map['staffType'],
  //       joiningDate: map['joiningDate'],
  //       salary: map['salary'],
  //       openingBalance: map['openingBalance'],
  //       openingBalanceDate: map['openingBalanceDate'],
  //       accessWhatsapp: map['accessWhatsapp'] ?? false,
  //       accessCallLog: map['accessCallLog'] ?? false,
  //       hasSalaryAccount: map['hasSalaryAccount'] ?? true,
  //       hasPettyCash: map['hasPettyCash'] ?? false,
  //       imageUrl: map['imageUrl'],
  //       documentName: map['documentName'],
  //       documentUrl: map['documentUrl'],
  //       accessibleUsers: map['accessibleUsers'],
  //       // toMap() stores createdAt as a Timestamp — here it's just a plain
  //       // map from JSON, so we parse the milliseconds stored by Timestamp.toDate()
  //       createdAt: _parseDateTime(map['createdAt']),
  //       deletedAt: _parseDateTime(map['deletedAt']),
  //     );
  //   } catch (e) {
  //     log('[SessionService] Corrupt session data, clearing: $e');
  //     await clearSession();
  //     return null;
  //   }
  // }
  Future<StaffModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedId = prefs.getString(_keyUserId) ?? '';

      // Inject the saved ID back since toJson() may not include it
      map['id'] = savedId.isNotEmpty ? savedId : map['id'];

      return StaffModel.fromJson(map); // ← use same parser everywhere
    } catch (e) {
      log('[SessionService] Corrupt session data, clearing: $e');
      await clearSession();
      return null;
    }
  }

  /// Firestore [Timestamp] serialises to `{"_seconds": x, "_nanoseconds": y}`
  /// after going through jsonEncode. Handle both that and a raw ISO string.
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      final seconds = value['_seconds'] as int?;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    return null;
  }
}
