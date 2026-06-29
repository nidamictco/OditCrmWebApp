import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class LeadDistributionSettingsScreen extends StatefulWidget {
  const LeadDistributionSettingsScreen({super.key});

  @override
  State<LeadDistributionSettingsScreen> createState() =>
      _LeadDistributionSettingsScreenState();
}

class _LeadDistributionSettingsScreenState
    extends State<LeadDistributionSettingsScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  final List<String> _positions = [
    "Position 1",
    "Position 2",
    "Position 3",
    "Position 4",
    "Position 5",
  ];

  final List<String> _options = ["User 1", "User 2", "User 3", "User 4"];

  final Map<int, String?> _selectedValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(subTitle: "Unassigned Lead Distribution Settings", title: 'Settings'),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 TITLE
                    Text(
                      "Unassigned Lead Distribution Settings",
                      style: AppTextStyle.heading(),
                    ),
        
                    SizedBox(height: 3.h),
        
                    /// 🔹 FORM LIST
                    ...List.generate(
                      _positions.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: 2.h, right: 10.w),
                        child: _buildRow(index),
                      ),
                    ),
        
                    SizedBox(height: 2.h),
        
                    /// 🔹 SUBMIT BUTTON
                    SizedBox(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 SINGLE ROW (LABEL + DROPDOWN)
  Widget _buildRow(int index) {
    return Row(
      children: [
        /// LEFT LABEL FIELD
        Expanded(
          flex: 1,
          child: Container(
            height: 6.h,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              _positions[index],
              style: AppTextStyle.medium(weight: FontWeight.w500),
            ),
          ),
        ),

        SizedBox(width: 0.7.w),

        /// RIGHT DROPDOWN
        Expanded(
          flex: 1,
          child: Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedValues[index],
                hint: Text(
                  "Select",
                  style: AppTextStyle.medium(
                    color: AppColors.grey,
                    weight: FontWeight.w400,
                  ),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                isExpanded: true,
                items: _options
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: AppTextStyle.body()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedValues[index] = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
