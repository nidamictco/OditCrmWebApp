import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
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
      body:Row(
        children: [
          /// LEFT SIDEBAR
          _sidebar(),

          /// RIGHT CONTENT
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Folders",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    /// EMPTY STATE (you can replace later)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No folders available",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            "My Uploads",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
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
          _menuItem(
            icon: Icons.folder_open,
            title: "My Drive",
            isActive: true,
          ),

          const Spacer(),

          /// STORAGE STATUS
          Text(
            "STORAGE STATUS",
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
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
              Icon(Icons.storage, size: 14.sp, color: Colors.grey),
              SizedBox(width: 1.w),
              Text(
                "0.00 used of 100 MB",
                style: TextStyle(
                  fontSize: 10.sp,
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
        color: isActive ? const Color(0xFFE8F5E9) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isActive ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 1.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: isActive ? Colors.green : Colors.black,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}