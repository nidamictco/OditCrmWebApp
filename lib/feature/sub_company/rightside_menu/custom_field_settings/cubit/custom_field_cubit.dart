import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_field_state.dart';
import '../data/custom_field_repo.dart';

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