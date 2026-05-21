import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/settings/general_settings/data/general_settings_repo.dart';
import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';
import 'general_settings_state.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsState> {
  final GeneralSettingsRepository _repo;

  GeneralSettingsCubit(this._repo) : super(const GeneralSettingsInitial());

  // ─── Called once when screen opens ────────────────────────
  Future<void> loadSettings() async {
    emit(const GeneralSettingsLoading());
    try {
      final settings = await _repo.fetchSettings();
      log('[GeneralSettingsCubit] Loaded: ${settings.toMap()}');
      emit(GeneralSettingsLoaded(settings));
    } catch (e) {
      log('[GeneralSettingsCubit] Load error: $e');
      emit(GeneralSettingsError('Failed to load settings: $e'));
    }
  }

  // ─── Called on every switch toggle ────────────────────────
  Future<void> toggleField(String field, bool value) async {
    // Get current settings from whichever live state we're in
    final current = _currentSettings();
    if (current == null) {
      log('[GeneralSettingsCubit] toggleField called but no settings loaded yet');
      return;
    }

    // 1️⃣ Apply toggle locally
    final updated = _applyToggle(current, field, value);
    log('[GeneralSettingsCubit] Toggling $field → $value');

    // 2️⃣ Update UI instantly (optimistic)
    emit(GeneralSettingsUpdating(updated));

    try {
      // 3️⃣ Save to Firebase
      await _repo.updateField(field, value);
      log('[GeneralSettingsCubit] Saved $field = $value to Firestore ✅');
      emit(GeneralSettingsLoaded(updated));
    } catch (e) {
      // 4️⃣ Rollback if Firebase fails
      log('[GeneralSettingsCubit] Save failed, rolling back: $e');
      emit(GeneralSettingsLoaded(current));
      emit(GeneralSettingsError('Failed to save: $e'));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────
  GeneralSettingsModel? _currentSettings() {
    final s = state;
    if (s is GeneralSettingsLoaded) return s.settings;
    if (s is GeneralSettingsUpdating) return s.settings;
    return null;
  }

  GeneralSettingsModel _applyToggle(
      GeneralSettingsModel m, String field, bool value) {
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