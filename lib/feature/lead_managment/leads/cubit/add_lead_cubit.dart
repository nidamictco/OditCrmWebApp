import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/data/add_lead_repo.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/notification/data/notification_repo.dart';
import 'package:oxdo/feature/reports/staff_reports/screen/staff_profile_screen.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/data/lead_category_repository.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/data/lead_source_repo.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/data/lead_stage_repo.dart';
import 'package:oxdo/feature/settings/general_settings/data/general_settings_repo.dart';
import 'package:oxdo/feature/staff_managment/staff/data/add_staff_repo.dart';


class AddLeadCubit extends Cubit<AddLeadState> {
  final IAddLeadRepository _leadRepository;
  final ILeadCategoryRepository _categoryRepository;
  final ILeadSourceRepository _sourceRepository;
  final ILeadStageRepository _leadStageRepository;
  final AdditionalFieldsRepository _additionalFieldsRepo;
  final StaffRepository _staffRepository;
  final NotificationRepo notificationRepo = NotificationRepo();

  StreamSubscription? _categorySubscription;
  StreamSubscription? _sourceSubscription;
  StreamSubscription? _leadStageSubscription;
  GeneralSettingsRepository? _settingsRepo;

  AddLeadCubit({
    IAddLeadRepository? leadRepository,
    ILeadCategoryRepository? categoryRepository,
    ILeadSourceRepository? sourceRepository,
    ILeadStageRepository? leadStageRepository,
    AdditionalFieldsRepository? additionalFieldsRepo,
    StaffRepository? staffRepository,
  }) : _leadRepository = leadRepository ?? AddLeadRepository(),
       _categoryRepository = categoryRepository ?? LeadCategoryRepository(),
       _sourceRepository = sourceRepository ?? LeadSourceRepository(),
       _leadStageRepository = leadStageRepository ?? LeadStageRepository(),
       _additionalFieldsRepo =
           additionalFieldsRepo ?? AdditionalFieldsRepositoryImpl(),
       _staffRepository = staffRepository ?? StaffRepository(),
       super(const AddLeadState());

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    emit(state.copyWith(status: AddLeadStatus.loading));

    // Load staff name + additional fields in parallel; streams fire independently
    await Future.wait([_loadStaffName(), _fetchAdditionalFields()]);

    _watchCategories();
    _watchSources();
    _watchLeadStages();

    emit(
      state.copyWith(
        selectedPriority: 'Normal',
        selectedLeadStage: 'NEW',
        status: AddLeadStatus.initial,
      ),
    );
  }

  void initSettings(String staffId) {
    _settingsRepo = GeneralSettingsRepository(staffId: staffId);
  }

  Future<void> _loadStaffName() async {
    final user = await SessionService().getSavedUser();
    emit(state.copyWith(assignedStaffName: user?.name ?? 'Unknown'));
  }

  Future<void> _fetchAdditionalFields() async {
    emit(state.copyWith(isLoadingAdditionalFields: true));
    try {
      final fields = await _additionalFieldsRepo.fetchFields();
      emit(
        state.copyWith(
          additionalFields: fields,
          isLoadingAdditionalFields: false,
        ),
      );
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

  void selectState(String? value) => emit(
    state.copyWith(
      selectedState: value,
      clearState: value == null,
      clearDistrict: true,
    ),
  );

  void selectDistrict(String? value) => emit(
    state.copyWith(selectedDistrict: value, clearDistrict: value == null),
  );

  void selectCallResult(String? value) =>
      emit(state.copyWith(selectedCallResult: value));

  void selectLeadTag(String? value) =>
      emit(state.copyWith(selectedLeadTag: value));

  void selectAssignedStaff({required String name, required String id}) {
    emit(state.copyWith(assignedStaffName: name, assignedStaffId: id));
  }
  // ── Fetch list ────────────────────────────────────────────────────────────

  Future<void> fetchLeads() async {
    emit(
      state.copyWith(listStatus: LeadListStatus.loading, clearListError: true),
    );
    try {
      final user = await SessionService().getSavedUser();
      final leads = await _leadRepository.fetchLeads(
        staffId: user?.id ?? '',
        role: user?.staffType ?? '',
      );
      emit(state.copyWith(listStatus: LeadListStatus.loaded, leads: leads));
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: LeadListStatus.failure,
          listError: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> fetchDashboardLeads({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime selectedDate,
  }) async {


    emit(
      state.copyWith(listStatus: LeadListStatus.loading, clearListError: true),
    );

    try {
      final leads = await _leadRepository.fetchDashboardLeads(
        staffId: staffId,
        role: role,
        fromCard: fromCard,
        selectedDate: selectedDate,
      );

      emit(state.copyWith(listStatus: LeadListStatus.loaded, leads: leads));
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: LeadListStatus.failure,
          listError: _friendlyError(e),
        ),
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteLead(String id, AddLeadModel lead) async {
    if (state.isDeleting) return;
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await _leadRepository.moveToDeleted(lead);
      final updated = state.leads.where((l) => l.id != id).toList();
      emit(
        state.copyWith(
          isDeleting: false,
          leads: updated,
          successMessage: 'Lead deleted successfully.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: _friendlyError(e)));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateLead(String id, AddLeadModel updated) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      // ✅ Capture previous state before overwriting
      final previous = state.leads.firstWhere(
        (l) => l.id == id,
        orElse: () => updated, // fallback: no diff will be logged
      );

      await _leadRepository.updateLead(id, updated);

      // ✅ Log what changed
      final user = await SessionService().getSavedUser();
      await _leadRepository.logLeadUpdated(
        leadId: id,
        changedByName: user?.name ?? '',
        changedById: user?.id ?? '',
        previous: previous,
        updated: updated,
      );

      final updatedList = state.leads.map((l) {
        return l.id == id ? updated.copyWith(id: id) : l;
      }).toList();

      emit(
        state.copyWith(
          isUpdating: false,
          leads: updatedList,
          successMessage: 'Lead updated successfully.',
          status: AddLeadStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          status: AddLeadStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // Future<void> updateLead(String id, AddLeadModel updated) async {
  //   if (state.isUpdating) return;
  //   emit(state.copyWith(isUpdating: true, clearError: true));
  //   try {
  //     await _leadRepository.updateLead(id, updated);
  //     final updatedList = state.leads.map((l) {
  //       return l.id == id ? updated.copyWith(id: id) : l;
  //     }).toList();
  //     emit(
  //       state.copyWith(
  //         isUpdating: false,
  //         leads: updatedList,
  //         successMessage: 'Lead updated successfully.',
  //         status: AddLeadStatus.success,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         isUpdating: false,
  //         status: AddLeadStatus.failure,
  //         errorMessage: _friendlyError(e),
  //       ),
  //     );
  //   }
  // }

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
    required DateTime nextFollowUpDate,
    Map<String, String> additionalFieldValues = const {},
  }) async {
    if (state.isSubmitting) return;

    if (clientName.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Client name is required.',
          clearSuccess: true,
        ),
      );
      return;
    }
    if (contactNumber.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Contact number is required.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final user = await SessionService().getSavedUser();

      if (isClosed) return;

      final resolvedStaffId = (state.assignedStaffId?.isNotEmpty == true)
          ? state.assignedStaffId!
          : user?.id ?? '';

      final resolvedStaffName = state.assignedStaffName.isNotEmpty
          ? state.assignedStaffName
          : user?.name ?? '';

      final lead = AddLeadModel(
        clientName: clientName,
        contactNumber: contactNumber,
        contactDialCode: contactDialCode,
        whatsappNumber: whatsappNumber,
        whatsappDialCode: whatsappDialCode,
        email: email,
        address: address,
        pinCode: pinCode,
        postOffice: postOffice,
        state: state.selectedState ?? '',
        district: state.selectedDistrict ?? '',
        assignedStaff: resolvedStaffName,
        assignedStaffId: resolvedStaffId,
        leadCategory: state.selectedCategory ?? '',
        leadSource: state.selectedSource ?? '',
        priority: state.selectedPriority ?? '',
        leadStage: state.selectedLeadStage ?? '',
        remarks: remarks,
        createdBy: user?.name ?? '',
        createdById: user?.id ?? '',
        callResult: state.selectedCallResult ?? '',
        leadTag: state.selectedLeadTag ?? '',
        followUpDate: nextFollowUpDate,
        additionalFields: additionalFieldValues,
      );

      final newId = await _leadRepository.addLead(lead);
      if (isClosed) return;
      // ✅ Log lead creation activity
      await _leadRepository.logLeadCreated(
        leadId: newId,
        createdByName: user?.name ?? '',
        createdById: user?.id ?? '',
        assignedTo: resolvedStaffName,
        leadStage: lead.leadStage,
        priority: lead.priority,
        leadCategory: lead.leadCategory,
      );

      if (isClosed) return;
      final newLead = lead.copyWith(id: newId);

      if (resolvedStaffId.isNotEmpty) {
        await notificationRepo.create(
          staffId: resolvedStaffId,
          title: 'New Lead Assigned',
          message: 'Name:${lead.clientName} phone No:${lead.contactNumber}',
        );
      }

      if (isClosed) return;

      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.success,
          successMessage: 'Lead added successfully.',
          leads: [newLead, ...state.leads],
          clearError: true,
          clearCategory: true,
          clearSource: true,
          clearPriority: true,
          clearLeadStage: true,
          clearState: true,
          clearDistrict: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.failure,
          errorMessage: _friendlyError(e),
          clearSuccess: true,
        ),
      );
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
    if (msg.contains('Client name')) return msg;
    if (msg.contains('Contact number')) return msg;
    return 'Something went wrong. Please try again.';
  }

  ///--------------deleted leads-------------
  ///---------------------------------------------

  Future<void> restoreLead(AddLeadModel lead) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      await _leadRepository.restoreLead(lead);
      emit(
        state.copyWith(
          isUpdating: false,
          successMessage: 'Lead restored successfully.',
        ),
      );
      await fetchDeletedLeads();
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: _friendlyError(e)));
    }
  }

  Future<void> fetchDeletedLeads() async {
    emit(
      state.copyWith(listStatus: LeadListStatus.loading, clearListError: true),
    );
    try {
      final leads = await _leadRepository.fetchDeletedLeads();
      emit(state.copyWith(listStatus: LeadListStatus.loaded, leads: leads));
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: LeadListStatus.failure,
          listError: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> permanentlyDeleteLead(String id) async {
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await _leadRepository.permanentlyDeleteLead(id);
      final updated = state.leads.where((l) => l.id != id).toList();
      emit(
        state.copyWith(
          isDeleting: false,
          leads: updated,
          successMessage: 'Lead deleted successfully.',
        ),
      );
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
      emit(
        state.copyWith(
          isUpdating: false,
          leads: updatedLeads,
          successMessage: 'Staff assigned successfully.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: _friendlyError(e)));
    }
  }

  // --------------add follow up--------------------------------

  Future<void> submitFollowUpOld({
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
      emit(
        state.copyWith(
          errorMessage: 'Call status is required.',
          clearSuccess: true,
        ),
      );
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

      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.success,
          successMessage: 'Follow-up added successfully.',
          clearError: true,
          clearCategory: true,
          clearPriority: true,
          clearLeadStage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.failure,
          errorMessage: _friendlyError(e),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> submitFollowUp({
    required String leadId,
    required String leadName,
    required String leadPhone, 
    required String leadWhatsappNo,
    required String leadWhatsappDialCode,
    required DateTime calledDate,
    required DateTime nextFollowUpDate,
    required String calledStatus,
    required String remarks,
    required String fromPage,
    required String editId,
    // Add these three — pass current lead values so repo can diff
    String previousStage = '',
    String previousCategory = '',
    String previousPriority = '',
  }) async {
    if (state.isSubmitting) return;

    if (calledStatus.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Call status is required.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final user = await SessionService().getSavedUser();

      log("fromPage : $fromPage");
      log("editId : $editId");

      String id = "";
      if(fromPage == "EDIT" && editId.isNotEmpty){
        id = editId;
      }
      else {
        id = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final followUp = FollowUpModel(
        id: id,
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

      await _leadRepository.addFollowUp(
        leadId,
        followUp,
        previousStage: previousStage,
        previousCategory: previousCategory,
        previousPriority: previousPriority,
        changedByName: user?.name ?? '',
        changedById: user?.id ?? '',
         leadName: leadName,
    leadPhone: leadPhone, 
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.success,
          successMessage: 'Follow-up added successfully.',
          clearError: true,
          clearCategory: true,
          clearPriority: true,
          clearLeadStage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AddLeadStatus.failure,
          errorMessage: _friendlyError(e),
          clearSuccess: true,
        ),
      );
    }
  }

  // ______transfer______________________

  Future<void> transferLead({
    required String leadId,
    required String leadName,
    required String contactNumber,
    required String leadCategory,
    required String leadStage,
    required String fromStaffId,
    required String fromStaff,
    required String toStaffId,
    required String toStaff,
  }) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, clearError: true));

  try {

    final user = await SessionService().getSavedUser();

    final transfer = TransferDetails(
      leadId: leadId,
      leadName: leadName,
      contactNumber: contactNumber,
      leadCategory: leadCategory,
      leadStage: leadStage,
      fromStaffId: fromStaffId,
      fromStaff: fromStaff,
      toStaffId: toStaffId,
      toStaff: toStaff,
      transferTime: DateTime.now(),
    );

    await _leadRepository.transferLead(
      leadId,
      transfer,
      changedByName: user?.name ?? '',
      changedById: user?.id ?? '',
    );
    // await _leadRepository.transferLead(leadId, transfer);

      if (toStaffId.isNotEmpty) {
        await notificationRepo.create(
          staffId: toStaffId,
          title: 'Lead Transferred',
          message: 'Name :$leadName, Phone No: $contactNumber',
        );
      }

      // if (fromStaffId.isNotEmpty) {
      //   await notificationRepo.create(
      //     staffId: fromStaffId,
      //     title: 'Lead Transferred',
      //     message: 'Name :$leadName, Phone No: $contactNumber to $toStaff',
      //   );
      // }

      if (isClosed) return;

      // ── Update local list ──────────────────────────────────────────────
      final updatedLeads = state.leads.map((l) {
        if (l.id != leadId) return l;
        return l.copyWith(
          assignedStaff: toStaff,
          assignedStaffId: toStaffId,
          transferLeads: [...(l.transferLeads ?? []), transfer],
        );
      }).toList();

      emit(
        state.copyWith(
          isUpdating: false,
          leads: updatedLeads,
          successMessage: 'Lead transferred successfully.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: _friendlyError(e)));
    }
  }

  // ── Fetch lead count ────────────────────────────────────────────────────────────

  // Future<void> fetchDashboardCounts(DateTime selectedDate) async {
  //   try {
  //     final user = await SessionService().getSavedUser();

  //     if (user == null) return;

  //     final counts = await _leadRepository.fetchLeadCounts(
  //       staffId: user.id ?? '',
  //       selectedDate: selectedDate,
  //       role: user.staffType ?? '',
  //     );

  //     emit(
  //       state.copyWith(
  //         newLeadCount: counts.newLeadCount.toString(),
  //         followUpCount: counts.followUpCount.toString(),
  //         closedLeadCount: counts.closedLeadCount.toString(),
  //         totalCalledCount: counts.totalCalledCount.toString(),
  //         missedLeadCount: counts.missedLeadCount.toString(),
  //         transferredCount: counts.transferredCount.toString(),
  //       ),
  //     );
  //   } catch (e) {
  //     log("Dashboard Count Error : $e");
  //   }
  // }
Future<void> fetchDashboardCounts(
  DateTime selectedDate, {
  String? staffId,  // ← add these
  String? role,
}) async {
  try {
    final user = await SessionService().getSavedUser();
    if (user == null) return;

    final counts = await _leadRepository.fetchLeadCounts(
      staffId: staffId ?? user.id ?? '',       // ← use passed staffId
      selectedDate: selectedDate,
      role: role ?? user.staffType ?? '',      // ← use passed role
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
  // ----------search----------

  Future<void> searchLeads(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(isSearching: false, searchResults: []));
      return;
    }

    // Show dropdown immediately with loading state
    emit(state.copyWith(isSearching: true, searchResults: []));

    try {
      // Use cached leads if already loaded — avoids Firestore call on every keystroke
      List<AddLeadModel> allLeads = state.leads;

      if (allLeads.isEmpty) {
        final user = await SessionService().getSavedUser();
        // Fetch directly into local variable — do NOT call fetchLeads() here
        // because fetchLeads() emits intermediate states that make state.leads
        // unreliable to read afterward
        allLeads = await _leadRepository.fetchLeads(
          staffId: user?.id ?? '',
          role: user?.staffType ?? '',
        );
        // Cache in state for future keystrokes (instant filter after first load)
        emit(
          state.copyWith(
            listStatus: LeadListStatus.loaded,
            leads: allLeads,
            isSearching: true,
          ),
        );
      }

      final q = query.toLowerCase();
      final results = allLeads
          .where(
            (lead) =>
                lead.clientName?.toLowerCase().contains(q) == true ||
                lead.contactNumber?.contains(query) == true ||
                lead.email?.toLowerCase().contains(q) == true,
          )
          .toList();

      emit(state.copyWith(isSearching: true, searchResults: results));
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchResults: []));
    }
  }

  void updateSelectedDashboardDate(DateTime date) {
    emit(state.copyWith(selectedDashboardDate: date));
  }

  // Future<void> fetchLeadChartCounts({
  //   required String staffId,
  //   required String role,
  //   required DateTime selectedDate,
  // }) async {
  //   try {
  //     final counts = await _leadRepository.fetchLeadCountsByCategory(
  //       staffId: staffId,
  //       role: role,
  //       selectedDate: selectedDate,
  //     );
  //     emit(state.copyWith(leadChartCounts: counts));
  //   } catch (e) {
  //     log('[AddLeadCubit] fetchLeadChartCounts error: $e');
  //   }
  // }
  Future<void> fetchLeadChartCounts({
  required String staffId,
  required String role,
  required DateTime selectedDate,
  DateTime? toDate,
}) async {
  try {
    // fetch both in parallel
    final results = await Future.wait([
      _leadRepository.fetchLeadCountsByCategory(
        staffId: staffId, role: role, selectedDate: selectedDate,
        toDate: toDate,   
      ),
      _leadRepository.fetchLeadCategoryTableRows(
        staffId: staffId, role: role, selectedDate: selectedDate, 
        toDate: toDate,  
      ),
    ]);

    emit(state.copyWith(
      leadChartCounts: results[0] as Map<String, int>,
      leadCategoryTableRows: results[1] as List<LeadCategoryTableRow>,
    ));
  } catch (e) {
    log('[AddLeadCubit] fetchLeadChartCounts error: $e');
  }
}


Future<void> fetchCallStatusCounts({
  required String staffId,
  required String role,
  DateTime? selectedDate,        
  DateTime? toDate, 
}) async {
  try {
    final counts = await _leadRepository.fetchCallStatusCounts(
      staffId: staffId,
      role: role,
      selectedDate: selectedDate,  
      toDate: toDate,    
    );
    emit(state.copyWith(
      totalCalledCount: counts['totalCalled'].toString(),
      connectedCount: counts['connected'].toString(),  
      notConnectedCount: counts['notConnected'].toString(), 
    ));
  } catch (e) {
    log('[AddLeadCubit] fetchCallStatusCounts error: $e');
  }
}

  Future<AddLeadModel?> getLeadById(String leadId) async {
    try {
      emit(state.copyWith(
        status: AddLeadStatus.loading,
        clearError: true,
      ));

      final lead = await _leadRepository.getLeadById(leadId);

      emit(state.copyWith(
        status: AddLeadStatus.success,
      ));

      return lead;
    } catch (e) {
      emit(state.copyWith(
        status: AddLeadStatus.failure,
        errorMessage: e.toString(),
      ));
      return null;
    }
  }


  Future<void> deleteFollowUp({
    required String leadId,
    required String followUpId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  }) async {
    try {
      emit(
        state.copyWith(
          status: AddLeadStatus.loading,
          clearError: true,
        ),
      );

      await _leadRepository.deleteFollowUp(
        leadId: leadId,
        followUpId: followUpId,
        changedByName: changedByName,
        changedById: changedById,
        leadName: leadName,
        leadPhone: leadPhone,
      );

      emit(
        state.copyWith(
          status: AddLeadStatus.success,
          successMessage: 'Follow-up deleted successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddLeadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }


}



Future<void> migrateCallResults() async {
  final db = FirebaseFirestore.instance;
  final leadsSnap = await db.collection('LEADS').get();

  for (final leadDoc in leadsSnap.docs) {
    // Get the latest follow-up for this lead
    final followUpsSnap = await db
        .collection('LEADS')
        .doc(leadDoc.id)
        .collection('FOLLOW_UPS')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (followUpsSnap.docs.isEmpty) continue;

    final latestCalledStatus =
        followUpsSnap.docs.first.data()['calledStatus'] as String? ?? '';

    if (latestCalledStatus.isEmpty) continue;

    // Update the lead's callResult
    await db.collection('LEADS').doc(leadDoc.id).update({
      'callResult': latestCalledStatus,
    });

    print('Updated lead ${leadDoc.id} → callResult: $latestCalledStatus');
  }

  print('Migration complete.');

  //////////called butten migrate////////////
  ///ElevatedButton(
 /// onPressed: () => migrateCallResults(),
 /// child: const Text('Run Migration'),
///),
}
