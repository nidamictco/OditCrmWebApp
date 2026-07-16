import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'tool_tips.dart';

/// A reusable multi-select dropdown that visually matches the existing
/// single-select `Dropdown` widget (same height / colors / borders /
/// typography / spacing), but allows selecting multiple values via
/// checkboxes, with an in-panel search box, "Select All" / "Clear All"
/// actions, and removable chips for each selected value.
///
/// Single source of truth: `widget.selectedValues`. The checkbox state,
/// the chips, and the closed-field summary are all derived directly from
/// this same list — there is no separate boolean/checkbox state anywhere.
///
/// This widget is intentionally separate from `Dropdown` so existing
/// single-select usages elsewhere in the app are untouched.
class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool showHelp;
  final String? message;
  final bool showClear;
  final bool enabled;
  final String? Function(List<String>)? validator;
  final bool showChips;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.showHelp = false,
    this.message,
    this.showClear = true,
    this.enabled = true,
    this.validator,
    this.showChips = true,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _errorText;

  // Keeps the search text alive across rebuilds triggered by selection
  // changes, so typing isn't lost when a checkbox is tapped.
  final TextEditingController _searchController = TextEditingController();

  // The overlay's own setState — lets us rebuild just the popup (checkbox
  // list + chips inside it) when selection changes, without rebuilding
  // the whole screen. Always driven by widget.selectedValues.
  StateSetter? _overlaySetState;
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-sync when the parent's value actually differs from ours —
    // e.g. an external "Reset Filters" tap — so we don't clobber an
    // in-flight local update with a stale prop from the same frame.
    if (!listEquals(oldWidget.selectedValues, widget.selectedValues) &&
        !listEquals(_selected, widget.selectedValues)) {
      _selected = List<String>.from(widget.selectedValues);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _removeOverlay();
    if (widget.validator != null) {
      setState(() => _errorText = widget.validator!(_selected));
    } else if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _removeOverlay() {
    _overlaySetState = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen && mounted) setState(() => _isOpen = false);
  }

  /// Single mutation point for selection changes. Always reads/writes
  /// widget.selectedValues — no local copy is kept anywhere.
  void _setSelection(List<String> updated) {
    setState(() => _selected = updated); // instant local rebuild
    _overlaySetState?.call(() {}); // instant popup rebuild
    widget.onChanged(updated); // tell parent (async rebuild, fine)
  }

  void _toggleItem(String item) {
    final current = List<String>.from(_selected);
    if (current.contains(item)) {
      current.remove(item);
    } else {
      current.add(item);
    }
    _setSelection(current);
  }

  void _removeItem(String item) {
    if (!_selected.contains(item)) return;
    final updated = List<String>.from(_selected)..remove(item);
    _setSelection(updated);
  }

  void _clearAll() {
    _setSelection(const []);
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.transparent)),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    color: Colors.transparent,
                    child: StatefulBuilder(
                      builder: (context, setPanelState) {
                        // Register the overlay's setState so selection
                        // changes made anywhere (checkbox, chip-X, Clear
                        // All, Select All) can refresh this popup too.
                        _overlaySetState = setPanelState;

                        final searchQuery = _searchController.text;
                        final filteredItems = widget.items
                            .where(
                              (item) => item.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                        // void selectAll() {
                        //   final current = List<String>.from(
                        //     widget.selectedValues,
                        //   );
                        //   for (final item in filteredItems) {
                        //     if (!current.contains(item)) current.add(item);
                        //   }
                        //   _setSelection(current);
                        // }
                        void selectAll() {
                          final current = List<String>.from(
                            _selected,
                          ); // ⬅ was widget.selectedValues
                          for (final item in filteredItems) {
                            if (!current.contains(item)) current.add(item);
                          }
                          _setSelection(current);
                        }

                        return Container(
                          width: size.width,
                          constraints: BoxConstraints(maxHeight: 42.h),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(1.5.w),
                                child: TextField(
                                  controller: _searchController,
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.black,
                                  ),
                                  cursorHeight: 10.sp,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Search...',
                                    hintStyle: AppTextStyle.small(
                                      size: 11.sp,
                                      color: AppColors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    visualDensity: VisualDensity.comfortable,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onChanged: (_) => setPanelState(() {}),
                                ),
                              ),

                              // // ── Selected chips (inside the popup, always
                              // // in sync with widget.selectedValues) ────────
                              // if (widget.selectedValues.isNotEmpty)
                              //   Padding(
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 2.w,
                              //       vertical: 0.6.h,
                              //     ),
                              //     child: Wrap(
                              //       spacing: 1.5.w,
                              //       runSpacing: 0.8.h,
                              //       children: widget.selectedValues.map((
                              //         value,
                              //       ) {
                              //         return _SelectedChip(
                              //           label: value,
                              //           onRemove: () => _removeItem(value),
                              //         );
                              //       }).toList(),
                              //     ),
                              //   ),
                              Divider(height: 1, color: AppColors.divider),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.6.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: selectAll,
                                      child: Text(
                                        'Select All',
                                        style: AppTextStyle.small(
                                          size: 10.5.sp,
                                          color: AppColors.primary,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_selected.length} selected',
                                      style: AppTextStyle.small(
                                        size: 10.sp,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _selected.isEmpty
                                          ? null
                                          : _clearAll,
                                      child: Text(
                                        'Clear All',
                                        style: AppTextStyle.small(
                                          size: 10.5.sp,
                                          color: AppColors.red,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: AppColors.divider),
                              Flexible(
                                child: filteredItems.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(2.h),
                                        child: Text(
                                          'No items found',
                                          style: AppTextStyle.small(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        // Preserves scroll position across
                                        // rebuilds triggered by selection.
                                        key: const PageStorageKey(
                                          'multi_select_list',
                                        ),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: filteredItems.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredItems[index];
                                          // Single source of truth: derive
                                          // checked state directly from
                                          // widget.selectedValues every
                                          // build — no separate boolean.
                                          // final isChecked = widget
                                          //     .selectedValues
                                          //     .contains(item);
                                          final isChecked = _selected.contains(
                                            item,
                                          );
                                          const highlightColor = Color(
                                            0xff4A5D9E,
                                          );
                                          return Container(
                                            color: isChecked
                                                ? highlightColor
                                                : Colors.white,
                                            child: InkWell(
                                              onTap: () => _toggleItem(item),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 1.w,
                                                  vertical: 1.h,
                                                ),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: Checkbox(
                                                        value: isChecked,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        activeColor:
                                                            Colors.white,
                                                        checkColor:
                                                            highlightColor,
                                                        side: isChecked
                                                            ? const BorderSide(
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : BorderSide(
                                                                color: AppColors
                                                                    .divider,
                                                              ),
                                                        onChanged: (_) =>
                                                            _toggleItem(item),
                                                      ),
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Expanded(
                                                      child: Text(
                                                        item,
                                                        style:
                                                            AppTextStyle.medium(
                                                              size: 11.sp,
                                                              weight: FontWeight
                                                                  .w400,
                                                              color: isChecked
                                                                  ? Colors.white
                                                                  : Colors
                                                                        .black87,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
            if (widget.showHelp && widget.message != null)
              ToolTipWidget(message: widget.message!),
          ],
        ),
        SizedBox(height: 0.5.h),
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            key: _fieldKey,
            onTap: _toggleDropdown,
            child: Container(
              // constraints: BoxConstraints(minHeight: 5.5.h),
              height: 5.5.h,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.4.h),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppColors.greyCard
                    : AppColors.background,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: _errorText != null
                      ? AppColors.red
                      : (_isOpen ? AppColors.primary : AppColors.divider),
                  width: _isOpen ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _selected.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              widget.hint,
                              style: AppTextStyle.small(
                                size: 11.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : widget.showChips
                            ? ClipRect(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      for (
                                        int i = 0;
                                        i < _selected.length;
                                        i++
                                      ) ...[
                                        if (i != 0) SizedBox(width: 1.w),
                                        _SelectedChip(
                                          label: _selected[i],
                                          onRemove: () => _removeItem(_selected[i]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  _selected.join(', '),
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.black,
                                    weight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                  ),
                  if (widget.showClear && _selected.isNotEmpty)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.only(right: 1.w),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.grey,
                        onPressed: _clearAll,
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(right: 1.w),
                      child: Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 0.3.h),
            child: Text(
              _errorText!,
              style: AppTextStyle.small(size: 9.5.sp, color: AppColors.red),
            ),
          ),
      ],
    );
  }
}

/// A small removable chip used both in the closed field and inside the
/// open popup to display a selected value. Purely presentational — all
/// mutation goes back through the parent's single `selectedValues` list
/// via [onRemove].
class _SelectedChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 2.w,
        right: 1.w,
        top: 0.3.h,
        bottom: 0.3.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff4A5D9E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 30.w),
            child: Text(
              label,
              style: AppTextStyle.medium(
                size: 10.sp,
                weight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
