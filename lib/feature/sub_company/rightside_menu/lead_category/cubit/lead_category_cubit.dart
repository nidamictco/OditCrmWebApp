// lib/features/lead_category/presentation/cubit/lead_category_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/data/lead_category_repository.dart';
import 'lead_category_state.dart';

class LeadCategoryCubit extends Cubit<LeadCategoryState> {
  final ILeadCategoryRepository _repository;
  StreamSubscription? _categoriesSubscription;

  LeadCategoryCubit({ILeadCategoryRepository? repository})
      : _repository = repository ?? LeadCategoryRepository(), 
        super(const LeadCategoryState());

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Start listening to Firestore in real time.
  void watchCategories() {
    emit(state.copyWith(status: LeadCategoryStatus.loading));

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _repository.watchCategories().listen(
      (categories) {
        emit(
          state.copyWith(
            status: LeadCategoryStatus.success,
            categories: [...categories],
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: LeadCategoryStatus.failure,
            errorMessage: _friendlyError(error),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }

  // ─── Write Operations ─────────────────────────────────────────────────────

  /// Add a new category.
  // Future<void> addCategory({
  //   required String name,
  // }) async {
  //   if (state.isSubmitting) return;
  //   emit(state.copyWith(isSubmitting: true, clearError: true));

  //   try {
  //     await _repository.addCategory(name: name, );
  //     emit(state.copyWith(isSubmitting: false));
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         isSubmitting: false,
  //         errorMessage: _friendlyError(e),
  //       ),
  //     );
  //   }
  // }
  Future<String> addCategory({required String name}) async {
  if (state.isSubmitting) return '';
  emit(state.copyWith(isSubmitting: true, clearError: true));

  try {
    final id = await _repository.addCategory(name: name);
    emit(state.copyWith(isSubmitting: false));
    return id;   // ← return the id up to the caller
  } catch (e) {
    emit(
      state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(e),
      ),
    );
    rethrow;   // let the dialog's try/catch handle showing an error
  }
}

bool categoryExists(String name, {String? excludingId}) {
  final normalized = name.trim().toUpperCase();
  return state.categories.any(
    (c) => c.name.trim().toUpperCase() == normalized && c.id != excludingId,
  );
}

  /// Update the name of an existing category.
  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.updateCategory(id: id, name: name);
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

  /// Delete a category by its Firestore document ID.
  Future<void> deleteCategory({required String id}) async {
    if (state.deletingId != null) return;
    emit(state.copyWith(deletingId: id, clearError: true));

    try {
      await _repository.deleteCategory(id: id);
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