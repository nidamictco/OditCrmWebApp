import '../cubit/add_company_state.dart';
import '../services/firebase_add_company_service.dart';

class FirebaseAddCompanyRepository {
  final FirebaseAddCompanyService service;

  FirebaseAddCompanyRepository({
    required this.service,
  });

  Future<void> createCompany(
      AddCompanyState state,
      ) async {
    await service.createCompany(
      state,
    );
  }
}