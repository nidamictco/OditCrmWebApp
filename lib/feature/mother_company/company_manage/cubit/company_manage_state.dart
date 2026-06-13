part of 'company_manage_cubit.dart';

enum CompanyManageStatus { initial, loading, loaded, error }

class CompanyManageState extends Equatable {
  const CompanyManageState({
    this.status = CompanyManageStatus.initial,
    this.allCompanies = const [],
    this.filteredCompanies = const [],
    this.dateFilter = DateFilter.last12Months,
    this.searchQuery = '',
    this.sortField = SortField.sl,
    this.sortOrder = SortOrder.asc,
    this.currentPage = 1,
    this.rowsPerPage = 10,
    this.error,
  });

  final CompanyManageStatus status;
  final List<CompanyActivity> allCompanies;
  final List<CompanyActivity> filteredCompanies;
  final DateFilter dateFilter;
  final String searchQuery;
  final SortField sortField;
  final SortOrder sortOrder;
  final int currentPage;
  final int rowsPerPage;
  final String? error;

  int get totalPages => (filteredCompanies.length / rowsPerPage).ceil();

  List<CompanyActivity> get pagedCompanies {
    final start = (currentPage - 1) * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredCompanies.length);
    if (start >= filteredCompanies.length) return [];
    return filteredCompanies.sublist(start, end);
  }

  CompanyManageState copyWith({
    CompanyManageStatus? status,
    List<CompanyActivity>? allCompanies,
    List<CompanyActivity>? filteredCompanies,
    DateFilter? dateFilter,
    String? searchQuery,
    SortField? sortField,
    SortOrder? sortOrder,
    int? currentPage,
    int? rowsPerPage,
    String? error,
  }) {
    return CompanyManageState(
      status: status ?? this.status,
      allCompanies: allCompanies ?? this.allCompanies,
      filteredCompanies: filteredCompanies ?? this.filteredCompanies,
      dateFilter: dateFilter ?? this.dateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      currentPage: currentPage ?? this.currentPage,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allCompanies,
        filteredCompanies,
        dateFilter,
        searchQuery,
        sortField,
        sortOrder,
        currentPage,
        rowsPerPage,
        error,
      ];
}
