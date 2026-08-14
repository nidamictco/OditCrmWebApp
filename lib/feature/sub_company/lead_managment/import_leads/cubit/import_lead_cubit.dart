import 'dart:developer';
import 'dart:typed_data';

import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/shared_preference/session_service.dart';
import 'import_lead_state.dart';
import '../data/import_lead_repo.dart';
import '../model/import_leads_model.dart';
import '../../../notification/data/notification_repo.dart';
import '../../../leads_settings_.dart/common_model/lead_model.dart';
import '../../../staff_managment/staff/model/staff_model.dart';

// class ImportLeadsCubit extends Cubit<ImportLeadsState> {
//   final IImportLeadsRepository _repository;
//    final IAddLeadRepository _leadRepository;
//   final NotificationRepo _notificationRepo;

//   ImportLeadsCubit({
//      IAddLeadRepository? leadRepository,
//     IImportLeadsRepository? repository,
//     NotificationRepo? notificationRepo,
//   }) :_leadRepository = leadRepository ?? AddLeadRepository(),
//    _repository = repository ?? ImportLeadsRepository(),
//        _notificationRepo = notificationRepo ?? NotificationRepo(),
//        super(const ImportLeadsState());

class ImportLeadsCubit extends Cubit<ImportLeadsState> {
  final IImportLeadsRepository _repository;
  final IAddLeadRepository _leadRepository;
  final NotificationRepo _notificationRepo;

  factory ImportLeadsCubit({
    IAddLeadRepository? leadRepository,
    IImportLeadsRepository? repository,
    NotificationRepo? notificationRepo,
  }) {
    final resolvedLeadRepo = leadRepository ?? AddLeadRepository();
    return ImportLeadsCubit._(
      leadRepository: resolvedLeadRepo,
      repository: repository ??
          ImportLeadsRepository(leadRepository: resolvedLeadRepo),
      notificationRepo: notificationRepo ?? NotificationRepo(),
    );
  }

  ImportLeadsCubit._({
    required IAddLeadRepository leadRepository,
    required IImportLeadsRepository repository,
    required NotificationRepo notificationRepo,
  })  : _leadRepository = leadRepository,
        _repository = repository,
        _notificationRepo = notificationRepo,
        super(const ImportLeadsState());


  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (state.status == ImportLeadsStatus.ready ||
        state.status == ImportLeadsStatus.success)
      return;

    emit(state.copyWith(status: ImportLeadsStatus.loading, clearError: true));

    try {
      // ── 1. Resolve logged-in user ────────────────────────────────────────
      final user = await SessionService().getSavedUser();
      final role = user?.staffType ?? ''; // e.g. 'Admin' or 'Staff'
      final isAdmin = role.toLowerCase() == 'admin';

      // ── 2. Fetch all dropdown data in parallel ───────────────────────────
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchSources(),
        _repository.fetchStaff(),
        _repository.fetchLeadStages(),
      ]);

      final fetchedStages = results[3] as List<LeadsModel>;
      final fetchedStaff = results[2] as List<StaffModel>;

      final defaultStage = fetchedStages.isEmpty
          ? null
          : fetchedStages
                .firstWhere(
                  (s) => s.name?.toLowerCase() == 'new',
                  orElse: () => fetchedStages.first,
                )
                .name;

      // ── 3. Resolve staff assignment based on role ────────────────────────
      //
      //  Admin  → no pre-selection; user picks from dropdown
      //  Staff  → auto-assign the logged-in staff; hide the dropdown
      //
      final String? preSelectedStaff = isAdmin ? null : (user?.name ?? '');
      final String preAssignedName = isAdmin ? '' : (user?.name ?? '');
      final String preAssignedId = isAdmin ? '' : (user?.id ?? '');
      final String loggedInStaffId = user?.id ?? '';

      emit(
        state.copyWith(
          status: ImportLeadsStatus.ready,
          categories: results[0] as List<LeadsModel>,
          sources: results[1] as List<LeadsModel>,
          staffList: fetchedStaff,
          stages: fetchedStages,
          userRole: role,
          loggedInStaffId: loggedInStaffId,
          selectedLeadStage: state.selectedLeadStage ?? defaultStage,
          // Staff users get their own name pre-filled; Admin leaves it null
          selectedStaff: preSelectedStaff,
          assignedStaffName: preAssignedName,
          assignedStaffId: preAssignedId,
        ),
      );

      log(
        '[ImportLeadsCubit] Initialized — role: $role, '
        'categories: ${state.categories.length}, '
        'sources: ${state.sources.length}, '
        'staff: ${state.staffList.length}, '
        'stages: ${state.stages.length}',
      );
    } catch (e, st) {
      log('[ImportLeadsCubit] initialize error: $e', stackTrace: st);
      emit(
        state.copyWith(
          status: ImportLeadsStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

 void selectNextFollowUpDate(DateTime? date) {
  log('[Cubit] selectNextFollowUpDate called with: $date');   // ← ADD
  emit(
    state.copyWith(
      nextFollowUpDate: date,
      clearNextFollowUpDate: date == null,
    ),
  );
  log('[Cubit] state.nextFollowUpDate after emit: ${state.nextFollowUpDate}');   // ← ADD
}

  // ── Selection helpers ─────────────────────────────────────────────────────

  // void selectCategory(String? value) => emit(
  //   state.copyWith(selectedCategory: value, clearCategory: value == null),
  // );

  Future<void> selectCategory(String? value) async {
    emit(state.copyWith(selectedCategory: value, clearCategory: value == null));
    emit(state.copyWith(subCategories: [], clearSubCategory: true));
    log("uuuuuuuuuuuu");
    if (value == null) return;

    final match = state.categories.where((c) => c.name == value);
    if (match.isEmpty) return;

    final categoryId = match.first.id;
    log("yyyyyyyyyyyyyyyyyyyy $categoryId");
    emit(state.copyWith(selectedCategoryId: categoryId));

    try {
      final subs = await _repository.fetchSubCategories(categoryId);
      log("zzzzzzzzzzzz $subs");
      emit(state.copyWith(subCategories: subs));
    } catch (_) {
      // non-fatal; leave subCategories empty
    }
  }

  void selectSubCategory(String? value) {
    emit(
      state.copyWith(
        selectedSubCategory: value,
        clearSubCategory: value == null,
      ),
    );
    if (value == null) return;
    final match = state.subCategories.where((s) => s.name == value);
    if (match.isNotEmpty) {
      emit(state.copyWith(selectedSubCategoryId: match.first.id));
    }
  }

  // void selectSource(String? value) =>
  //     emit(state.copyWith(selectedSource: value, clearSource: value == null));

  void selectSource(String? value) {
    emit(state.copyWith(selectedSource: value, clearSource: value == null));
    if (value == null) return;
    final match = state.sources.where((s) => s.name == value);
    if (match.isNotEmpty) {
      emit(state.copyWith(selectedSourceId: match.first.id));
    }
  }

 
void selectLeadStage(String? value) {
  final normalized = value?.toUpperCase().replaceAll(' ', '');
   log('[Cubit] selectLeadStage: value="$value" normalized="$normalized" '
      'clearNextFollowUpDate=${normalized != 'FOLLOWUP'}');   
  emit(
    state.copyWith(
      selectedLeadStage: value,
      clearLeadStage: value == null,
      clearNextFollowUpDate: normalized != 'FOLLOWUP',
    ),
  );
}

  void selectPriority(String? value) => emit(
    state.copyWith(selectedPriority: value, clearPriority: value == null),
  );

  /// Only called for Admin users — Staff assignment is read-only.
  void selectStaff(String? value) {
    if (!state.isAdmin) return; // guard: Staff users cannot change assignment
    final staffMember = value == null || state.staffList.isEmpty
        ? null
        : state.staffList.firstWhere(
            (s) => s.name == value,
            orElse: () => state.staffList.first,
          );
    emit(
      state.copyWith(
        selectedStaff: value,
        assignedStaffName: value ?? '',
        assignedStaffId: staffMember?.id,
        clearStaff: value == null,
      ),
    );
  }

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

  void selectTab(int tab) => emit(state.copyWith(selectedTab: tab));

  void setDialCode(String code) => emit(state.copyWith(dialCode: code));

  void setCsvBytes(Uint8List? bytes) => emit(state.copyWith(csvBytes: bytes));

  void clearCsvBytes() => emit(state.copyWith(clearCsvBytes: true));

  void updateFieldPosition(String fieldName, int position) {
    final updated = Map<String, int>.from(state.fieldPositions);
    updated[fieldName] = position;
    emit(state.copyWith(fieldPositions: updated));
  }

  // ── Refresh helpers ───────────────────────────────────────────────────────

  Future<void> refreshCategories() async {
    try {
      final cats = await _repository.fetchCategories();
      emit(state.copyWith(categories: cats));
    } catch (e) {
      log('[ImportLeadsCubit] refreshCategories error: $e');
    }
  }

  Future<void> refreshSources() async {
    try {
      final srcs = await _repository.fetchSources();
      emit(state.copyWith(sources: srcs));
    } catch (e) {
      log('[ImportLeadsCubit] refreshSources error: $e');
    }
  }

  Future<void> refreshStages() async {
    try {
      final stgs = await _repository.fetchLeadStages();
      emit(state.copyWith(stages: stgs));
    } catch (e) {
      log('[ImportLeadsCubit] refreshStages error: $e');
    }
  }

  // ── Duplicate pre-check ───────────────────────────────────────────────────

  Future<int> checkDuplicates({required Uint8List csvBytes}) async {
    try {
      return await _repository.countDuplicates(
        csvBytes: csvBytes,
        fieldPositions: state.fieldPositions,
      );
    } catch (e) {
      log('[ImportLeadsCubit] checkDuplicates error: $e');
      return 0;
    }
  }

  // ── CSV Import ────────────────────────────────────────────────────────────

  Future<void> importLeads({required Uint8List csvBytes}) async {
    // ── Validation ───────────────────────────────────────────────────────────
    //
    //  Admin  → must have selected a staff member from the dropdown.
    //  Staff  → assignedStaffName is always pre-filled during initialize();
    //           nothing to validate on the UI side.
    //
    if (state.isAdmin &&
        (state.selectedStaff == null || state.selectedStaff!.trim().isEmpty)) {
      emit(
        state.copyWith(
          status: ImportLeadsStatus.failure,
          errorMessage: 'Please select a staff member before importing leads.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ImportLeadsStatus.importing,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final user = await SessionService().getSavedUser();

      // ── Resolve the final staff assignment ──────────────────────────────
      //
      //  Admin  → uses whatever the Admin chose in the dropdown.
      //  Staff  → always the logged-in user (never overrideable).
      //
      final String resolvedStaffName;
      final String resolvedStaffId;

      if (state.isAdmin) {
        resolvedStaffName = state.selectedStaff ?? '';
        resolvedStaffId = _staffIdFromName(state.selectedStaff);
      } else {
        // Staff: use the session user directly (most authoritative source)
        resolvedStaffName = user?.name ?? state.assignedStaffName;
        resolvedStaffId = user?.id ?? state.loggedInStaffId;
      }

       log('[Cubit] importLeads start — state.nextFollowUpDate=${state.nextFollowUpDate}'); 

      final defaults = AddLeadModel(
        leadCategory: state.selectedCategory ?? '',
        leadCategoryId: state.selectedCategoryId ?? '',
        leadSubCategory: state.selectedSubCategory ?? '',
        leadSubCategoryId: state.selectedSubCategoryId ?? '',
        leadSource: state.selectedSource ?? '',
        leadSourceId: state.selectedSourceId ?? '',
        leadStage: state.selectedLeadStage ?? '',
        leadStageId: state.selectedLeadStageId ?? '',
        priority: state.selectedPriority ?? 'Normal',
        state: state.selectedState ?? '',
        district: state.selectedDistrict ?? '',
        assignedStaff: state.assignedStaffName,
        assignedStaffId: state.assignedStaffId ?? '',
        contactDialCode: state.dialCode,
        createdBy: user?.name ?? '',
        createdById: user?.id ?? '',
        followUpDate:  state.nextFollowUpDate ??
      (state.selectedLeadStage?.toUpperCase().replaceAll(' ', '') == 'FOLLOWUP'
          ? DateTime.now().add(const Duration(hours: 2))
          : null), clientName: '', contactNumber: '',
      );

log('[Cubit] defaults.followUpDate=${defaults.followUpDate}, '
      'defaults.leadStage="${defaults.leadStage}"'); 

      final result = await _repository.importFromCsv(
        csvBytes: csvBytes,
        fieldPositions: state.fieldPositions,
        defaults: defaults,
        hasCountryCode: state.selectedTab == 0,
      );
      if (isClosed) return;

      final count = result['imported']!;
      final skipped = result['skipped']!;

      // ── Notifications ────────────────────────────────────────────────────
      final creatorId = user?.id ?? '';

      await _notificationRepo.createForAdmins(
        title: 'Leads Imported',
        message:
            '$count lead${count == 1 ? '' : 's'} have been imported and assigned to $resolvedStaffName',
        excludeStaffId: creatorId,
      );
      if (isClosed) return;

      
      // ── Reset form, keep role-level defaults ────────────────────────────
      final defaultStage = state.stages.isEmpty
          ? null
          : state.stages
                .firstWhere(
                  (s) => s.name?.toLowerCase() == 'new',
                  orElse: () => state.stages.first,
                )
                .name;

      // For Staff users, re-pin the staff assignment after reset.
      final postStaffName = state.isAdmin ? '' : resolvedStaffName;
      final postStaffId = state.isAdmin ? '' : resolvedStaffId;
      final postSelected = state.isAdmin ? null : resolvedStaffName;

      emit(
        state.copyWith(
          status: ImportLeadsStatus.success,
          importedCount: count,
          skippedCount: skipped,
          successMessage: skipped > 0
              ? '$count lead${count == 1 ? '' : 's'} imported. '
                    '$skipped duplicate${skipped == 1 ? '' : 's'} skipped.'
              : '$count lead${count == 1 ? '' : 's'} imported successfully.',
          clearError: true,
          clearCsvBytes: true,
          clearCategory: true,
          clearSource: true,
          selectedLeadStage: defaultStage,
          selectedPriority: 'Normal',
          // Admin: clear staff selection so they must re-pick next time.
          // Staff: re-pin their own details.
          selectedStaff: postSelected,
          assignedStaffName: postStaffName,
          assignedStaffId: postStaffId,
          clearState: true,
          clearDistrict: true,
        ),
      );

      log(
        '[ImportLeadsCubit] Import complete: $count imported, $skipped skipped',
      );
    } catch (e, st) {
      log('[ImportLeadsCubit] importLeads error: $e', stackTrace: st);
      emit(
        state.copyWith(
          status: ImportLeadsStatus.failure,
          errorMessage: _friendlyError(e),
          clearSuccess: true,
        ),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _staffIdFromName(String? name) {
    if (name == null || name.isEmpty || state.staffList.isEmpty) return '';
    try {
      return state.staffList
              .firstWhere(
                (s) => s.name == name,
                orElse: () => state.staffList.first,
              )
              .id ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('permission-denied')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('network') || msg.contains('unavailable')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('empty') || msg.contains('no data')) return msg;
    return 'Something went wrong. Please try again.';
  }
}
