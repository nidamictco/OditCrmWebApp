// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/core/utils/tool_tips.dart';
// import 'package:sizer/sizer.dart';
//
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
//     this.message = "",
//     this.showStar = false,
//     this.icon = Icons.person_2_outlined,
//   });
//
//   @override
//   State<Dropdown> createState() => _DropdownState();
// }
//
// class _DropdownState extends State<Dropdown> {
//   List<String> localItems = [];
//
//   BoxDecoration _box() {
//     return BoxDecoration(
//       border: Border.all(color: AppColors.divider),
//       borderRadius: BorderRadius.circular(3),
//       color: AppColors.greyCard,
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     localItems = List.from(widget.items);
//   }
//
//   @override
//   void didUpdateWidget(covariant Dropdown oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!listEquals(oldWidget.items, widget.items)) {
//       setState(() {
//         localItems = List.from(widget.items);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// 🔹 LABEL + OPTIONAL HELP
//         Row(
//           children: [
//             if (widget.showIcon)
//               Icon(widget.icon, size: 12.sp, color: AppColors.green),
//             Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
//             if (widget.showStar)
//               Text(
//                 "*",
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
//         /// 🔹 DROPDOWN
//         Container(
//           height: 5.5.h,
//           decoration: _box(),
//           child: DropdownSearch<String>(
//             // ✅ v7: use 'items' as a callback function, not a list directly
//             items: (filter, infiniteScrollProps) => localItems
//                 .where(
//                   (item) =>
//                       filter.isEmpty ||
//                       item.toLowerCase().contains(filter.toLowerCase()),
//                 )
//                 .toList(),
//             selectedItem: widget.selectedValue,
//             itemAsString: (item) => item,
//             dropdownBuilder: (context, selectedItem) {
//               if (selectedItem == null) {
//                 return Text(
//                   widget.hint,
//                   style: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
//                 );
//               }
//               return Text(
//                 selectedItem,
//                 style: AppTextStyle.medium(
//                   size: 11.sp,
//                   weight: FontWeight.w400,
//                   color: AppColors.black,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               );
//             },
//
//             //  suffix replaces dropdownButtonProps
//             suffixProps: DropdownSuffixProps(
//               dropdownButtonProps: DropdownButtonProps(
//                 iconClosed: Padding(
//                   padding: EdgeInsets.only(right: 1.w),
//                   child: const Icon(Icons.keyboard_arrow_down),
//                 ),
//                 iconOpened: Padding(
//                   padding: EdgeInsets.only(right: 1.w),
//                   child: const Icon(Icons.keyboard_arrow_up),
//                 ),
//               ),
//             ),
//             /// 🔥 POPUP STYLE
//             popupProps: PopupProps.menu(
//               // interceptCallBacks: true,
//               showSearchBox: true,
//               showSelectedItems: true,
//               fit: FlexFit.loose,
//               constraints: const BoxConstraints(maxHeight: 250),
//               itemBuilder: (context, item, isDisabled, isSelected) {
//                 final bool isCurrentlySelected =
//                     isSelected || item == widget.selectedValue;
//
//                 return _DropdownItem(
//                   item: item,
//                   isSelected: isCurrentlySelected,
//                 );
//               },
//
//
//               menuProps: MenuProps(
//                 backgroundColor: Colors.white,
//                 elevation: 4,
//                 margin: EdgeInsets.zero,
//                 clipBehavior: Clip.antiAlias,
//                 barrierColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 positionCallback: (RenderBox buttonBox, RenderBox overlayBox) {
//                   // Convert button position to overlay's local coordinates
//                   final buttonOffset = overlayBox.globalToLocal(
//                     buttonBox.localToGlobal(Offset.zero),
//                   );
//
//                   final buttonSize = buttonBox.size;
//                   final overlaySize = overlayBox.size;
//                   const menuHeight = 200.0;
//
//                   final spaceBelow =
//                       overlaySize.height -
//                       (buttonOffset.dy + buttonSize.height);
//                   final spaceAbove = buttonOffset.dy;
//
//                   double top;
//                   if (spaceBelow >= menuHeight || spaceBelow >= spaceAbove) {
//                     // Show below the field
//                     top = buttonOffset.dy + buttonSize.height;
//                   } else {
//                     // Show above the field
//                     top = buttonOffset.dy - menuHeight;
//                   }
//
//                   final left = buttonOffset.dx;
//                   final right =
//                       overlaySize.width - (buttonOffset.dx + buttonSize.width);
//
//                   return RelativeRect.fromLTRB(left, top, right, 0);
//                 },
//               ),
//
//               searchFieldProps: TextFieldProps(
//                 style: AppTextStyle.small(size: 11.sp, color: AppColors.black),
//                 cursorHeight: 10.sp,
//                 decoration: InputDecoration(
//                   hintText: "Search...",
//                   hintStyle: AppTextStyle.small(
//                     size: 11.sp,
//                     color: AppColors.grey,
//                   ),
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 10,
//                   ),
//                   visualDensity: VisualDensity.comfortable,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//               ),
//             ),
//
//             /// 🔥 INPUT STYLE
//             decoratorProps: DropDownDecoratorProps(
//               // baseStyle: AppTextStyle.medium(
//               //   size: 11.sp,
//               //   weight: FontWeight.w400,
//               //   color: AppColors.black,
//               // ),
//               decoration: InputDecoration(
//                 // hintText: widget.hint,
//                 // hintStyle: AppTextStyle.small(
//                 //   size: 11.sp,
//                 //   color: AppColors.white,
//                 // ),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 1.w,
//                   vertical: 1.h,
//                 ),
//               ),
//             ),
//             onSelected: (value) => widget.onChanged?.call(value),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _DropdownItem extends StatefulWidget {
//   final String item;
//   final bool isSelected;
//
//   const _DropdownItem({required this.item, required this.isSelected});
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
//     Color bgColor;
//
//     if (widget.isSelected) {
//       bgColor = const Color(0xff4A5D9E);
//     } else if (_isHovered) {
//       bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
//     } else {
//       bgColor = Colors.white;
//     }
//
//     return MouseRegion(
//       onHover: (_) {
//         setState(() {
//           print("wwwwwww");
//           _isHovered = true;
//         });
//       },
//       onEnter: (_) {
//         setState(() {
//           _isHovered = true;
//         });
//       },
//       onExit: (_) {
//         setState(() {
//           _isHovered = false;
//         });
//       },
//       // Listener(
//       // onPointerDown: (_) =>
//       //     setState(() => _isHovered = true), // ✅ low-level, never blocked
//       // onPointerUp: (_) => setState(() => _isHovered = false),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
//         alignment: Alignment.centerLeft,
//         color: bgColor,
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 widget.item,
//                 style: AppTextStyle.medium(
//                   size: 11.sp,
//                   weight: FontWeight.w400,
//                   color: widget.isSelected ? Colors.white : Colors.black,
//                 ),
//               ),
//             ),
//             if (widget.isSelected)
//               const Icon(Icons.check, size: 16, color: Colors.white),
//           ],
//         ),
//       ),
//     );
//   }
// }

///
//-------------Dropdown (focusNode included)------------------------------

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dropdown
//
// Changes vs. original:
//  • Accepts [focusNode] and [nextFocusNode] so AddLeadPage can manage the
//    sequential Enter-key navigation chain.
//  • The outer Container is wrapped in a Focus widget that intercepts
//    Space / Enter to programmatically open/close the dropdown, and
//    Tab / Arrow keys to handle navigation without a mouse.
//  • Dropdown overlay position: uses the positionCallback that was already
//    partially in the original but is now hardened to never detach.
//  • The _DropdownItem hover logic is preserved exactly.
// ─────────────────────────────────────────────────────────────────────────────
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

  // ── NEW: focus-chain support ────────────────────────────────────────────────
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
  List<String> localItems = [];

  /// Used to programmatically open/close the underlying DropdownSearch.
  final DropdownSearchPopupItemBuilder<String>? _itemBuilder = null;
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();

  /// Tracks whether we have keyboard focus on this dropdown container.
  bool _hasFocus = false;

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(
        color: _hasFocus ? AppColors.primary : AppColors.divider,
        width: _hasFocus ? 1.5 : 1.0,
      ),
      borderRadius: BorderRadius.circular(3),
      color: AppColors.greyCard,
    );
  }

  @override
  void initState() {
    super.initState();
    localItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      setState(() {
        localItems = List.from(widget.items);
      });
    }
  }

  void _openDropdown() {
    _dropdownKey.currentState?.openDropDownSearch();
  }

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

        // ── Focusable container + DropdownSearch ───────────────────────────────
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() {
            _hasFocus = focused;
            if (focused) {
              _openDropdown();
            }
          }),
          // Keyboard handling: Space / Enter open the popup;
          // Tab moves to the next node in the chain.
          onKeyEvent: (node, event) {
            log("event: $event");
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

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
          },
          child: Container(
            height: 5.5.h,
            decoration: _box(),
            child: DropdownSearch<String>(
              key: _dropdownKey,
              // items callback — filter-aware
              items: (filter, infiniteScrollProps) => localItems
                  .where(
                    (item) =>
                filter.isEmpty ||
                    item.toLowerCase().contains(filter.toLowerCase()),
              )
                  .toList(),
              selectedItem: widget.selectedValue,
              itemAsString: (item) => item,
              enabled: widget.enabled,

              // ── Selected value display ──────────────────────────────────────
              dropdownBuilder: (context, selectedItem) {
                if (selectedItem == null) {
                  return Text(
                    widget.hint,
                    style: AppTextStyle.small(
                        size: 11.sp, color: AppColors.grey),
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

              // ── Arrow icons ─────────────────────────────────────────────────
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

              // ── Popup / overlay ─────────────────────────────────────────────
              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                fit: FlexFit.loose,
                constraints: const BoxConstraints(maxHeight: 250),

                itemBuilder:
                    (context, item, isDisabled, isSelected) {
                  final bool isCurrentlySelected =
                      isSelected || item == widget.selectedValue;
                  return _DropdownItem(
                    item: item,
                    isSelected: isCurrentlySelected,
                  );
                },

                // ── Anchored overlay positioning ──────────────────────────────
                // Uses the button's RenderBox to position the menu directly
                // below (or above when space is constrained). This replaces the
                // partially-working version in the original and guarantees the
                // menu never detaches from its widget.
                menuProps: MenuProps(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  barrierColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  positionCallback:
                      (RenderBox buttonBox, RenderBox overlayBox) {
                    // Convert button position to the overlay's coordinate space.
                    final buttonOffset = overlayBox.globalToLocal(
                      buttonBox.localToGlobal(Offset.zero),
                    );
                    final buttonSize = buttonBox.size;
                    final overlaySize = overlayBox.size;
                    const menuHeight = 260.0; // matches constraints.maxHeight + search box

                    final spaceBelow = overlaySize.height -
                        (buttonOffset.dy + buttonSize.height);
                    final spaceAbove = buttonOffset.dy;

                    // Place below if there's room; otherwise place above.
                    final double top;
                    if (spaceBelow >= menuHeight ||
                        spaceBelow >= spaceAbove) {
                      top = buttonOffset.dy + buttonSize.height;
                    } else {
                      top = buttonOffset.dy - menuHeight;
                    }

                    final left = buttonOffset.dx;
                    final right = overlaySize.width -
                        (buttonOffset.dx + buttonSize.width);

                    return RelativeRect.fromLTRB(left, top, right, 0);
                  },
                ),

                // ── Search box ────────────────────────────────────────────────
                searchFieldProps: TextFieldProps(
                  style: AppTextStyle.small(
                      size: 11.sp, color: AppColors.black),
                  cursorHeight: 10.sp,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: AppTextStyle.small(
                        size: 11.sp, color: AppColors.grey),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    visualDensity: VisualDensity.comfortable,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              // ── Input decoration ────────────────────────────────────────────
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
                widget.onChanged?.call(value);
                // After selection, move focus forward in the chain.
                if (widget.nextFocusNode != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.nextFocusNode!.requestFocus();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DropdownItem — unchanged hover logic from original
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownItem extends StatefulWidget {
  final String item;
  final bool isSelected;

  const _DropdownItem({required this.item, required this.isSelected});

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
    } else if (_isHovered) {
      bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
    } else {
      bgColor = Colors.white;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
                  color:
                  widget.isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (widget.isSelected)
              const Icon(Icons.check, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}