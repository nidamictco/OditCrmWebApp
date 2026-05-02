import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/top_bread_crumb_bar.dart';
import 'models/follow_up_details_models.dart';

class FollowUpDetailsScreen extends StatefulWidget {
  const FollowUpDetailsScreen({super.key});

  @override
  State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
}

class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen>  with SingleTickerProviderStateMixin{

  late TabController _tabController;

  /// ── Sample Data ──────────────────────────────────────────
  final List<FollowupEntry> _followups = const [
    FollowupEntry(
      date: '20-04-2026',
      time: '04:41 AM',
      agent: 'Shahid',
      calledDate: '20-04-2026 04:41 AM',
      callStatus: 'Connected',
      tags: 'Costly',
      remark: 'her husband not allowing to go to pmna to learn something',
      status: 'Rejected',
      products: '',
    ),
    FollowupEntry(
      date: '19-04-2026',
      time: '08:39 PM',
      agent: 'Shahid',
      calledDate: '19-04-2026 08:39 PM',
      callStatus: 'Connected',
      tags: 'Interested',
      remark: 'Will call back tomorrow morning',
      status: 'Follow Up',
      products: '',
    ),
  ];

  final List<ActivityEntry> _activities = const [
    ActivityEntry(
      agent: 'Shahid',
      description:
      'Status changed to Rejected. Cost Updated from to 0\nLead Category Updated from May Visit to',
      dateTime: '20-04-2026 04:42 PM',
    ),
    ActivityEntry(
      agent: 'Shahid',
      description:
      'Status changed to Follow Up. Next followup scheduled to 20-04-2026 10:38\nCost Updated from to 0',
      dateTime: '19-04-2026 08:39 PM',
    ),
    ActivityEntry(
      agent: 'Shahid',
      description: 'Lead Created. Assigned to Shahid',
      dateTime: '18-04-2026 06:30 PM',
    ),
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:Column(
        children: [
          TopBreadcrumbBar(
            subTitle: 'Details',
            title: 'Lead Management',
            subTitle2: 'Lead List',
            show2ndTitle: true,
            showMenu: true,
          ),
          SizedBox(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FollowupTab(followups: _followups),
                      _ActivitiesTab(activities: _activities),
                      const _DetailsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

// ── Header ───────────────────────────────────────────────
Widget _buildHeader() {
  return Container(
    color: const Color(0xFFFFF3E0),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with back button
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: Color(0xFF444444)),
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Sanidha',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(width: 10),
                _PriorityBadge(label: 'Lead priority: High'),
                const Spacer(),
                // Action icons
                _headerIcon(Icons.edit_outlined, onTap: () {}),
                const SizedBox(width: 4),
                _headerIcon(Icons.swap_horiz, onTap: () {}),
                const SizedBox(width: 4),
                _headerIcon(Icons.add_box_outlined, onTap: () {}),
                const SizedBox(width: 4),
                _headerIcon(Icons.delete_outline,
                    color: Colors.red.shade300, onTap: () {}),
              ],
            ),
          ),

          // Meta row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _metaItem(Icons.phone, '8086287726'),
                _divider(),
                _metaItem(Icons.location_on_outlined, 'Karuvarkund, Malappuram'),
                _divider(),
                _metaText('Create Date : 18 Apr, 2026'),
                _divider(),
                _metaText('category :'),
                _divider(),
                _metaText('Staff : Shahid'),
                _divider(),
                _metaText('Cost : 0'),
                _divider(),
                _StatusBadge(label: 'Rejected', color: const Color(0xFF2196F3)),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _metaText('Lead Source : Ads'),
          ),
          const SizedBox(height: 10),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: const Color(0xFF888888),
            indicatorColor: const Color(0xFF1565C0),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Followup'),
              Tab(text: 'Activities'),
              Tab(text: 'Details'),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _headerIcon(IconData icon,
    {Color color = const Color(0xFF555555), VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Icon(icon, size: 22, color: color),
  );
}

Widget _metaItem(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: const Color(0xFF777777)),
      const SizedBox(width: 3),
      Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
      ),
    ],
  );
}

Widget _metaText(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
  );
}

Widget _divider() {
  return const Text('|',
      style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)));
}
}

// ─────────────────────────────────────────────────────────
// Tab 1 – Followup
// ─────────────────────────────────────────────────────────

class _FollowupTab extends StatelessWidget {
  final List<FollowupEntry> followups;
  const _FollowupTab({required this.followups});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<FollowupEntry>> grouped = {};
    for (final f in followups) {
      grouped.putIfAbsent(f.date, () => []).add(f);
    }
    final dates = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top bar
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Followup Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const Spacer(),
                // WhatsApp button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: const [
                      Icon(Icons.chat, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Add Follow-up button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                  ),
                  child: const Text(
                    'Add Follow-up',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: dates.length,
              itemBuilder: (ctx, i) {
                final date = dates[i];
                final entries = grouped[date]!;
                return _DateGroup(date: date, entries: entries);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final List<FollowupEntry> entries;

  const _DateGroup({required this.date, required this.entries});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 80,
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Date bubble
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    date,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
                // Vertical line
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFDDDDDD),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((e) => _FollowupCard(entry: e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowupCard extends StatelessWidget {
  final FollowupEntry entry;
  const _FollowupCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time with dot
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF00BCD4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                entry.time,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(Icons.person,
                            size: 16, color: Color(0xFF888888)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.agent,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.edit_outlined,
                          size: 18, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade400),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _cardRow('Called Date', entry.calledDate),
                      const SizedBox(height: 6),
                      _cardRow('Call Status', entry.callStatus),
                      const SizedBox(height: 6),
                      _cardRow('Tags', entry.tags),
                      const SizedBox(height: 6),
                      _cardRow('Remark', ':  -${entry.remark}'),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Status',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Text(': ',
                              style: TextStyle(color: Color(0xFF555555))),
                          const SizedBox(width: 4),
                          _StatusChip(label: entry.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _cardRow('Products', entry.products),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            ':  $value',
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 2 – Activities
// ─────────────────────────────────────────────────────────

class _ActivitiesTab extends StatelessWidget {
  final List<ActivityEntry> activities;
  const _ActivitiesTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((a) => _ActivityItem(entry: a)).toList(),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + vertical line
          Column(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
              ),
              Container(
                width: 1.5,
                height: 40,
                color: const Color(0xFFE0E0E0),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.agent,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.dateTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 3 – Details
// ─────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  const _DetailsTab();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 13,
      color: Color(0xFF888888),
      fontWeight: FontWeight.w500,
    );
    const valueStyle = TextStyle(
      fontSize: 13,
      color: Color(0xFF222222),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),

          // Two-column grid of details
          _DetailGrid(rows: const [
            ['Phone', '+917902207315', 'Address', 'Cheruplasheri'],
            ['State', '', 'District', ''],
            ['Post office', '', 'Pincode', ''],
            ['Whatsapp_number', '+917902207315', 'Email', ''],
            ['Created Date', '25 Apr, 2026', 'Created By', 'Oxdo technologies pvt ltd'],
            ['Lead Category', 'May Visit', 'Assigned Staff', 'Shahid'],
            ['Cost', '0', 'Call Status', 'Follow Up'],
            ['Products', '', '', ''],
          ]),

          const SizedBox(height: 8),

          // Lead Method & Remarks
          _detailRow(
            labelStyle: labelStyle,
            valueStyle: valueStyle,
            left: 'Lead Method',
            leftVal: 'Direct Entry',
            right: 'Remarks',
            rightVal:
            'planning to visit on 4th may with friends, some friends are in different places. will try to visit before 4th otherwise will come on 4th',
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          const Text(
            'Lead handled staffs',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StaffCard(
                  name: 'Oxdo technologies pvt ltd',
                  phone: '9207554433',
                  activities: 1,
                  isStarred: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StaffCard(
                  name: 'Shahid',
                  phone: '918089131915',
                  activities: 2,
                  isStarred: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailRow({
    required TextStyle labelStyle,
    required TextStyle valueStyle,
    required String left,
    required String leftVal,
    required String right,
    required String rightVal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$left :', style: labelStyle),
                const SizedBox(height: 2),
                Text(leftVal, style: valueStyle),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$right :', style: labelStyle),
                const SizedBox(height: 2),
                Text(rightVal, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<List<String>> rows;
  const _DetailGrid({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DetailCell(label: row[0], value: row[1])),
              const SizedBox(width: 12),
              Expanded(child: _DetailCell(label: row[2], value: row[3])),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  const _DetailCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label :',
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
        ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final String name;
  final String phone;
  final int activities;
  final bool isStarred;

  const _StaffCard({
    required this.name,
    required this.phone,
    required this.activities,
    required this.isStarred,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEECC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 6),
                Text(
                  '$activities Activities',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
          if (isStarred)
            const Icon(Icons.star, color: Color(0xFFFFA000), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final String label;
  const _PriorityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5722),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  Color get _color {
    switch (label.toLowerCase()) {
      case 'rejected':
        return const Color(0xFFFF5722);
      case 'follow up':
        return const Color(0xFF2196F3);
      case 'connected':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
