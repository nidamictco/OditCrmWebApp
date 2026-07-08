
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/widget/cloud_call_tab.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/widget/folow_up_tab.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/widget/phone_log_tab.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  int selectedTab = 0;

  final tabs = ["Cloud Call History", "Follow Up History", "Phone Log"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TopBreadcrumbBar(title: "Lead Management", subTitle: 'Call History'),
          Expanded(
            child: SingleChildScrollView(
              // ✅ FIXED
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _header(),
                      SizedBox(height: 0.5.h),

                      /// TABS
                      Row(
                        children: List.generate(
                          tabs.length,
                          (i) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTab = i),
                              child: _tabItem(tabs[i], i == selectedTab),
                            ),
                          ),
                        ),
                      ),

                      // Divider(color: AppColors.divider),
                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case 0:
        return const CloudCallTab();
      case 1:
        return const FollowUpTab();
      case 2:
        return const PhoneLogTab();
      default:
        return const SizedBox();
    }
  }

  /// ---------- COMMON ----------

  Widget _header() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Call History",
            style: AppTextStyle.medium(
              size: 13.6.sp,
              color: AppColors.black.withOpacity(0.77),
              weight: FontWeight.w600,
            ),
          ),
          Container(
            height: 4.h,
            width: 4.h,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 71, 174, 243),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: BrowserAwareLink(
                destination: RoutePaths.outgoingCallHistory,
                usePush: true,
                enableInkWell: false,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.contact_phone_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String text, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 🔹 Top green line
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: active ? AppColors.green : Colors.transparent,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(
              top: BorderSide(
                color: active ? Colors.transparent : AppColors.divider,
                width: 2,
              ),
            ),
          ),
        ),

        /// 🔹 Tab body
        Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          color: active ? AppColors.greyCard : AppColors.white,
          alignment: Alignment.center,
          child: Text(
            text,
            style: AppTextStyle.medium(
              size: 11.sp,
              color: active ? AppColors.green : AppColors.grey,
            ),
          ),
        ),

        /// 🔹 Bottom divider
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}
