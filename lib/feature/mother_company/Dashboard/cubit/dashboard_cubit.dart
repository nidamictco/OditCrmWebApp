import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/dashboard_models.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final cashFlow = _generateCashFlowData();
      final companies = _generateCompanyData();
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        cashFlowData: cashFlow,
        companies: companies,
        stats: const DashboardStats(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  void changeOverviewFilter(DateFilter filter) {
    emit(state.copyWith(overviewFilter: filter));
  }

  void changeCashFlowFilter(DateFilter filter) {
    emit(state.copyWith(cashFlowFilter: filter));
  }

  void changePayableFilter(DateFilter filter) {
    emit(state.copyWith(payableFilter: filter));
  }

  void selectCashFlowPoint(int index) {
    emit(state.copyWith(selectedCashFlowIndex: index));
  }

  void clearCashFlowSelection() {
    emit(state.copyWith(clearSelectedIndex: true));
  }

  List<CashFlowPoint> _generateCashFlowData() {
    return const [
      CashFlowPoint(month: 'Jan', receipt: 120, payment: 80),
      CashFlowPoint(month: 'Feb', receipt: 200, payment: 150),
      CashFlowPoint(month: 'Mar', receipt: 180, payment: 200),
      CashFlowPoint(month: 'Apr', receipt: 220, payment: 170),
      CashFlowPoint(month: 'May', receipt: 260, payment: 190),
      CashFlowPoint(month: 'Jun', receipt: 240, payment: 210),
      CashFlowPoint(month: 'Jul', receipt: 300, payment: 220, label: '29 July 00:00'),
      CashFlowPoint(month: 'Aug', receipt: 350, payment: 240),
      CashFlowPoint(month: 'Sep', receipt: 420, payment: 280),
      CashFlowPoint(month: 'Oct', receipt: 500, payment: 320),
      CashFlowPoint(month: 'Nov', receipt: 650, payment: 380),
      CashFlowPoint(month: 'Dec', receipt: 900, payment: 420),
    ];
  }

  List<CompanyActivity> _generateCompanyData() {
    return [
      CompanyActivity(
        sl: 1,
        companyName: 'Oxdo Technologies PVT LTD',
        adminName: 'Isamil CT',
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate:  DateTime(2023, 12, 31),
        planType: PlanType.enterprise,
        status: CompanyStatus.active,
      ),
       CompanyActivity(
        sl: 2,
        companyName: 'Maharajika Gold',
        adminName: 'Hameed',
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate:  DateTime(2023, 12, 31),
        planType: PlanType.standard,
        status: CompanyStatus.pending,
      ),
       CompanyActivity(
        sl: 3,
        companyName: 'Codignus Technologies',
        adminName: 'Shafeeque',
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate:  DateTime(2023, 12, 31),
        planType: PlanType.basic,
        status: CompanyStatus.active,
      ),
       CompanyActivity(
        sl: 4,
        companyName: 'Crypsty Cafe',
        adminName: 'Abhiram',
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate:  DateTime(2023, 12, 31),
        planType: PlanType.enterprise,
        status: CompanyStatus.suspended,
      ),
       CompanyActivity(
        sl: 5,
        companyName: 'Mictco IT Solutions',
        adminName: 'Isamil CT',
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate:  DateTime(2023, 12, 31),
        planType: PlanType.enterprise,
        status: CompanyStatus.active,
      ),
    ];
  }
}
