//

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class TableColumn {
  final String title;
  final int flex;

  TableColumn({required this.title, this.flex = 1});
}

class CustomTable extends StatefulWidget {
  final List<TableColumn> columns;
  final List<List<Widget>> rows;
  final String emptyMessage;
  final bool showCheckboxes;
  final List<bool>? initialCheckedStates;
  final void Function(int rowIndex)? onRowTap;
  final void Function(int rowIndex, bool checked)? onCheckChanged;
  final List<Color>? priorityColors;
  final double? height;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = "No data available in table",
    this.showCheckboxes = false,
    this.onRowTap,
    this.initialCheckedStates,
    this.onCheckChanged,
    this.priorityColors,
    this.height,
  });

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  late List<bool> _checkedStates;

  @override
  void initState() {
    super.initState();
    _checkedStates = widget.initialCheckedStates != null
        ? List<bool>.from(widget.initialCheckedStates!)
        : List<bool>.filled(widget.rows.length, false);
  }

  @override
  void didUpdateWidget(covariant CustomTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔹 Sync state if rows change
    if (widget.rows.length != _checkedStates.length) {
      _checkedStates = widget.initialCheckedStates != null
          ? List<bool>.from(widget.initialCheckedStates!)
          : List<bool>.filled(widget.rows.length, false);
    }
  }

  /// 🔹 true = all checked, false = none, null = some (indeterminate)
  bool? get _isAllSelected {
    if (_checkedStates.every((e) => e)) return true;
    if (_checkedStates.every((e) => !e)) return false;
    return null; // indeterminate
  }

  /// 🔹 If all selected → deselect all, otherwise → select all
  void _toggleSelectAll() {
    final selectAll = _isAllSelected != true;
    setState(() {
      for (int i = 0; i < _checkedStates.length; i++) {
        _checkedStates[i] = selectAll;
      }
    });
    // 🔹 Notify parent for every row
    for (int i = 0; i < _checkedStates.length; i++) {
      widget.onCheckChanged?.call(i, selectAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(
        right: 2.w,
        left: 2.w,
        bottom: 2.w,
        top: widget.height ?? 2.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Center(
                child: Text(
                  widget.emptyMessage,
                  style: AppTextStyle.medium(color: Colors.grey),
                ),
              ),
            )
          else
            ..._buildRows(),
        ],
      ),
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(width: 1.2.w),
          // SizedBox(width: 1.5.w),
          // Checkbox header placeholder (keeps alignment)
          if (widget.showCheckboxes)
            SizedBox(
              width: 5.w,
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.divider)),
                ),
                child: Checkbox(
                  value: _isAllSelected, // 🔹 tri-state: true / false / null
                  tristate: true,
                  activeColor: AppColors.primary,
                  onChanged: (_) => _toggleSelectAll(),
                ),
              ),
            ),

          // Regular column headers
          ...List.generate(widget.columns.length, (index) {
            final col = widget.columns[index];
            return Expanded(
              flex: col.flex,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(),
                child: Text(
                  col.title,
                  style: AppTextStyle.medium(weight: FontWeight.w600),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ROWS
  List<Widget> _buildRows() {
    return List.generate(widget.rows.length, (rowIndex) {
      final dotColor =
          (widget.priorityColors != null &&
              rowIndex < widget.priorityColors!.length)
          ? widget.priorityColors![rowIndex]
          : Colors.transparent;
      return GestureDetector(
        onTap: () => widget.onRowTap?.call(rowIndex),
        child: Container(
          decoration: BoxDecoration(
            color: rowIndex.isEven ? AppColors.greyCard : Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              SizedBox(width: 10),

              // ── Priority dot ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(right: 0.1.w),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 🔹 Checkbox cell
              // Row(
              //   children: [
              if (widget.showCheckboxes)
                SizedBox(
                  width: 5.w,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      // border: Border(right: BorderSide(color: AppColors.divider)),
                    ),
                    child: Checkbox(
                      value: _checkedStates[rowIndex],
                      activeColor: AppColors.primary, // use your brand color
                      onChanged: (val) {
                        setState(() => _checkedStates[rowIndex] = val ?? false);
                        widget.onCheckChanged?.call(rowIndex, val ?? false);
                      },
                    ),
                  ),
                ),
              //   ],
              // ),

              // 🔹 Regular data cells
              ...List.generate(widget.rows[rowIndex].length, (colIndex) {
                return Expanded(
                  flex: widget.columns[colIndex].flex,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border(
                        // right: colIndex == widget.columns.length - 1
                        //     ? BorderSide.none
                        //     : BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: widget.rows[rowIndex][colIndex],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
