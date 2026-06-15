import '../cubit/add_new_company_state.dart';
import '../services/firebase_add_new_company_service.dart';

class AddNewCompanyRepository {
  final FirebaseAddNewCompanyService service;

  AddNewCompanyRepository({required this.service});

  Future<void> createCompany(AddNewCompanyState state) async {
    await service.createCompany(state);
  }
}
