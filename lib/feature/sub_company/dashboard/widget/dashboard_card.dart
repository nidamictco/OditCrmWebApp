import 'dart:developer';

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/tool_tips.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
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
  final String? dateText;
  final double? width;

  const DashboardCard({
    super.key,
    required this.title,
    required this.message,
    required this.fromCard,
    this.dateText,
    this.width,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool isHovering = false;
  StaffModel? staff;

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> getCurrentUser() async {
    final user = await SessionService().getSavedUser();
    staff = user;
  }

  IconData _getCardIcon() {
    switch (widget.fromCard) {
      case 'NEW':
        return Icons.leaderboard_outlined;
      case 'FOLLOWUP':
        return Icons.person_outline_sharp;
      case 'CLOSED':
        return Icons.folder_open_outlined;
      case 'TOTAL':
        return Icons.phone_in_talk_outlined;
      case 'MISSED':
        return Icons.call_missed;
      case 'TRANSFERRED':
        return Icons.compare_arrows_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getCardBgColor() {
    switch (widget.fromCard) {
      case 'NEW':
        return AppThemeColors.basicGreen;
      case 'FOLLOWUP':
        return const Color(0xff6C99F2);
      case 'CLOSED':
        return const Color(0xff7A43D2);
      case 'TOTAL':
        return const Color(0xff002660);
      case 'MISSED':
        return const Color(0xffDF655A);
      case 'TRANSFERRED':
        return const Color(0xff5177AE);
      default:
        return AppColors.primary;
    }
  }

  Color _getCardBgColor1() {
    switch (widget.fromCard) {
      case 'NEW':
        return const Color(0xffe6fbf4);
      case 'FOLLOWUP':
        return const Color(0xffeff6ff);
      case 'CLOSED':
        return const Color(0xfffaf5ff);
      case 'TOTAL':
        return const Color(0xffeff6ff);
      case 'MISSED':
        return const Color(0xfffef2f2);
      case 'TRANSFERRED':
        return const Color(0xffe0e7ff);
      default:
        return AppColors.primary.withOpacity(0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
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
            count = state.totalCalledCount;
            break;
          case 'MISSED':
            count = state.missedLeadCount;
            break;
          case 'TRANSFERRED':
            count = state.transferredCount;
            break;
        }

        final staffId = staff?.id;
        String? dateStr;
        if (widget.fromCard == "TOTAL") {
          if (widget.dateText != null && widget.dateText!.isNotEmpty) {
            try {
              final parsedDate = DateFormat(
                'dd-MM-yyyy',
              ).parse(widget.dateText!);
              dateStr = parsedDate.toIso8601String();
            } catch (_) {
              dateStr = state.selectedDashboardDate?.toIso8601String();
            }
          } else {
            dateStr = null;
          }
        } else {
          dateStr = state.selectedDashboardDate?.toIso8601String();
        }

        final path = Uri(
          path: RoutePaths.newLeads,
          queryParameters: {
            if (widget.fromCard.isNotEmpty) 'fromCard': widget.fromCard,
            if (dateStr != null) 'selectedDate': dateStr,
            if (staffId != null) 'staffId': staffId,
          },
        ).toString();

        return MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: BrowserAwareLink(
            destination: path,
            usePush: true,
            enableInkWell: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isHovering ? -6 : 0, 0),
              width: widget.width ?? 18.w,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovering
                        ? Colors.black.withOpacity(0.08)
                        : Colors.black.withOpacity(0.02),
                    blurRadius: isHovering ? 16 : 8,
                    offset: Offset(0, isHovering ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row (Icon + Actions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getCardBgColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCardIcon(),
                          color: AppColors.white,
                          // color: _getCardColor(),
                          size: 20,
                        ),
                      ),
                      Row(
                        children: [
                          // GestureDetector(
                          //   onTap: () {
                          //     showLeadsDialog(
                          //       context: context,
                          //       title: "${widget.title.toUpperCase()} LEADS",
                          //       value: count,
                          //     );
                          //   },
                          //   child: Icon(
                          //     Symbols.vital_signs,
                          //     size: 14.sp,
                          //     color: Colors.indigoAccent[400]?.withOpacity(0.7),
                          //   ),
                          // ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.north_east,
                            size: 14.sp,
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title Text
                  Text(
                    widget.title,
                    style: AppTextStyle.medium(
                      color: AppThemeColors.cardText,
                      weight: FontWeight.w500,
                      size: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Metric Count
                  Text(
                    count.padLeft(2, '0'),
                    style: AppTextStyle.heading(
                      size: 16,
                      weight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
