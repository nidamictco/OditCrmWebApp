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
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(3),
      color: AppColors.greyCard,
    );
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
                Icons.person_2_outlined,
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
            items: widget.items,
            selectedItem: widget.selectedValue,
            enabled: widget.enabled && widget.items.isNotEmpty,

            dropdownButtonProps: DropdownButtonProps(
              icon: Padding(
                padding: EdgeInsets.only(right: 1.w),
                child: Icon(Icons.keyboard_arrow_down),
              ),
            ),

            /// 🔥 POPUP STYLE
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              constraints: const BoxConstraints(maxHeight: 300),
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
                  // vertical: 1.5.h,
                ),
              ),
            ), 

            /// 🔥 DISPLAY SELECTED VALUE (IMPORTANT FIX)
            dropdownBuilder: (context, selectedItem) {
              final isHint = selectedItem == null;

              return Padding(
                padding: EdgeInsets.all(0.4.w),
                child: Text(
                  isHint ? "Select ${widget.label}" : selectedItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isHint
                      ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
                      : AppTextStyle.medium(size: 11.sp),
                ),
              );
            },

            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
