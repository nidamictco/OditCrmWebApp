import 'package:equatable/equatable.dart';

// ─── Plan Type ───────────────────────────────────────────────────────────────

enum PlanType { enterprise, standard, basic }

extension PlanTypeLabel on PlanType {
  String get label {
    switch (this) {
      case PlanType.enterprise:
        return 'ENTERPRISE';
      case PlanType.standard:
        return 'STANDARD';
      case PlanType.basic:
        return 'BASIC';
    }
  }
}

// ─── Company Status ───────────────────────────────────────────────────────────

enum CompanyStatus { active, pending, suspended }

extension CompanyStatusLabel on CompanyStatus {
  String get label {
    switch (this) {
      case CompanyStatus.active:
        return 'Active';
      case CompanyStatus.pending:
        return 'Pending';
      case CompanyStatus.suspended:
        return 'Suspend';
    }
  }
}

// ─── Company Activity (shared with dashboard) ─────────────────────────────────

class CompanyActivity extends Equatable {
  const CompanyActivity({
    required this.sl,
    required this.companyId,
    required this.companyName,
    required this.adminName,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.planType,
    required this.status,
    required this.domain,
    required this.industry,
    required this.adminEmail,
    required this.adminMobile,
    required this.yearlyBilling,
  });

  final int sl;
  final String companyId;
  final String companyName;
  final String adminName;
  final DateTime subscriptionStartDate;
  final DateTime subscriptionEndDate;
  final PlanType planType;
  final CompanyStatus status;
  final String domain;
  final String industry;
  final String adminEmail;
  final String adminMobile;
  final bool yearlyBilling;

  @override
  List<Object?> get props => [
        sl,
        companyId,
        companyName,
        adminName,
        subscriptionStartDate,
        subscriptionEndDate,
        planType,
        status,
        domain,
        industry,
        adminEmail,
        adminMobile,
        yearlyBilling,
      ];
}

// ─── Filter / Sort ────────────────────────────────────────────────────────────

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

enum SortField { sl, companyName, adminName, planType, status }

enum SortOrder { asc, desc }
