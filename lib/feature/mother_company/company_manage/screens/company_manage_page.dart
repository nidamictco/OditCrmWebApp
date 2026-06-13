import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oxdo/feature/mother_company/company_manage/widgets/company_table.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/dashboard_topbar.dart';
import '../cubit/company_manage_cubit.dart';
import '../models/company_manage_models.dart';

class CompanyManagePage extends StatelessWidget {
  final VoidCallback? onAddCompanyTap;
  const CompanyManagePage({super.key, this.onAddCompanyTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyManageCubit()..loadCompanies(),
      child: _CompanyManageView(onAddCompanyTap: onAddCompanyTap),
    );
  }
}

class _CompanyManageView extends StatelessWidget {
  final VoidCallback? onAddCompanyTap;
  const _CompanyManageView({this.onAddCompanyTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyManageCubit, CompanyManageState>(
      builder: (context, state) {
        final cubit = context.read<CompanyManageCubit>();
        return Scaffold(
          backgroundColor: AppThemeColors.scaffoldBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardTopBar(),
              // ── Page header ─────────────────────────────────────
              _PageHeader(state: state, cubit: cubit, onAddCompanyTap: onAddCompanyTap),
              // ── Content ─────────────────────────────────────────
              Expanded(
                child: _buildBody(context, state, cubit),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CompanyManageState state,
    CompanyManageCubit cubit,
  ) {
    if (state.status == CompanyManageStatus.loading ||
        state.status == CompanyManageStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppThemeColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (state.status == CompanyManageStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(state.error ?? 'Something went wrong'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: cubit.loadCompanies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        children: [
          // ── Search + filter bar ───────────────────────────────
          // _SearchFilterBar(state: state, cubit: cubit),
          const SizedBox(height: 16),
          // ── Table ─────────────────────────────────────────────
          CompanyTable(state: state, cubit: cubit),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.state, required this.cubit, this.onAddCompanyTap});
  final CompanyManageState state;
  final CompanyManageCubit cubit;
  final VoidCallback? onAddCompanyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title + subtitle
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Company Manage',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your all-in-one solution for modern company management.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date filter
          _DateFilterChip(
            value: state.dateFilter,
            onChanged: cubit.changeDateFilter,
          ),
          const SizedBox(width: 12),
          // Add New Company button
          _AddCompanyButton(onTap: () {
            if (onAddCompanyTap != null) {
              onAddCompanyTap!();
            } else {
              _showAddDialog(context);
            }
          }),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add New Company'),
        content: const Text('Add company form goes here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search + filter bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchFilterBar extends StatefulWidget {
  const _SearchFilterBar({required this.state, required this.cubit});
  final CompanyManageState state;
  final CompanyManageCubit cubit;

  @override
  State<_SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<_SearchFilterBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.searchQuery);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          // Search
          Expanded(
            child: _SearchField(
              controller: _ctrl,
              onChanged: widget.cubit.onSearch,
            ),
          ),
          const SizedBox(width: 12),
          // Status filter chips
          _FilterChipGroup(
            current: widget.state.searchQuery,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppThemeColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Search company, admin, plan...',
          hintStyle: TextStyle(fontSize: 13, color: AppThemeColors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppThemeColors.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _FilterChipGroup extends StatelessWidget {
  const _FilterChipGroup({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallChip(label: 'All', isActive: true, onTap: () {}),
        const SizedBox(width: 6),
        _SmallChip(label: 'Active', isActive: false, onTap: () {}),
        const SizedBox(width: 6),
        _SmallChip(label: 'Pending', isActive: false, onTap: () {}),
        const SizedBox(width: 6),
        _SmallChip(label: 'Suspended', isActive: false, onTap: () {}),
      ],
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppThemeColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppThemeColors.primary : AppThemeColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date filter dropdown chip
// ─────────────────────────────────────────────────────────────────────────────

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({required this.value, required this.onChanged});
  final DateFilter value;
  final ValueChanged<DateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _show(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppThemeColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: AppThemeColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              value.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppThemeColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppThemeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext context) {
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
    showMenu<DateFilter>(
      context: context,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: DateFilter.values.map((f) {
        return PopupMenuItem<DateFilter>(
          value: f,
          child: Text(
            f.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: f == value ? FontWeight.w600 : FontWeight.w400,
              color: f == value ? AppThemeColors.primary : AppThemeColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    ).then((v) {
      if (v != null) onChanged(v);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Company button
// ─────────────────────────────────────────────────────────────────────────────

class _AddCompanyButton extends StatelessWidget {
  const _AddCompanyButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B388), // teal-green from Figma
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text(
        'Add New Company',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
