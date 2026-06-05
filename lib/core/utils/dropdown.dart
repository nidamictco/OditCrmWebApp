// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/core/utils/tool_tips.dart';
// import 'package:sizer/sizer.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Dropdown
// //
// // Key fixes vs. previous version:
// //  1. onFocusChange no longer calls _openDropdown() — opening on focus-gain
// //     was causing the popup to re-open immediately after closing (because the
// //     search-box inside the popup returns focus to the container on dismiss).
// //     Instead, Space / Enter / ArrowDown open the popup via the keyboard handler.
// //  2. Arrow-key navigation inside the open popup list now works:
// //     - ArrowDown / ArrowUp move a highlighted index.
// //     - Enter selects the highlighted item.
// //     - Escape closes the popup.
// //  3. Hover highlight on list items works because we use the isHighlighted
// //     flag passed by dropdown_search's itemBuilder instead of a custom
// //     StatefulWidget with MouseRegion (which was blocked by the library's own
// //     InkWell wrapping each item).
// //  4. After selection, focus is moved to nextFocusNode from add_lead.dart,
// //     not from inside the dropdown, preventing double focus-change events.
// // ─────────────────────────────────────────────────────────────────────────────
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
//
//   // Focus-chain support
//   final FocusNode? focusNode;
//   final FocusNode? nextFocusNode;
//
//
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
//   });
//
//   @override
//   State<Dropdown> createState() => _DropdownState();
// }
//
// class _DropdownState extends State<Dropdown> {
//   List<String> _localItems = [];
//   final _dropdownKey = GlobalKey<DropdownSearchState<String>>();
//   final FocusNode _popupFocusNode = FocusNode();
//   bool _hasFocus = false;
//
//   // Keyboard-navigation state for the open popup
//   bool _popupOpen = false;
//   int _highlightedIndex = -1;
//
//   BoxDecoration _box() {
//     return BoxDecoration(
//       border: Border.all(
//         color: _hasFocus ? AppColors.primary : AppColors.divider,
//         width: _hasFocus ? 1.5 : 1.0,
//       ),
//       borderRadius: BorderRadius.circular(3),
//       color: AppColors.greyCard,
//     );
//   }
//
//   @override
//   void dispose() {
//     _popupFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _localItems = List.from(widget.items);
//   }
//
//   @override
//   void didUpdateWidget(covariant Dropdown oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!listEquals(oldWidget.items, widget.items)) {
//       setState(() => _localItems = List.from(widget.items));
//     }
//   }
//
//   // void _openDropdown() {
//   //   if (!_popupOpen) {
//   //     setState(() => _popupOpen = true);
//   //     _dropdownKey.currentState?.openDropDownSearch();
//   //   }
//   // }
//
//   void _openDropdown() {
//     if (!_popupOpen) {
//       setState(() {
//         _popupOpen = true;
//         _highlightedIndex = widget.selectedValue != null
//             ? _localItems.indexOf(widget.selectedValue!)
//             : 0;
//       });
//
//       _dropdownKey.currentState?.openDropDownSearch();
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _popupFocusNode.requestFocus();
//       });
//     }
//   }
//
//   void _closeDropdown() {
//     _dropdownKey.currentState?.closeDropDownSearch();
//   }
//
//   /// Returns the filtered item list (same logic as the items callback).
//   List<String> _filteredItems(String filter) => _localItems
//       .where(
//         (item) =>
//             filter.isEmpty || item.toLowerCase().contains(filter.toLowerCase()),
//       )
//       .toList();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Label ───────────────────────────────────────────────────────────
//         Row(
//           children: [
//             if (widget.showIcon)
//               Icon(widget.icon, size: 12.sp, color: AppColors.green),
//             Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
//             if (widget.showStar)
//               Text(
//                 '*',
//                 style: AppTextStyle.medium(
//                   size: 11.sp,
//                   weight: FontWeight.w600,
//                   color: AppColors.red,
//                 ),
//               ),
//             if (widget.showHelp) ToolTipWidget(message: widget.message),
//           ],
//         ),
//
//         SizedBox(height: 0.5.h),
//
//         // ── Focusable container ──────────────────────────────────────────────
//         Focus(
//           focusNode: widget.focusNode,
//           onFocusChange: (focused) {
//             setState(() => _hasFocus = focused);
//             // Do NOT auto-open here — it re-opens the popup after dismiss.
//           },
//           onKeyEvent: (node, event) {
//             if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
//               return KeyEventResult.ignored;
//             }
//
//             // ── When popup is CLOSED ─────────────────────────────────────
//             if (!_popupOpen) {
//               if (event.logicalKey == LogicalKeyboardKey.space ||
//                   event.logicalKey == LogicalKeyboardKey.enter ||
//                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                 // setState(() => _highlightedIndex = 0);
//                 setState(() {
//                   _highlightedIndex =
//                   widget.selectedValue != null
//                       ? _localItems.indexOf(widget.selectedValue!)
//                       : 0;
//                 });
//                 _openDropdown();
//                 return KeyEventResult.handled;
//               }
//               if (event.logicalKey == LogicalKeyboardKey.tab) {
//                 final shift = HardwareKeyboard.instance.isShiftPressed;
//                 if (shift) {
//                   node.previousFocus();
//                 } else if (widget.nextFocusNode != null) {
//                   widget.nextFocusNode!.requestFocus();
//                 } else {
//                   node.nextFocus();
//                 }
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             }
//
//             // ── When popup is OPEN ───────────────────────────────────────
//             final items = _filteredItems(
//               '',
//             ); // approximate; search filters live inside popup
//             final count = items.length;
//
//             if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//               setState(() {
//                 _highlightedIndex = (_highlightedIndex + 1).clamp(0, count - 1);
//               });
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//               setState(() {
//                 _highlightedIndex = (_highlightedIndex - 1).clamp(0, count - 1);
//               });
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.enter) {
//               if (_highlightedIndex >= 0 && _highlightedIndex < count) {
//                 final selected = items[_highlightedIndex];
//                 _closeDropdown();
//                 widget.onChanged?.call(selected);
//                 if (widget.nextFocusNode != null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     widget.nextFocusNode!.requestFocus();
//                   });
//                 }
//               }
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.escape) {
//               _closeDropdown();
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.tab) {
//               _closeDropdown();
//               final shift = HardwareKeyboard.instance.isShiftPressed;
//               if (shift) {
//                 node.previousFocus();
//               } else if (widget.nextFocusNode != null) {
//                 widget.nextFocusNode!.requestFocus();
//               } else {
//                 node.nextFocus();
//               }
//               return KeyEventResult.handled;
//             }
//
//             return KeyEventResult.ignored;
//           },
//           child: Container(
//             height: 5.5.h,
//             decoration: _box(),
//             child: DropdownSearch<String>(
//               key: _dropdownKey,
//               enabled: widget.enabled,
//               items: (filter, _) => _localItems
//                   .where(
//                     (item) =>
//                         filter.isEmpty ||
//                         item.toLowerCase().contains(filter.toLowerCase()),
//                   )
//                   .toList(),
//               selectedItem: widget.selectedValue,
//               itemAsString: (item) => item,
//
//               // ── Selected-value display ─────────────────────────────────────
//               dropdownBuilder: (context, selectedItem) {
//                 if (selectedItem == null) {
//                   return Text(
//                     widget.hint,
//                     style: AppTextStyle.small(
//                       size: 11.sp,
//                       color: AppColors.grey,
//                     ),
//                   );
//                 }
//                 return Text(
//                   selectedItem,
//                   style: AppTextStyle.medium(
//                     size: 11.sp,
//                     weight: FontWeight.w400,
//                     color: AppColors.black,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 );
//               },
//
//               // ── Arrow icons ────────────────────────────────────────────────
//               suffixProps: DropdownSuffixProps(
//                 dropdownButtonProps: DropdownButtonProps(
//                   iconClosed: Padding(
//                     padding: EdgeInsets.only(right: 1.w),
//                     child: const Icon(Icons.keyboard_arrow_down),
//                   ),
//                   iconOpened: Padding(
//                     padding: EdgeInsets.only(right: 1.w),
//                     child: const Icon(Icons.keyboard_arrow_up),
//                   ),
//                 ),
//               ),
//
//               // ── Popup ──────────────────────────────────────────────────────
//               popupProps: PopupProps.menu(
//                 showSearchBox: true,
//                 showSelectedItems: true,
//                 fit: FlexFit.loose,
//                 constraints: const BoxConstraints(maxHeight: 250),
//
//                 // // FIX: track popup open/close so keyboard handler knows state
//                 // onDismissed: () {
//                 //   setState(() {
//                 //     _popupOpen = false;
//                 //     _highlightedIndex = -1;
//                 //   });
//                 // },
//                 onDismissed: () {
//                   // Guard: don't call setState if widget is being torn down
//                   if (!mounted) return;
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     if (!mounted) return;
//                     setState(() {
//                       _popupOpen = false;
//                       _highlightedIndex = -1;
//                     });
//                   });
//                 },
//
//                 itemBuilder: (context, item, isDisabled, isSelected) {
//                   final currentIndex = _filteredItems('').indexOf(item);
//                   final isKeyboardHighlighted =
//                       currentIndex == _highlightedIndex;
//
//                   return _DropdownItem(
//                     item: item,
//                     isSelected: isSelected || item == widget.selectedValue,
//                     isKeyboardHighlighted: isKeyboardHighlighted,
//                   );
//                 },
//
//                 menuProps: MenuProps(
//                   elevation: 4,
//                   margin: EdgeInsets.zero,
//                   clipBehavior: Clip.antiAlias,
//                   barrierColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   positionCallback:
//                       (RenderBox buttonBox, RenderBox overlayBox) {
//                         final buttonOffset = overlayBox.globalToLocal(
//                           buttonBox.localToGlobal(Offset.zero),
//                         );
//                         final buttonSize = buttonBox.size;
//                         final overlaySize = overlayBox.size;
//                         const maxMenuHeight = 250.0;
//
//                         final spaceBelow =
//                             overlaySize.height -
//                             (buttonOffset.dy + buttonSize.height);
//                         final spaceAbove = buttonOffset.dy;
//
//                         final bool showBelow =
//                             spaceBelow >= maxMenuHeight ||
//                             spaceBelow >= spaceAbove;
//
//                         final left = buttonOffset.dx;
//                         final right =
//                             overlaySize.width -
//                             (buttonOffset.dx + buttonSize.width);
//
//                         if (showBelow) {
//                           final double top =
//                               buttonOffset.dy + buttonSize.height;
//                           return RelativeRect.fromLTRB(left, top, right, 0);
//                         } else {
//                           // Anchor bottom edge to top of button so menu
//                           // grows upward and stays flush regardless of
//                           // how many items are shown.
//                           final double bottom =
//                               overlaySize.height - buttonOffset.dy;
//                           return RelativeRect.fromLTRB(left, 0, right, bottom);
//                         }
//                       },
//                 ),
//
//                 searchFieldProps: TextFieldProps(
//                   focusNode: _popupFocusNode,
//                   onKeyEvent: (node, event) {
//                     if (event is! KeyDownEvent &&
//                         event is! KeyRepeatEvent) {
//                       return KeyEventResult.ignored;
//                     }
//
//                     final count = _localItems.length;
//
//                     if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       setState(() {
//                         _highlightedIndex =
//                             (_highlightedIndex + 1).clamp(0, count - 1);
//                       });
//
//                       return KeyEventResult.handled;
//                     }
//
//                     if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowUp) {
//                       setState(() {
//                         _highlightedIndex =
//                             (_highlightedIndex - 1).clamp(0, count - 1);
//                       });
//
//                       return KeyEventResult.handled;
//                     }
//
//                     if (event.logicalKey ==
//                         LogicalKeyboardKey.enter) {
//                       if (_highlightedIndex >= 0 &&
//                           _highlightedIndex < count) {
//
//                         final selected =
//                         _localItems[_highlightedIndex];
//
//                         _closeDropdown();
//
//                         widget.onChanged?.call(selected);
//                       }
//
//                       return KeyEventResult.handled;
//                     }
//
//                     if (event.logicalKey ==
//                         LogicalKeyboardKey.escape) {
//                       _closeDropdown();
//                       return KeyEventResult.handled;
//                     }
//
//                     return KeyEventResult.ignored;
//                   },
//                   style: AppTextStyle.small(
//                     size: 11.sp,
//                     color: AppColors.black,
//                   ),
//                   cursorHeight: 10.sp,
//                   decoration: InputDecoration(
//                     hintText: 'Search...',
//                     hintStyle: AppTextStyle.small(
//                       size: 11.sp,
//                       color: AppColors.grey,
//                     ),
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 10,
//                     ),
//                     visualDensity: VisualDensity.comfortable,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ── Decorator ─────────────────────────────────────────────────
//               decoratorProps: DropDownDecoratorProps(
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 1.w,
//                     vertical: 1.h,
//                   ),
//                 ),
//               ),
//
//               // // FIX: onSelected drives focus change; popup-open tracking happens
//               // // via the library callbacks below.
//               // onSelected: (value) {
//               //   setState(() {
//               //     _popupOpen = false;
//               //     _highlightedIndex = -1;
//               //   });
//               //   widget.onChanged?.call(value);
//               //   if (widget.nextFocusNode != null) {
//               //     WidgetsBinding.instance.addPostFrameCallback((_) {
//               //       widget.nextFocusNode!.requestFocus();
//               //     });
//               //   }
//               // },
//               onSelected: (value) {
//                 if (!mounted) return;
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (!mounted) return;
//                   setState(() {
//                     _popupOpen = false;
//                     _highlightedIndex = -1;
//                   });
//                   widget.onChanged?.call(value);
//                   if (widget.nextFocusNode != null) {
//                     widget.nextFocusNode!.requestFocus();
//                   }
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // _DropdownItem
// //
// // FIX: combines keyboard-highlight (isKeyboardHighlighted) with mouse-hover.
// // The library's InkWell sits above this widget, so we rely on MouseRegion
// // to detect hover AND accept the isHighlighted flag from the keyboard handler.
// // ─────────────────────────────────────────────────────────────────────────────
// // class _DropdownItem extends StatefulWidget {
// //   final String item;
// //   final bool isSelected;
// //   final bool isKeyboardHighlighted;
//
// //   const _DropdownItem({
// //     required this.item,
// //     required this.isSelected,
// //     this.isKeyboardHighlighted = false,
// //   });
//
// //   @override
// //   State<_DropdownItem> createState() => _DropdownItemState();
// // }
//
// // class _DropdownItemState extends State<_DropdownItem> {
// //   bool _isHovered = false;
//
// //   @override
// //   Widget build(BuildContext context) {
// //     final Color bgColor;
// //     if (widget.isSelected) {
// //       bgColor = const Color(0xff4A5D9E);
// //     } else if (widget.isKeyboardHighlighted || _isHovered) {
// //       bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
// //     } else {
// //       bgColor = Colors.white;
// //     }
//
// //     return MouseRegion(
// //       onEnter: (_) => setState(() => _isHovered = true),
// //       onExit: (_) => setState(() => _isHovered = false),
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
// //         alignment: Alignment.centerLeft,
// //         color: bgColor,
// //         child: Row(
// //           children: [
// //             Expanded(
// //               child: Text(
// //                 widget.item,
// //                 style: AppTextStyle.medium(
// //                   size: 11.sp,
// //                   weight: FontWeight.w400,
// //                   color: widget.isSelected ? Colors.white : Colors.black,
// //                 ),
// //               ),
// //             ),
// //             if (widget.isSelected)
// //               const Icon(Icons.check, size: 16, color: Colors.white),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// class _DropdownItem extends StatefulWidget {
//   final String item;
//   final bool isSelected;
//   final bool isKeyboardHighlighted;
//
//   const _DropdownItem({
//     required this.item,
//     required this.isSelected,
//     this.isKeyboardHighlighted = false,
//   });
//
//   @override
//   State<_DropdownItem> createState() => _DropdownItemState();
// }
//
// class _DropdownItemState extends State<_DropdownItem> {
//   bool _isHovered = false;
//
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
//
//     // Listener fires at the raw pointer level — BEFORE GestureDetector
//     // or InkWell inside dropdown_search gets a chance to absorb the event.
//     // This is why MouseRegion alone doesn't work: the library's InkWell
//     // sits above your widget in hit-test order and consumes PointerHover
//     // events. Listener receives PointerHoverEvent at a lower level.
//     return Listener(
//       onPointerHover: (_) {
//         if (!_isHovered) setState(() => _isHovered = true);
//       },
//       // Also wrap in MouseRegion just for the exit event,
//       // because Listener has no onPointerExit equivalent.
//       child: MouseRegion(
//         onExit: (_) {
//           if (_isHovered) setState(() => _isHovered = false);
//         },
//         // HitTestBehavior.translucent ensures our widget participates
//         // in hit testing even when the library's InkWell is on top.
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

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
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
    borderRadius: BorderRadius.circular(3),
    color: AppColors.greyCard,
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

    _highlightedIndexNotifier.value =
    preselect >= 0
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
    if (_highlightedIndexNotifier.value >= 0 && _highlightedIndexNotifier.value < visible.length) {
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
        _highlightedIndexNotifier.value =
            (_highlightedIndexNotifier.value + 1)
                .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        // setState(() {
        //   _highlightedIndex = (_highlightedIndex - 1).clamp(0, count - 1);
        // });
        _highlightedIndexNotifier.value =
            (_highlightedIndexNotifier.value - 1)
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
              Icon(widget.icon, size: 12.sp, color: AppColors.green),
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

        // ── Focusable container ────────────────────────────────────────────────
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          onKeyEvent: _handleOuterKeyEvent,
          child: Container(
            height: 5.5.h,
            decoration: _box(),
            child: DropdownSearch<String>(
              key: _dropdownKey,
              enabled: widget.enabled,
              items: (filter, _) => _filteredItems(filter),
              selectedItem: widget.selectedValue,
              itemAsString: (item) => item,

              dropdownBuilder: (context, selectedItem) {
                if (selectedItem == null) {
                  return Text(
                    widget.hint,
                    style: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
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

              suffixProps: DropdownSuffixProps(
                dropdownButtonProps: DropdownButtonProps(
                  iconClosed: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  iconOpened: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                ),
              ),

              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                fit: FlexFit.loose,
                constraints: const BoxConstraints(maxHeight: 250),

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
                        isSelected: isSelected || item == widget.selectedValue,
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
                    const maxMenuHeight = 200.0;

                    final spaceBelow =
                        overlaySize.height - (buttonOffset.dy + buttonSize.height);
                    final spaceAbove = buttonOffset.dy;

                    final bool showBelow =
                        spaceBelow >= maxMenuHeight || spaceBelow >= spaceAbove;

                    final left = buttonOffset.dx;
                    final right =
                        overlaySize.width - (buttonOffset.dx + buttonSize.width);

                    if (showBelow) {
                      // Menu top = bottom edge of the button.
                      final double top = buttonOffset.dy + buttonSize.height;
                      return RelativeRect.fromLTRB(left, top, right, 0);
                    } else {
                      // Menu must sit ABOVE the button, flush against its top edge.
                      // The actual rendered height is capped at min(spaceAbove, maxMenuHeight).
                      // Setting top = buttonOffset.dy - actualMenuHeight pins the
                      // menu's bottom edge exactly to the button's top edge, regardless
                      // of how many items are in the list.
                      final double actualMenuHeight =
                      spaceAbove < maxMenuHeight ? spaceAbove : maxMenuHeight;
                      final double top = buttonOffset.dy - actualMenuHeight;
                      return RelativeRect.fromLTRB(left, top, right, 0);
                    }
                  },
                ),

                // Search tracking is done via the controller's addListener.
                searchFieldProps: TextFieldProps(selectAllOnFocus: true,
                  focusNode: _popupSearchFocusNode,
                  controller: _searchController,
                  style: AppTextStyle.small(size: 11.sp, color: AppColors.black),
                  cursorHeight: 10.sp,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle:
                    AppTextStyle.small(size: 11.sp, color: AppColors.grey),
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