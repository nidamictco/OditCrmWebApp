import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/custom_calender.dart';
import 'package:oxdo/core/utils/menu_hover_bottun.dart';
import 'package:oxdo/feature/dashboard/widget/add_leads_button.dart';
import 'package:oxdo/feature/dashboard/widget/dashboard_card.dart';
import 'package:oxdo/feature/dashboard/widget/social_connect_card.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

import '../lead_managment/leads/cubit/add_lead_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final today = DateTime.now();

    _dateController.text = DateFormat('dd-MM-yyyy').format(today);

    // context.read<AddLeadCubit>().fetchDashboardCounts(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.only(top: 3.h, left: 2.w, right: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP HEADER ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEFT SIDE (TITLE + SUBTITLE)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lead Management",
                              style: AppTextStyle.heading(size: 15),
                            ),

                            SizedBox(height: 0.5.h),

                            Text(
                              "Calling features that give you wings that fast..",
                              style: AppTextStyle.small(
                                color: AppColors.grey.withOpacity(0.8),
                                size: 11.5.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        /// RIGHT SIDE (ACTIONS)
                        Row(
                          children: [
                            /// SEARCH BOX
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (context) {
                                    return Stack(
                                      children: [
                                        Positioned(
                                          top: 20.h,
                                          right: 5.w,
                                          child: CustomCalendar(
                                            onDateSelected: (date) {
                                              _dateController.text = DateFormat(
                                                'dd-MM-yyyy',
                                              ).format(date);

                                              context
                                                  .read<AddLeadCubit>()
                                                  .fetchDashboardCounts(date);

                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 15.w,
                                    height: 6.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                    child: Center(
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: _dateController,
                                          readOnly: true,
                                          style: AppTextStyle.small(
                                            size: 11.sp,
                                            color: AppColors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            // hintText: _dateController.text,
                                            hintStyle: AppTextStyle.small(
                                              size: 11.sp,
                                              color: AppColors.grey,
                                            ),
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// CALENDAR BUTTON
                                  Container(
                                    height: 6.h,
                                    width: 6.h,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                      size: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 1.w),

                            /// ADD LEADS BUTTON
                            AddLeadsButton(),

                            SizedBox(width: 1.w),

                            /// MENU BUTTON
                            MenuHoverButton(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    /// 🔥 SOCIAL CONNECT SECTION
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 2.h,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 800
                              ? 38.w
                              : 200.w,
                          child: SocialConnectCard(
                            title: "Connect facebook",
                            buttonText: "Facebook Settings",
                            buttonColor: AppColors.primary,
                            icon: Icons.facebook,
                            iconColor: AppColors.primary,
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(selectedIndex: 21),
                                ),
                              );
                            },
                          ),
                        ),
                        // SizedBox(width: 2.w),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 38.w
                              : 200.w,
                          child: SocialConnectCard(
                            title: "Connect WhatsApp",
                            buttonText: "Whatsapp Settings",
                            buttonColor: AppColors.green,
                            icon: Icons.chat,
                            iconColor: AppColors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    /// CARDS
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 2.h,
                      children: const [
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "NEW LEADS",
                            message:
                                'The combined count of new\nleads and unattended leads.',
                            fromCard: 'NEW',
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "FOLLOWUP LEADS",
                            message:
                                'The current count of leads assigned \nfor today, including missed follow-up leads.',
                            fromCard: 'FOLLOWUP',
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "CLOSED LEADS",
                            message:
                                'Closed leads can be filtered using a specific \ndate range to determine the count of \nclosed leads within that period.',
                            fromCard: 'CLOSED',
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "TOTAL CALLED",
                            message:
                                'Total called can be filtered \nusing a specific date range to determine \nthe count of total leads within that period.',
                            fromCard: 'TOTAL',
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "MISSED LEADS",
                            message: 'Missed Leads',
                            fromCard: 'MISSED',
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DashboardCard(
                            title: "TRANSFERRED LEADS",
                            message:
                                'Count of total leads \ntransferred to you.',
                            fromCard: 'TRANSFERRED',
                          ),
                        ),
                      ],
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
}
