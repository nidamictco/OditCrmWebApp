import 'package:flutter/material.dart';
import '../theme/app_text_style.dart';
import '../router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';

class TableColumn {
  final String title;
  final int flex;
  final double? width;

  TableColumn({required this.title, this.flex = 1, this.width});
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
  final double? minWidth;
  final String Function(int rowIndex)? getRowDestination;

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
    this.minWidth,
    this.getRowDestination,
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
    // 🔹 Sync state if initialCheckedStates provided or rows length change
    if (widget.initialCheckedStates != null) {
      _checkedStates = List<bool>.from(widget.initialCheckedStates!);
    } else if (widget.rows.length != _checkedStates.length) {
      _checkedStates = List<bool>.filled(widget.rows.length, false);
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
    Widget tableContent = Column(
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
    );

    if (widget.minWidth != null) {
      tableContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: widget.minWidth, child: tableContent),
      );
    }

    return Container(
      // width: 100.w,
      // margin: EdgeInsets.only(
      //   right: 2.w,
      //   left: 2.w,
      //   bottom: 2.w,
      //   top: widget.height ?? 2.w,
      // ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: tableContent,
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(width: 0.8.w),
          // Checkbox header placeholder (keeps alignment)
          if (widget.showCheckboxes)
            SizedBox(
              width: 3.5.w,
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Checkbox(
                  value: _isAllSelected, // 🔹 tri-state: true / false / null
                  tristate: true,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (_) => _toggleSelectAll(),
                ),
              ),
            ),

          // Regular column headers
          ...List.generate(widget.columns.length, (index) {
            final col = widget.columns[index];
            final cellContent = Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 8),
              decoration: const BoxDecoration(),
              child: col.title.toLowerCase() == 'select all'
                  ? Row(
                      children: [
                        Text(
                          col.title,
                          style: AppTextStyle.medium(
                            weight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(
                          width: 3.5.w,
                          // child: Container(
                          //   alignment: Alignment.topLeft,
                          //   padding: EdgeInsets.symmetric(vertical: 1.6.h),
                          //   decoration: const BoxDecoration(
                          //     border: Border(
                          //       right: BorderSide(color: Color(0xFFE2E8F0)),
                          //     ),
                          //   ),
                          child: Checkbox(
                            value:
                                _isAllSelected, // 🔹 tri-state: true / false / null
                            tristate: true,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (_) => _toggleSelectAll(),
                          ),
                          // ),
                        ),
                      ],
                    )
                  : Text(
                      col.title,
                      style: AppTextStyle.medium(
                        weight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
            );

            if (col.width != null) {
              return SizedBox(width: col.width, child: cellContent);
            }

            return Expanded(flex: col.flex, child: cellContent);
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
      final childWidget = Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),

            // ── Priority dot ───────────────────────────────────────────────
            if (dotColor != Colors.transparent)
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
            if (widget.showCheckboxes)
              SizedBox(
                width: 3.8.w,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Checkbox(
                    value: _checkedStates[rowIndex],
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => _checkedStates[rowIndex] = val ?? false);
                      widget.onCheckChanged?.call(rowIndex, val ?? false);
                    },
                  ),
                ),
              ),

            // 🔹 Regular data cells
            ...List.generate(widget.rows[rowIndex].length, (colIndex) {
              final col = widget.columns[colIndex];
              final cellContent = Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 8),
                decoration: const BoxDecoration(),
                child: widget.rows[rowIndex][colIndex],
              );

              if (col.width != null) {
                return SizedBox(width: col.width, child: cellContent);
              }

              return Expanded(flex: col.flex, child: cellContent);
            }),
            SizedBox(width: 15),
          ],
        ),
      );

      final rowDest = widget.getRowDestination?.call(rowIndex);
      if (rowDest != null && rowDest.isNotEmpty) {
        return BrowserAwareLink(
          destination: rowDest,
          onTap: () => widget.onRowTap?.call(rowIndex),
          enableInkWell: false,
          child: childWidget,
        );
      }

      return GestureDetector(
        onTap: () => widget.onRowTap?.call(rowIndex),
        child: childWidget,
      );
    });
  }
}
