import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/settings/general_settings/cubit/general_settings_state.dart';
import 'package:oxdo/feature/settings/general_settings/data/general_settings_repo.dart';
import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsState> {
  GeneralSettingsRepository? _repo;

  GeneralSettingsCubit() : super(const GeneralSettingsInitial());

  // ── Called from screen — resolves staffId at runtime ──────────────────────
  Future<void> loadForCurrentUser() async {
    emit(const GeneralSettingsLoading());
    try {
      final user = await SessionService().getSavedUser();
      final staffId = user?.id ?? '';

      log('[GeneralSettingsCubit] staffId = "$staffId"');

      if (staffId.isEmpty) {
        emit(GeneralSettingsError('User not found. Please log in again.'));
        return;
      }

      _repo = GeneralSettingsRepository(staffId: staffId);
      final settings = await _repo!.fetchSettings();
      log('[GeneralSettingsCubit] Loaded: ${settings.toMap()}');
      emit(GeneralSettingsLoaded(settings));
    } catch (e) {
      log('[GeneralSettingsCubit] Load error: $e');
      emit(GeneralSettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> toggleField(String field, bool value) async {
     log('[GeneralSettingsCubit] toggleField called: $field = $value'); // ← ADD
  log('[GeneralSettingsCubit] _repo = $_repo');                       // ← ADD
  
    if (_repo == null) {
      log('[GeneralSettingsCubit] _repo is null — loadForCurrentUser not called yet');
      return;
    }

    final current = _currentSettings();
    if (current == null) return;

    final updated = _applyToggle(current, field, value);
    emit(GeneralSettingsLoaded(updated));

    try {
      await _repo!.updateField(field, value);
      log('[GeneralSettingsCubit] Saved $field = $value ✅');
    } catch (e) {
      log('[GeneralSettingsCubit] Save failed, rolling back: $e');
      emit(GeneralSettingsLoaded(current));
      emit(GeneralSettingsError('Failed to save: $e'));
    }
  }

  GeneralSettingsModel? _currentSettings() {
    final s = state;
    if (s is GeneralSettingsLoaded) return s.settings;
    if (s is GeneralSettingsUpdating) return s.settings;
    return null;
  }

  GeneralSettingsModel _applyToggle(GeneralSettingsModel m, String field, bool value) {
    return m.copyWith(
      newLead:      field == 'newLead'      ? value : null,
      facebookLead: field == 'facebookLead' ? value : null,
      transferLead: field == 'transferLead' ? value : null,
      whatsapp:     field == 'whatsapp'     ? value : null,
      cloudCall:    field == 'cloudCall'    ? value : null,
      phoneCall:    field == 'phoneCall'    ? value : null,
      autoAssign:   field == 'autoAssign'   ? value : null,
    );
  }
}