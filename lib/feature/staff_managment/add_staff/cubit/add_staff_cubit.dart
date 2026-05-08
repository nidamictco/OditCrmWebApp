import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/staff_managment/add_staff/data/add_staff_repo.dart';
import 'package:oxdo/feature/staff_managment/add_staff/model/staff_model.dart';

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository _repository;
 
  StaffCubit({StaffRepository? repository})
      : _repository = repository ?? StaffRepository(),
        super(StaffInitial());

  // ─── Add ──────────────────────────────────────────────────────────────────

  Future<void> addStaff(
    StaffModel staff, {
    File? imageFile,
    File? documentFile,
  }) async {
    emit(StaffSaving());
    try {
      final docId = await _repository.addStaff(
        staff,
        imageFile: imageFile,
        documentFile: documentFile,
      );
      log('[StaffCubit] Staff added: $docId');
      emit(StaffSaved(docId));
    } catch (e, st) {
      log('[StaffCubit] Add error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  Future<void> updateStaff(
    StaffModel staff, {
    File? imageFile,
    File? documentFile,
  }) async {
    emit(StaffSaving());
    try {
      await _repository.updateStaff(
        staff,
        imageFile: imageFile,
        documentFile: documentFile,
      );
      log('[StaffCubit] Staff updated: ${staff.id}');
      emit(StaffSaved(staff.id!, isUpdate: true));
    } catch (e, st) {
      log('[StaffCubit] Update error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

 Future<void> deleteStaff(String id, StaffModel staff) async {
  emit(StaffLoading());
  try {
    await _repository.moveToDeleted(staff); // ✅ single atomic operation
    log('[StaffCubit] Staff moved to deleted: $id');
    emit(StaffDeleted(id));
    await fetchAll();
  } catch (e, st) {
    log('[StaffCubit] Delete error: $e', stackTrace: st);
    emit(StaffError(e.toString()));
  }
}



  // ─── Fetch single ─────────────────────────────────────────────────────────

  Future<void> getStaff(String id) async {
    emit(StaffLoading());
    try {
      final staff = await _repository.getStaff(id);
      if (staff != null) {
        emit(StaffLoaded(staff));
      } else {
        emit(StaffError('Staff member not found'));
      }
    } catch (e, st) {
      log('[StaffCubit] GetStaff error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Fetch all ────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    emit(StaffLoading());
    try {
      final list = await _repository.fetchAll();
      emit(StaffListLoaded(list));
    } catch (e, st) {
      log('[StaffCubit] FetchAll error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }



///---------deleted staff-----------
///-------------------------------------
  Future<void> restoreStaff(
    StaffModel staff, { 
    File? imageFile,
    File? documentFile,
  }) async {
    emit(StaffSaving());
    try {
      final docId = await _repository.restoreStaff(
        staff, 
        imageFile: imageFile,
        documentFile: documentFile,
      );
      log('[StaffCubit] Staff added: $docId');
      emit(StaffSaved(docId));
      await fetchDeletedStaff();
    } catch (e, st) {
      log('[StaffCubit] Add error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

 Future<void> fetchDeletedStaff() async {
    emit(StaffLoading());
    try {
      final list = await _repository.fetchDeletedStaff();
      emit(StaffListLoaded(list));
    } catch (e, st) {
      log('[StaffCubit] FetchAll error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

 Future<void> deleteStaffPermanently(String id) async {
    emit(StaffLoading());
    try {
      await _repository.deleteStaffPermanently(id);
      log('[StaffCubit] Staff deleted permanently: $id');
      emit(StaffDeleted(id));
      await fetchDeletedStaff();
    } catch (e, st) {
      log('[StaffCubit] Delete error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }


  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() => emit(StaffInitial());
}