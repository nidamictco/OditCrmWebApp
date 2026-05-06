import 'package:oxdo/feature/lead_managment/add_lead/model/add_lead_model.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/model/custom_field_model.dart';

enum AddLeadStatus { initial, loading, success, failure }
enum LeadListStatus { initial, loading, loaded, failure }

class AddLeadState {
  final AddLeadStatus status;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  // ── Lead list ─────────────────────────────────────────────────────────────
  final List<AddLeadModel> leads;
  final LeadListStatus listStatus;
  final String? listError;
  final bool isDeleting;
  final bool isUpdating;

  // ── Dropdown data ─────────────────────────────────────────────────────────
  final List<LeadsModel> categories;
  final List<LeadsModel> sources;
  final List<LeadsModel> stages;

  // ── Form selections ───────────────────────────────────────────────────────
  final String? selectedCategory;
  final String? selectedSource;
  final String? selectedPriority;
  final String? selectedLeadStage;
  final String? selectedState;
  final String? selectedDistrict;
  final String assignedStaffName;

  // ── Additional / custom fields ────────────────────────────────────────────
  final List<AdditionalFieldModel> additionalFields;
  final bool isLoadingAdditionalFields;

  const AddLeadState({
    this.status = AddLeadStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.leads = const [],
    this.listStatus = LeadListStatus.initial,
    this.listError,
    this.isDeleting = false,
    this.isUpdating = false,
    this.categories = const [],
    this.sources = const [],
    this.stages = const [],
    this.selectedCategory,
    this.selectedSource,
    this.selectedPriority,
    this.selectedLeadStage,
    this.selectedState,
    this.selectedDistrict,
    this.assignedStaffName = '',
    this.additionalFields = const [],
    this.isLoadingAdditionalFields = false,
  });

  bool get isLoading        => status == AddLeadStatus.loading;
  bool get isListLoading    => listStatus == LeadListStatus.loading;

  AddLeadState copyWith({
    AddLeadStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<AddLeadModel>? leads,
    LeadListStatus? listStatus,
    String? listError,
    bool? isDeleting,
    bool? isUpdating,
    List<LeadsModel>? categories,
    List<LeadsModel>? sources,
    List<LeadsModel>? stages,
    String? selectedCategory,
    String? selectedSource,
    String? selectedPriority,
    String? selectedLeadStage,
    String? selectedState,
    String? selectedDistrict,
    String? assignedStaffName,
    List<AdditionalFieldModel>? additionalFields,
    bool? isLoadingAdditionalFields,
    // ── clear flags ──────────────────────────────────────────────────────────
    bool clearError         = false,
    bool clearSuccess       = false,
    bool clearListError     = false,
    bool clearState         = false,
    bool clearDistrict      = false,
    bool clearCategory      = false,
    bool clearSource        = false,
    bool clearPriority      = false,
    bool clearLeadStage     = false,
  }) {
    return AddLeadState(
      status:               status           ?? this.status,
      isSubmitting:         isSubmitting     ?? this.isSubmitting,
      errorMessage:         clearError       ? null : (errorMessage   ?? this.errorMessage),
      successMessage:       clearSuccess     ? null : (successMessage ?? this.successMessage),
      leads:                leads            ?? this.leads,
      listStatus:           listStatus       ?? this.listStatus,
      listError:            clearListError   ? null : (listError      ?? this.listError),
      isDeleting:           isDeleting       ?? this.isDeleting,
      isUpdating:           isUpdating       ?? this.isUpdating,
      categories:           categories       ?? this.categories,
      sources:              sources          ?? this.sources,
      stages:               stages           ?? this.stages,
      selectedCategory:     clearCategory    ? null : (selectedCategory  ?? this.selectedCategory),
      selectedSource:       clearSource      ? null : (selectedSource    ?? this.selectedSource),
      selectedPriority:     clearPriority    ? null : (selectedPriority  ?? this.selectedPriority),
      selectedLeadStage:    clearLeadStage   ? null : (selectedLeadStage ?? this.selectedLeadStage),
      selectedState:        clearState       ? null : (selectedState     ?? this.selectedState),
      selectedDistrict:     clearDistrict    ? null : (selectedDistrict  ?? this.selectedDistrict),
      assignedStaffName:    assignedStaffName ?? this.assignedStaffName,
      additionalFields:           additionalFields          ?? this.additionalFields,
      isLoadingAdditionalFields:  isLoadingAdditionalFields ?? this.isLoadingAdditionalFields,
    );
  }
}