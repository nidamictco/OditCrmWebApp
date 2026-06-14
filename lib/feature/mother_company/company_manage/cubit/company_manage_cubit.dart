import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_manage_models.dart';

part 'company_manage_state.dart';

class CompanyManageCubit extends Cubit<CompanyManageState> {
  final FirebaseFirestore firestore;

  CompanyManageCubit({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance,
      super(const CompanyManageState());

  // ─── Load ────────────────────────────────────────────────────────────────────

  Future<void> loadCompanies() async {
    emit(state.copyWith(status: CompanyManageStatus.loading));
    try {
      final snapshot = await firestore
          .collection('COMPANY')
          .orderBy('createdAt', descending: true)
          .get();

      final List<CompanyActivity> companies = [];
      int sl = 1;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final companyId = doc.id;
        final companyName = data['companyName'] as String? ?? '';
        final adminName = data['adminName'] as String? ?? '';
        final domain = data['domain'] as String? ?? '';
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
          ),
        );
      }

      emit(
        state.copyWith(
          status: CompanyManageStatus.loaded,
          allCompanies: companies,
          filteredCompanies: companies,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CompanyManageStatus.error, error: e.toString()),
      );
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

  // ─── Filters ─────────────────────────────────────────────────────────────────

  void changeDateFilter(DateFilter filter) {
    emit(state.copyWith(dateFilter: filter, currentPage: 1));
    _applyFilters();
  }

  void onSearch(String query) {
    emit(state.copyWith(searchQuery: query, currentPage: 1));
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<CompanyActivity>.from(state.allCompanies);

    // Search
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) {
        return c.companyName.toLowerCase().contains(q) ||
            c.adminName.toLowerCase().contains(q) ||
            c.planType.label.toLowerCase().contains(q) ||
            c.status.label.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    list = _sortList(list, state.sortField, state.sortOrder);

    emit(state.copyWith(filteredCompanies: list, currentPage: 1));
  }

  // ─── Sort ─────────────────────────────────────────────────────────────────────

  void onSort(SortField field) {
    final newOrder =
        (state.sortField == field && state.sortOrder == SortOrder.asc)
        ? SortOrder.desc
        : SortOrder.asc;

    final sorted = _sortList(
      List<CompanyActivity>.from(state.filteredCompanies),
      field,
      newOrder,
    );

    emit(
      state.copyWith(
        sortField: field,
        sortOrder: newOrder,
        filteredCompanies: sorted,
        currentPage: 1,
      ),
    );
  }

  List<CompanyActivity> _sortList(
    List<CompanyActivity> list,
    SortField field,
    SortOrder order,
  ) {
    list.sort((a, b) {
      int cmp;
      switch (field) {
        case SortField.sl:
          cmp = a.sl.compareTo(b.sl);
          break;
        case SortField.companyName:
          cmp = a.companyName.compareTo(b.companyName);
          break;
        case SortField.adminName:
          cmp = a.adminName.compareTo(b.adminName);
          break;
        case SortField.planType:
          cmp = a.planType.index.compareTo(b.planType.index);
          break;
        case SortField.status:
          cmp = a.status.index.compareTo(b.status.index);
          break;
      }
      return order == SortOrder.asc ? cmp : -cmp;
    });
    return list;
  }

  // ─── Pagination ───────────────────────────────────────────────────────────────

  void goToPage(int page) {
    if (page < 1 || page > state.totalPages) return;
    emit(state.copyWith(currentPage: page));
  }

  void nextPage() => goToPage(state.currentPage + 1);
  void prevPage() => goToPage(state.currentPage - 1);

  void changeRowsPerPage(int rows) {
    emit(state.copyWith(rowsPerPage: rows, currentPage: 1));
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  Future<void> suspendCompany(String companyId) async {
    try {
      emit(state.copyWith(status: CompanyManageStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).update({
        'status': 'SUSPENDED',
      });
      await loadCompanies();
    } catch (e) {
      emit(
        state.copyWith(status: CompanyManageStatus.error, error: e.toString()),
      );
    }
  }

  Future<void> activateCompany(String companyId) async {
    try {
      emit(state.copyWith(status: CompanyManageStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).update({
        'status': 'ACTIVE',
      });
      await loadCompanies();
    } catch (e) {
      emit(
        state.copyWith(status: CompanyManageStatus.error, error: e.toString()),
      );
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      emit(state.copyWith(status: CompanyManageStatus.loading));
      await firestore.collection('COMPANY').doc(companyId).delete();
      await loadCompanies();
    } catch (e) {
      emit(
        state.copyWith(status: CompanyManageStatus.error, error: e.toString()),
      );
    }
  }

  Future<void> updateCompany({
    required String companyId,
    required String companyName,
    required String domain,
    required String industry,
    required String adminName,
    required String adminEmail,
    required String adminMobile,
    required PlanType planType,
    required bool yearlyBilling,
  }) async {
    try {
      emit(state.copyWith(status: CompanyManageStatus.loading));

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
        'industry': industry,
        'adminName': adminName,
        'adminEmail': adminEmail,
        'adminMobile': adminMobile,
        'subscriptionPlan': planName,
        'yearlyBilling': yearlyBilling,
        'subscriptionEndDate': Timestamp.fromDate(endDate),
      });

      await loadCompanies();
    } catch (e) {
      emit(
        state.copyWith(status: CompanyManageStatus.error, error: e.toString()),
      );
    }
  }
}
