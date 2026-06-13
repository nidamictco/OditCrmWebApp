import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oxdo/feature/lead_managment/follow_up/data/activity_repo.dart';
import 'package:oxdo/feature/lead_managment/follow_up/models/follow_up_activities_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

abstract class StaffActivityState extends Equatable {
  const StaffActivityState();
  @override List<Object?> get props => [];
}

class StaffActivityInitial  extends StaffActivityState {}
class StaffActivityLoading  extends StaffActivityState {}

class StaffActivityLoaded extends StaffActivityState {
  final List<ActivityModel> activities;
  const StaffActivityLoaded(this.activities);
  @override List<Object?> get props => [activities];
}

class StaffActivityError extends StaffActivityState {
  final String message;
  const StaffActivityError(this.message);
  @override List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────
