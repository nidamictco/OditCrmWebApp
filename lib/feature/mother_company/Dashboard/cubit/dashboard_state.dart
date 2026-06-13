part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, loaded, error }

enum DateFilter { last12Months, last6Months, last3Months, thisMonth }

extension DateFilterLabel on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.last12Months:
        return 'Last 12 Months';
      case DateFilter.last6Months:
        return 'Last 6 Months';
      case DateFilter.last3Months:
        return 'Last 3 Months';
      case DateFilter.thisMonth:
        return 'This Month';
    }
  }
}

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.overviewFilter = DateFilter.last12Months,
    this.cashFlowFilter = DateFilter.last12Months,
    this.payableFilter = DateFilter.last12Months,
    this.stats = const DashboardStats(),
    this.cashFlowData = const [],
    this.companies = const [],
    this.selectedCashFlowIndex,
    this.error,
  });

  final DashboardStatus status;
  final DateFilter overviewFilter;
  final DateFilter cashFlowFilter;
  final DateFilter payableFilter;
  final DashboardStats stats;
  final List<CashFlowPoint> cashFlowData;
  final List<CompanyActivity> companies;
  final int? selectedCashFlowIndex;
  final String? error;

  DashboardState copyWith({
    DashboardStatus? status,
    DateFilter? overviewFilter,
    DateFilter? cashFlowFilter,
    DateFilter? payableFilter,
    DashboardStats? stats,
    List<CashFlowPoint>? cashFlowData,
    List<CompanyActivity>? companies,
    int? selectedCashFlowIndex,
    String? error,
    bool clearSelectedIndex = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      overviewFilter: overviewFilter ?? this.overviewFilter,
      cashFlowFilter: cashFlowFilter ?? this.cashFlowFilter,
      payableFilter: payableFilter ?? this.payableFilter,
      stats: stats ?? this.stats,
      cashFlowData: cashFlowData ?? this.cashFlowData,
      companies: companies ?? this.companies,
      selectedCashFlowIndex:
          clearSelectedIndex ? null : (selectedCashFlowIndex ?? this.selectedCashFlowIndex),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        overviewFilter,
        cashFlowFilter,
        payableFilter,
        stats,
        cashFlowData,
        companies,
        selectedCashFlowIndex,
        error,
      ];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    this.totalCompanies = 1276,
    this.companiesGrowth = 12.5,
    this.activeLeads = 8,
    this.leadsGrowth = 12.5,
    this.staffMembers = 890,
    this.staffStatus = 'Stables',
    this.systemUptime = 99.9,
    this.uptimeStatus = 'Optimum',
    this.receivable = 34567.00,
    this.payable = 5678.00,
  });

  final int totalCompanies;
  final double companiesGrowth;
  final int activeLeads;
  final double leadsGrowth;
  final int staffMembers;
  final String staffStatus;
  final double systemUptime;
  final String uptimeStatus;
  final double receivable;
  final double payable;

  @override
  List<Object?> get props => [
        totalCompanies,
        companiesGrowth,
        activeLeads,
        leadsGrowth,
        staffMembers,
        staffStatus,
        systemUptime,
        uptimeStatus,
        receivable,
        payable,
      ];
}
