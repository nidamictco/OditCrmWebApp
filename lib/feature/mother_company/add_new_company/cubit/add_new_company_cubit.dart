import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/add_new_company_repo.dart';
import 'add_new_company_state.dart';

class AddNewCompanyCubit extends Cubit<AddNewCompanyState> {
  final AddNewCompanyRepository repository;

  AddNewCompanyCubit({required this.repository})
      : super(AddNewCompanyState(
          companyId: 'comp-${DateTime.now().millisecondsSinceEpoch}',
          registrationDate: DateTime.now(),
        ));

  void updateCompanyName(String value) {
    emit(state.copyWith(companyName: value));
  }

  void updateAdminName(String value) {
    emit(state.copyWith(adminName: value));
  }

  void updateEmail(String value) {
    emit(state.copyWith(adminEmail: value));
  }

  void updatePhone(String value) {
    emit(state.copyWith(phone: value));
  }

  void updatePlanType(String value) {
    emit(state.copyWith(planType: value));
  }

  void updateStatus(String value) {
    emit(state.copyWith(status: value));
  }

  void updateRegistrationDate(DateTime value) {
    emit(state.copyWith(registrationDate: value));
  }

  void updateLocation(String value) {
    emit(state.copyWith(location: value));
  }

  Future<void> submitCompany() async {
    emit(state.copyWith(formStatus: AddNewCompanyStatus.submitting));
    try {
      await repository.createCompany(state);
      emit(state.copyWith(formStatus: AddNewCompanyStatus.success));
    } catch (e) {
      emit(state.copyWith(
        formStatus: AddNewCompanyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(AddNewCompanyState(
      companyId: 'comp-${DateTime.now().millisecondsSinceEpoch}',
      registrationDate: DateTime.now(),
    ));
  }
}
