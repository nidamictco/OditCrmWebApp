import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../company_manage/models/company_manage_models.dart';
import '../../shared/widgets/plan_badge.dart';
// import '../models/dashboard_models.dart';
import '../cubit/dashboard_cubit.dart';
import '../../company_manage/widgets/edit_company_dialog.dart';
import '../../company_manage/widgets/company_details_dialog.dart';

class RecentCompanyTable extends StatelessWidget {
  const RecentCompanyTable({
    super.key,
    required this.companies,
    required this.cubit,
    this.onViewAll,
  });

  final List<CompanyActivity> companies;
  final VoidCallback? onViewAll;
  final DashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Text('Recent Company Activity', style: AppTextStyle.heading2()),
                const Spacer(),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTextStyle.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppThemeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const double minWidth = 920;
              final double tableWidth = constraints.maxWidth > minWidth
                  ? constraints.maxWidth
                  : minWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column headers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text('SL', style: AppTextStyle.tableHeader()),
                            ),
                            SizedBox(
                              width: 250,
                              child: Text('COMPANY NAME', style: AppTextStyle.tableHeader()),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text('ADMIN NAME', style: AppTextStyle.tableHeader()),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text('PLAN TYPE', style: AppTextStyle.tableHeader()),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'SUBSCRIPTION START',
                                style: AppTextStyle.tableHeader(),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'SUBSCRIPTION END',
                                style: AppTextStyle.tableHeader(),
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: Text('STATUS', style: AppTextStyle.tableHeader()),
                            ),
                            SizedBox(
                              width: 56,
                              child: Text(
                                'ACTION',
                                style: AppTextStyle.tableHeader(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppThemeColors.divider),
                      // Rows
                      if (companies.isEmpty)
                        const _EmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: companies.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppThemeColors.divider),
                          itemBuilder: (context, index) {
                            return _CompanyRow(company: companies[index], cubit: cubit);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatefulWidget {
  const _CompanyRow({required this.company, required this.cubit});
  final CompanyActivity company;
  final DashboardCubit cubit;

  @override
  State<_CompanyRow> createState() => _CompanyRowState();
}

class _CompanyRowState extends State<_CompanyRow> {
  bool _hovered = false;

  Color get _statusColor {
    switch (widget.company.status) {
      case CompanyStatus.active:
        return AppThemeColors.statusActive;
      case CompanyStatus.pending:
        return AppThemeColors.statusPending;
      case CompanyStatus.suspended:
        return AppThemeColors.statusSuspended;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sl = widget.company.sl.toString().padLeft(2, '0');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => CompanyDetailsDialog(
              company: widget.company,
              cubit: widget.cubit,
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered ? AppThemeColors.scaffoldBg : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                child: Text(sl, style: AppTextStyle.tableCell()),
              ),
              SizedBox(
                width: 250,
                // flex: 1,
                child: Text(
                  widget.company.companyName,
                  style: AppTextStyle.tableCell(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 150,
                // flex: 2,
                child: Text(
                  widget.company.adminName,
                  style: AppTextStyle.tableCell(),
                ),
              ),
              SizedBox(
                width: 100,
                // flex: 1,
                child: PlanBadge(label: widget.company.planType.label),
              ),
              SizedBox(
                width: 100,
                // flex: 1,
                child: Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(widget.company.subscriptionStartDate),
                  style: AppTextStyle.tableCell(),
                ),
              ),
              SizedBox(
                width: 100,
                // flex: 1,
                child: Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(widget.company.subscriptionEndDate),
                  style: AppTextStyle.tableCell(),
                ),
              ),

              SizedBox(
                width: 72,
                child: Text(
                  widget.company.status.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showActionMenu(context),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: AppThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Edit', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                widget.company.status == CompanyStatus.suspended
                    ? Icons.check_circle_outline
                    : Icons.block_outlined,
                size: 16,
                color: widget.company.status == CompanyStatus.suspended
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                widget.company.status == CompanyStatus.suspended
                    ? 'Activate'
                    : 'Suspend',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.company.status == CompanyStatus.suspended
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((val) {
      if (!context.mounted) return;
      if (val == 'edit') {
        showDialog(
          context: context,
          builder: (_) =>
              EditCompanyDialog(company: widget.company, cubit: widget.cubit),
        );
      } else if (val == 'toggle') {
        if (widget.company.status == CompanyStatus.suspended) {
          widget.cubit.activateCompany(widget.company.companyId);
        } else {
          widget.cubit.suspendCompany(widget.company.companyId);
        }
      } else if (val == 'delete') {
        widget.cubit.deleteCompany(widget.company.companyId);
      }
    });
  }
}

// class _PlanBadge extends StatelessWidget {
//   const _PlanBadge({required this.planType});
//   final PlanType planType;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppThemeColors.planBorder),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         planType.label,
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: AppThemeColors.planText,
//           letterSpacing: 0.6,
//         ),
//       ),
//     );
//   }
// }

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: AppThemeColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No companies found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppThemeColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Click "Add Company" in the sidebar to onboard a new organization.',
              style: TextStyle(fontSize: 13, color: AppThemeColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
