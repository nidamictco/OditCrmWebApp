import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
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
    this.message = "",
    this.showStar = false,
  });

  @override
  State<DropdownWithAdd> createState() => _DropdownWithAddState();
}

class _DropdownWithAddState extends State<DropdownWithAdd> {
  late List<String> localItems;

  @override
  void initState() {
    super.initState();
    localItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant DropdownWithAdd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
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
        /// 🔹 LABEL
        Row(
          children: [
            if (widget.showIcon) ...[
              Icon(widget.icon, size: 16, color: AppColors.green),
              SizedBox(width: 1.w),
            ],
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

        /// 🔹 FIELD
        Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(6),
            color: AppColors.greyCard,
          ),
          child: Row(
            children: [
              /// ➕ ADD BUTTON
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

              /// 🔽 DROPDOWN
              Expanded(
                child: DropdownSearch<String>(
                  // ✅ v7: items is now a callback function
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
                  widget.label,
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

                  /// 🔥 POPUP STYLE
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    showSelectedItems: true,
                    fit: FlexFit.loose,
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 1.h,
                        ),
                        alignment: Alignment.centerLeft,
                        color: isSelected
                            ? const Color(0xff4A5D9E)
                            : Colors.white,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            item,
                            style: AppTextStyle.medium(
                              weight: FontWeight.w400,
                              color: isSelected ? Colors.white : Colors.black87,
                              size: 11.sp,
                            ),
                          ),
                        ),
                      );
                    },

                    menuProps: MenuProps(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: const EdgeInsets.only(top: 4),
                    ),

                    searchFieldProps: TextFieldProps(
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

                  /// 🔹 FIELD STYLE
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 1.w,
                        vertical: 1.h,
                      ),
                    ),
                  ),
                  onSelected: (value) => widget.onChanged(value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
