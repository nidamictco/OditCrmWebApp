import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class ShowEntries extends StatefulWidget {
  /// Called whenever the search text changes — parent owns the value.
  final ValueChanged<String>? onSearchChanged;

  /// Called whenever the entries-per-page dropdown changes — parent owns the value.
  final ValueChanged<String>? onEntriesChanged;

  /// Optional initial values (so the widget reflects parent state on rebuild).
  final String initialSearch;
  final String initialEntries;

  const ShowEntries({
    super.key,
    this.onSearchChanged,
    this.onEntriesChanged,
    this.initialSearch = '',
    this.initialEntries = '1',
  });

  @override
  State<ShowEntries> createState() => _ShowEntriesState();
}

class _ShowEntriesState extends State<ShowEntries> {
  late String selectedValue;
  final List<String> dropdownItems = ['1','10', '50', '100','500'];
  late final TextEditingController _searchController; 

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialEntries;
    _searchController =
        TextEditingController(text: widget.initialSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 1.h,
        left: 2.w,
        right: 2.w,
        bottom: 1.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Show N entries ──────────────────────────────────────────
          Row(
            children: [
              Text(
                "Show ",
                style: AppTextStyle.medium(
                  size: 11.sp,
                  weight: FontWeight.w400,
                ),
              ),
              _smallDropdown(),
              Text(
                " entries",
                style: AppTextStyle.medium(
                  size: 11.sp,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),

          // ── Search ──────────────────────────────────────────────────
          Row(
            children: [
              Text(
                "Search:",
                style: AppTextStyle.medium(
                  size: 11.sp,
                  weight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 1.w),
              Container(
                width: 12.w,
                height: 4.h,
                decoration: _box(),
                child: TextField(
                  controller: _searchController,
                  // ✅ Notify parent on every keystroke
                  onChanged: (v) => widget.onSearchChanged?.call(v),
                  style: AppTextStyle.small(
                    size: 10.sp,
                    color: AppColors.black,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallDropdown() {
    return Container(
      width: 4.2.w,
      height: 4.h,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _box(),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 16),
          style: AppTextStyle.small(size: 11.sp),
          onChanged: (String? newValue) {
            if (newValue == null) return;
            setState(() => selectedValue = newValue);
            // ✅ Notify parent when entries limit changes
            widget.onEntriesChanged?.call(newValue);
          },
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: AppTextStyle.small(size: 11.sp)),
            );
          }).toList(),
        ),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.white,
    );
  }
}