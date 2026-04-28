import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(0.5.w),
        child: SizedBox(
          child: Row(
            children: [
              /// LEFT SIDEBAR
              _sidebar(),
              VerticalDivider(color: AppColors.background, width: 0.5.w),

              /// RIGHT CONTENT
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Folders", style: AppTextStyle.medium(size: 12.sp)),

                      SizedBox(height: 2.h),

                      /// EMPTY STATE (you can replace later)
                      Expanded(
                        child: Center(
                          child: Text(
                            "No folders available",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SIDEBAR
  Widget _sidebar() {
    return Container(
      width: 22.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        // border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            "My Uploads",
            style: AppTextStyle.medium(size: 12.sp, weight: FontWeight.w700),
          ),

          SizedBox(height: 2.h),

          /// SEARCH BAR
          Container(
            height: 5.h,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16.sp, color: Colors.grey),
                SizedBox(width: 1.w),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search here...",
                      hintStyle: AppTextStyle.small(
                        size: 10.sp,
                        weight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          /// MENU ITEM
          _menuItem(icon: Icons.folder_open, title: "My Drive", isActive: true),

          const Spacer(),

          /// STORAGE STATUS
          Text(
            "STORAGE STATUS",
            style: AppTextStyle.small(
              size: 10.sp,
              color: Colors.grey.shade600,
              weight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          LinearProgressIndicator(
            value: 0.0,
            minHeight: 0.8.h,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
          ),

          SizedBox(height: 1.h),

          Row(
            children: [
              Icon(Icons.storage_rounded, size: 11.sp, color: Colors.grey),
              SizedBox(width: 0.4.w),
              Text(
                "0.00 used of 100 MB",
                style: AppTextStyle.small(
                  size: 10.sp,
                  weight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ), 
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// MENU ITEM WIDGET
  Widget _menuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
      decoration: BoxDecoration(
        // color: isActive ? AppColors.greenLight : Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: isActive ? AppColors.green : Colors.grey,
          ),
          SizedBox(width: 1.w),
          Text(
            title,
            style: AppTextStyle.medium(
              size: 11.sp,
              color: isActive ? AppColors.green : Colors.black,
              weight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
