import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../company_manage/models/company_manage_models.dart';
import '../models/dashboard_models.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FirebaseFirestore firestore;

  DashboardCubit({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance,
      super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final snapshot = await firestore
          .collection('COMPANY')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final List<CompanyActivity> companies = [];
      int sl = 1;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final companyId = doc.id;
        final companyName = data['companyName'] as String? ?? '';
        final adminId = data['adminId'] as String? ?? '';
        final adminName = data['adminName'] as String? ?? '';
        final domain = data['domain'] as String? ?? '';
        final location = data['location'] as String? ?? '';
        final industry = data['industry'] as String? ?? '';
        final adminEmail = data['adminEmail'] as String? ?? '';
        final adminMobile = data['adminMobile'] as String? ?? '';
        final yearlyBilling = data['yearlyBilling'] as bool? ?? false;

        final startTimestamp = data['subscriptionStartDate'] as Timestamp?;
        final endTimestamp = data['subscriptionEndDate'] as Timestamp?;

        final subscriptionStartDate =
            startTimestamp?.toDate() ?? DateTime.now();
        final subscriptionEndDate = endTimestamp?.toDate() ?? DateTime.now();

        final planStr = data['subscriptionPlan'] as String? ?? '';
        final planType = _mapPlanType(planStr);

        final statusStr = data['status'] as String? ?? 'PENDING';
        final status = _mapCompanyStatus(statusStr);

        companies.add(
          CompanyActivity(
            sl: sl++,
            companyId: companyId,
            companyName: companyName,
            adminId: adminId,
            adminName: adminName,
            subscriptionStartDate: subscriptionStartDate,
            subscriptionEndDate: subscriptionEndDate,
            planType: planType,
            status: status,
            domain: domain,
            industry: industry,
            adminEmail: adminEmail,
            adminMobile: adminMobile,
            yearlyBilling: yearlyBilling,
            location: location,
          ),
        );
      }

      final totalSnapshot = await firestore.collection('COMPANY').get();
      final totalCompanies = totalSnapshot.docs.length;

      final activeCompanies = totalSnapshot.docs.where((doc) {
        final data = doc.data();
        final statusStr = data['status'] as String? ?? 'PENDING';
        return statusStr.toUpperCase() == 'ACTIVE';
      }).length;

      final pendingCompanies = totalSnapshot.docs.where((doc) {
        final data = doc.data();
        final statusStr = data['status'] as String? ?? 'PENDING';
        return statusStr.toUpperCase() == 'PENDING';
      }).length;

      final suspendedCompanies = totalSnapshot.docs.where((doc) {
        final data = doc.data();
        final statusStr = data['status'] as String? ?? 'PENDING';
        return statusStr.toUpperCase() == 'SUSPENDED';
      }).length;

      final cashFlow = _generateCashFlowData();

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          cashFlowData: cashFlow,
          companies: companies,
          stats: DashboardStats(
            totalCompanies: totalCompanies,
            activeCompanies: activeCompanies,
            pendingCompanies: pendingCompanies,
            suspendedCompanies: suspendedCompanies,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, error: e.toString()));
    }
  }

  PlanType _mapPlanType(String planStr) {
    switch (planStr.toLowerCase()) {
      case 'enterprise':
        return PlanType.enterprise;
      case 'professional':
      case 'standard':
        return PlanType.standard;
      case 'basic':
      default:
        return PlanType.basic;
    }
  }

  CompanyStatus _mapCompanyStatus(String statusStr) {
    switch (statusStr.toUpperCase()) {
      case 'ACTIVE':
        return CompanyStatus.active;
      case 'SUSPENDED':
        return CompanyStatus.suspended;
      case 'PENDING':
      default:
        return CompanyStatus.pending;
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
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

  Future<void> suspendCompany(String companyId) async {
    try {
      emit(state.copyWith(status: DashboardStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).update({
        'status': 'SUSPENDED',
      });
      await loadDashboard();
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, error: e.toString()));
    }
  }

  Future<void> activateCompany(String companyId) async {
    try {
      emit(state.copyWith(status: DashboardStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).update({
        'status': 'ACTIVE',
      });
      await loadDashboard();
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      emit(state.copyWith(status: DashboardStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).delete();
      await firestore
          .collection('USERS')
          .where('companyId', isEqualTo: companyId)
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
      await loadDashboard();
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, error: e.toString()));
    }
  }

  Future<void> updateCompany({
    required String companyId,
    required String companyName,
    required String domain,
    required String location,
    required String industry,
    required String adminId,
    required String adminName,
    required String adminEmail,
    required String adminMobile,
    required PlanType planType,
    required bool yearlyBilling,
  }) async {
    try {
      emit(state.copyWith(status: DashboardStatus.loading));

      final now = DateTime.now();
      final endDate = yearlyBilling
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year, now.month + 1, now.day);

      String planName = 'basic';
      final name = planType is String ? planType : planType.name.toString();
      if (name == 'enterprise') {
        planName = 'enterprise';
      } else if (name == 'standard') {
        planName = 'professional';
      }

      await firestore.collection('COMPANY').doc(companyId).update({
        'companyName': companyName,
        'domain': domain,
        'location': location,
        'industry': industry,
        'adminId': adminId,
        'adminName': adminName,
        'adminEmail': adminEmail,
        'adminMobile': adminMobile,
        'subscriptionPlan': planName,
        'yearlyBilling': yearlyBilling,
        'subscriptionEndDate': Timestamp.fromDate(endDate),
      });

      await firestore.collection('USERS').doc(adminId).update({
        'name': adminName,
        'email': adminEmail,
        'phone': adminMobile,
      });

      await loadDashboard();
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, error: e.toString()));
    }
  }

  List<CashFlowPoint> _generateCashFlowData() {
    return const [
      CashFlowPoint(month: 'Jan', receipt: 120, payment: 80),
      CashFlowPoint(month: 'Feb', receipt: 200, payment: 150),
      CashFlowPoint(month: 'Mar', receipt: 180, payment: 200),
      CashFlowPoint(month: 'Apr', receipt: 220, payment: 170),
      CashFlowPoint(month: 'May', receipt: 260, payment: 190),
      CashFlowPoint(month: 'Jun', receipt: 240, payment: 210),
      CashFlowPoint(
        month: 'Jul',
        receipt: 300,
        payment: 220,
        label: '29 July 00:00',
      ),
      CashFlowPoint(month: 'Aug', receipt: 350, payment: 240),
      CashFlowPoint(month: 'Sep', receipt: 420, payment: 280),
      CashFlowPoint(month: 'Oct', receipt: 500, payment: 320),
      CashFlowPoint(month: 'Nov', receipt: 650, payment: 380),
      CashFlowPoint(month: 'Dec', receipt: 900, payment: 420),
    ];
  }
}
