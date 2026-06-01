import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/lead_managment/import_leads/cubit/import_lead_state.dart';
import 'package:oxdo/feature/lead_managment/import_leads/data/import_lead_repo.dart';
import 'package:oxdo/feature/lead_managment/import_leads/model/import_leads_model.dart';
import 'package:oxdo/feature/notification/data/notification_repo.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/settings/general_settings/data/general_settings_repo.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';

class ImportLeadsCubit extends Cubit<ImportLeadsState> {
  final IImportLeadsRepository _repository;
  final NotificationRepo _notificationRepo;

  ImportLeadsCubit({
    IImportLeadsRepository? repository,
    NotificationRepo? notificationRepo,
  }) : _repository = repository ?? ImportLeadsRepository(),
       _notificationRepo = notificationRepo ?? NotificationRepo(),
       super(const ImportLeadsState());

  // ── Initialization ────────────────────────────────────────────────────────

  /// Call once from initState — loads all dropdown data in parallel.
  Future<void> initialize() async {
    if (state.status == ImportLeadsStatus.ready ||
        state.status == ImportLeadsStatus.success)
      return;
    emit(state.copyWith(status: ImportLeadsStatus.loading, clearError: true));

    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchSources(),
        _repository.fetchStaff(),
        _repository.fetchLeadStages(),
      ]);
      log("categories length: ${results[0].length}");
      log("sources length: ${results[1].length}");
      log("staff length: ${results[2].length}");
      log("stages length: ${results[3].length}");

      final fetchedStages = results[3] as List<LeadsModel>;

      final defaultStage = fetchedStages
          .firstWhere(
            (s) => s.name?.toLowerCase() == 'new',
            orElse: () => fetchedStages.first,
          )
          .name;
      emit(
        state.copyWith(
          status: ImportLeadsStatus.ready,
          categories: results[0] as List<LeadsModel>,
          sources: results[1] as List<LeadsModel>,
          staffList: results[2] as List<StaffModel>,
         stages:            fetchedStages,
  selectedLeadStage: state.selectedLeadStage ?? defaultStage,
        ),
      );

      log(
        '[ImportLeadsCubit] Initialized — '
        'categories: ${state.categories.length}, '
        'sources: ${state.sources.length}, '
        'staff: ${state.staffList.length}'
        'stages ${state.stages.length}',
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

  // ── Form selection helpers ────────────────────────────────────────────────

  void selectTab(int tab) => emit(state.copyWith(selectedTab: tab));

  void selectCategory(String? value) =>
      emit(state.copyWith(selectedCategory: value));

  void selectSource(String? value) =>
      emit(state.copyWith(selectedSource: value));

  void selectLeadStage(String? value) =>
      emit(state.copyWith(selectedLeadStage: value));

  void selectPriority(String? value) =>
      emit(state.copyWith(selectedPriority: value));

  void selectStaff(String? value) => emit(state.copyWith(selectedStaff: value));

  void selectState(String? value) => emit(
    state.copyWith(
      selectedState: value,
      clearDistrict: true, // reset district when state changes
    ),
  );

  void selectDistrict(String? value) =>
      emit(state.copyWith(selectedDistrict: value));

  void setDialCode(String code) => emit(state.copyWith(dialCode: code));

  void setCsvBytes(Uint8List? bytes) => emit(state.copyWith(csvBytes: bytes));

  /// Update a single field-position entry, e.g. updateFieldPosition('phone', 2)
  void updateFieldPosition(String fieldName, int position) {
    final updated = Map<String, int>.from(state.fieldPositions);
    updated[fieldName] = position;
    emit(state.copyWith(fieldPositions: updated));
  }

  // ── Add category / source (inline quick-add) ──────────────────────────────

  /// Refreshes categories after a new one is added externally.
  Future<void> refreshCategories() async {
    try {
      final cats = await _repository.fetchCategories();
      emit(state.copyWith(categories: cats));
    } catch (e) {
      log('[ImportLeadsCubit] refreshCategories error: $e');
    }
  }

  /// Refreshes sources after a new one is added externally.
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

  // ── CSV Import ────────────────────────────────────────────────────────────

  Future<void> importLeads({required Uint8List csvBytes}) async {
    emit(
      state.copyWith(
        status: ImportLeadsStatus.importing,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final user = await SessionService().getSavedUser();

      // Build the default values that will fill non-CSV columns
      final defaults = ImportLeadModel(
        contactDialCode: state.selectedTab == 0 ? state.dialCode : '',
        whatsappDialCode: state.selectedTab == 0 ? state.dialCode : '',
        assignedStaff: state.selectedStaff ?? '',
        assignedStaffId: _staffIdFromName(state.selectedStaff),
        leadCategory: state.selectedCategory ?? '',
        leadSource: state.selectedSource ?? '',
        priority: state.selectedPriority ?? '',
        leadStage: state.selectedLeadStage ?? '',
        createdBy: user?.name ?? '',
        createdById: user?.id ?? '',
      );

      // final count = await _repository.importFromCsv(
      //   csvBytes: csvBytes,
      //   fieldPositions: state.fieldPositions,
      //   defaults: defaults,
      //   hasCountryCode: state.selectedTab == 0,
      // );
      // if (isClosed) return;
      final result = await _repository.importFromCsv(
  csvBytes: csvBytes,
  fieldPositions: state.fieldPositions,
  defaults: defaults,
  hasCountryCode: state.selectedTab == 0,
);
if (isClosed) return;

final count   = result['imported']!;
final skipped = result['skipped']!;

      //       // ── Notify assigned staff ──────────────────────────────────────────────
     
final assignedStaffId = _staffIdFromName(state.selectedStaff);
if (assignedStaffId.isNotEmpty) {
  await _notificationRepo.create(
    staffId: assignedStaffId,
    title: 'Leads Imported',
    message: '$count lead${count == 1 ? '' : 's'} have been imported and assigned to ${state.selectedStaff}',
  );
  if (isClosed) return;
}

// ── Always notify admin/creator ───────────────────────────────────────────
final creatorId = user?.id ?? '';
if (creatorId.isNotEmpty && creatorId != assignedStaffId) {
  await _notificationRepo.create(
    staffId: creatorId,
    title: 'Import Complete',
    message: '$count lead${count == 1 ? '' : 's'} imported successfully'
        '${state.selectedStaff != null ? ' and assigned to ${state.selectedStaff}' : ''}',
  );
  if (isClosed) return;
}

     final defaultStage = state.stages
    .firstWhere(
      (s) => s.name?.toLowerCase() == 'new',
      orElse: () => state.stages.first,
    )
    .name;

      emit(
  state.copyWith(
    status: ImportLeadsStatus.success,
    importedCount: count,
    skippedCount: skipped,   // ✅ make sure this is added to state too
    successMessage: skipped > 0
        ? '$count lead${count == 1 ? '' : 's'} imported. '
          '$skipped duplicate${skipped == 1 ? '' : 's'} skipped.'
        : '$count lead${count == 1 ? '' : 's'} imported successfully.',
    clearError: true,
    clearCsvBytes: true,
    clearCategory: true,
    clearSource: true,
    selectedLeadStage: defaultStage,
    clearPriority: true,
    clearStaff: true,
    clearState: true,
    clearDistrict: true,
  ),
);

      log('[ImportLeadsCubit] Import complete: $count records');
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

  /// Look up the staff ID for a given name from the loaded staff list.
  String _staffIdFromName(String? name) {
    if (name == null || name.isEmpty) return '';
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
    if (msg.contains('empty')) return msg;
    if (msg.contains('no data')) return msg;
    return 'Something went wrong. Please try again.';
  }

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
}
