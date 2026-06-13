import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/plan_badge.dart';
import '../models/dashboard_models.dart';

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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                 Text('Recent Company Activity', style: AppTextStyles.heading2),
                const Spacer(),
                GestureDetector(
                  onTap: onViewAll,
                  child:  Text(
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
          const SizedBox(height: 14),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                SizedBox(
                  width: 40,
                  child: Text('SL', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  width: 250,
                  child: Text('COMPANY NAME', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  width: 150,
                  // flex: 2,
                  child: Text('ADMIN NAME', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  // flex: 2,
                  width: 100,
                  child: Text('PLAN TYPE', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  // flex: 2,
                  width: 100,
                  child: Text('SUBSCRIPTION START', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  // flex: 2,
                  width: 100,
                  child: Text('SUBSCRIPTION END', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  width: 72,
                  child: Text('STATUS', style: AppTextStyles.tableHeader),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'ACTION',
                    style: AppTextStyles.tableHeader,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppThemeColors.divider),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: companies.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppThemeColors.divider),
            itemBuilder: (context, index) {
              return _CompanyRow(company: companies[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatefulWidget {
  const _CompanyRow({required this.company});
  final CompanyActivity company;

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered ? AppThemeColors.scaffoldBg : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              child: Text(sl, style: AppTextStyles.tableCell),
            ),
            SizedBox(
              width: 250,
              // flex: 1,
              child: Text(
                widget.company.companyName,
                style: AppTextStyles.tableCell,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              // flex: 2,
              child: Text(
                widget.company.adminName,
                style: AppTextStyles.tableCell,
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
                DateFormat('dd MMM yyyy').format(widget.company.subscriptionStartDate),
                style: AppTextStyles.tableCell,
              ),
            ),
            SizedBox(
              width: 100,
              // flex: 1,
              child: Text(
                DateFormat('dd MMM yyyy').format(widget.company.subscriptionEndDate),
                style: AppTextStyles.tableCell,
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
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: const [
        PopupMenuItem(value: 'view', child: Text('View Details')),
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'suspend',
          child: Text('Suspend', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
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
