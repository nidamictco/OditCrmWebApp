import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/company_manage_models.dart';
import '../cubit/company_manage_cubit.dart';

/// Compact table used on the Dashboard screen.
/// Mirrors the full [CompanyTable] but shows only 5 rows with no pagination.
class RecentCompanyTable extends StatelessWidget {
  const RecentCompanyTable({
    super.key,
    required this.companies,
    this.onViewAll,
  });

  final List<CompanyActivity> companies;
  final VoidCallback? onViewAll;

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
          // ── Card header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Text('Recent Company Activity', style: AppTextStyle.heading2),
                const Spacer(),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppThemeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Column headers ───────────────────────────────────────
          Container(
            color: AppThemeColors.scaffoldBg,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Row(
              children: [
                SizedBox(width: 50, child: _HeaderCell('SL')),
                SizedBox(width: 220, child: _HeaderCell('COMPANY NAME')),
                SizedBox(width: 150, child: _HeaderCell('ADMIN NAME')),
                SizedBox(width: 110, child: _HeaderCell('PLAN TYPE')),
                SizedBox(width: 120, child: _HeaderCell('SUB. START')),
                SizedBox(width: 120, child: _HeaderCell('SUB. END')),
                SizedBox(width: 80, child: _HeaderCell('STATUS')),
                SizedBox(
                  width: 56,
                  child: _HeaderCell('ACTION', centered: true),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppThemeColors.divider),
          // ── Data rows ────────────────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: companies.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppThemeColors.divider),
            itemBuilder: (context, i) =>
                _RecentCompanyRow(company: companies[i]),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.centered = false});
  final String label;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.tableHeader,
      textAlign: centered ? TextAlign.center : TextAlign.start,
    );
  }
}

class _RecentCompanyRow extends StatefulWidget {
  const _RecentCompanyRow({required this.company});
  final CompanyActivity company;

  @override
  State<_RecentCompanyRow> createState() => _RecentCompanyRowState();
}

class _RecentCompanyRowState extends State<_RecentCompanyRow> {
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
    final fmt = DateFormat('dd MMM yyyy');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered ? const Color(0xFFF8F9FD) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 50, child: Text(sl, style: AppTextStyle.tableCell)),
            SizedBox(
              width: 220,
              child: Text(
                widget.company.companyName,
                style: AppTextStyle.tableCell,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                widget.company.adminName,
                style: AppTextStyle.tableCell,
              ),
            ),
            SizedBox(
              width: 110,
              child: _PlanBadge(planType: widget.company.planType),
            ),
            SizedBox(
              width: 120,
              child: Text(
                fmt.format(widget.company.subscriptionStartDate),
                style: AppTextStyle.tableCell,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                fmt.format(widget.company.subscriptionEndDate),
                style: AppTextStyle.tableCell,
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                widget.company.status.label,
                style: GoogleFonts.poppins(
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
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: AppThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final overlay =
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
        PopupMenuItem(
          value: 'view',
          child: Text('View Details', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'suspend',
          child: Text(
            'Suspend',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.planType});
  final PlanType planType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeColors.planBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        planType.label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.planText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
