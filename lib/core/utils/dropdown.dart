// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_style.dart';
// import 'tool_tips.dart';
// import 'package:sizer/sizer.dart';

// class Dropdown extends StatefulWidget {
//   final String label;
//   final String hint;
//   final bool showHelp;
//   final bool showIcon;
//   final IconData icon;
//   final List<String> items;
//   final String? selectedValue;
//   final Function(String?)? onChanged;
//   final bool enabled;
//   final String message;
//   final bool showStar;

//   final bool showClear;

//   final FocusNode? focusNode;
//   final FocusNode? nextFocusNode;

//   const Dropdown({
//     super.key,
//     required this.label,
//     required this.hint,
//     this.showIcon = false,
//     this.showHelp = false,
//     this.items = const [],
//     this.selectedValue,
//     this.onChanged,
//     this.enabled = true,
//     this.message = '',
//     this.showStar = false,
//     this.icon = Icons.person_2_outlined,
//     this.focusNode,
//     this.nextFocusNode,
//     this.showClear = true,
//   });

//   @override
//   State<Dropdown> createState() => _DropdownState();
// }

// class _DropdownState extends State<Dropdown> {
//   List<String> _localItems = [];
//   final _dropdownKey = GlobalKey<DropdownSearchState<String>>();

//   // Search-field controller lets us read current search text at any time.
//   final TextEditingController _searchController = TextEditingController();

//   // FIX: onKeyEvent is attached directly to the FocusNode, NOT via
//   // TextFieldProps (which doesn't have that parameter in dropdown_search).
//   late final FocusNode _popupSearchFocusNode;

//   bool _hasFocus = false;
//   bool _popupOpen = false;
//   // int _highlightedIndex = -1;
//   final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

//   // ── Helpers ─────────────────────────────────────────────────────────────────
//   String get _searchText => _searchController.text;

//   List<String> _filteredItems(String filter) => _localItems
//       .where(
//         (item) =>
//             filter.isEmpty || item.toLowerCase().contains(filter.toLowerCase()),
//       )
//       .toList();

//   BoxDecoration _box() => BoxDecoration(
//     border: Border.all(
//       color: _hasFocus ? AppColors.primary : AppColors.divider,
//       width: _hasFocus ? 1.5 : 1.0,
//     ),
//     borderRadius: BorderRadius.circular(8),
//     // color: AppColors.greyCard,
//   );

//   // ── Lifecycle ───────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _localItems = List.from(widget.items);

//     // Attach key handler directly to the FocusNode — this is the supported
//     // API and works regardless of what TextFieldProps exposes.
//     _popupSearchFocusNode = FocusNode(
//       onKeyEvent: (node, event) {
//         if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
//           return KeyEventResult.ignored;
//         }
//         return _handlePopupNavKey(event);
//       },
//     );

//     _searchController.addListener(() {
//       // When search text changes, reset highlight to first visible item.
//       final visible = _filteredItems(_searchController.text);
//       final newIdx = visible.isEmpty ? -1 : 0;
//       // if (_highlightedIndex != newIdx) {
//       //   setState(() => _highlightedIndex = newIdx);
//       // }
//       if (_highlightedIndexNotifier.value != newIdx) {
//         _highlightedIndexNotifier.value = newIdx;
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(covariant Dropdown oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!listEquals(oldWidget.items, widget.items)) {
//       setState(() => _localItems = List.from(widget.items));
//     }
//   }

//   @override
//   void dispose() {
//     _highlightedIndexNotifier.dispose();
//     _popupSearchFocusNode.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ── Popup open / close ──────────────────────────────────────────────────────
//   void _openDropdown() {
//     if (_popupOpen) return;
//     _searchController.clear();

//     final visible = _filteredItems('');
//     final preselect = widget.selectedValue != null
//         ? visible.indexOf(widget.selectedValue!)
//         : -1;

//     // setState(() {
//     //   _popupOpen = true;
//     //   _highlightedIndex = preselect >= 0 ? preselect : (visible.isEmpty ? -1 : 0);
//     // });

//     setState(() {
//       _popupOpen = true;
//     });

//     _highlightedIndexNotifier.value = preselect >= 0
//         ? preselect
//         : (visible.isEmpty ? -1 : 0);

//     _dropdownKey.currentState?.openDropDownSearch();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _popupSearchFocusNode.requestFocus();
//     });
//   }

//   void _closeDropdown() {
//     _dropdownKey.currentState?.closeDropDownSearch();
//   }

//   void _selectHighlighted() {
//     final visible = _filteredItems(_searchText);
//     // if (_highlightedIndex >= 0 && _highlightedIndex < visible.length) {
//     //   final selected = visible[_highlightedIndex];
//     if (_highlightedIndexNotifier.value >= 0 &&
//         _highlightedIndexNotifier.value < visible.length) {
//       final selected = visible[_highlightedIndexNotifier.value];
//       _closeDropdown();
//       widget.onChanged?.call(selected);
//       if (widget.nextFocusNode != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) widget.nextFocusNode!.requestFocus();
//         });
//       }
//     }
//   }

//   // ── Key handlers ────────────────────────────────────────────────────────────
//   KeyEventResult _handleOuterKeyEvent(FocusNode node, KeyEvent event) {
//     if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
//       return KeyEventResult.ignored;
//     }

//     if (!_popupOpen) {
//       if (event.logicalKey == LogicalKeyboardKey.space ||
//           event.logicalKey == LogicalKeyboardKey.enter ||
//           event.logicalKey == LogicalKeyboardKey.arrowDown) {
//         _openDropdown();
//         return KeyEventResult.handled;
//       }
//       if (event.logicalKey == LogicalKeyboardKey.tab) {
//         final shift = HardwareKeyboard.instance.isShiftPressed;
//         if (shift) {
//           node.previousFocus();
//         } else if (widget.nextFocusNode != null) {
//           widget.nextFocusNode!.requestFocus();
//         } else {
//           node.nextFocus();
//         }
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     return _handlePopupNavKey(event);
//   }

//   /// Handles ArrowDown/Up/Enter/Escape/Tab when the popup is open.
//   /// Called from both the outer Focus fallback and _popupSearchFocusNode.
//   KeyEventResult _handlePopupNavKey(KeyEvent event) {
//     final visible = _filteredItems(_searchText);
//     final count = visible.length;

//     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (count > 0) {
//         // setState(() {
//         // _highlightedIndex = (_highlightedIndex + 1).clamp(0, count - 1);
//         // });
//         _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1)
//             .clamp(0, count - 1);
//       }
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (count > 0) {
//         // setState(() {
//         //   _highlightedIndex = (_highlightedIndex - 1).clamp(0, count - 1);
//         // });
//         _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value - 1)
//             .clamp(0, count - 1);
//       }
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.enter) {
//       _selectHighlighted();
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.escape) {
//       _closeDropdown();
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.tab) {
//       _closeDropdown();
//       final shift = HardwareKeyboard.instance.isShiftPressed;
//       if (shift) {
//         widget.focusNode?.previousFocus();
//       } else if (widget.nextFocusNode != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) widget.nextFocusNode!.requestFocus();
//         });
//       } else {
//         widget.focusNode?.nextFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   // ── Build ───────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Label ─────────────────────────────────────────────────────────────
//         Row(
//           children: [
//             if (widget.showIcon)
//               Icon(widget.icon, size: 13, color: AppColors.green),
//             Text(widget.label, style: AppTextStyle.medium(size: 12)),
//             if (widget.showStar)
//               Text(
//                 '*',
//                 style: AppTextStyle.medium(
//                   size: 11,
//                   weight: FontWeight.w600,
//                   color: AppColors.red,
//                 ),
//               ),
//             if (widget.showHelp) ToolTipWidget(message: widget.message),
//           ],
//         ),

//         SizedBox(height: 3),

//         // ── Focusable container ────────────────────────────────────────────────
//         Focus(
//           focusNode: widget.focusNode,
//           onFocusChange: (focused) => setState(() => _hasFocus = focused),
//           onKeyEvent: _handleOuterKeyEvent,
//           child: Container(
//             height: 35,
//             decoration: _box(),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: DropdownSearch<String>(
//                     key: _dropdownKey,
//                     enabled: widget.enabled,
//                     items: (filter, _) => _filteredItems(filter),
//                     selectedItem: widget.selectedValue,
//                     itemAsString: (item) => item,

//                     // dropdownBuilder: (context, selectedItem) {
//                     //   if (selectedItem == null) {
//                     //     return Text(
//                     //       widget.hint,
//                     //       style: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
//                     //     );
//                     //   }
//                     //   return Text(
//                     //     selectedItem,
//                     //     style: AppTextStyle.medium(
//                     //       size: 11.sp,
//                     //       weight: FontWeight.w400,
//                     //       color: AppColors.black,
//                     //     ),
//                     //     overflow: TextOverflow.ellipsis,
//                     //   );
//                     // },
//                     dropdownBuilder: (context, selectedItem) {
//                       if (selectedItem == null) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 0.5.w,
//                             vertical: 0.5.h,
//                           ),
//                           child: Text(
//                             widget.hint,
//                             style: AppTextStyle.small(
//                               size: 11.sp,
//                               color: AppColors.grey,
//                             ),
//                           ),
//                         );
//                       }
//                       return Row(
//                         children: [
//                           // if (widget.showClear)
//                           //   GestureDetector(
//                           //     onTap: () => widget.onChanged?.call(null),
//                           //     child: Container(
//                           //       child: Padding(
//                           //         padding: EdgeInsets.only(right: 1.w),
//                           //         child: Icon(
//                           //           Icons.close,
//                           //           size: 16,
//                           //           color: AppColors.grey,
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   ),
//                           Expanded(
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 0.5.w,
//                                 vertical: 0.5.h,
//                               ),
//                               child: Text(
//                                 selectedItem,
//                                 style: AppTextStyle.medium(
//                                   size: 11.sp,
//                                   weight: FontWeight.w400,
//                                   color: AppColors.black,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },

//                     suffixProps: DropdownSuffixProps(
//                       dropdownButtonProps: DropdownButtonProps(
//                         constraints:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? const BoxConstraints.tightFor(width: 0, height: 0)
//                             : const BoxConstraints(),
//                         splashColor:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? Colors.transparent
//                             : null,
//                         highlightColor:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? Colors.transparent
//                             : null,
//                         hoverColor:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? Colors.transparent
//                             : null,

//                         // ✅ FIXED — show arrow only when clear button is NOT shown
//                         iconClosed:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? const SizedBox.shrink()
//                             : const Icon(
//                                 Icons.keyboard_arrow_down,
//                                 size: 12.5,
//                                 weight: 12.5,
//                               ),
//                         iconOpened:
//                             (widget.showClear && widget.selectedValue != null)
//                             ? const SizedBox.shrink()
//                             : const Icon(
//                                 Icons.keyboard_arrow_up,
//                                 size: 12.5,
//                                 weight: 12.5,
//                               ),
//                       ),
//                     ),

//                     popupProps: PopupProps.menu(
//                       scrollbarProps: ScrollbarProps(
//                         thumbVisibility: true,
//                         thickness: 10,
//                         trackVisibility: true,
//                         thumbColor: AppColors.grey,
//                         interactive: true,
//                       ),
//                       showSearchBox: true,
//                       showSelectedItems: true,
//                       fit: FlexFit.loose,
//                       constraints: const BoxConstraints(maxHeight: 150),

//                       onDismissed: () {
//                         if (!mounted) return;
//                         WidgetsBinding.instance.addPostFrameCallback((_) {
//                           if (!mounted) return;
//                           setState(() {
//                             _popupOpen = false;
//                             // _highlightedIndex = -1;
//                           });
//                           _highlightedIndexNotifier.value = -1;
//                           _searchController.clear();
//                         });
//                       },

//                       // itemBuilder: (context, item, isDisabled, isSelected) {
//                       //   final visible = _filteredItems(_searchText);
//                       //   final currentIndex = visible.indexOf(item);
//                       //   final isKeyboardHighlighted = currentIndex == _highlightedIndex;
//                       //   return _DropdownItem(
//                       //     item: item,
//                       //     isSelected: isSelected || item == widget.selectedValue,
//                       //     isKeyboardHighlighted: isKeyboardHighlighted,
//                       //   );
//                       // },
//                       itemBuilder: (context, item, isDisabled, isSelected) {
//                         final visible = _filteredItems(_searchText);
//                         final currentIndex = visible.indexOf(item);

//                         return ValueListenableBuilder<int>(
//                           valueListenable: _highlightedIndexNotifier,
//                           builder: (_, highlightedIndex, __) {
//                             return _DropdownItem(
//                               item: item,
//                               isSelected:
//                                   isSelected || item == widget.selectedValue,
//                               isKeyboardHighlighted:
//                                   currentIndex == highlightedIndex,
//                             );
//                           },
//                         );
//                       },

//                       menuProps: MenuProps(
//                         elevation: 4,
//                         margin: EdgeInsets.zero,
//                         clipBehavior: Clip.antiAlias,
//                         barrierColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         positionCallback: (RenderBox buttonBox, RenderBox overlayBox) {
//                           final buttonOffset = overlayBox.globalToLocal(
//                             buttonBox.localToGlobal(Offset.zero),
//                           );
//                           final buttonSize = buttonBox.size;
//                           final overlaySize = overlayBox.size;
//                           // Must match the maxHeight in constraints above.
//                           const maxMenuHeight = 150.0;

//                           final spaceBelow =
//                               overlaySize.height -
//                               (buttonOffset.dy + buttonSize.height);
//                           final spaceAbove = buttonOffset.dy;

//                           final bool showBelow =
//                               spaceBelow >= maxMenuHeight ||
//                               spaceBelow >= spaceAbove;

//                           final left = buttonOffset.dx;
//                           final right =
//                               overlaySize.width -
//                               (buttonOffset.dx + buttonSize.width);

//                           if (showBelow) {
//                             // Menu top = bottom edge of the button.
//                             final double top =
//                                 buttonOffset.dy + buttonSize.height;
//                             return RelativeRect.fromLTRB(left, top, right, 0);
//                           } else {
//                             // Menu must sit ABOVE the button, flush against its top edge.
//                             // The actual rendered height is capped at min(spaceAbove, maxMenuHeight).
//                             // Setting top = buttonOffset.dy - actualMenuHeight pins the
//                             // menu's bottom edge exactly to the button's top edge, regardless
//                             // of how many items are in the list.
//                             final double actualMenuHeight =
//                                 spaceAbove < maxMenuHeight
//                                 ? spaceAbove
//                                 : maxMenuHeight;
//                             final double top =
//                                 buttonOffset.dy - actualMenuHeight;
//                             return RelativeRect.fromLTRB(left, top, right, 0);
//                           }
//                         },
//                       ),

//                       // Search tracking is done via the controller's addListener.
//                       searchFieldProps: TextFieldProps(
//                         selectAllOnFocus: true,
//                         focusNode: _popupSearchFocusNode,
//                         controller: _searchController,
//                         style: AppTextStyle.small(
//                           size: 11.sp,
//                           color: AppColors.black,
//                         ),
//                         cursorHeight: 10.sp,
//                         decoration: InputDecoration(
//                           hintText: 'Search...',
//                           hintStyle: AppTextStyle.small(
//                             size: 11.sp,
//                             color: AppColors.grey,
//                           ),
//                           isDense: true,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 10,
//                           ),
//                           visualDensity: VisualDensity.comfortable,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                     ),

//                     decoratorProps: DropDownDecoratorProps(
//                       expands: true,
//                       isHovering: true,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 1.w,
//                           vertical: 1.h,
//                         ),
//                       ),
//                     ),

//                     onSelected: (value) {
//                       if (!mounted) return;
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (!mounted) return;
//                         setState(() {
//                           _popupOpen = false;
//                           // _highlightedIndex = -1;
//                         });
//                         _highlightedIndexNotifier.value = -1;
//                         _searchController.clear();
//                         widget.onChanged?.call(value);
//                         if (widget.nextFocusNode != null) {
//                           widget.nextFocusNode!.requestFocus();
//                         }
//                       });
//                     },
//                   ),
//                 ),
//                 if (widget.selectedValue != null && widget.showClear == true)
//                   Padding(
//                     padding: EdgeInsets.only(right: 1.w),
//                     child: SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: IconButton(
//                         padding: EdgeInsets.only(right: 1.w),
//                         constraints: const BoxConstraints(),
//                         icon: const Icon(Icons.close, size: 12.5, weight: 12),
//                         onPressed: () => widget.onChanged?.call(null),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // _DropdownItem
// // ─────────────────────────────────────────────────────────────────────────────
// class _DropdownItem extends StatefulWidget {
//   final String item;
//   final bool isSelected;
//   final bool isKeyboardHighlighted;

//   const _DropdownItem({
//     required this.item,
//     required this.isSelected,
//     this.isKeyboardHighlighted = false,
//   });

//   @override
//   State<_DropdownItem> createState() => _DropdownItemState();
// }

// class _DropdownItemState extends State<_DropdownItem> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final Color bgColor;
//     if (widget.isSelected) {
//       bgColor = const Color(0xff4A5D9E);
//     } else if (widget.isKeyboardHighlighted || _isHovered) {
//       bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
//     } else {
//       bgColor = Colors.white;
//     }

//     return Listener(
//       onPointerHover: (_) {
//         if (!_isHovered) setState(() => _isHovered = true);
//       },
//       child: MouseRegion(
//         onExit: (_) {
//           if (_isHovered) setState(() => _isHovered = false);
//         },
//         cursor: SystemMouseCursors.click,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
//           alignment: Alignment.centerLeft,
//           color: bgColor,
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   widget.item,
//                   style: AppTextStyle.medium(
//                     size: 11.sp,
//                     weight: FontWeight.w400,
//                     color: widget.isSelected ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ),
//               if (widget.isSelected)
//                 const Icon(Icons.check, size: 16, color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'tool_tips.dart';

/// Reusable dropdown field.
///
/// Implementation notes:
/// Positioning, keyboard-nav and the popup itself are built directly on
/// Flutter's own `LayerLink` / `CompositedTransformFollower` / `OverlayEntry`
/// primitives instead of a third-party dropdown package. This keeps 100%
/// control over the exact visual output (border, height, padding, typography,
/// icons, clear button, item highlight) while giving reliable above/below
/// auto-positioning that works inside any scrollable ancestor, dialog, or
/// bottom sheet — with no clipping and no dependency-version risk.
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

/// Popup max height — kept as a top-level constant so both the field and the
/// position-calculation logic reference the exact same number.
const double _kMaxMenuHeight = 150.0;
const double _kItemExtent = 34.0;
const double _kScreenEdgePadding = 8.0;
const double _kEmptyStateHeight = 48.0;

/// Decides where the popup opens (above/below the field) and how tall/wide
/// it may be, given the field's position and the room around it.
///
/// Kept as its own value type — independent of the field's State — so the
/// positioning rule is a single, pure, reusable calculation: below is used
/// whenever it fits the popup's natural height; otherwise above is used if
/// it fits; if neither side fits the full list, whichever side has more
/// room wins and the popup's height is capped to that room (the list
/// becomes scrollable instead of overflowing into whatever sits beyond it).
class _DropdownPopupGeometry {
  final bool showBelow;
  final double menuHeightCap;
  final double safeWidth;

  const _DropdownPopupGeometry({
    required this.showBelow,
    required this.menuHeightCap,
    required this.safeWidth,
  });

  factory _DropdownPopupGeometry.compute({
    required Offset fieldOffset,
    required Size fieldSize,
    required Size overlaySize,
    required double bottomInset,
    required int itemCount,
  }) {
    final spaceBelow =
        overlaySize.height -
        fieldOffset.dy -
        fieldSize.height -
        bottomInset -
        _kScreenEdgePadding;
    final spaceAbove = fieldOffset.dy - _kScreenEdgePadding;

    // The popup's natural (unclamped-by-available-space) height for the
    // current item count — used only to decide which side to prefer, not
    // as the height that gets rendered.
    final rawHeight = itemCount == 0
        ? _kEmptyStateHeight
        : itemCount * _kItemExtent;
    final naturalHeight = rawHeight.clamp(0.0, _kMaxMenuHeight);

    final fitsBelow = spaceBelow >= naturalHeight;
    final fitsAbove = spaceAbove >= naturalHeight;

    final bool showBelow;
    if (fitsBelow) {
      showBelow = true;
    } else if (fitsAbove) {
      showBelow = false;
    } else {
      // Neither side fits the full list — open on whichever side has more
      // room and let the menu cap its own height to that room.
      showBelow = spaceBelow >= spaceAbove;
    }

    final availableSpace = showBelow ? spaceBelow : spaceAbove;
    // Ceiling passed down to the menu, not a forced height — the menu
    // still sizes itself to its actual content up to this cap, and this
    // cap guarantees it never overflows past the field's opposite edge or
    // the screen bounds.
    final menuHeightCap = availableSpace.clamp(0.0, _kMaxMenuHeight);

    // Defensive clamp: never let the popup claim more width than the field
    // actually has, and never let it run past the right edge of the visible
    // overlay region — protects against a field whose measured RenderBox is
    // wider than its visible bordered box (e.g. an un-Expanded Row child).
    final safeWidth = fieldSize.width.clamp(
      0.0,
      overlaySize.width - fieldOffset.dx - _kScreenEdgePadding,
    );

    return _DropdownPopupGeometry(
      showBelow: showBelow,
      menuHeightCap: menuHeightCap,
      safeWidth: safeWidth,
    );
  }
}

class _DropdownState extends State<Dropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  late final FocusNode _popupFocusNode;

  late final _DropdownMenuController _menuController;

  bool _hasFocus = false;
  bool _isOpen = false;

  // ── Helpers ─────────────────────────────────────────────────────────────
  BoxDecoration _box() => BoxDecoration(
    border: Border.all(
      color: _hasFocus ? AppThemeColors.primary : AppColors.divider,
      width: _hasFocus ? 1.5 : 1.0,
    ),
    borderRadius: BorderRadius.circular(8),
  );

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    // Receives keyboard focus while the popup is open so arrow/enter/escape/
    // tab keep working now that there's no search field to host them.
    _popupFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        return _handlePopupNavKey(event);
      },
    );
    _menuController = _DropdownMenuController(items: List.from(widget.items));
    _focusNode.addListener(_handleOuterFocusChange);
  }

  @override
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      _menuController.updateItems(List.from(widget.items));
    }
  }

  void _handleOuterFocusChange() {
    if (!mounted) return;
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _closeDropdown(refocusField: false);
    _focusNode.removeListener(_handleOuterFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    _popupFocusNode.dispose();
    _menuController.dispose();
    super.dispose();
  }

  // ── Popup open / close ──────────────────────────────────────────────────
  void _openDropdown() {
    if (!widget.enabled || _isOpen) return;

    _menuController.reset(List.from(widget.items));
    final items = _menuController.items;
    final preselect = widget.selectedValue != null
        ? items.indexOf(widget.selectedValue!)
        : -1;
    _menuController.setHighlighted(
      preselect >= 0 ? preselect : (items.isEmpty ? -1 : 0),
    );

    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _popupFocusNode.requestFocus();
    });
  }

  void _closeDropdown({bool refocusField = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!_isOpen) return;
    if (mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }
    _menuController.reset(List.from(widget.items));
    if (refocusField && mounted) {
      _focusNode.requestFocus();
    }
  }

  void _selectHighlighted() {
    final items = _menuController.items;
    final idx = _menuController.highlightedIndex;
    if (idx < 0 || idx >= items.length) return;
    final selected = items[idx];
    _closeDropdown(refocusField: widget.nextFocusNode == null);
    widget.onChanged?.call(selected);
    if (widget.nextFocusNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.nextFocusNode!.requestFocus();
      });
    }
  }

  // ── Overlay construction & positioning ───────────────────────────────────
  OverlayEntry _buildOverlayEntry() {
    final overlayState = Overlay.of(context);
    // Measure against the Overlay's own RenderBox — the exact region the
    // popup is inserted into — instead of MediaQuery's raw device screen
    // size. This is the fix for popups mis-judging available space (and
    // overrunning into sibling content) whenever the field lives inside
    // anything shorter than the full screen: a Dialog, BottomSheet, split
    // panel, or a fixed-height card. MediaQuery.size.height is the whole
    // phone screen regardless of where in the tree you are; the Overlay's
    // RenderBox is the actual paintable bounds this popup will occupy.
    final overlayBox = overlayState.context.findRenderObject() as RenderBox;
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final fieldSize = renderBox.size;
    final fieldOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final overlaySize = overlayBox.size;

    // Keyboard + safe-area aware: don't treat space the keyboard or a
    // system inset is about to cover as "available".
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom > 0
        ? mq.viewInsets.bottom
        : mq.padding.bottom;

    // Recomputed fresh on every open — the field may have moved (scroll,
    // keyboard, rotation) since it was last shown, so the side it opens on
    // is decided dynamically each time rather than cached.
    final geometry = _DropdownPopupGeometry.compute(
      fieldOffset: fieldOffset,
      fieldSize: fieldSize,
      overlaySize: overlaySize,
      bottomInset: bottomInset,
      itemCount: widget.items.length,
    );
    final showBelow = geometry.showBelow;
    final menuHeightCap = geometry.menuHeightCap;
    final safeWidth = geometry.safeWidth;

    return OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Transparent barrier: tapping outside the popup closes it,
            // without blocking scroll/tap on the popup itself.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _closeDropdown(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: showBelow
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              followerAnchor: showBelow
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              child: Material(
                color: Colors.transparent,
                child: _DropdownMenu(
                  width: safeWidth,
                  maxHeight: menuHeightCap,
                  controller: _menuController,
                  popupFocusNode: _popupFocusNode,
                  selectedValue: widget.selectedValue,
                  onItemTap: (item) {
                    _closeDropdown(refocusField: widget.nextFocusNode == null);
                    widget.onChanged?.call(item);
                    if (widget.nextFocusNode != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) widget.nextFocusNode!.requestFocus();
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Key handlers ────────────────────────────────────────────────────────
  KeyEventResult _handleOuterKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (!_isOpen) {
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
  /// Called from both the outer Focus fallback and _popupFocusNode.
  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final items = _menuController.items;
    final count = items.length;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        _menuController.setHighlighted(
          (_menuController.highlightedIndex + 1).clamp(0, count - 1),
        );
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        _menuController.setHighlighted(
          (_menuController.highlightedIndex - 1).clamp(0, count - 1),
        );
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
      _closeDropdown(refocusField: false);
      final shift = HardwareKeyboard.instance.isShiftPressed;
      if (shift) {
        _focusNode.previousFocus();
      } else if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      } else {
        _focusNode.nextFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────
        Row(
          children: [
            if (widget.showIcon)
              Icon(widget.icon, size: 13, color: AppColors.green),
            Text(widget.label, style: AppTextStyle.medium(size: 11.5)),
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

        // ── Field ────────────────────────────────────────────────────────
        CompositedTransformTarget(
          link: _layerLink,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _handleOuterKeyEvent,
            child: Container(
              key: _fieldKey,
              height: 35,
              decoration: _box(),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.enabled
                          ? () {
                              _focusNode.requestFocus();
                              if (_isOpen) {
                                _closeDropdown();
                              } else {
                                _openDropdown();
                              }
                            }
                          : null,
                      child: widget.selectedValue == null
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 0.5.h,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.hint,
                                  style: AppTextStyle.small(
                                    size: 11,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 0.5.h,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.selectedValue!,
                                  style: AppTextStyle.medium(
                                    size: 11,
                                    weight: FontWeight.w400,
                                    color: AppColors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (widget.selectedValue != null && widget.showClear)
                    Padding(
                      padding: EdgeInsets.only(right: 1.w),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.only(right: 1.w),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, size: 12.5),
                          onPressed: widget.enabled
                              ? () => widget.onChanged?.call(null)
                              : null,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 12.5,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _DropdownMenuController — single source of truth for the open popup's
// item list and keyboard-highlighted index. A plain ChangeNotifier keeps
// the popup's rebuild scope isolated from the field's own setState calls,
// and from the parent widget tree entirely.
// ─────────────────────────────────────────────────────────────────────────
class _DropdownMenuController extends ChangeNotifier {
  List<String> _items;
  int _highlightedIndex = -1;

  _DropdownMenuController({required List<String> items}) : _items = items;

  List<String> get items => _items;
  int get highlightedIndex => _highlightedIndex;

  void updateItems(List<String> items) {
    _items = items;
    notifyListeners();
  }

  void setHighlighted(int index) {
    _highlightedIndex = index;
    notifyListeners();
  }

  void reset(List<String> items) {
    _items = items;
    _highlightedIndex = -1;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _DropdownMenu — the popup itself: a scrollable, height-capped, rounded,
// shadowed item list. Rebuilds only when _DropdownMenuController notifies,
// independent of the field and the host screen.
// ─────────────────────────────────────────────────────────────────────────
class _DropdownMenu extends StatefulWidget {
  final double width;

  /// Ceiling only — the menu sizes itself to fit its actual item count and
  /// only reaches (and scrolls at) this value once content exceeds it.
  final double maxHeight;
  final _DropdownMenuController controller;
  final FocusNode popupFocusNode;
  final String? selectedValue;
  final ValueChanged<String> onItemTap;

  const _DropdownMenu({
    required this.width,
    required this.maxHeight,
    required this.controller,
    required this.popupFocusNode,
    required this.selectedValue,
    required this.onItemTap,
  });

  @override
  State<_DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<_DropdownMenu> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHighlighted(int index) {
    if (index < 0 || !_scrollController.hasClients) return;
    final target = index * _kItemExtent;
    final viewport = _scrollController.position.viewportDimension;
    final current = _scrollController.offset;
    if (target < current) {
      _scrollController.jumpTo(target);
    } else if (target + _kItemExtent > current + viewport) {
      _scrollController.jumpTo(target + _kItemExtent - viewport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        // Focus target that receives keyboard input while the popup is
        // open, so arrow/enter/escape/tab keep working without a visible
        // search field to host them.
        child: Focus(
          focusNode: widget.popupFocusNode,
          autofocus: true,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              final items = widget.controller.items;
              final highlighted = widget.controller.highlightedIndex;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _scrollToHighlighted(highlighted);
              });

              // Shrink-to-fit: sized to exactly `itemCount * itemExtent`, only
              // clamped (and made scrollable) once that exceeds the space
              // budget. Recomputes on every controller change, so it grows
              // and shrinks live — the enclosing CompositedTransformFollower
              // re-anchors automatically as this size changes, keeping the
              // "open above" case pinned flush to the field at any height.
              final listCap = widget.maxHeight.clamp(0.0, _kMaxMenuHeight);

              if (items.isEmpty) {
                final emptyHeight = _kEmptyStateHeight.clamp(
                  0.0,
                  listCap <= 0 ? _kEmptyStateHeight : listCap,
                );
                return SizedBox(
                  height: emptyHeight,
                  child: Center(
                    child: Text(
                      'No items available',
                      style: AppTextStyle.small(
                        size: 11.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                );
              }

              final naturalHeight = items.length * _kItemExtent;
              final needsScroll = naturalHeight > listCap;
              final listHeight = needsScroll ? listCap : naturalHeight;

              // Lazily built — cheap even at 1000+ items since only
              // on-screen rows are ever instantiated.
              final list = ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemExtent: _kItemExtent,
                itemCount: items.length,
                // No scroll physics at all when everything already fits —
                // avoids a rubber-band/bounce on a list with nowhere to go.
                physics: needsScroll
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DropdownItem(
                    item: item,
                    isSelected: item == widget.selectedValue,
                    isKeyboardHighlighted: index == highlighted,
                    onTap: () => widget.onItemTap(item),
                  );
                },
              );

              return SizedBox(
                height: listHeight,
                child: needsScroll
                    ? Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 6,
                        interactive: true,
                        child: list,
                      )
                    : list,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _DropdownItem — unchanged visual design from the previous implementation.
// ─────────────────────────────────────────────────────────────────────────
class _DropdownItem extends StatefulWidget {
  final String item;
  final bool isSelected;
  final bool isKeyboardHighlighted;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
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

    return MouseRegion(
      onEnter: (_) {
        if (!_isHovered) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isHovered) setState(() => _isHovered = false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
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
