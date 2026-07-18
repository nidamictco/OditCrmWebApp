import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/dashboard_cubit.dart';
import '../../shared/widgets/dashboard_topbar.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_company_table.dart';
import '../../company_manage/models/company_manage_models.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback? onViewAllTap;
  const DashboardPage({super.key, this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..loadDashboard(),
      child: _DashboardView(onViewAllTap: onViewAllTap),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final VoidCallback? onViewAllTap;
  const _DashboardView({super.key, this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(
                  screen: 'dashboard',
                  onSearchChanged: (value) {
                    context.read<DashboardCubit>().updateSearchQuery(value);
                  },
                ),
                Expanded(
                  child: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      if (state.status == DashboardStatus.loading ||
                          state.status == DashboardStatus.initial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppThemeColors.primary,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      if (state.status == DashboardStatus.error) {
                        return Center(
                          child: Text(
                            state.error ?? 'An error occurred',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        );
                      }
                      return _DashboardContent(
                        state: state,
                        onViewAllTap: onViewAllTap,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state, this.onViewAllTap});
  final DashboardState state;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Overview', style: AppTextStyle.heading1),
                  SizedBox(height: 3),
                  Text(
                    'Welcome back, Super Admin. Here is what\'s happening today.',
                    style: AppTextStyle.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              // DateFilterDropdown(
              //   value: state.overviewFilter,
              //   onChanged: cubit.changeOverviewFilter,
              // ),
            ],
          ),
          const SizedBox(height: 22),

          /// ── Stat cards ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Companies',
                  value: state.stats.totalCompanies.toString(),
                  icon: Icons.apartment,
                  iconBg: AppThemeColors.statCompanyIcon,
                  iconColor: AppThemeColors.statCompanyBg,
                  cardBg: AppThemeColors.statCompanyIcon.withValues(alpha: .06),
                  growth: state.stats.companiesGrowth,
                  valueColor: AppThemeColors.statCompanyIcon,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Active Companies',
                  value: state.stats.activeCompanies.toString(),
                  icon: Icons.business,
                  iconBg:
                      AppThemeColors.statusActive, //AppThemeColors.statLeadsBg,
                  iconColor: AppThemeColors.statLeadsBg,
                  cardBg: AppThemeColors.statusActive.withValues(
                    alpha: .06,
                  ), //Color(0xFF4FC3CE).withValues(alpha: .06),
                  growth: state.stats.leadsGrowth,
                  valueColor: AppThemeColors.statusActive,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Pending Companies',
                  value: state.stats.pendingCompanies.toString(),
                  icon: Icons.manage_accounts_rounded,
                  iconBg: AppThemeColors.statusPending,
                  iconColor: AppThemeColors.statStaffBg,
                  cardBg: Color(0xFFD97706).withValues(alpha: .1),
                  statusLabel: state.stats.staffStatus,
                  statusColor: AppThemeColors.statusPending,
                  valueColor: AppThemeColors.statusPending,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Suspended Companies',
                  value: state.stats.suspendedCompanies.toString(),
                  icon: Icons.block,
                  iconBg: AppThemeColors.statusSuspended,
                  iconColor: AppThemeColors
                      .statStaffBg, //AppThemeColors.statUptimeIcon,
                  cardBg: AppThemeColors.statusSuspended.withValues(alpha: .06),
                  statusLabel: state.stats.uptimeStatus,
                  statusColor: AppThemeColors.statusSuspended,
                  valueColor: AppThemeColors.statusSuspended,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          //
          // // ── Charts row ─────────────────────────────────────────
          // IntrinsicHeight(
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       // Cash Flow card
          //       Expanded(
          //         flex: 5,
          //         child: Container(
          //           padding: const EdgeInsets.all(22),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(14),
          //             border: Border.all(color: AppThemeColors.borderLight),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.03),
          //                 blurRadius: 8,
          //                 offset: const Offset(0, 2),
          //               ),
          //             ],
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Row(
          //                 children: [
          //                   const Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text('Cash Flow', style: AppTextStyle.heading2()),
          //                       SizedBox(height: 2),
          //                       Text(
          //                         'Monthly receipt vs payment overview',
          //                         style: AppTextStyle.bodySmall(),
          //                       ),
          //                     ],
          //                   ),
          //                   const Spacer(),
          //                   DateFilterDropdown(
          //                     value: state.cashFlowFilter,
          //                     onChanged: cubit.changeCashFlowFilter,
          //                   ),
          //                 ],
          //               ),
          //               const SizedBox(height: 16),
          //               SizedBox(
          //                 height: 280,
          //                 child: CashFlowChart(
          //                   data: state.cashFlowData,
          //                   selectedIndex: state.selectedCashFlowIndex,
          //                   onHover: cubit.selectCashFlowPoint,
          //                   onExit: cubit.clearCashFlowSelection,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       // Payable / Receivable card
          //       Expanded(
          //         flex: 2,
          //         child: Container(
          //           padding: const EdgeInsets.all(22),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(14),
          //             border: Border.all(color: AppThemeColors.borderLight),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.03),
          //                 blurRadius: 8,
          //                 offset: const Offset(0, 2),
          //               ),
          //             ],
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Row(
          //                 children: [
          //                   const Text(
          //                     'Payable / Receivable',
          //                     style: AppTextStyle.heading2(),
          //                   ),
          //                   const Spacer(),
          //                 ],
          //               ),
          //               const SizedBox(height: 8),
          //               DateFilterDropdown(
          //                 value: state.payableFilter,
          //                 onChanged: cubit.changePayableFilter,
          //               ),
          //               const SizedBox(height: 20),
          //               Expanded(
          //                 child: PayableReceivableChart(
          //                   receivable: state.stats.receivable,
          //                   payable: state.stats.payable,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 22),

          // ── Recent Company Activity table ──────────────────────
          RecentCompanyTable(
            companies: state.searchQuery.isEmpty
                ? state.companies
                : state.companies.where((company) {
                    final query = state.searchQuery.toLowerCase();
                    return company.companyName.toLowerCase().contains(query) ||
                        company.adminName.toLowerCase().contains(query) ||
                        company.planType.label.toLowerCase().contains(query) ||
                        company.status.label.toLowerCase().contains(query);
                  }).toList(),
            cubit: cubit,
            onViewAll: onViewAllTap,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
