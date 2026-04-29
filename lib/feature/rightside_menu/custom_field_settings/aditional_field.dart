import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class AdditionalFieldsSection extends StatefulWidget {
  const AdditionalFieldsSection({super.key});

  @override
  State<AdditionalFieldsSection> createState() =>
      _AdditionalFieldsSectionState();
}

class _AdditionalFieldsSectionState extends State<AdditionalFieldsSection> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    if (_controllers.length == 1) return; // keep at least one
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TopBreadcrumbBar(
            subTitle: "Additional Fields",
            title: "Dashboard",
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Container(
              height: 50.h,
              // padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 HEADER
                  Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Row(
                      children: [
                        Text(
                          "Additional Fields",
                          style: AppTextStyle.medium(
                            size: 13.6.sp,
                            color: AppColors.black.withOpacity(0.77),
                            weight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 0.5.w),
                        Tooltip(
                          textAlign: TextAlign.center,
                          message:'Custom Field Settings allow\nyou to add extra fields as\nneeded to capture specific\ninformation that isn’t covered\nby the default options.',
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          waitDuration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 2.h,
                            width: 2.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.green, width: 1),
                            ),
                            child: Icon(
                              Icons.question_mark_rounded,
                              size: 10.sp,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  Padding(
                    padding: EdgeInsets.only(left: 1.w, right: 1.w, bottom: 2.h),
                    child: Text(
                      "If you require extra fields on the lead creation form, kindly generate the fields here.",
                      style: AppTextStyle.medium(size: 11.sp),
                    ),
                  ),
                  Divider(color: AppColors.divider),
          
                  SizedBox(height: 3.h),
          
                  /// 🔹 INPUT FIELDS
                  Column(
                    children: List.generate(_controllers.length, (index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// TEXT FIELD
                          Container(
                            height: 5.5.h,
                            width: 40.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.lightGrey),
                              color: AppColors.container,
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controllers[index],
                                style: AppTextStyle.medium(),
                                textAlign: TextAlign.left,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: "Enter field name",
                                  hintStyle: AppTextStyle.small(size: 11.sp),
                                  border: InputBorder.none,
                                  isCollapsed: true,
          
                                  contentPadding: EdgeInsets.only(
                                    left: 2.w,
                                    right: 2.w,
                                    top: 0,
                                    bottom: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
          
                          SizedBox(width: 1.w),
          
                          /// DELETE BUTTON
                          InkWell(
                            onTap: () => _removeField(index),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 4.8.h,
                              width: 5.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: AppColors.red,
                                  width: 2.3.sp,
                                ),
                              ),
                              child: Icon(
                                Icons.delete_forever_outlined,
                                color: AppColors.red,
                                size: 13.5.sp,
                                weight: 0.5.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
          
                  SizedBox(height: 3.h),
          
                  /// 🔹 ADD BUTTON
                  Center(
                    child: InkWell(
                      onTap: _addField,
                      child: Container(
                        height: 5.4.h,
                        width: 2.5.w,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(Icons.add, color: AppColors.white, size: 14.sp),
                      ),
                    ),
                  ),
          
                  SizedBox(height: 2.5.h),
          
                  /// 🔹 SUBMIT BUTTON
                  Center(
                    child: SizedBox(
                      width: 7.w,
                      height: 5.5.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          List<String> values = _controllers
                              .map((c) => c.text)
                              .toList();
                          debugPrint(values.toString());
                        },
                        child: Text(
                          "Submit",
                          style: AppTextStyle.medium(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
