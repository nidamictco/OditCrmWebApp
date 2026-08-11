import 'package:flutter/material.dart';
import '../theme/app_text_style.dart';
import '../router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';
import 'table_checkbox.dart';

class TableColumn {
  final String title;

  const TableColumn({required this.title});
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

  // ── Cached column widths ──────────────────────────────────
  List<double> _columnWidths = [];

  // ── Column sizing constants ───────────────────────────────
  static const double _kMinColWidth = 50.0;
  static const double _kMaxColWidth = 400.0;
  static const double _kCellPadding = 24.0;
  static const double _kDateCellPadding =
      44.0; // Extra breathing room for date/time columns
  static const double _kFallbackWidth =
      36.0; // Fallback for unknown action/custom widgets
  static const double _kPriorityDotExtra = 22.0; // 8 dot + 8 spacing + 6 icon
  static const double _kCheckboxExtraWidth = 30.0; // checkbox(18) + spacing(12)
  static const double _kOuterHorizontalPadding = 16.0;

  // Header text style (matches the header builder)
  static final TextStyle _headerStyle = AppTextStyle.medium(
    weight: FontWeight.w600,
    fontSize: 11.5,
    color: const Color(0xFF475569),
  );

  @override
  void initState() {
    super.initState();
    _checkedStates = widget.initialCheckedStates != null
        ? List<bool>.from(widget.initialCheckedStates!)
        : List<bool>.filled(widget.rows.length, false);
    _columnWidths = _computeColumnWidths();
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

    // 🔹 Recompute widths only when columns or rows change
    if (!_columnsEqual(oldWidget.columns, widget.columns) ||
        oldWidget.rows.length != widget.rows.length ||
        !identical(oldWidget.rows, widget.rows)) {
      _columnWidths = _computeColumnWidths();
    }
  }

  bool _columnsEqual(List<TableColumn> a, List<TableColumn> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].title != b[i].title) return false;
    }
    return true;
  }

  // ════════════════════════════════════════════════════════════
  // COLUMN WIDTH COMPUTATION
  // ════════════════════════════════════════════════════════════

  List<double> _computeColumnWidths() {
    final int colCount = widget.columns.length;
    if (colCount == 0) return [];

    final bool hasPriority = widget.priorityColors != null;
    final int nameColIdx = _nameColumnIndex;

    final List<double> widths = List<double>.filled(colCount, 0.0);

    for (int col = 0; col < colCount; col++) {
      final column = widget.columns[col];
      final String titleLower = column.title.toLowerCase();
      final bool isSelectAll = titleLower == 'select all';
      final bool isNameCol = col == nameColIdx;
      final bool isDateCol =
          titleLower.contains('date') ||
          titleLower.contains('time') ||
          titleLower.contains('followup') ||
          titleLower.contains('called');

      // ── Measure header text ────────────────────────────────
      double headerWidth = _measureTextWidth(column.title, _headerStyle);

      // Account for extra header elements
      if (isSelectAll) {
        // "Select All" text + 8 spacing + checkbox(18)
        headerWidth += 8 + 18;
      } else if (isNameCol && hasPriority) {
        // priority icon(12) + 6 spacing
        headerWidth += 12 + 6;
      }

      double maxCellWidth = headerWidth;

      // ── Measure each row's cell ────────────────────────────
      for (int row = 0; row < widget.rows.length; row++) {
        if (col >= widget.rows[row].length) continue;

        double cellWidth = _measureWidget(widget.rows[row][col]);

        // Account for priority dot in name column
        if (isNameCol && hasPriority) {
          cellWidth += _kPriorityDotExtra;
        }

        // Account for checkbox in select-all column
        if (isSelectAll && widget.showCheckboxes) {
          cellWidth += _kCheckboxExtraWidth;
        }

        if (cellWidth > maxCellWidth) {
          maxCellWidth = cellWidth;
        }
      }

      // Add padding and clamp (use extra padding for date/time columns, minimum 120 for select-all)
      final double padding = isDateCol ? _kDateCellPadding : _kCellPadding;
      final double minColW = isSelectAll ? 120.0 : _kMinColWidth;
      widths[col] = (maxCellWidth + padding).clamp(minColW, _kMaxColWidth);
    }

    return widths;
  }

  /// Recursively measure the approximate intrinsic width of a widget.
  double _measureWidget(Widget widget) {
    if (widget is Text) {
      final String text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      final TextStyle style =
          widget.style ?? AppTextStyle.medium(fontSize: 11.5);
      return _measureTextWidth(text, style);
    }

    if (widget is Row) {
      double total = 0;
      for (final child in widget.children) {
        if (child is Expanded || child is Flexible) {
          // Measure the inner child of Expanded/Flexible
          final innerChild = child is Expanded
              ? child.child
              : (child as Flexible).child;
          total += _measureWidget(innerChild);
        } else if (child is SizedBox) {
          total +=
              child.width ?? _measureWidget(child.child ?? const SizedBox());
        } else {
          total += _measureWidget(child);
        }
      }
      // Account for mainAxisAlignment spacing (approximate)
      if (widget.children.length > 1) {
        total += (widget.children.length - 1) * 4;
      }
      return total;
    }

    if (widget is Icon) {
      return (widget.size ?? 24.0);
    }

    if (widget is IconButton) {
      return (widget.iconSize ?? 24.0) + 16; // icon + padding
    }

    if (widget is SizedBox) {
      if (widget.width != null) return widget.width!;
      if (widget.child != null) return _measureWidget(widget.child!);
      return 0;
    }

    if (widget is Container) {
      if (widget.constraints?.maxWidth != null &&
          widget.constraints!.maxWidth != double.infinity) {
        return widget.constraints!.maxWidth;
      }
      // Check for explicit width through BoxConstraints
      final padding = widget.padding;
      double extra = 0;
      if (padding is EdgeInsets) {
        extra = padding.left + padding.right;
      } else if (padding is EdgeInsetsDirectional) {
        extra = padding.start + padding.end;
      }
      if (widget.child != null) {
        return _measureWidget(widget.child!) + extra;
      }
      // Fixed-size container (e.g. dot indicator)
      if (widget.constraints?.maxWidth != null) {
        return widget.constraints!.maxWidth + extra;
      }
      return _kFallbackWidth;
    }

    if (widget is Padding) {
      double extra = 0;
      final p = widget.padding;
      if (p is EdgeInsets) {
        extra = p.left + p.right;
      } else if (p is EdgeInsetsDirectional) {
        extra = p.start + p.end;
      }
      return (widget.child != null ? _measureWidget(widget.child!) : 0) + extra;
    }

    if (widget is GestureDetector) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is InkWell) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is MouseRegion) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is Tooltip) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is Center) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is Align) {
      return widget.child != null
          ? _measureWidget(widget.child!)
          : _kFallbackWidth;
    }

    if (widget is Expanded) {
      return _measureWidget(widget.child);
    }

    if (widget is Flexible) {
      return _measureWidget(widget.child);
    }

    if (widget is BrowserAwareLink) {
      return _measureWidget(widget.child);
    }

    if (widget is CircleAvatar) {
      return (widget.radius ?? 20) * 2;
    }

    if (widget is AnimatedContainer) {
      return _kFallbackWidth;
    }

    if (widget is CircularProgressIndicator) {
      return 24;
    }

    // Fallback for any unknown widget
    return _kFallbackWidth;
  }

  /// Measure the rendered pixel width of [text] using [style] via TextPainter.
  double _measureTextWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  // ════════════════════════════════════════════════════════════
  // CHECKBOX / SELECT-ALL LOGIC (unchanged)
  // ════════════════════════════════════════════════════════════

  /// 🔹 true = all checked, false = none, null = some (indeterminate)
  bool? get _isAllSelected {
    if (_checkedStates.isEmpty) return false;
    if (_checkedStates.every((e) => e)) return true;
    if (_checkedStates.every((e) => !e)) return false;
    return null; // indeterminate
  }

  /// 🔹 If all selected → deselect all, otherwise → select all
  void _toggleSelectAll() {
    if (widget.rows.isEmpty) return;
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

  /// Calculates display column widths. If available width exceeds computed content width,
  /// extra space is distributed across flexible content columns proportionally, while keeping
  /// fixed columns (serial numbers & action/select-all columns) at their compact measured sizes.
  List<double> _getDisplayColumnWidths(double availableWidth) {
    if (_columnWidths.isEmpty) return [];

    // Account for outer horizontal padding (32px) and 2px border width (1px left + 1px right)
    final double outerPadding = _kOuterHorizontalPadding * 2 + 2.0;
    final double contentAvailableWidth = availableWidth - outerPadding;

    final double totalContentWidth = _columnWidths.fold(
      0.0,
      (sum, w) => sum + w,
    );

    if (contentAvailableWidth > totalContentWidth && totalContentWidth > 0) {
      final double extraSpace = contentAvailableWidth - totalContentWidth;

      // Identify fixed columns (serial numbers & action/select-all columns) vs flexible data columns
      final List<bool> isFixed = List<bool>.generate(widget.columns.length, (
        i,
      ) {
        final title = widget.columns[i].title.toLowerCase().trim();
        final isSerial =
            title == 'no.' ||
            title == 'sl no.' ||
            title == 'sl.no.' ||
            title == 'sl. no.' ||
            title == '#' ||
            title == 'sl';
        final isAction =
            title == 'select all' || title == 'action' || title == 'actions';
        return isSerial || isAction;
      });

      // Sum the measured width of all flexible columns
      double totalFlexWidth = 0.0;
      for (int i = 0; i < _columnWidths.length; i++) {
        if (!isFixed[i]) {
          totalFlexWidth += _columnWidths[i];
        }
      }

      final List<double> result = List<double>.filled(
        _columnWidths.length,
        0.0,
      );
      double allocated = 0.0;

      if (totalFlexWidth > 0) {
        // Distribute extraSpace across flexible columns proportionally to their measured widths
        int lastFlexIndex = -1;
        for (int i = 0; i < _columnWidths.length; i++) {
          if (isFixed[i]) {
            result[i] = _columnWidths[i];
          } else {
            final double portion =
                (_columnWidths[i] / totalFlexWidth) * extraSpace;
            result[i] = (_columnWidths[i] + portion).floorToDouble();
            lastFlexIndex = i;
          }
          allocated += result[i];
        }

        // Adjust remaining rounding pixels onto the last flexible column
        final double remaining = contentAvailableWidth - allocated;
        if (remaining != 0) {
          final int targetIdx = lastFlexIndex != -1
              ? lastFlexIndex
              : _columnWidths.length - 1;
          result[targetIdx] = (result[targetIdx] + remaining).clamp(
            _kMinColWidth,
            double.infinity,
          );
        }
      } else {
        // Fallback if all columns are marked fixed: scale across all columns except the last
        final double scale = contentAvailableWidth / totalContentWidth;
        for (int i = 0; i < _columnWidths.length - 1; i++) {
          final double w = (_columnWidths[i] * scale).floorToDouble();
          result[i] = w;
          allocated += w;
        }
        result[_columnWidths.length - 1] = (contentAvailableWidth - allocated)
            .clamp(_kMinColWidth, double.infinity);
      }

      return result;
    }

    return List<double>.from(_columnWidths);
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double parentWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Account for Container's 1px left + 1px right border (2px total border offset)
        final double innerParentWidth = (parentWidth - 2.0).clamp(0.0, double.infinity);

        final double totalComputedWidth = _columnWidths.fold(
          _kOuterHorizontalPadding * 2 + 2.0,
          (sum, w) => sum + w,
        );

        final bool contentExceedsParent =
            totalComputedWidth > innerParentWidth + 0.5;

        final List<double> displayWidths = contentExceedsParent
            ? List<double>.from(_columnWidths)
            : _getDisplayColumnWidths(parentWidth);

        final double totalTableWidth = displayWidths.fold(
          _kOuterHorizontalPadding * 2 + 2.0,
          (sum, w) => sum + w,
        );

        final double effectiveWidth =
            (contentExceedsParent &&
                widget.minWidth != null &&
                widget.minWidth! > totalTableWidth)
            ? widget.minWidth!
            : totalTableWidth;

        Widget tableContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(displayWidths),
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
              ..._buildRows(displayWidths),
          ],
        );

        final bool needsScroll =
            contentExceedsParent || effectiveWidth > innerParentWidth + 0.5;

        if (needsScroll) {
          tableContent = Scrollbar(
            controller: _hScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _hScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: effectiveWidth, child: tableContent),
            ),
          );
        } else {
          tableContent = SizedBox(width: innerParentWidth, child: tableContent);
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: tableContent,
          ),
        );
      },
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader(List<double> columnWidths) {
    final bool hasPriority = widget.priorityColors != null;
    final int nameColIdx = _nameColumnIndex;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _kOuterHorizontalPadding,
        vertical: 14,
      ),
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
                  Flexible(
                    child: Text(
                      col.title,
                      style: _headerStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  buildRoundedCheckbox(
                    value: _isAllSelected == true,
                    onTap: () {
                      if (widget.rows.isEmpty) return;
                      _toggleSelectAll();
                    },
                  ),
                ],
              );
            } else if (isNameCol && hasPriority) {
              // "Name" header with priority dot icon hint
              cellChild = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        col.title,
                        style: _headerStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Normal header
              cellChild = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  col.title,
                  style: _headerStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }

            final double colWidth = index < columnWidths.length
                ? columnWidths[index]
                : _kFallbackWidth;

            return SizedBox(
              width: colWidth,
              child: Align(
                alignment: isSelectAll
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cellChild,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ROWS
  List<Widget> _buildRows(List<double> columnWidths) {
    final int nameColIdx = _nameColumnIndex;

    return List.generate(widget.rows.length, (rowIndex) {
      final dotColor =
          (widget.priorityColors != null &&
              rowIndex < widget.priorityColors!.length)
          ? widget.priorityColors![rowIndex]
          : Colors.transparent;
      final bool hasDot = dotColor != Colors.transparent;

      final childWidget = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _kOuterHorizontalPadding,
          vertical: 10,
        ),
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
                cellChild = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
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
                  ),
                );
              } else if (isLastCol &&
                  widget.showCheckboxes &&
                  col.title.toLowerCase() == 'select all') {
                // Last column ("Select All") — append checkbox at the end
                cellChild = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: widget.rows[rowIndex][colIndex],
                      ),
                    ),
                    const SizedBox(width: 10),
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
                cellChild = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: widget.rows[rowIndex][colIndex],
                );
              }

              final double colWidth = colIndex < columnWidths.length
                  ? columnWidths[colIndex]
                  : _kFallbackWidth;

              return SizedBox(
                width: colWidth,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: cellChild,
                  ),
                ),
              );
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
