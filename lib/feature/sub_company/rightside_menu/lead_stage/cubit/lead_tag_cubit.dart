import 'dart:async';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_tag_state.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/data/lead_tag_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/data/sub_category_repository.dart';


class LeadTagCubit extends Cubit<LeadTagState> {
  final ILeadTagRepository _repository;
  StreamSubscription? _subCategoriesSubscription;

  LeadTagCubit({
    required String leadStageId,
    ILeadTagRepository? repository,
  })  : _repository = repository ?? LeadTagRepository(tagId: leadStageId),
        super(const LeadTagState());

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Start listening to Firestore in real time.
  void watchLeadTags() {
    emit(state.copyWith(status: LeadTagStatus.loading));

    _subCategoriesSubscription?.cancel();
    _subCategoriesSubscription = _repository.watchLeadTags().listen(
      (subCategories) {
        emit(
          state.copyWith(
            status: LeadTagStatus.success,
            leadTags: [...subCategories],
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: LeadTagStatus.failure,
            errorMessage: _friendlyError(error),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subCategoriesSubscription?.cancel();
    return super.close();
  }

  // ─── Write Operations ─────────────────────────────────────────────────────

  /// Add a new sub category.
  Future<void> addLeadTag({
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.addLeadTag(name: name);
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  /// Update the name of an existing sub category.
  Future<void> updateLeadTag({
    required String id,
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.updateLeadTag(id: id, name: name);
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  /// Delete a sub category by its Firestore document ID.
  Future<void> deleteLeadTag({required String id}) async {
    if (state.deletingId != null) return;
    emit(state.copyWith(deletingId: id, clearError: true));

    try {
      await _repository.deleteLeadTag(id: id);
      emit(state.copyWith(clearDeletingId: true));
    } catch (e) {
      emit(
        state.copyWith(
          clearDeletingId: true,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('permission-denied')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('network') || msg.contains('unavailable')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('not-found')) {
      return 'Record not found. It may have been deleted already.';
    }
    return 'Something went wrong. Please try again.';
  }
}
