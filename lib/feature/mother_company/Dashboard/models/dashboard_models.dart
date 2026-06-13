import 'package:equatable/equatable.dart';

class CashFlowPoint extends Equatable {
  const CashFlowPoint({
    required this.month,
    required this.receipt,
    required this.payment,
    this.label,
  });

  final String month;
  final double receipt;
  final double payment;
  final String? label;

  @override
  List<Object?> get props => [month, receipt, payment, label];
}

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

class CompanyActivity extends Equatable {
  const CompanyActivity({
    required this.sl,
    required this.companyName,
    required this.adminName,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.planType,
    required this.status,
  });

  final int sl;
  final String companyName;
  final String adminName;
  final DateTime subscriptionStartDate;
  final DateTime subscriptionEndDate;
  final PlanType planType;
  final CompanyStatus status;

  @override
  List<Object?> get props => [sl, companyName, adminName, subscriptionStartDate, subscriptionEndDate, planType, status];
}
