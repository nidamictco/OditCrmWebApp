import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'tool_tips.dart';
import 'package:sizer/sizer.dart';

class DropdownWithAdd extends StatefulWidget {
  final bool showIcon;
  final bool showHelp;
  final String label;
  final IconData? icon;
  final List<String> items;
  final String? selectedValue;
  final VoidCallback onTap;
  final Function(String?) onChanged;
  final String message;
  final bool showStar;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool showClear;

  const DropdownWithAdd({
    super.key,
    this.showIcon = false,
    this.showHelp = false,
    required this.label,
    this.icon,
    required this.items,
    required this.onTap,
    required this.selectedValue,
    required this.onChanged,
    this.message = '',
    this.showStar = false,
    this.focusNode,
    this.nextFocusNode,
    this.showClear = true,
  });

  @override
  State<DropdownWithAdd> createState() => _DropdownWithAddState();
}

class _DropdownWithAddState extends State<DropdownWithAdd> {
  late List<String> _localItems;
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _popupSearchFocusNode;

  bool _hasFocus = false;
  bool _popupOpen = false;
  final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

  String get _searchText => _searchController.text;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.items);
    if (widget.selectedValue != null &&
        !_localItems.contains(widget.selectedValue)) {
      _localItems.add(widget.selectedValue!);
    }

    _popupSearchFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        return _handlePopupNavKey(event);
      },
    );

    _searchController.addListener(() {
      final visible = _filteredItems(_searchController.text);
      final newIdx = visible.isEmpty ? -1 : 0;
      if (_highlightedIndexNotifier.value != newIdx) {
        _highlightedIndexNotifier.value = newIdx;
      }
    });
  }

  @override
  void didUpdateWidget(covariant DropdownWithAdd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        _localItems = List.from(widget.items);
        if (widget.selectedValue != null &&
            !_localItems.contains(widget.selectedValue)) {
          _localItems.add(widget.selectedValue!);
        }
      });
    }
  }

  @override
  void dispose() {
    _highlightedIndexNotifier.dispose();
    _popupSearchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> _filteredItems(String filter) => _localItems
      .where(
        (item) =>
            filter.isEmpty || item.toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();

  void _openDropdown() {
    if (_popupOpen) return;
    _searchController.clear();

    final visible = _filteredItems('');
    final preselect = widget.selectedValue != null
        ? visible.indexOf(widget.selectedValue!)
        : -1;

    setState(() => _popupOpen = true);

    _highlightedIndexNotifier.value = preselect >= 0
        ? preselect
        : (visible.isEmpty ? -1 : 0);

    _dropdownKey.currentState?.openDropDownSearch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _popupSearchFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    _dropdownKey.currentState?.closeDropDownSearch();
  }

  void _selectHighlighted() {
    final visible = _filteredItems(_searchText);
    if (_highlightedIndexNotifier.value >= 0 &&
        _highlightedIndexNotifier.value < visible.length) {
      final selected = visible[_highlightedIndexNotifier.value];
      _closeDropdown();
      widget.onChanged(selected);
      if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      }
    }
  }

  // ── Key handlers ───────────────────────────────────────────────────────────
  KeyEventResult _handleOuterKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (!_popupOpen) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _openDropdown();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        final shift = HardwareKeyboard.instance.isShiftPressed;
        if (shift) {
          node.previousFocus();
        } else if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        } else {
          node.nextFocus();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return _handlePopupNavKey(event);
  }

  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final visible = _filteredItems(_searchText);
    final count = visible.length;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value - 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _selectHighlighted();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _closeDropdown();
      final shift = HardwareKeyboard.instance.isShiftPressed;
      if (shift) {
        widget.focusNode?.previousFocus();
      } else if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      } else {
        widget.focusNode?.nextFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        Row(
          children: [
            if (widget.showIcon && widget.icon != null) ...[
              Icon(widget.icon, size: 16, color: AppColors.green),
              SizedBox(width: 1.w),
            ],
            Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
            if (widget.showStar)
              Text(
                '*',
                style: AppTextStyle.medium(
                  size: 11.sp,
                  weight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            if (widget.showHelp) ToolTipWidget(message: widget.message),
          ],
        ),

        SizedBox(height: 0.5.h),

        // ── Field ─────────────────────────────────────────────────────────────
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          onKeyEvent: _handleOuterKeyEvent,
          child: Container(
            height: 5.5.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasFocus ? AppColors.primary : AppColors.divider,
                width: _hasFocus ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
              color: AppColors.greyCard,
            ),
            child: Row(
              children: [
                // ── Add button ──────────────────────────────────────────────
                GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: 3.4.w,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),

                // ── Dropdown ────────────────────────────────────────────────
                // X button is now a Row sibling — zero overlap with DropdownSearch
                Expanded(
                  child: DropdownSearch<String>(
                    key: _dropdownKey,
                    items: (filter, _) => _filteredItems(filter),
                    selectedItem: widget.selectedValue,
                    itemAsString: (item) => item,

                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          widget.label,
                          style: AppTextStyle.small(
                            size: 11.sp,
                            color: AppColors.grey,
                          ),
                        );
                      }
                      return Text(
                        selectedItem,
                        style: AppTextStyle.medium(
                          size: 11.sp,
                          weight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },

                    // suffixProps: DropdownSuffixProps(
                    //   dropdownButtonProps: DropdownButtonProps(
                    //     iconClosed: widget.selectedValue != null
                    //         ? const SizedBox.shrink()
                    //         : Padding(
                    //             padding: EdgeInsets.only(right: 1.w),
                    //             child: const Icon(Icons.keyboard_arrow_down),
                    //           ),
                    //     iconOpened: widget.selectedValue != null
                    //         ? const SizedBox.shrink()
                    //         : Padding(
                    //             padding: EdgeInsets.only(right: 1.w),
                    //             child: const Icon(Icons.keyboard_arrow_up),
                    //           ),
                    //   ),
                    // ),
                    suffixProps: DropdownSuffixProps(
                      dropdownButtonProps: DropdownButtonProps(
                        constraints:
                            (widget.showClear && widget.selectedValue != null)
                            ? const BoxConstraints.tightFor(width: 0, height: 0)
                            : const BoxConstraints(),
                        splashColor:
                            (widget.showClear && widget.selectedValue != null)
                            ? Colors.transparent
                            : null,
                        highlightColor:
                            (widget.showClear && widget.selectedValue != null)
                            ? Colors.transparent
                            : null,
                        hoverColor:
                            (widget.showClear && widget.selectedValue != null)
                            ? Colors.transparent
                            : null,

                        // ✅ FIXED — show arrow only when clear button is NOT shown
                        iconClosed:
                            (widget.showClear && widget.selectedValue != null)
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: EdgeInsets.only(right: 1.w),
                                child: const Icon(Icons.keyboard_arrow_down),
                              ),
                        iconOpened:
                            (widget.showClear && widget.selectedValue != null)
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: EdgeInsets.only(right: 1.w),
                                child: const Icon(Icons.keyboard_arrow_up),
                              ),
                      ),
                    ),

                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                      fit: FlexFit.loose,

                      onDismissed: () {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _popupOpen = false);
                          _highlightedIndexNotifier.value = -1;
                          _searchController.clear();
                        });
                      },

                      itemBuilder: (context, item, isDisabled, isSelected) {
                        final visible = _filteredItems(_searchText);
                        final currentIndex = visible.indexOf(item);
                        return ValueListenableBuilder<int>(
                          valueListenable: _highlightedIndexNotifier,
                          builder: (_, highlightedIndex, __) {
                            return _DropdownWithAddItem(
                              item: item,
                              isSelected: isSelected,
                              isKeyboardHighlighted:
                                  currentIndex == highlightedIndex,
                            );
                          },
                        );
                      },

                      menuProps: MenuProps(
                        elevation: 4,
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        barrierColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),

                      searchFieldProps: TextFieldProps(
                        focusNode: _popupSearchFocusNode,
                        controller: _searchController,
                        style: AppTextStyle.small(
                          size: 11.sp,
                          color: AppColors.black,
                        ),
                        cursorHeight: 10.sp,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: AppTextStyle.small(
                            size: 11.sp,
                            color: AppColors.grey,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          visualDensity: VisualDensity.comfortable,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),

                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 1.h,
                        ),
                      ),
                    ),

                    onSelected: (value) {
                      if (!mounted) return;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _popupOpen = false);
                        _highlightedIndexNotifier.value = -1;
                        _searchController.clear();
                        widget.onChanged(value);
                        if (widget.nextFocusNode != null) {
                          widget.nextFocusNode!.requestFocus();
                        }
                      });
                    },
                  ),
                ),

                // ── Clear button — Row sibling, NO overlap with DropdownSearch
                if (widget.selectedValue != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onChanged(null),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.8.w),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DropdownWithAddItem
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownWithAddItem extends StatefulWidget {
  final String item;
  final bool isSelected;
  final bool isKeyboardHighlighted;

  const _DropdownWithAddItem({
    required this.item,
    required this.isSelected,
    this.isKeyboardHighlighted = false,
  });

  @override
  State<_DropdownWithAddItem> createState() => _DropdownWithAddItemState();
}

class _DropdownWithAddItemState extends State<_DropdownWithAddItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    if (widget.isSelected) {
      bgColor = const Color(0xff4A5D9E);
    } else if (widget.isKeyboardHighlighted || _isHovered) {
      bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
    } else {
      bgColor = Colors.white;
    }

    return Listener(
      onPointerHover: (_) {
        if (!_isHovered) setState(() => _isHovered = true);
      },
      child: MouseRegion(
        onExit: (_) {
          if (_isHovered) setState(() => _isHovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
          alignment: Alignment.centerLeft,
          color: bgColor,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item,
                  style: AppTextStyle.medium(
                    size: 11.sp,
                    weight: FontWeight.w400,
                    color: widget.isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(Icons.check, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
