import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/model/custom_field_model.dart';

enum AdditionalFieldsStatus { initial, loading, success, failure }

class AdditionalFieldsState {
  final AdditionalFieldsStatus status;
  final List<AdditionalFieldModel> savedFields;
  final String? errorMessage;
  final bool isSaving;
  final bool isUpdating; // NEW
  final bool isDeleting;

  const AdditionalFieldsState({
    this.status = AdditionalFieldsStatus.initial,
    this.savedFields = const [],
    this.errorMessage,
    this.isSaving = false,
    this.isUpdating = false, // NEW
    this.isDeleting = false,
  });

  AdditionalFieldsState copyWith({
    AdditionalFieldsStatus? status,
    List<AdditionalFieldModel>? savedFields,
    String? errorMessage,
    bool? isSaving,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
  }) {
    return AdditionalFieldsState(
      status: status ?? this.status,
      savedFields: savedFields ?? this.savedFields,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isUpdating: isUpdating ?? this.isUpdating, // NEW
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isLoading => status == AdditionalFieldsStatus.loading;

  @override
  String toString() {
    return 'AdditionalFieldsState('
        'status: $status, '
        'savedFields: ${savedFields.length}, '
        'errorMessage: $errorMessage, '
        'isSaving: $isSaving, '
        'isUpdating: $isUpdating, '
        'isDeleting: $isDeleting)';
  }
}