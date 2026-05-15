import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    this.message = "",
    this.showStar = false,
    this.icon = Icons.person_2_outlined,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  List<String> localItems = [];

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 LABEL + OPTIONAL HELP
        Row(
          children: [
            if (widget.showIcon)
              Icon(widget.icon, size: 12.sp, color: AppColors.green),
            Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
            if (widget.showStar)
              Text(
                "*",
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

        /// 🔹 DROPDOWN
        Container(
          height: 5.5.h,
          decoration: _box(),
          child: DropdownSearch<String>(
            // ✅ v7: use 'items' as a callback function, not a list directly
            items: (filter, infiniteScrollProps) => localItems
                .where(
                  (item) =>
                      filter.isEmpty ||
                      item.toLowerCase().contains(filter.toLowerCase()),
                )
                .toList(),
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

            //  suffix replaces dropdownButtonProps
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

            /// 🔥 POPUP STYLE
            popupProps: PopupProps.menu(
              showSearchBox: true,
              showSelectedItems: true,
              fit: FlexFit.loose,
              constraints: const BoxConstraints(maxHeight: 250),
              itemBuilder: (context, item, isDisabled, isSelected) {
                final bool isCurrentlySelected =
                    isSelected || item == widget.selectedValue;

                return _DropdownItem(
                  item: item,
                  isSelected: isCurrentlySelected,
                );
              },

              menuProps: MenuProps(
                backgroundColor: Colors.white,
                elevation: 4,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                barrierColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                positionCallback: (RenderBox buttonBox, RenderBox overlayBox) {
                  // Convert button position to overlay's local coordinates
                  final buttonOffset = overlayBox.globalToLocal(
                    buttonBox.localToGlobal(Offset.zero),
                  );

                  final buttonSize = buttonBox.size;
                  final overlaySize = overlayBox.size;
                  const menuHeight = 200.0;

                  final spaceBelow =
                      overlaySize.height -
                      (buttonOffset.dy + buttonSize.height);
                  final spaceAbove = buttonOffset.dy;

                  double top;
                  if (spaceBelow >= menuHeight || spaceBelow >= spaceAbove) {
                    // Show below the field
                    top = buttonOffset.dy + buttonSize.height;
                  } else {
                    // Show above the field
                    top = buttonOffset.dy - menuHeight;
                  }

                  final left = buttonOffset.dx;
                  final right =
                      overlaySize.width - (buttonOffset.dx + buttonSize.width);

                  return RelativeRect.fromLTRB(left, top, right, 0);
                },
              ),

              searchFieldProps: TextFieldProps(
                style: AppTextStyle.small(size: 11.sp, color: AppColors.black),
                cursorHeight: 10.sp,
                decoration: InputDecoration(
                  hintText: "Search...",
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

            /// 🔥 INPUT STYLE
            decoratorProps: DropDownDecoratorProps(
              // baseStyle: AppTextStyle.medium(
              //   size: 11.sp,
              //   weight: FontWeight.w400,
              //   color: AppColors.black,
              // ),
              decoration: InputDecoration(
                // hintText: widget.hint,
                // hintStyle: AppTextStyle.small(
                //   size: 11.sp,
                //   color: AppColors.white,
                // ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 1.h,
                ),
              ),
            ),

            onSelected: (value) => widget.onChanged?.call(value),
          ),
        ),
      ],
    );
  }
}

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
    Color bgColor;

    if (widget.isSelected) {
      bgColor = const Color(0xff4A5D9E);
    } else if (_isHovered) {
      bgColor = const Color(0xff4A5D9E).withOpacity(0.15);
    } else {
      bgColor = Colors.white;
    }

    return Listener(
      onPointerDown: (_) =>
          setState(() => _isHovered = true), // ✅ low-level, never blocked
      onPointerUp: (_) => setState(() => _isHovered = false),
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
                  color: widget.isSelected ? Colors.white : Colors.black,
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
