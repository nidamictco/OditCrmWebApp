import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/cubit/custom_field_state.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/data/custom_field_repo.dart';

class AdditionalFieldsCubit extends Cubit<AdditionalFieldsState> {
  final AdditionalFieldsRepository _repository;

  AdditionalFieldsCubit({required AdditionalFieldsRepository repository})
      : _repository = repository,
        super(const AdditionalFieldsState()) {
    fetchFields();
  }

  /// Fetch all saved fields from Firestore on init
  Future<void> fetchFields() async {
    emit(state.copyWith(status: AdditionalFieldsStatus.loading, clearError: true));
    try {
      final fields = await _repository.fetchFields();
      emit(state.copyWith(
        status: AdditionalFieldsStatus.success,
        savedFields: fields,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdditionalFieldsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save a list of field name strings to Firestore
  Future<void> saveFields(List<String> fieldNames) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveFields(fieldNames);
      // Refresh list after saving
      final updated = await _repository.fetchFields();
      emit(state.copyWith(
        isSaving: false,
        status: AdditionalFieldsStatus.success,
        savedFields: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        status: AdditionalFieldsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

   Future<void> updateField(String id, String fieldName) async {
    if (fieldName.trim().isEmpty) return;

    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      await _repository.updateField(id, fieldName);

      // Update locally instead of a full refetch — cheaper, and avoids
      // a loading flicker for a single-field rename.
      final updated = state.savedFields.map((f) {
        return f.id == id ? f.copyWith(fieldName: fieldName.trim()) : f;
      }).toList();

      emit(state.copyWith(
        isUpdating: false,
        status: AdditionalFieldsStatus.success,
        savedFields: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        status: AdditionalFieldsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Delete a single field by Firestore document ID
  Future<void> deleteField(String id) async {
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await _repository.deleteField(id);
      final updated = state.savedFields.where((f) => f.id != id).toList();
      emit(state.copyWith(
        isDeleting: false,
        savedFields: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        status: AdditionalFieldsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}