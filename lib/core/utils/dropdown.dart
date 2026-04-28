import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/tool_tips.dart';
import 'package:sizer/sizer.dart';

class Dropdown extends StatefulWidget {
  final String label;
  final String hint;
  final bool showHelp;
  final List<String> items;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final bool enabled;
  final String message;

  const Dropdown({
    super.key,
    required this.label,
    required this.hint,
    this.showHelp = false,
    this.items = const [],
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.message = "",
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
            Text(widget.label, style: AppTextStyle.medium(size: 11.sp)),

            if (widget.showHelp) ...[
              // SizedBox(width: 0.5.w),
              // Container(
              //   height: 1.8.h,
              //   width: 1.8.h,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: AppColors.green),
              //     shape: BoxShape.circle,
              //   ),
              //   child: Center(
              //     child: Text(
              //       "?",
              //       style: TextStyle(fontSize: 9.sp, color: AppColors.green),
              //     ),
              //   ),
              // ),
              ToolTipWidget(message: widget.message),
            ],
          ],
        ),

        SizedBox(height: 0.5.h),

        /// 🔹 DROPDOWN
        Container(
          height: 5.5.h,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: _box(),

          child: DropdownSearch<String>(
            items: widget.items,
            selectedItem: widget.selectedValue,
            enabled: widget.enabled && widget.items.isNotEmpty,

            /// 🔥 POPUP STYLE
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              constraints: const BoxConstraints(maxHeight: 300),
            ),

            /// 🔥 INPUT STYLE
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            /// 🔥 DISPLAY SELECTED VALUE (IMPORTANT FIX)
            dropdownBuilder: (context, selectedItem) {
              final isHint = selectedItem == null;

              return Text(
                isHint ? "Select ${widget.label}" : selectedItem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isHint
                    ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
                    : AppTextStyle.medium(size: 11.sp),
              );
            },

            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
