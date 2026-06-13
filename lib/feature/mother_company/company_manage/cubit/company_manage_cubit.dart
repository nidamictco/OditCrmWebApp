import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/company_manage_models.dart';

part 'company_manage_state.dart';

class CompanyManageCubit extends Cubit<CompanyManageState> {
  CompanyManageCubit() : super(const CompanyManageState());

  // ─── Load ────────────────────────────────────────────────────────────────────

  Future<void> loadCompanies() async {
    emit(state.copyWith(status: CompanyManageStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final companies = _mockCompanies();
      emit(state.copyWith(
        status: CompanyManageStatus.loaded,
        allCompanies: companies,
        filteredCompanies: companies,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyManageStatus.error,
        error: e.toString(),
      ));
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
    final newOrder = (state.sortField == field && state.sortOrder == SortOrder.asc)
        ? SortOrder.desc
        : SortOrder.asc;

    final sorted = _sortList(
      List<CompanyActivity>.from(state.filteredCompanies),
      field,
      newOrder,
    );

    emit(state.copyWith(
      sortField: field,
      sortOrder: newOrder,
      filteredCompanies: sorted,
      currentPage: 1,
    ));
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

  void suspendCompany(int sl) {
    final updated = state.allCompanies.map((c) {
      if (c.sl == sl) {
        return CompanyActivity(
          sl: c.sl,
          companyName: c.companyName,
          adminName: c.adminName,
          subscriptionStartDate: c.subscriptionStartDate,
          subscriptionEndDate: c.subscriptionEndDate,
          planType: c.planType,
          status: CompanyStatus.suspended,
        );
      }
      return c;
    }).toList();
    emit(state.copyWith(allCompanies: updated));
    _applyFilters();
  }

  void activateCompany(int sl) {
    final updated = state.allCompanies.map((c) {
      if (c.sl == sl) {
        return CompanyActivity(
          sl: c.sl,
          companyName: c.companyName,
          adminName: c.adminName,
          subscriptionStartDate: c.subscriptionStartDate,
          subscriptionEndDate: c.subscriptionEndDate,
          planType: c.planType,
          status: CompanyStatus.active,
        );
      }
      return c;
    }).toList();
    emit(state.copyWith(allCompanies: updated));
    _applyFilters();
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────────

  List<CompanyActivity> _mockCompanies() {
    final names = [
      ('Oxdo Technologies PVT LTD', 'Isamil CT', PlanType.enterprise, CompanyStatus.active),
      ('Maharajika Gold', 'Hameed', PlanType.standard, CompanyStatus.pending),
      ('Codignus Technologies', 'Shafeeque', PlanType.basic, CompanyStatus.active),
      ('Crypsty Cafe', 'Abhiram', PlanType.enterprise, CompanyStatus.suspended),
      ('Mictco IT Solutions', 'Isamil CT', PlanType.enterprise, CompanyStatus.active),
      ('Oxdo Technologies PVT LTD', 'Isamil CT', PlanType.enterprise, CompanyStatus.active),
      ('Maharajika Gold', 'Hameed', PlanType.standard, CompanyStatus.pending),
      ('Codignus Technologies', 'Shafeeque', PlanType.basic, CompanyStatus.active),
      ('Crypsty Cafe', 'Abhiram', PlanType.enterprise, CompanyStatus.suspended),
      ('Mictco IT Solutions', 'Isamil CT', PlanType.enterprise, CompanyStatus.active),
    ];

    return names.asMap().entries.map((e) {
      final i = e.key;
      final data = e.value;
      return CompanyActivity(
        sl: i + 1,
        companyName: data.$1,
        adminName: data.$2,
        subscriptionStartDate: DateTime(2023, 1, 1),
        subscriptionEndDate: DateTime(2023, 12, 31),
        planType: data.$3,
        status: data.$4,
      );
    }).toList();
  }
}
