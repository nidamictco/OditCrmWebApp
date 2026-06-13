import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/company_manage_models.dart';

class SortableColumnHeader extends StatelessWidget {
  const SortableColumnHeader({
    super.key,
    required this.label,
    required this.field,
    required this.currentSortField,
    required this.currentSortOrder,
    required this.onSort,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final SortField field;
  final SortField currentSortField;
  final SortOrder currentSortOrder;
  final ValueChanged<SortField> onSort;
  final TextAlign textAlign;

  bool get _isActive => currentSortField == field;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSort(field),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.tableHeader.copyWith(
              color: _isActive ? AppThemeColors.primary : AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_drop_up,
                size: 14,
                color: (_isActive && currentSortOrder == SortOrder.asc)
                    ? AppThemeColors.primary
                    : AppThemeColors.textMuted,
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
                color: (_isActive && currentSortOrder == SortOrder.desc)
                    ? AppThemeColors.primary
                    : AppThemeColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
