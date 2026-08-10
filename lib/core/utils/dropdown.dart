import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'tool_tips.dart';
import 'package:sizer/sizer.dart';

class Dropdown extends StatefulWidget {
  final String label;
  final String hint;
  final bool showHelp;
  final bool showIcon;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final bool enabled;
  final String message;
  final bool showStar;

  final bool showClear;

  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const Dropdown({
    super.key,
    required this.label,
    required this.hint,
    this.showIcon = false,
    this.showHelp = false,
    this.items = const [],
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.message = '',
    this.showStar = false,
    this.icon = Icons.person_2_outlined,
    this.focusNode,
    this.nextFocusNode,
    this.showClear = true,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  List<String> _localItems = [];
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();

  // Search-field controller lets us read current search text at any time.
  final TextEditingController _searchController = TextEditingController();

  // FIX: onKeyEvent is attached directly to the FocusNode, NOT via
  // TextFieldProps (which doesn't have that parameter in dropdown_search).
  late final FocusNode _popupSearchFocusNode;

  bool _hasFocus = false;
  bool _popupOpen = false;
  // int _highlightedIndex = -1;
  final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _searchText => _searchController.text;

  List<String> _filteredItems(String filter) => _localItems
      .where(
        (item) =>
            filter.isEmpty || item.toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();

  BoxDecoration _box() => BoxDecoration(
    border: Border.all(
      color: _hasFocus ? AppColors.primary : AppColors.divider,
      width: _hasFocus ? 1.5 : 1.0,
    ),
    borderRadius: BorderRadius.circular(8),
    // color: AppColors.greyCard,
  );

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.items);

    // Attach key handler directly to the FocusNode — this is the supported
    // API and works regardless of what TextFieldProps exposes.
    _popupSearchFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        return _handlePopupNavKey(event);
      },
    );

    _searchController.addListener(() {
      // When search text changes, reset highlight to first visible item.
      final visible = _filteredItems(_searchController.text);
      final newIdx = visible.isEmpty ? -1 : 0;
      // if (_highlightedIndex != newIdx) {
      //   setState(() => _highlightedIndex = newIdx);
      // }
      if (_highlightedIndexNotifier.value != newIdx) {
        _highlightedIndexNotifier.value = newIdx;
      }
    });
  }

  @override
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      setState(() => _localItems = List.from(widget.items));
    }
  }

  @override
  void dispose() {
    _highlightedIndexNotifier.dispose();
    _popupSearchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Popup open / close ──────────────────────────────────────────────────────
  void _openDropdown() {
    if (_popupOpen) return;
    _searchController.clear();

    final visible = _filteredItems('');
    final preselect = widget.selectedValue != null
        ? visible.indexOf(widget.selectedValue!)
        : -1;

    // setState(() {
    //   _popupOpen = true;
    //   _highlightedIndex = preselect >= 0 ? preselect : (visible.isEmpty ? -1 : 0);
    // });

    setState(() {
      _popupOpen = true;
    });

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
    // if (_highlightedIndex >= 0 && _highlightedIndex < visible.length) {
    //   final selected = visible[_highlightedIndex];
    if (_highlightedIndexNotifier.value >= 0 &&
        _highlightedIndexNotifier.value < visible.length) {
      final selected = visible[_highlightedIndexNotifier.value];
      _closeDropdown();
      widget.onChanged?.call(selected);
      if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      }
    }
  }

  // ── Key handlers ────────────────────────────────────────────────────────────
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

  /// Handles ArrowDown/Up/Enter/Escape/Tab when the popup is open.
  /// Called from both the outer Focus fallback and _popupSearchFocusNode.
  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final visible = _filteredItems(_searchText);
    final count = visible.length;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        // setState(() {
        // _highlightedIndex = (_highlightedIndex + 1).clamp(0, count - 1);
        // });
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        // setState(() {
        //   _highlightedIndex = (_highlightedIndex - 1).clamp(0, count - 1);
        // });
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

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ─────────────────────────────────────────────────────────────
        Row(
          children: [
            if (widget.showIcon)
              Icon(widget.icon, size: 13, color: AppColors.green),
            Text(widget.label, style: AppTextStyle.medium(size: 12)),
            if (widget.showStar)
              Text(
                '*',
                style: AppTextStyle.medium(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            if (widget.showHelp) ToolTipWidget(message: widget.message),
          ],
        ),

        SizedBox(height: 3),

        // ── Focusable container ────────────────────────────────────────────────
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          onKeyEvent: _handleOuterKeyEvent,
          child: Container(
            height: 35,
            decoration: _box(),
            child: Row(
              children: [
                Expanded(
                  child: DropdownSearch<String>(
                    key: _dropdownKey,
                    enabled: widget.enabled,
                    items: (filter, _) => _filteredItems(filter),
                    selectedItem: widget.selectedValue,
                    itemAsString: (item) => item,

                    // dropdownBuilder: (context, selectedItem) {
                    //   if (selectedItem == null) {
                    //     return Text(
                    //       widget.hint,
                    //       style: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
                    //     );
                    //   }
                    //   return Text(
                    //     selectedItem,
                    //     style: AppTextStyle.medium(
                    //       size: 11.sp,
                    //       weight: FontWeight.w400,
                    //       color: AppColors.black,
                    //     ),
                    //     overflow: TextOverflow.ellipsis,
                    //   );
                    // },
                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.5.w,
                            vertical: 0.5.h,
                          ),
                          child: Text(
                            widget.hint,
                            style: AppTextStyle.small(
                              size: 11.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        );
                      }
                      return Row(
                        children: [
                          // if (widget.showClear)
                          //   GestureDetector(
                          //     onTap: () => widget.onChanged?.call(null),
                          //     child: Container(
                          //       child: Padding(
                          //         padding: EdgeInsets.only(right: 1.w),
                          //         child: Icon(
                          //           Icons.close,
                          //           size: 16,
                          //           color: AppColors.grey,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.5.w,
                                vertical: 0.5.h,
                              ),
                              child: Text(
                                selectedItem,
                                style: AppTextStyle.medium(
                                  size: 11.sp,
                                  weight: FontWeight.w400,
                                  color: AppColors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      );
                    },

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
                            : const Icon(
                                Icons.keyboard_arrow_down,
                                size: 12.5,
                                weight: 12.5,
                              ),
                        iconOpened:
                            (widget.showClear && widget.selectedValue != null)
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.keyboard_arrow_up,
                                size: 12.5,
                                weight: 12.5,
                              ),
                      ),
                    ),

                    popupProps: PopupProps.menu(
                      scrollbarProps: ScrollbarProps(
                        thumbVisibility: true,
                        thickness: 10,
                        trackVisibility: true,
                        thumbColor: AppColors.grey,
                        interactive: true,
                      ),
                      showSearchBox: true,
                      showSelectedItems: true,
                      fit: FlexFit.loose,
                      constraints: const BoxConstraints(maxHeight: 150),

                      onDismissed: () {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _popupOpen = false;
                            // _highlightedIndex = -1;
                          });
                          _highlightedIndexNotifier.value = -1;
                          _searchController.clear();
                        });
                      },

                      // itemBuilder: (context, item, isDisabled, isSelected) {
                      //   final visible = _filteredItems(_searchText);
                      //   final currentIndex = visible.indexOf(item);
                      //   final isKeyboardHighlighted = currentIndex == _highlightedIndex;
                      //   return _DropdownItem(
                      //     item: item,
                      //     isSelected: isSelected || item == widget.selectedValue,
                      //     isKeyboardHighlighted: isKeyboardHighlighted,
                      //   );
                      // },
                      itemBuilder: (context, item, isDisabled, isSelected) {
                        final visible = _filteredItems(_searchText);
                        final currentIndex = visible.indexOf(item);

                        return ValueListenableBuilder<int>(
                          valueListenable: _highlightedIndexNotifier,
                          builder: (_, highlightedIndex, __) {
                            return _DropdownItem(
                              item: item,
                              isSelected:
                                  isSelected || item == widget.selectedValue,
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
                        positionCallback: (RenderBox buttonBox, RenderBox overlayBox) {
                          final buttonOffset = overlayBox.globalToLocal(
                            buttonBox.localToGlobal(Offset.zero),
                          );
                          final buttonSize = buttonBox.size;
                          final overlaySize = overlayBox.size;
                          // Must match the maxHeight in constraints above.
                          const maxMenuHeight = 150.0;

                          final spaceBelow =
                              overlaySize.height -
                              (buttonOffset.dy + buttonSize.height);
                          final spaceAbove = buttonOffset.dy;

                          final bool showBelow =
                              spaceBelow >= maxMenuHeight ||
                              spaceBelow >= spaceAbove;

                          final left = buttonOffset.dx;
                          final right =
                              overlaySize.width -
                              (buttonOffset.dx + buttonSize.width);

                          if (showBelow) {
                            // Menu top = bottom edge of the button.
                            final double top =
                                buttonOffset.dy + buttonSize.height;
                            return RelativeRect.fromLTRB(left, top, right, 0);
                          } else {
                            // Menu must sit ABOVE the button, flush against its top edge.
                            // The actual rendered height is capped at min(spaceAbove, maxMenuHeight).
                            // Setting top = buttonOffset.dy - actualMenuHeight pins the
                            // menu's bottom edge exactly to the button's top edge, regardless
                            // of how many items are in the list.
                            final double actualMenuHeight =
                                spaceAbove < maxMenuHeight
                                ? spaceAbove
                                : maxMenuHeight;
                            final double top =
                                buttonOffset.dy - actualMenuHeight;
                            return RelativeRect.fromLTRB(left, top, right, 0);
                          }
                        },
                      ),

                      // Search tracking is done via the controller's addListener.
                      searchFieldProps: TextFieldProps(
                        selectAllOnFocus: true,
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
                      expands: true,
                      isHovering: true,
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
                        setState(() {
                          _popupOpen = false;
                          // _highlightedIndex = -1;
                        });
                        _highlightedIndexNotifier.value = -1;
                        _searchController.clear();
                        widget.onChanged?.call(value);
                        if (widget.nextFocusNode != null) {
                          widget.nextFocusNode!.requestFocus();
                        }
                      });
                    },
                  ),
                ),
                if (widget.selectedValue != null && widget.showClear == true)
                  Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.only(right: 1.w),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, size: 12.5, weight: 12),
                        onPressed: () => widget.onChanged?.call(null),
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
// _DropdownItem
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownItem extends StatefulWidget {
  final String item;
  final bool isSelected;
  final bool isKeyboardHighlighted;

  const _DropdownItem({
    required this.item,
    required this.isSelected,
    this.isKeyboardHighlighted = false,
  });

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
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
