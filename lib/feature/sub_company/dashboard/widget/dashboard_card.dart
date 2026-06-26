import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/tool_tips.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/main_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/shared_preference/session_service.dart';
import '../../lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../lead_managment/leads/cubit/add_lead_state.dart';
import '../../staff_managment/staff/model/staff_model.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String message;
  final String fromCard;
  // final DateTime selectedDate;

  const DashboardCard({
    super.key,
    required this.title,
    required this.message,
    required this.fromCard,
    // required this.selectedDate,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool isHovering = false;

  StaffModel? staff;

  Future<void> getCurrentUser() async {
    final user = await SessionService().getSavedUser();
    staff = user;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,

        // 👇 lift effect
        transform: Matrix4.translationValues(0, isHovering ? -6 : 0, 0),

        width: 18.w,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(5),

          // 👇 shadow change on hover
          boxShadow: [
            BoxShadow(
              color: isHovering
                  ? Colors.black.withOpacity(0.15)
                  : AppColors.lightGrey,
              blurRadius: isHovering ? 20 : 8,
              offset: Offset(0, isHovering ? 10 : 2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyle.medium(
                    color: AppColors.grey,
                    weight: FontWeight.w600,
                  ),
                ),

                ToolTipWidget(message: widget.message),
              ],
            ),

            SizedBox(height: 1.5.h),

            /// NUMBER
            // Text("0", style: AppTextStyle.number(size: 14.sp)),
            BlocBuilder<AddLeadCubit, AddLeadState>(
              builder: (context, state) {
                String count = "0";

                switch (widget.fromCard) {
                  case 'NEW':
                    count = state.newLeadCount;
                    break;

                  case 'FOLLOWUP':
                    count = state.followUpCount;
                    break;

                  case 'CLOSED':
                    count = state.closedLeadCount;
                    break;

                  case 'TOTAL':
                    count = state.dashboardTotalCalledCount;
                    break;

                  case 'MISSED':
                    count = state.missedLeadCount;
                    break;

                  case 'TRANSFERRED':
                    count = state.transferredCount;
                    break;
                }

                return Text(count, style: AppTextStyle.number(size: 14.sp));
              },
            ),

            SizedBox(height: 1.5.h),

            /// LINK ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<AddLeadCubit, AddLeadState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () async {
                        final user = await SessionService().getSavedUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/new_leads'),
                            builder: (context) => MainScreen(
                              selectedIndex: 12,
                              fromCard: widget.fromCard,
                              staff: user,
                              selectedDate: state.selectedDashboardDate,
                              goToDashboardOnBack: true,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "View Details",
                        style: AppTextStyle.link(
                          color: AppColors.grey,
                          decorationColor: AppColors.grey,
                        ),
                      ),
                    );
                  },
                ),
                BlocBuilder<AddLeadCubit, AddLeadState>(
                  builder: (context, state) {
                    String count = "0";

                    switch (widget.fromCard) {
                      case 'NEW':
                        count = state.newLeadCount;
                        break;

                      case 'FOLLOWUP':
                        count = state.followUpCount;
                        break;

                      case 'CLOSED':
                        count = state.closedLeadCount;
                        break;

                      case 'TOTAL':
                        count = state.dashboardTotalCalledCount;
                        break;

                      case 'MISSED':
                        count = state.missedLeadCount;
                        break;

                      case 'TRANSFERRED':
                        count = state.transferredCount;
                        break;
                    }
                    return GestureDetector(
                      onTap: () {
                        showLeadsDialog(
                          context: context,
                          title: "${widget.fromCard.toUpperCase()} LEADS",
                          value: count,
                        );
                      },
                      child: Container(
                        height: 5.h,
                        width: 5.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(
                          Symbols.vital_signs,
                          size: 14.sp,
                          color: Colors.indigoAccent[400],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLeadsDialog({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 35.w,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// CLOSE BUTTON (top right)
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ),

                SizedBox(height: 1.h),

                /// CENTER CONTENT
                Center(
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.medium(color: AppColors.grey),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        value,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.number(
                          size: 18.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
