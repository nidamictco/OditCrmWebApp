

import 'package:oxdo/feature/staff_managment/staff/model/note_model.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';


abstract class StaffState {}

// ─── Initial ──────────────────────────────────────────────────────────────────
class StaffInitial extends StaffState {}

// ─── Loading (generic — fetch / delete) ──────────────────────────────────────
class StaffLoading extends StaffState {}

// ─── Saving (add / update — shows spinner on submit button) ──────────────────
class StaffSaving extends StaffState {}

// ─── List loaded ─────────────────────────────────────────────────────────────
class StaffListLoaded extends StaffState {
  final List<StaffModel> staffList;
  StaffListLoaded(this.staffList);
}

// ─── Single staff loaded (for edit pre-fill) ─────────────────────────────────
class StaffLoaded extends StaffState {
  final StaffModel staff;
  StaffLoaded(this.staff);
}

// ─── Successfully saved/updated ───────────────────────────────────────────────
class StaffSaved extends StaffState {
  final String docId;
  final bool isUpdate;
  StaffSaved(this.docId, {this.isUpdate = false});
}

// ─── Successfully deleted ────────────────────────────────────────────────────
class StaffDeleted extends StaffState {
  final String deletedId;
  StaffDeleted(this.deletedId);
}

// ─── Error ───────────────────────────────────────────────────────────────────
class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

class NotesLoading extends StaffState {}

class NotesLoaded extends StaffState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}

// in add_staff_state.dart
class NoteSaved extends StaffState {}