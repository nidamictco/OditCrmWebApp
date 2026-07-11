import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/models/follow_up_activities_model.dart';
import 'package:sizer/sizer.dart';

class RecentLeadActivityTile extends StatelessWidget {
  final ActivityModel activity;

  const RecentLeadActivityTile({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Circle Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getBgColor(activity.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(activity.type),
              color: const Color(0xff3b82f6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Middle Text (Title + Description)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(activity),
                  style: AppTextStyle.medium(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: AppTextStyle.small(
                    size: 11.5,
                    color: AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Right Time
          Text(
            _formatTime(activity.changedAt),
            style: AppTextStyle.small(
              size: 11,
              color: AppColors.grey,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(ActivityModel activity) {
    final leadName = activity.leadName ?? 'Unknown Lead';
    switch (activity.type) {
      case ActivityType.followupAdded:
        return 'Follow-up: $leadName';
      case ActivityType.leadCreated:
        return 'Lead Created: $leadName';
      case ActivityType.statusChanged:
        return 'Status Changed: $leadName';
      case ActivityType.staffAssigned:
        return 'Staff Assigned: $leadName';
      case ActivityType.categoryChanged:
        return 'Category Changed: $leadName';
      case ActivityType.priorityChanged:
        return 'Priority Changed: $leadName';
      default:
        // Try to guess from description (e.g. if email was sent)
        if (activity.description.toLowerCase().contains('email')) {
          return 'Email Sent: $leadName';
        }
        return 'Activity: $leadName';
    }
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.followupAdded:
        return Icons.phone;
      case ActivityType.leadCreated:
        return Icons.person_add_outlined;
      case ActivityType.statusChanged:
        return Icons.cached_outlined;
      case ActivityType.staffAssigned:
        return Icons.assignment_ind_outlined;
      default:
        return Icons.mail_outline;
    }
  }

  Color _getBgColor(ActivityType type) {
    return const Color(0xffeff6ff); // very light blue
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final activityDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (activityDate == todayStart) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (activityDate == yesterdayStart) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yy').format(dateTime);
    }
  }
}
