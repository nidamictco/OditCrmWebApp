import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/dropdown.dart';
import '../../../../core/utils/footer.dart';
import '../../../../core/utils/show_entries.dart';
import '../../../../core/utils/table.dart';
import '../../../../core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class OutGoingCallhistory extends StatefulWidget {
  const OutGoingCallhistory({super.key});

  @override
  State<OutGoingCallhistory> createState() => _OutGoingCallhistoryState();
}

class _OutGoingCallhistoryState extends State<OutGoingCallhistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              title: "Lead Management",
              subTitle: 'Outgoing Call History',
              show2ndTitle: true,
              subTitle2: 'Call History',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Text(
                        "Outgoing Call History ",
                        style: AppTextStyle.medium(
                          size: 13.6.sp,
                          color: AppColors.black.withOpacity(0.77),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Divider(color: AppColors.divider),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 15.w,
                            child: Dropdown(label: "Staff", hint: 'All'),
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
                            child: Dropdown(label: 'Lead Source', hint: 'All'),
                          ),
                          SizedBox(width: 1.w),
                          SizedBox(
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
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Divider(color: AppColors.divider),
                    ShowEntries(),
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "No."),
                          TableColumn(title: "Staff"),
                          TableColumn(title: "To Phone"),
                          TableColumn(title: "Date"),
                          TableColumn(title: "Event ID "),
                          TableColumn(title: "Response"),
                        ],
                        rows:
                            [
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                'test',
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                "test",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                "test",
                              ],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Text(row[4], style: AppTextStyle.medium()),
                                Text(row[5], style: AppTextStyle.medium()),
                              ];
                            }).toList(),
                      ),
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
