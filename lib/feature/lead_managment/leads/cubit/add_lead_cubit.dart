import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/data/add_lead_repo.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/data/lead_category_repository.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/data/lead_source_repo.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/data/lead_stage_repo.dart';
import 'package:oxdo/feature/staff_managment/staff/data/add_staff_repo.dart';

class AddLeadCubit extends Cubit<AddLeadState> {
  final IAddLeadRepository          _leadRepository;
  final ILeadCategoryRepository     _categoryRepository;
  final ILeadSourceRepository       _sourceRepository;
  final ILeadStageRepository        _leadStageRepository;
  final AdditionalFieldsRepository  _additionalFieldsRepo;
  final StaffRepository _staffRepository;

  StreamSubscription? _categorySubscription;
  StreamSubscription? _sourceSubscription;
  StreamSubscription? _leadStageSubscription;

  AddLeadCubit({
    IAddLeadRepository?         leadRepository,
    ILeadCategoryRepository?    categoryRepository,
    ILeadSourceRepository?      sourceRepository,
    ILeadStageRepository?       leadStageRepository,
    AdditionalFieldsRepository? additionalFieldsRepo,
    StaffRepository?            staffRepository,
  })  : _leadRepository       = leadRepository      ?? AddLeadRepository(),
        _categoryRepository   = categoryRepository  ?? LeadCategoryRepository(),
        _sourceRepository     = sourceRepository    ?? LeadSourceRepository(),
        _leadStageRepository  = leadStageRepository ?? LeadStageRepository(),
        _additionalFieldsRepo = additionalFieldsRepo ?? AdditionalFieldsRepositoryImpl(),
        _staffRepository      = staffRepository     ?? StaffRepository(),
        super(const AddLeadState());

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    emit(state.copyWith(status: AddLeadStatus.loading));

    // Load staff name + additional fields in parallel; streams fire independently
    await Future.wait([
      _loadStaffName(),
      _fetchAdditionalFields(),
    ]);

    _watchCategories();
    _watchSources();
    _watchLeadStages();

    emit(state.copyWith(status: AddLeadStatus.initial));
  }

  Future<void> _loadStaffName() async {
    final user = await SessionService().getSavedUser();
    emit(state.copyWith(assignedStaffName: user?.name ?? 'Unknown'));
  }

  Future<void> _fetchAdditionalFields() async {
    emit(state.copyWith(isLoadingAdditionalFields: true));
    try {
      final fields = await _additionalFieldsRepo.fetchFields();
      emit(state.copyWith(
        additionalFields:          fields,
        isLoadingAdditionalFields: false,
      ));
    } catch (_) {
      // Non-fatal — form works fine without custom fields
      emit(state.copyWith(isLoadingAdditionalFields: false));
    }
  }

  void _watchCategories() {
    _categorySubscription?.cancel();
    _categorySubscription = _categoryRepository.watchCategories().listen(
      (cats) => emit(state.copyWith(categories: [...cats])),
      onError: (_) {},
    );
  }

  void _watchSources() {
    _sourceSubscription?.cancel();
    _sourceSubscription = _sourceRepository.watchSource().listen(
      (srcs) => emit(state.copyWith(sources: [...srcs])),
      onError: (_) {},
    );
  }

  void _watchLeadStages() {
    _leadStageSubscription?.cancel();
    _leadStageSubscription = _leadStageRepository.watchCategories().listen(
      (stages) => emit(state.copyWith(stages: [...stages])),
      onError: (_) {},
    );
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    _sourceSubscription?.cancel();
    _leadStageSubscription?.cancel();
    return super.close();
  }

  // ── Selection helpers ─────────────────────────────────────────────────────

  void selectCategory(String? value) =>
      emit(state.copyWith(selectedCategory: value));

  void selectSource(String? value) =>
      emit(state.copyWith(selectedSource: value));

  void selectPriority(String? value) =>
      emit(state.copyWith(selectedPriority: value));

  void selectLeadStage(String? value) =>
      emit(state.copyWith(selectedLeadStage: value));
      
  void selectState(String? value) =>
      emit(state.copyWith(selectedState: value, clearState: value == null, clearDistrict: true));

  void selectDistrict(String? value) =>
      emit(state.copyWith(selectedDistrict: value, clearDistrict: value == null));

  // ── Fetch list ────────────────────────────────────────────────────────────

  Future<void> fetchLeads() async {
    emit(state.copyWith(listStatus: LeadListStatus.loading, clearListError: true));
    try {
      final leads = await _leadRepository.fetchLeads();
      emit(state.copyWith(listStatus: LeadListStatus.loaded, leads: leads));
    } catch (e) {
      emit(state.copyWith(
        listStatus: LeadListStatus.failure,
        listError:  _friendlyError(e),
      ));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteLead(String id, AddLeadModel lead) async {
    if (state.isDeleting) return;
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await _leadRepository.moveToDeleted(lead);
      final updated = state.leads.where((l) => l.id != id).toList();
      emit(state.copyWith(
        isDeleting:     false,
        leads:          updated,
        successMessage: 'Lead deleted successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: _friendlyError(e)));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateLead(String id, AddLeadModel updated) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      await _leadRepository.updateLead(id, updated);
      final updatedList = state.leads.map((l) {
        return l.id == id ? updated.copyWith(id: id) : l;
      }).toList();
      emit(state.copyWith(
        isUpdating:     false,
        leads:          updatedList,
        successMessage: 'Lead updated successfully.',
        status:         AddLeadStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating:   false,
        status:       AddLeadStatus.failure,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  // ── Submit (add) ──────────────────────────────────────────────────────────

  Future<void> submitLead({
    required String clientName,
    required String contactNumber,
    required String contactDialCode,
    required String whatsappNumber,
    required String whatsappDialCode,
    required String email,
    required String address,
    required String pinCode,
    required String postOffice,
    required String remarks,
    // Additional custom field values collected from the UI
    Map<String, String> additionalFieldValues = const {},
  }) async {
    if (state.isSubmitting) return;

    // ── Validation ────────────────────────────────────────────────────────
    if (clientName.trim().isEmpty) {
      emit(state.copyWith(
          errorMessage: 'Client name is required.', clearSuccess: true));
      return;
    }
    if (contactNumber.trim().isEmpty) {
      emit(state.copyWith(
          errorMessage: 'Contact number is required.', clearSuccess: true));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final user = await SessionService().getSavedUser();

      final lead = AddLeadModel(
        clientName:       clientName,
        contactNumber:    contactNumber,
        contactDialCode:  contactDialCode,
        whatsappNumber:   whatsappNumber,
        whatsappDialCode: whatsappDialCode,
        email:            email,
        address:          address,
        pinCode:          pinCode,
        postOffice:       postOffice,
        state:            state.selectedState    ?? '',
        district:         state.selectedDistrict ?? '',
        assignedStaff:    state.assignedStaffName,
        assignedStaffId:  user?.id  ?? '',
        leadCategory:     state.selectedCategory  ?? '',
        leadSource:       state.selectedSource    ?? '',
        priority:         state.selectedPriority  ?? '',
        leadStage:        state.selectedLeadStage ?? '',
        remarks:          remarks,
        createdBy:        user?.name ?? '',
        createdById:      user?.id   ?? '',
        // Store dynamic field values alongside the lead
        additionalFields: additionalFieldValues,
      );

      final newId  = await _leadRepository.addLead(lead);
      final newLead = lead.copyWith(id: newId);

      emit(state.copyWith(
        isSubmitting:   false,
        status:         AddLeadStatus.success,
        successMessage: 'Lead added successfully.',
        leads:          [newLead, ...state.leads],
        clearError:     true,
        clearCategory:  true,
        clearSource:    true,
        clearPriority:  true,
        clearLeadStage: true,
        clearState:     true,
        clearDistrict:  true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting:  false,
        status:        AddLeadStatus.failure,
        errorMessage:  _friendlyError(e),
        clearSuccess:  true,
      ));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('permission-denied'))
      return 'You do not have permission to perform this action.';
    if (msg.contains('network') || msg.contains('unavailable'))
      return 'Network error. Please check your connection.';
    if (msg.contains('not-found'))
      return 'Record not found. It may have been deleted.';
    if (msg.contains('Client name'))   return msg;
    if (msg.contains('Contact number')) return msg;
    return 'Something went wrong. Please try again.';
  }



  ///--------------deleted leads-------------
  ///---------------------------------------------
  
  Future<void> restoreLead(AddLeadModel lead) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      await _leadRepository.restoreLead(lead);
      emit(state.copyWith(isUpdating: false, successMessage: 'Lead restored successfully.'));
      await fetchDeletedLeads();
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: _friendlyError(e)));
    }
  }

  Future<void> fetchDeletedLeads() async {
    emit(state.copyWith(listStatus: LeadListStatus.loading, clearListError: true));
    try {
      final leads = await _leadRepository.fetchDeletedLeads();
      emit(state.copyWith(listStatus: LeadListStatus.loaded, leads: leads));
    } catch (e) {
      emit(state.copyWith(
        listStatus: LeadListStatus.failure,
        listError:  _friendlyError(e),
      ));
    }
  }

  Future<void> permanentlyDeleteLead(String id) async {
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await _leadRepository.permanentlyDeleteLead(id);
      final updated = state.leads.where((l) => l.id != id).toList();
      emit(state.copyWith(
        isDeleting:     false, 
        leads:          updated,
        successMessage: 'Lead deleted successfully.',
      ));
      await fetchDeletedLeads();
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: _friendlyError(e)));
    }
  }
// ----------------fetch staff----------------
Future<void> fetchStaff() async {
  try {
    final list = await _staffRepository.fetchAll();
    emit(state.copyWith(staffList: list));
  } catch (e) {
    log('[AddLeadCubit] fetchStaff error: $e');
  }
}

Future<void> assignStaff({
  required String leadId,
  required String staffId,
  required String staffName,
}) async {
  emit(state.copyWith(isUpdating: true, clearError: true));
  try {
    await _leadRepository.assignStaff(leadId, staffId, staffName);
    // 🔹 Update local list so UI reflects immediately without re-fetch
    final updatedLeads = state.leads.map((l) {
      return l.id == leadId
          ? l.copyWith(assignedStaffId: staffId, assignedStaff: staffName)
          : l;
    }).toList();
    emit(state.copyWith(
      isUpdating:     false,
      leads:          updatedLeads,
      successMessage: 'Staff assigned successfully.',
    ));
  } catch (e) {
    emit(state.copyWith(
      isUpdating:   false,
      errorMessage: _friendlyError(e),
    ));
  }}

  // --------------add follow up--------------------------------





  
  Future<void> submitFollowUp({
  required String leadId,
  required String leadName,
  required String leadWhatsappNo,
  required String leadWhatsappDialCode,
  required DateTime calledDate,
  required DateTime nextFollowUpDate,
  required String calledStatus,
  required String remarks,
}) async {
  if (state.isSubmitting) return;

  if (calledStatus.trim().isEmpty) {
    emit(state.copyWith(
        errorMessage: 'Call status is required.', clearSuccess: true));
    return;
  }

  emit(state.copyWith(isSubmitting: true, clearError: true));

  try {
    final user = await SessionService().getSavedUser();

    final followUp = FollowUpModel(
      leadId: leadId,
      leadName: leadName,
      leadWhatsappNo: leadWhatsappNo,
      leadWhatsappDialCode: leadWhatsappDialCode,
      calledDate: calledDate,
      nextFollowUpDate: nextFollowUpDate,
      calledStatus: calledStatus,
      leadStage: state.selectedLeadStage ?? '',
      leadCategory: state.selectedCategory ?? '',
      priority: state.selectedPriority ?? '',
      remarks: remarks,
      createdById: user?.id ?? '',
      createdAt: DateTime.now(),
    );

    await _leadRepository.addFollowUp(leadId, followUp);

    emit(state.copyWith(
      isSubmitting: false,
      status: AddLeadStatus.success,
      successMessage: 'Follow-up added successfully.',
      clearError: true,
      clearCategory: true,
      clearPriority: true,
      clearLeadStage: true,
    ));
  } catch (e) {
    emit(state.copyWith(
      isSubmitting: false,
      status: AddLeadStatus.failure,
      errorMessage: _friendlyError(e),
      clearSuccess: true,
    ));
  }
}


  // ── Fetch lead count ────────────────────────────────────────────────────────────

  Future<void> fetchDashboardCounts(DateTime selectedDate) async {

    try {

      final user = await SessionService().getSavedUser();

      if (user == null) return;

      final counts = await _leadRepository.fetchLeadCounts(
        staffId: user.id ?? '',
        selectedDate: selectedDate,
      );

      emit(
        state.copyWith(
          newLeadCount: counts.newLeadCount.toString(),
          followUpCount: counts.followUpCount.toString(),
          closedLeadCount: counts.closedLeadCount.toString(),
          totalCalledCount: counts.totalCalledCount.toString(),
          missedLeadCount: counts.missedLeadCount.toString(),
          transferredCount: counts.transferredCount.toString(),
        ),
      );

    } catch (e) {

      log("Dashboard Count Error : $e");
    }
  }

}