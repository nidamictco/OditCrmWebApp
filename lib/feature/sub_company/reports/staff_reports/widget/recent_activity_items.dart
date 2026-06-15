
// ─────────────────────────────────────────────
// RECENT ACTIVITY
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/models/follow_up_activities_model.dart';

class RecentActivityItem {
  final String name;
  final String phone;
  final String description;
  // final String subText;
  final String date;

  const RecentActivityItem({
    required this.name,
    required this.phone,
    required this.description,
    // required this.subText,
    required this.date,
  });
}

class RecentActivityCard extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;

  const RecentActivityCard({
    super.key,
    required this.activities,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const Divider(height: 1),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: activities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemBuilder: (context, index) => TimelineItem(
                item: _toDisplayItem(activities[index]),
                isLast: index == activities.length - 1,
              ),
            ),
        ],
      ),
    );
  }

  /// Maps an ActivityModel to the existing RecentActivityItem display object.
  RecentActivityItem _toDisplayItem(ActivityModel m) {
    return RecentActivityItem(
      name: m.leadName ?? m.changedBy,
      phone: m.leadPhone ?? '',
      description: m.description,
      date: _formatActivityDate(m.changedAt),
    );
  }

 String _formatActivityDate(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ap = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4F6BED)),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4F6BED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.05)),
    ],
  );
}


class TimelineItem extends StatelessWidget {
  final RecentActivityItem item;
  final bool isLast;

  const TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              _circle(),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(painter: _DottedLinePainter()),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.name} - ${item.phone}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2D3748),
                      height: 1.4,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   item.subText,
                  //   style: const TextStyle(
                  //     fontSize: 13,
                  //     color: Color(0xFF2D3748),
                  //   ),
                  // ),
                  const SizedBox(height: 6),
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle() {
    // Use first letter of name as avatar
    final initial = item.name.isNotEmpty ? item.name[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE6F4F1),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF38B2AC),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}


class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    final paint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

