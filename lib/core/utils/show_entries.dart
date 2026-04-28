import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class ShowEntries extends StatefulWidget {
  const ShowEntries({super.key});

  @override
  State<ShowEntries> createState() => _ShowEntriesState();
}

class _ShowEntriesState extends State<ShowEntries> {
   String selectedValue = '10';
  List<String> dropdownItems = ['10', '50', '100', '500', '1000'];

  @override
  Widget build(BuildContext context) {
    return  Padding(
                      padding: EdgeInsets.only(
                        top: 1.h,
                        left: 2.w,
                        right: 2.w,
                        bottom: 1.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
            setState(() {
              selectedValue = newValue!;
            });
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