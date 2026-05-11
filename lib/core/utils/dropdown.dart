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
              Icon(
                widget.icon,
                size: 12.sp,
                color: AppColors.green,
              ),
            Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),
            if (widget.showStar) ...[
              Text(
                "*",
                style: AppTextStyle.medium(
                  size: 11.sp,
                  weight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ],

            if (widget.showHelp) ...[ToolTipWidget(message: widget.message)],
          ],
        ),

        SizedBox(height: 0.5.h),

        /// 🔹 DROPDOWN
        Container(
          height: 5.5.h,
          // padding: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: _box(),

          child: DropdownSearch<String>(
            items: localItems,
            selectedItem: widget.selectedValue,

            // enabled: widget.enabled && localItems.isNotEmpty,
            dropdownButtonProps: DropdownButtonProps(
              icon: Padding(
                padding: EdgeInsets.only(right: 1.w),
                child: Icon(Icons.keyboard_arrow_down),
              ),
            ),

            /// 🔥 POPUP STYLE
            popupProps: PopupProps.menu(
              showSearchBox: true,
              showSelectedItems: true,

              fit: FlexFit.loose,
              itemBuilder: (context, item, isSelected) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                  alignment: Alignment.centerLeft,
                  color: isSelected ? const Color(0xff4A5D9E) : Colors.white,
                  child: Text(
                    item,
                    style: AppTextStyle.medium(
                      size: 11.sp,
                      weight: FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
              menuProps: MenuProps(
                backgroundColor: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(6),
              ),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search...",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  visualDensity: VisualDensity.comfortable,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            /// 🔥 INPUT STYLE
            dropdownDecoratorProps: DropDownDecoratorProps(
              baseStyle: AppTextStyle.medium(
                size: 11.sp,
                weight: FontWeight.w400,
                color: AppColors.black,
              ),
              dropdownSearchDecoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 1.h,
                ),
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
