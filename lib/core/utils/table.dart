import 'package:flutter/material.dart';
import '../theme/app_text_style.dart';
import '../router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';
import 'table_checkbox.dart';

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
  final ScrollController _hScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkedStates = widget.initialCheckedStates != null
        ? List<bool>.from(widget.initialCheckedStates!)
        : List<bool>.filled(widget.rows.length, false);
  }

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
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

  /// Find the index of the "Name" column (case-insensitive).
  /// Returns -1 if not found.
  int get _nameColumnIndex {
    for (int i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].title.toLowerCase() == 'name') return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    Widget tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
      tableContent = Scrollbar(
        controller: _hScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _hScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: widget.minWidth, child: tableContent),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: tableContent,
      ),
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader() {
    final bool hasPriority = widget.priorityColors != null;
    final int nameColIdx = _nameColumnIndex;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.only(top: 1.8.h, bottom: 1.8.h, right: 20, left: 10),
      child: Row(
        children: [
          // Regular column headers
          ...List.generate(widget.columns.length, (index) {
            final col = widget.columns[index];
            final bool isSelectAll = col.title.toLowerCase() == 'select all';
            final bool isNameCol = index == nameColIdx;

            Widget cellChild;

            if (isSelectAll) {
              // "Select All" header — right-aligned with rounded checkbox
              cellChild = Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    col.title,
                    style: AppTextStyle.medium(
                      weight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 8),
                  buildRoundedCheckbox(
                    value: _isAllSelected == true,
                    onTap: _toggleSelectAll,
                  ),
                ],
              );
            } else if (isNameCol && hasPriority) {
              // "Name" header with priority dot icon hint
              cellChild = Row(
                children: [
                  const Icon(
                    Icons.radio_button_unchecked,
                    size: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    col.title,
                    style: AppTextStyle.medium(
                      weight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              );
            } else {
              // Normal header
              cellChild = Text(
                col.title,
                style: AppTextStyle.medium(
                  weight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              );
            }

            if (col.width != null) {
              return SizedBox(width: col.width, child: cellChild);
            }

            return Expanded(flex: col.flex, child: cellChild);
          }),
        ],
      ),
    );
  }

  /// ROWS
  List<Widget> _buildRows() {
    final int nameColIdx = _nameColumnIndex;

    return List.generate(widget.rows.length, (rowIndex) {
      final dotColor =
          (widget.priorityColors != null &&
              rowIndex < widget.priorityColors!.length)
          ? widget.priorityColors![rowIndex]
          : Colors.transparent;
      final bool hasDot = dotColor != Colors.transparent;

      final childWidget = Container(
        padding: EdgeInsets.only(top: 1.h, bottom: 1.h, left: 1.w, right: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            // 🔹 Regular data cells
            ...List.generate(widget.rows[rowIndex].length, (colIndex) {
              final col = widget.columns[colIndex];
              final bool isNameCol = colIndex == nameColIdx;
              final bool isLastCol =
                  colIndex == widget.rows[rowIndex].length - 1;

              Widget cellChild;

              if (isNameCol && hasDot) {
                // Name cell with priority dot before the content
                cellChild = Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: widget.rows[rowIndex][colIndex]),
                  ],
                );
              } else if (isLastCol &&
                  widget.showCheckboxes &&
                  col.title.toLowerCase() == 'select all') {
                // Last column ("Select All") — append checkbox at the end
                cellChild = Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.rows[rowIndex][colIndex],
                    const SizedBox(width: 12),
                    buildRoundedCheckbox(
                      value: _checkedStates[rowIndex],
                      onTap: () {
                        setState(
                          () => _checkedStates[rowIndex] =
                              !_checkedStates[rowIndex],
                        );
                        widget.onCheckChanged?.call(
                          rowIndex,
                          _checkedStates[rowIndex],
                        );
                      },
                    ),
                  ],
                );
              } else {
                cellChild = widget.rows[rowIndex][colIndex];
              }

              final cellContent = Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(right: 10),
                // color: Colors.yellow,
                child: cellChild,
              );

              if (col.width != null) {
                return SizedBox(width: col.width, child: cellContent);
              }

              return Expanded(flex: col.flex, child: cellContent);
            }),
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
