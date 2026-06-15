
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/data/activity_repo.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_state.dart';

class StaffActivityCubit extends Cubit<StaffActivityState> {
  final ActivityRepository _repo;
  StaffActivityCubit(this._repo) : super(StaffActivityInitial());

  Future<void> load(String staffId) async {
  emit(StaffActivityLoading());
  try {
    final items = await _repo.getActivitiesByStaff(staffId);
    // Add this temporarily
    print('StaffActivityCubit: staffId=$staffId, found=${items.length}');
    emit(StaffActivityLoaded(items));
  } catch (e) {
    // This is probably swallowing your error silently
    print('StaffActivityCubit ERROR: $e');
    emit(StaffActivityError(e.toString()));
  }
}
}