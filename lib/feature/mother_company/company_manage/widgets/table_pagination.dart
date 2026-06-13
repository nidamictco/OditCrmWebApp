import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TablePagination extends StatelessWidget {
  const TablePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.rowsPerPage,
    required this.onPrev,
    required this.onNext,
    required this.onPageTap,
    required this.onRowsPerPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int rowsPerPage;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onPageTap;
  final ValueChanged<int> onRowsPerPageChanged;

  List<int> get _pageNumbers {
    if (totalPages <= 7) return List.generate(totalPages, (i) => i + 1);
    final pages = <int>[];
    pages.add(1);
    if (currentPage > 3) pages.add(-1); // ellipsis
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) pages.add(i);
    }
    if (currentPage < totalPages - 2) pages.add(-1); // ellipsis
    pages.add(totalPages);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final start = ((currentPage - 1) * rowsPerPage) + 1;
    final end = (currentPage * rowsPerPage).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Rows per page
          const Text(
            'Rows per page:',
            style: TextStyle(fontSize: 12, color: AppThemeColors.textSecondary),
          ),
          const SizedBox(width: 8),
          _RowsDropdown(value: rowsPerPage, onChanged: onRowsPerPageChanged),
          const Spacer(),
          // Info
          Text(
            '$start–$end of $totalItems',
            style: const TextStyle(
              fontSize: 12,
              color: AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          // Page numbers
          ..._pageNumbers.map((p) {
            if (p == -1) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '…',
                  style: TextStyle(color: AppThemeColors.textMuted),
                ),
              );
            }
            final isActive = p == currentPage;
            return _PageBtn(
              page: p,
              isActive: isActive,
              onTap: () => onPageTap(p),
            );
          }),
          const SizedBox(width: 8),
          // Prev / Next
          _NavBtn(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onTap: onPrev,
          ),
          const SizedBox(width: 4),
          _NavBtn(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _RowsDropdown extends StatelessWidget {
  const _RowsDropdown({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: true,
        style: const TextStyle(
          fontSize: 12,
          color: AppThemeColors.textPrimary,
          fontFamily: 'Inter',
        ),
        items: [5, 10, 20, 50].map((v) {
          return DropdownMenuItem(value: v, child: Text('$v'));
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({required this.page, required this.isActive, required this.onTap});
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? AppThemeColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? null : Border.all(color: AppThemeColors.borderLight),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : AppThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppThemeColors.borderLight),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppThemeColors.textSecondary : AppThemeColors.textMuted,
        ),
      ),
    );
  }
}
