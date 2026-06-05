// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/core/utils/tool_tips.dart';
// import 'package:sizer/sizer.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // DropdownWithAdd  (focus + keyboard fixes — mirrors Dropdown changes)
// //
// // Same four fixes as Dropdown:
// //  1. onFocusChange no longer auto-opens the popup.
// //  2. Arrow-key navigation + Enter selection inside the open popup.
// //  3. Hover highlight via MouseRegion + keyboard highlight flag.
// //  4. Focus moves to nextFocusNode from onSelected (not duplicate paths).
// // ─────────────────────────────────────────────────────────────────────────────
// class DropdownWithAdd extends StatefulWidget {
//   final bool showIcon;
//   final bool showHelp;
//   final String label;
//   final IconData? icon;
//   final List<String> items;
//   final String? selectedValue;
//   final VoidCallback onTap;
//   final Function(String?) onChanged;
//   final String message;
//   final bool showStar;
//
//   final FocusNode? focusNode;
//   final FocusNode? nextFocusNode;
//
//   const DropdownWithAdd({
//     super.key,
//     this.showIcon = false,
//     this.showHelp = false,
//     required this.label,
//     this.icon,
//     required this.items,
//     required this.onTap,
//     required this.selectedValue,
//     required this.onChanged,
//     this.message = '',
//     this.showStar = false,
//     this.focusNode,
//     this.nextFocusNode,
//   });
//
//   @override
//   State<DropdownWithAdd> createState() => _DropdownWithAddState();
// }
//
// class _DropdownWithAddState extends State<DropdownWithAdd> {
//   late List<String> _localItems;
//   final _dropdownKey = GlobalKey<DropdownSearchState<String>>();
//   bool _hasFocus = false;
//
//   // Keyboard-navigation state
//   bool _popupOpen = false;
//   int _highlightedIndex = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     _localItems = List.from(widget.items);
//     if (widget.selectedValue != null &&
//         !_localItems.contains(widget.selectedValue)) {
//       _localItems.add(widget.selectedValue!);
//     }
//   }
//
//   @override
//   void didUpdateWidget(covariant DropdownWithAdd oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.items != widget.items ||
//         oldWidget.selectedValue != widget.selectedValue) {
//       if (oldWidget.items != widget.items) {
//         setState(() {
//           _localItems = List.from(widget.items);
//           if (widget.selectedValue != null &&
//               !_localItems.contains(widget.selectedValue)) {
//             _localItems.add(widget.selectedValue!);
//           }
//         });
//       }
//     }
//   }
//
//   void _openDropdown() {
//     if (!_popupOpen) {
//       setState(() => _popupOpen = true);
//       _dropdownKey.currentState?.openDropDownSearch();
//     }
//   }
//
//   void _closeDropdown() {
//     _dropdownKey.currentState?.closeDropDownSearch();
//   }
//
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
//             if (widget.showIcon) ...[
//               Icon(widget.icon, size: 16, color: AppColors.green),
//               SizedBox(width: 1.w),
//             ],
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
//         // ── Field ────────────────────────────────────────────────────────────
//         Focus(
//           focusNode: widget.focusNode,
//           onFocusChange: (focused) {
//             setState(() => _hasFocus = focused);
//             // Do NOT auto-open here.
//           },
//           onKeyEvent: (node, event) {
//             if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
//               return KeyEventResult.ignored;
//             }
//
//             // ── Popup CLOSED ────────────────────────────────────────────────
//             if (!_popupOpen) {
//               if (event.logicalKey == LogicalKeyboardKey.space ||
//                   event.logicalKey == LogicalKeyboardKey.enter ||
//                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                 setState(() => _highlightedIndex = 0);
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
//             // ── Popup OPEN ──────────────────────────────────────────────────
//             final items = _filteredItems('');
//             final count = items.length;
//
//             if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//               setState(
//                 () => _highlightedIndex = (_highlightedIndex + 1).clamp(
//                   0,
//                   count - 1,
//                 ),
//               );
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//               setState(
//                 () => _highlightedIndex = (_highlightedIndex - 1).clamp(
//                   0,
//                   count - 1,
//                 ),
//               );
//               return KeyEventResult.handled;
//             }
//
//             if (event.logicalKey == LogicalKeyboardKey.enter) {
//               if (_highlightedIndex >= 0 && _highlightedIndex < count) {
//                 final selected = items[_highlightedIndex];
//                 _closeDropdown();
//                 widget.onChanged(selected);
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
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _hasFocus ? AppColors.primary : AppColors.divider,
//                 width: _hasFocus ? 1.5 : 1.0,
//               ),
//               borderRadius: BorderRadius.circular(6),
//               color: AppColors.greyCard,
//             ),
//             child: Row(
//               children: [
//                 // ── Add button ───────────────────────────────────────────────
//                 GestureDetector(
//                   onTap: widget.onTap,
//                   child: Container(
//                     width: 3.4.w,
//                     height: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(4),
//                         bottomLeft: Radius.circular(4),
//                       ),
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white),
//                   ),
//                 ),
//
//                 // ── Dropdown ─────────────────────────────────────────────────
//                 Expanded(
//                   child: Stack(
//                     alignment: Alignment.centerRight,
//                     children: [
//                       DropdownSearch<String>(
//                         key: _dropdownKey,
//                         items: (filter, _) => _localItems
//                             .where(
//                               (item) =>
//                                   filter.isEmpty ||
//                                   item.toLowerCase().contains(
//                                     filter.toLowerCase(),
//                                   ),
//                             )
//                             .toList(),
//                         selectedItem: widget.selectedValue,
//                         itemAsString: (item) => item,
//
//                         dropdownBuilder: (context, selectedItem) {
//                           if (selectedItem == null) {
//                             return Text(
//                               widget.label,
//                               style: AppTextStyle.small(
//                                 size: 11.sp,
//                                 color: AppColors.grey,
//                               ),
//                             );
//                           }
//                           return Padding(
//                             padding: EdgeInsets.only(right: 3.w),
//                             child: Text(
//                               selectedItem,
//                               style: AppTextStyle.medium(
//                                 size: 11.sp,
//                                 weight: FontWeight.w400,
//                                 color: AppColors.black,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         },
//
//                         suffixProps: DropdownSuffixProps(
//                           dropdownButtonProps: DropdownButtonProps(
//                             iconClosed: widget.selectedValue != null
//                                 ? const SizedBox.shrink()
//                                 : Padding(
//                                     padding: EdgeInsets.only(right: 1.w),
//                                     child: const Icon(
//                                       Icons.keyboard_arrow_down,
//                                     ),
//                                   ),
//                             iconOpened: widget.selectedValue != null
//                                 ? const SizedBox.shrink()
//                                 : Padding(
//                                     padding: EdgeInsets.only(right: 1.w),
//                                     child: const Icon(Icons.keyboard_arrow_up),
//                                   ),
//                           ),
//                         ),
//
//                         popupProps: PopupProps.menu(
//                           showSearchBox: true,
//                           showSelectedItems: true,
//                           fit: FlexFit.loose,
//                           constraints: const BoxConstraints(maxHeight: 250),
//
//                           // onDismissed: () {
//                           //   setState(() {
//                           //     _popupOpen = false;
//                           //     _highlightedIndex = -1;
//                           //   });
//                           // },
//                           onDismissed: () {
//                             // Guard: don't call setState if widget is being torn down
//                             if (!mounted) return;
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               if (!mounted) return;
//                               setState(() {
//                                 _popupOpen = false;
//                                 _highlightedIndex = -1;
//                               });
//                             });
//                           },
//
//                           itemBuilder: (context, item, isDisabled, isSelected) {
//                             final currentIndex = _filteredItems(
//                               '',
//                             ).indexOf(item);
//                             final isKeyboardHighlighted =
//                                 currentIndex == _highlightedIndex;
//                             return _DropdownWithAddItem(
//                               item: item,
//                               isSelected: isSelected,
//                               isKeyboardHighlighted: isKeyboardHighlighted,
//                             );
//                           },
//
//                           menuProps: MenuProps(
//                             backgroundColor: Colors.white,
//                             elevation: 4,
//                             margin: EdgeInsets.zero,
//                             clipBehavior: Clip.antiAlias,
//                             barrierColor: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             positionCallback:
//                                 (RenderBox buttonBox, RenderBox overlayBox) {
//                                   final buttonOffset = overlayBox.globalToLocal(
//                                     buttonBox.localToGlobal(Offset.zero),
//                                   );
//                                   final buttonSize = buttonBox.size;
//                                   final overlaySize = overlayBox.size;
//                                   const menuHeight = 260.0;
//
//                                   final spaceBelow =
//                                       overlaySize.height -
//                                       (buttonOffset.dy + buttonSize.height);
//                                   final spaceAbove = buttonOffset.dy;
//
//                                   final double top;
//                                   if (spaceBelow >= menuHeight ||
//                                       spaceBelow >= spaceAbove) {
//                                     top = buttonOffset.dy + buttonSize.height;
//                                   } else {
//                                     top = buttonOffset.dy - menuHeight;
//                                   }
//
//                                   final left = buttonOffset.dx;
//                                   final right =
//                                       overlaySize.width -
//                                       (buttonOffset.dx + buttonSize.width);
//                                   return RelativeRect.fromLTRB(
//                                     left,
//                                     top,
//                                     right,
//                                     0,
//                                   );
//                                 },
//                           ),
//
//                           searchFieldProps: TextFieldProps(
//                             decoration: InputDecoration(
//                               hintText: 'Search...',
//                               hintStyle: AppTextStyle.small(
//                                 size: 11.sp,
//                                 color: AppColors.grey,
//                               ),
//                               isDense: true,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 10,
//                               ),
//                               visualDensity: VisualDensity.comfortable,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         decoratorProps: DropDownDecoratorProps(
//                           decoration: InputDecoration(
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 1.w,
//                               vertical: 1.h,
//                             ),
//                           ),
//                         ),
//
//                         // onSelected: (value) {
//                         //   setState(() {
//                         //     _popupOpen = false;
//                         //     _highlightedIndex = -1;
//                         //   });
//                         //   widget.onChanged(value);
//                         //   if (widget.nextFocusNode != null) {
//                         //     WidgetsBinding.instance.addPostFrameCallback((_) {
//                         //       widget.nextFocusNode!.requestFocus();
//                         //     });
//                         //   }
//                         // },
//                         onSelected: (value) {
//                           if (!mounted) return;
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (!mounted) return;
//                             setState(() {
//                               _popupOpen = false;
//                               _highlightedIndex = -1;
//                             });
//                             widget.onChanged?.call(value);
//                             if (widget.nextFocusNode != null) {
//                               widget.nextFocusNode!.requestFocus();
//                             }
//                           });
//                         },
//                       ),
//
//                       // ── Clear button ──────────────────────────────────────
//                       if (widget.selectedValue != null)
//                         Positioned(
//                           right: 0.5.w,
//                           child: GestureDetector(
//                             onTap: () => widget.onChanged(null),
//                             child: Container(
//                               padding: const EdgeInsets.all(2),
//                               child: const Icon(
//                                 Icons.close,
//                                 size: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // _DropdownWithAddItem — hover + keyboard highlight
// // ─────────────────────────────────────────────────────────────────────────────
// // class _DropdownWithAddItem extends StatefulWidget {
// //   final String item;
// //   final bool isSelected;
// //   final bool isKeyboardHighlighted;
//
// //   const _DropdownWithAddItem({
// //     required this.item,
// //     required this.isSelected,
// //     this.isKeyboardHighlighted = false,
// //   });
//
// //   @override
// //   State<_DropdownWithAddItem> createState() => _DropdownWithAddItemState();
// // }
//
// // class _DropdownWithAddItemState extends State<_DropdownWithAddItem> {
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
// //                   weight: FontWeight.w400,
// //                   color: widget.isSelected ? Colors.white : Colors.black87,
// //                   size: 11.sp,
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
//
// class _DropdownWithAddItem extends StatefulWidget {
//   final String item;
//   final bool isSelected;
//   final bool isKeyboardHighlighted;
//
//   const _DropdownWithAddItem({
//     required this.item,
//     required this.isSelected,
//     this.isKeyboardHighlighted = false,
//   });
//
//   @override
//   State<_DropdownWithAddItem> createState() => _DropdownWithAddItemState();
// }
//
// class _DropdownWithAddItemState extends State<_DropdownWithAddItem> {
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DropdownWithAdd
//
// Same approach as Dropdown:
//  - onKeyEvent attached to _popupSearchFocusNode in initState (NOT via
//    TextFieldProps which doesn't support those params in dropdown_search).
//  - _searchController.addListener tracks search text for filtered indexing.
//  - Opening pre-highlights the currently selected item.
// ─────────────────────────────────────────────────────────────────────────────
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
  });

  @override
  State<DropdownWithAdd> createState() => _DropdownWithAddState();
}

class _DropdownWithAddState extends State<DropdownWithAdd> {
  late List<String> _localItems;
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();

  final TextEditingController _searchController = TextEditingController();

  // onKeyEvent is attached to the FocusNode directly — TextFieldProps does
  // not expose onKeyEvent or onChanged as named parameters.
  late final FocusNode _popupSearchFocusNode;

  bool _hasFocus = false;
  bool _popupOpen = false;
  // int _highlightedIndex = -1;
  final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

  String get _searchText => _searchController.text;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.items);
    if (widget.selectedValue != null &&
        !_localItems.contains(widget.selectedValue)) {
      _localItems.add(widget.selectedValue!);
    }

    // KEY FIX: attach key handler to FocusNode, not TextFieldProps.
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
      // if (_highlightedIndex != newIdx) {
      //   setState(() => _highlightedIndex = newIdx);
      // }
      if(_highlightedIndexNotifier.value != newIdx){
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

  // ── Helpers ─────────────────────────────────────────────────────────────────
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

    // setState(() {
    //   _popupOpen = true;
    //   _highlightedIndex = preselect >= 0 ? preselect : (visible.isEmpty ? -1 : 0);
    // });
    setState(() {
      _popupOpen = true;
    });

    _highlightedIndexNotifier.value = preselect >= 0 ? preselect : (visible.isEmpty ? -1 : 0);

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
      widget.onChanged(selected);
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

  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final visible = _filteredItems(_searchText);
    final count = visible.length;

    // if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
    //   if (count > 0) {
    //     setState(
    //             () => _highlightedIndex = (_highlightedIndex + 1).clamp(0, count - 1));
    //   }
    //   return KeyEventResult.handled;
    // }
    //
    // if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
    //   if (count > 0) {
    //     setState(
    //             () => _highlightedIndex = (_highlightedIndex - 1).clamp(0, count - 1));
    //   }
    //   return KeyEventResult.handled;
    // }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1).clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
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
                // ── Add button ───────────────────────────────────────────────
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

                // ── Dropdown ─────────────────────────────────────────────────
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      DropdownSearch<String>(
                        key: _dropdownKey,
                        items: (filter, _) => _filteredItems(filter),
                        selectedItem: widget.selectedValue,
                        itemAsString: (item) => item,

                        dropdownBuilder: (context, selectedItem) {
                          if (selectedItem == null) {
                            return Text(
                              widget.label,
                              style: AppTextStyle.small(
                                  size: 11.sp, color: AppColors.grey),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: Text(
                              selectedItem,
                              style: AppTextStyle.medium(
                                size: 11.sp,
                                weight: FontWeight.w400,
                                color: AppColors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },

                        suffixProps: DropdownSuffixProps(
                          dropdownButtonProps: DropdownButtonProps(
                            iconClosed: widget.selectedValue != null
                                ? const SizedBox.shrink()
                                : Padding(
                              padding: EdgeInsets.only(right: 1.w),
                              child: const Icon(Icons.keyboard_arrow_down),
                            ),
                            iconOpened: widget.selectedValue != null
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
                          //   final isKeyboardHighlighted =
                          //       currentIndex == _highlightedIndex;
                          //   return _DropdownWithAddItem(
                          //     item: item,
                          //     isSelected: isSelected,
                          //     isKeyboardHighlighted: isKeyboardHighlighted,
                          //   );
                          // },
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

                          // menuProps: MenuProps(
                          //   backgroundColor: Colors.white,
                          //   elevation: 4,
                          //   margin: EdgeInsets.zero,
                          //   clipBehavior: Clip.antiAlias,
                          //   barrierColor: Colors.transparent,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(6),
                          //   ),
                          //   positionCallback:
                          //       (RenderBox buttonBox, RenderBox overlayBox) {
                          //     final buttonOffset = overlayBox.globalToLocal(
                          //       buttonBox.localToGlobal(Offset.zero),
                          //     );
                          //     final buttonSize = buttonBox.size;
                          //     final overlaySize = overlayBox.size;
                          //     const menuHeight = 260.0;
                          //     final spaceBelow = overlaySize.height -
                          //         (buttonOffset.dy + buttonSize.height);
                          //     final spaceAbove = buttonOffset.dy;
                          //     final double top =
                          //     (spaceBelow >= menuHeight || spaceBelow >= spaceAbove)
                          //         ? buttonOffset.dy + buttonSize.height
                          //         : buttonOffset.dy - menuHeight;
                          //     final left = buttonOffset.dx;
                          //     final right = overlaySize.width -
                          //         (buttonOffset.dx + buttonSize.width);
                          //     return RelativeRect.fromLTRB(left, top, right, 0);
                          //   },
                          // ),

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
                              const maxMenuHeight = 250.0;

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

                          // FIX: only valid TextFieldProps params used here.
                          // Key events are handled via FocusNode.onKeyEvent (initState).
                          // Search text is tracked via _searchController + addListener.
                          searchFieldProps: TextFieldProps(
                            focusNode: _popupSearchFocusNode,
                            controller: _searchController,
                            style: AppTextStyle.small(
                                size: 11.sp, color: AppColors.black),
                            cursorHeight: 10.sp,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: AppTextStyle.small(
                                  size: 11.sp, color: AppColors.grey),
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
                            widget.onChanged(value);
                            if (widget.nextFocusNode != null) {
                              widget.nextFocusNode!.requestFocus();
                            }
                          });
                        },
                      ),

                      // ── Clear button ─────────────────────────────────────
                      if (widget.selectedValue != null)
                        Positioned(
                          right: 0.5.w,
                          child: GestureDetector(
                            onTap: () => widget.onChanged(null),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close,
                                  size: 18, color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
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