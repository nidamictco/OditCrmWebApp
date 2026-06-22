import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/plan_badge.dart';
import '../cubit/company_manage_cubit.dart';
import '../models/company_manage_models.dart';
import 'edit_company_dialog.dart';
import 'company_details_dialog.dart';

import 'sortable_column_header.dart';
import 'table_pagination.dart';

// Column width constants — matches Figma proportions
class _ColW {
  static const sl = 56.0;
  static const companyName = 220.0;
  static const adminName = 160.0;
  static const planType = 100.0;
  static const subStart = 130.0;
  static const subEnd = 130.0;
  static const status = 90.0;
  static const action = 56.0;
}

class CompanyTable extends StatelessWidget {
  const CompanyTable({super.key, required this.state, required this.cubit});

  final CompanyManageState state;
  final CompanyManageCubit cubit;

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
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const double minWidth = 1000;
              final double tableWidth = constraints.maxWidth > minWidth
                  ? constraints.maxWidth
                  : minWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // ── Header row ────────────────────────────────────────────
                      _TableHeaderRow(state: state, cubit: cubit),
                      const Divider(height: 1, color: AppThemeColors.divider),
                      // ── Data rows ─────────────────────────────────────────────
                      if (state.pagedCompanies.isEmpty)
                        const _EmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.pagedCompanies.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: AppThemeColors.divider,
                          ),
                          itemBuilder: (context, index) {
                            return _CompanyRow(
                              company: state.pagedCompanies[index],
                              cubit: cubit,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          // ── Pagination ────────────────────────────────────────────
          const Divider(height: 1, color: AppThemeColors.divider),
          TablePagination(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalItems: state.filteredCompanies.length,
            rowsPerPage: state.rowsPerPage,
            onPrev: cubit.prevPage,
            onNext: cubit.nextPage,
            onPageTap: cubit.goToPage,
            onRowsPerPageChanged: cubit.changeRowsPerPage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header row
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.state, required this.cubit});
  final CompanyManageState state;
  final CompanyManageCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeColors.scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: _ColW.sl,
            child: SortableColumnHeader(
              label: 'SL',
              field: SortField.sl,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              onSort: cubit.onSort,
            ),
          ),
          SizedBox(
            width: _ColW.companyName,
            child: SortableColumnHeader(
              label: 'COMPANY NAME',
              field: SortField.companyName,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              onSort: cubit.onSort,
            ),
          ),
          SizedBox(
            width: _ColW.adminName,
            child: SortableColumnHeader(
              label: 'ADMIN NAME',
              field: SortField.adminName,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              onSort: cubit.onSort,
            ),
          ),
          SizedBox(
            width: _ColW.planType,
            child: SortableColumnHeader(
              label: 'PLAN TYPE',
              field: SortField.planType,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              onSort: cubit.onSort,
            ),
          ),
          SizedBox(
            width: _ColW.subStart,
            child: Text('SUB. START', style: AppTextStyle.tableHeader()),
          ),
          SizedBox(
            width: _ColW.subEnd,
            child: Text('SUB. END', style: AppTextStyle.tableHeader()),
          ),
          SizedBox(
            width: _ColW.status,
            child: SortableColumnHeader(
              label: 'STATUS',
              field: SortField.status,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              onSort: cubit.onSort,
            ),
          ),
          SizedBox(
            width: _ColW.action,
            child: Text(
              'ACTION',
              style: AppTextStyle.tableHeader(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data row
// ─────────────────────────────────────────────────────────────────────────────

class _CompanyRow extends StatefulWidget {
  const _CompanyRow({required this.company, required this.cubit});
  final CompanyActivity company;
  final CompanyManageCubit cubit;

  @override
  State<_CompanyRow> createState() => _CompanyRowState();
}

class _CompanyRowState extends State<_CompanyRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final sl = widget.company.sl.toString().padLeft(2, '0');
    final fmt = DateFormat('dd MMM yyyy');

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
          color: _hovered ? const Color(0xFFF8F9FD) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // SL
              SizedBox(
                width: _ColW.sl,
                child: Text(sl, style: AppTextStyle.tableCell()),
              ),
              // Company Name
              SizedBox(
                width: _ColW.companyName,
                child: Text(
                  widget.company.companyName,
                  style: AppTextStyle.tableCell(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Admin Name
              SizedBox(
                width: _ColW.adminName,
                child: Text(
                  widget.company.adminName,
                  style: AppTextStyle.tableCell(),
                ),
              ),
              // Plan Type
              SizedBox(
                width: _ColW.planType,
                child: PlanBadge(label: widget.company.planType.label),
              ),
              // Subscription Start
              SizedBox(
                width: _ColW.subStart,
                child: Text(
                  fmt.format(widget.company.subscriptionStartDate),
                  style: AppTextStyle.tableCell(),
                ),
              ),
              // Subscription End
              SizedBox(
                width: _ColW.subEnd,
                child: Text(
                  fmt.format(widget.company.subscriptionEndDate),
                  style: AppTextStyle.tableCell(),
                ),
              ),
              // Status
              SizedBox(
                width: _ColW.status,
                child: _StatusBadge(status: widget.company.status),
              ),
              // Action
              SizedBox(
                width: _ColW.action,
                child: Center(
                  child: _ActionMenu(
                    company: widget.company,
                    cubit: widget.cubit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final CompanyStatus status;

  Color get _color {
    switch (status) {
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
    return Text(
      status.label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action menu button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({required this.company, required this.cubit});
  final CompanyActivity company;
  final CompanyManageCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: AppThemeColors.textSecondary,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: pos,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        // const PopupMenuItem(
        //   value: 'view',
        //   child: Row(children: [
        //     Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
        //     SizedBox(width: 8),
        //     Text('View Details', style: TextStyle(fontSize: 13)),
        //   ]),
        // ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Edit', style: GoogleFonts.poppins(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                company.status == CompanyStatus.suspended
                    ? Icons.check_circle_outline
                    : Icons.block_outlined,
                size: 16,
                color: company.status == CompanyStatus.suspended
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                company.status == CompanyStatus.suspended
                    ? 'Activate'
                    : 'Suspend',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: company.status == CompanyStatus.suspended
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text('Delete', style: GoogleFonts.poppins(fontSize: 13, color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((val) {
      if (!context.mounted) return;
      if (val == 'edit') {
        showDialog(
          context: context,
          builder: (_) => EditCompanyDialog(company: company, cubit: cubit),
        );
      } else if (val == 'toggle') {
        if (company.status == CompanyStatus.suspended) {
          cubit.activateCompany(company.companyId);
        } else {
          cubit.suspendCompany(company.companyId);
        }
      } else if (val == 'delete') {
        cubit.deleteCompany(company.companyId);
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.business_outlined,
              size: 48,
              color: AppThemeColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No companies found',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search or filter.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppThemeColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
