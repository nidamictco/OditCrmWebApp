import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/designation_repository.dart';
import '../model/designation_model.dart';

part 'designation_state.dart';

class DesignationCubit extends Cubit<DesignationState> {
  final DesignationRepository _repository;

  DesignationCubit({DesignationRepository? repository})
      : _repository = repository ?? DesignationRepository(),
        super(DesignationInitial());

  // ─── Save (Add) ────────────────────────────────────────────────────────────

  Future<void> saveDesignation(DesignationModel designation) async {
    emit(DesignationSaving());
    try {
      final docId = await _repository.addDesignation(designation);
      if (isClosed) return;
      log('[DesignationCubit] Saved designation: $docId');
      emit(DesignationSaved(docId));
    } catch (e, st) {
      if (isClosed) return;
      log('[DesignationCubit] Save error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> updateDesignation(DesignationModel designation) async {
    emit(DesignationSaving());
    try {
      await _repository.updateDesignation(designation);
      if (isClosed) return;
      log('[DesignationCubit] Updated designation: ${designation.id}');
      emit(DesignationSaved(designation.id!));
    } catch (e, st) {
      if (isClosed) return;
      log('[DesignationCubit] Update error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteDesignation(String id) async {
    try {
      await _repository.deleteDesignation(id);
      if (isClosed) return;
      log('[DesignationCubit] Deleted designation: $id');
      await fetchAll(); // refresh list
    } catch (e, st) {
      if (isClosed) return;
      log('[DesignationCubit] Delete error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Fetch All ─────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    emit(DesignationLoading());
    try {
      final list = await _repository.fetchAll();
      if (isClosed) return;
      print('✅ Designations fetched: ${list.length}'); 
      emit(DesignationListLoaded(list));
    } catch (e, st) {
      if (isClosed) return;
      log('[DesignationCubit] FetchAll error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Reset to initial (e.g. after navigation) ──────────────────────────────

  void reset() {
    if (isClosed) return;
    emit(DesignationInitial());
  }
}