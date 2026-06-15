import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/staff_top_bar.dart';
import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/widget/caleder_screen.dart';
import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/widget/calender_grid.dart';
import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/widget/calender_header.dart';
import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/widget/week_row.dart';
import 'package:sizer/sizer.dart';

class ScheduledLeads extends StatefulWidget {
  const ScheduledLeads({super.key});

  @override
  State<ScheduledLeads> createState() => _ScheduledLeadsState();
}

class _ScheduledLeadsState extends State<ScheduledLeads> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          StaffTopBar(
            title: 'Scheduled Leads',
            parent: 'Reports',
            current: 'Scheduled Leads',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        /// FILTER SECTION
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            children: [
                              SizedBox(height: 2.w),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 15.w,
                                    child: Dropdown(
                                      label: "Staff",
                                      hint: 'All',
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  SizedBox(
                                    width: 15.w,
                                    child: Dropdown(
                                      label: 'Lead Category',
                                      hint: 'All',
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  SizedBox(
                                    width: 15.w,
                                    child: Dropdown(
                                      label: 'Lead Source',
                                      hint: 'All',
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 1.h),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: SizedBox(
                            width: 7.w,
                            height: 4.5.h,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xff1BAA90),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  "View",
                                  style: AppTextStyle.small(
                                    size: 10.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),

                        /// ✅ FORCE HEIGHT (THIS FIXES EVERYTHING)
                        SizedBox(
                          height:
                              constraints.maxHeight - 170, // adjust if needed
                          child: CalendarScreen(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
