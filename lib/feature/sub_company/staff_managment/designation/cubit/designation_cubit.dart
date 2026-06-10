import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/data/designation_repository.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/model/designation_model.dart';

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
      log('[DesignationCubit] Saved designation: $docId');
      emit(DesignationSaved(docId));
    } catch (e, st) {
      log('[DesignationCubit] Save error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> updateDesignation(DesignationModel designation) async {
    emit(DesignationSaving());
    try {
      await _repository.updateDesignation(designation);
      log('[DesignationCubit] Updated designation: ${designation.id}');
      emit(DesignationSaved(designation.id!));
    } catch (e, st) {
      log('[DesignationCubit] Update error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteDesignation(String id) async {
    try {
      await _repository.deleteDesignation(id);
      log('[DesignationCubit] Deleted designation: $id');
      await fetchAll(); // refresh list
    } catch (e, st) {
      log('[DesignationCubit] Delete error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Fetch All ─────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    emit(DesignationLoading());
    try {
      final list = await _repository.fetchAll();
      print('✅ Designations fetched: ${list.length}'); 
      emit(DesignationListLoaded(list));
    } catch (e, st) {
      log('[DesignationCubit] FetchAll error: $e', stackTrace: st);
      emit(DesignationError(e.toString()));
    }
  }

  // ─── Reset to initial (e.g. after navigation) ──────────────────────────────

  void reset() => emit(DesignationInitial());
}