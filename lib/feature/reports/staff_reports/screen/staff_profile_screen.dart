import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/reports/staff_reports/widget/note_dialog.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/add_staff/screen/add_staff.dart';
import 'package:sizer/sizer.dart';

// // ─────────────────────────────────────────────
// // DATA MODELS
// // ─────────────────────────────────────────────

class StaffInfo {
  final String name;
  final String role;
  final String mobile;
  final String email;
  final String address;
  final String joiningDate;
  final String createdBy;
  final String createdDate;
  final String status;

  const StaffInfo({
    required this.name,
    required this.role,
    required this.mobile,
    required this.email,
    required this.address,
    required this.joiningDate,
    required this.createdBy,
    required this.createdDate,
    required this.status,
  });
}

class CallStatusData {
  final String cloudCallDuration;
  final String phoneCallDuration;
  final int closedCount;
  final int costAmount;
  final int totalCalled;
  final Map<String, int> leadsByCategory;

  const CallStatusData({
    required this.cloudCallDuration,
    required this.phoneCallDuration,
    required this.closedCount,
    required this.costAmount,
    required this.totalCalled,
    required this.leadsByCategory,
  });
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  String _selectedDate = '29-04-2026';

  final StaffInfo _staff = const StaffInfo(
    name: 'Shibina',
    role: 'Telecalling',
    mobile: '9747339991',
    email: '',
    address: '',
    joiningDate: '',
    createdBy: 'Oxdo Technologies Pvt Ltd',
    createdDate: '18-04-2026',
    status: 'Active',
  );

  final CallStatusData _callData = const CallStatusData(
    cloudCallDuration: '-',
    phoneCallDuration: '-',
    closedCount: 0,
    costAmount: 0,
    totalCalled: 0,
    leadsByCategory: {
      'New': 0,
      'Follow Up': 0,
      'Rejected': 0,
      'Closed': 0,
      'Pending': 0,
    },
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverHeader(innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildOverviewTab(), _buildDocumentsTab()],
        ),
      ),
    );
  }

  // ─── SLIVER HEADER ───────────────────────────────────────

  SliverAppBar _buildSliverHeader(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 35.h,
      pinned: true,
      backgroundColor: const Color(0xFF1E3A5F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        _StatusDropdown(status: _staff.status),
        SizedBox(width: 1.w),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const NotesDialog(),
            );
          },
          icon: Icon(Icons.note_alt_outlined, size: 16),
          label: Text(
            'Open Notes',
            style: AppTextStyle.medium(size: 11.sp, color: AppColors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2B5BA8),
            foregroundColor: Colors.white,
            textStyle: AppTextStyle.small(size: 11.sp, color: AppColors.white),
            padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(width: 1.w),
        Container(
          margin: EdgeInsets.only(right: 1.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(selectedIndex: 15),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _ProfileHeader(staff: _staff),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: const Color(0xFF1E3A5F),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: AppTextStyle.medium(
              weight: FontWeight.w700,
              size: 12.sp,
            ),
            unselectedLabelStyle: AppTextStyle.medium(
              weight: FontWeight.w400,
              size: 12.sp,
            ),
            tabs: [
              Tab(
                child: Text(
                  'Overview',
                  style: AppTextStyle.medium(
                    // weight: FontWeight.w00,
                    color: AppColors.white,
                    size: 11.sp,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Staff Document',
                  style: AppTextStyle.medium(
                    // weight: FontWeight.w700,
                    size: 11.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── OVERVIEW TAB ────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(2.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Information Card
              Expanded(flex: 4, child: _InformationCard(staff: _staff)),
              const SizedBox(width: 16),
              // Right: Call Status
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _CallStatusCard(
                      data: _callData,
                      selectedDate: _selectedDate,
                      onDateChanged: (d) => setState(() => _selectedDate = d),
                    ),
                    SizedBox(height: 16),
                    RecentActivityCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Container(
      // width: double.infinity,
      margin: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Documents',
                    style: AppTextStyle.medium(
                      color: AppColors.black,
                      size: 13.sp,
                      weight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 5.h,
                      width: 6.5.w,
                      decoration: BoxDecoration(
                        color: Color(0xFF1E3A5F),
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          "Upload",
                          style: AppTextStyle.medium(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  child: CustomTable(
                    columns: [
                      // TableColumn(title: "", flex: 1),
                      TableColumn(title: "File Type", flex: 4),
                      TableColumn(title: "FileName", flex: 4),
                      TableColumn(title: "Date Modified", flex: 4),
                      TableColumn(title: "Action", flex: 2),
                    ],
                    rows:
                        [
                          ["png", "name", "1234567890", "Telecalling"],
                          ["pdf", "name", "1234567890", "Telecalling"],
                          ["docx", "name", "1234567890", "Telecalling"],
                          ["xlxs", "name", "1234567890", "Telecalling"],
                        ].map((row) {
                          return [
                            Text(row[0], style: AppTextStyle.medium()),
                            Text(row[1], style: AppTextStyle.medium()),
                            Text(row[2], style: AppTextStyle.medium()),
                            Center(
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 14.sp,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ];
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE HEADER WIDGET
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final StaffInfo staff;
  const _ProfileHeader({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2442), Color(0xFF1E3A5F), Color(0xFF2D5F8A)],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
          // Content
          Padding(
            // padding:  EdgeInsets.fromLTRB(20, 80, 20, 60),
            padding: EdgeInsets.fromLTRB(3.w, 6.h, 2.w, 6.h),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 7.5.w,
                  height: 7.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D5F8A),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 44,
                  ),
                ),
                SizedBox(width: 1.5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      staff.name,
                      style: AppTextStyle.medium(
                        color: Colors.white,
                        size: 16.sp,
                        weight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.5.w,
                        vertical: 0.5.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff.role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.white54,
                          size: 16,
                        ),
                        SizedBox(width: 0.2.w),
                        Text(
                          staff.email.isEmpty
                              ? 'No email provided'
                              : staff.email,
                          style: AppTextStyle.small(
                            color: Colors.white54,
                            size: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS DROPDOWN
// ─────────────────────────────────────────────

class _StatusDropdown extends StatefulWidget {
  final String status;
  const _StatusDropdown({required this.status});

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _current,
          isDense: true,
          style: const TextStyle(
            color: Color(0xFF1E3A5F),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          items: [
            'Active',
            'Inactive',
            'On Leave',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _current = v!),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFORMATION CARD
// ─────────────────────────────────────────────

class _InformationCard extends StatelessWidget {
  final StaffInfo staff;
  const _InformationCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1),
              ),
            ),
            child: const Text(
              'Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Name', value: staff.name),
                _InfoRow(label: 'Mobile', value: staff.mobile),
                _InfoRow(
                  label: 'Email',
                  value: staff.email.isEmpty ? '—' : staff.email,
                ),
                _InfoRow(
                  label: 'Address',
                  value: staff.address.isEmpty ? '—' : staff.address,
                ),
                _InfoRow(
                  label: 'Joining Date',
                  value: staff.joiningDate.isEmpty ? '—' : staff.joiningDate,
                ),
                _InfoRow(label: 'Created By', value: staff.createdBy),
                _InfoRow(
                  label: 'Created Date',
                  value: staff.createdDate,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF7FAFC), width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF2D3748)),
            ),
          ),
        ],
      ),
    );
  }
}

// // ─────────────────────────────────────────────
// // CALL STATUS CARD
// // ─────────────────────────────────────────────

// class _CallStatusCard extends StatelessWidget {
//   final CallStatusData data;
//   final String selectedDate;
//   final ValueChanged<String> onDateChanged;

//   const _CallStatusCard({
//     required this.data,
//     required this.selectedDate,
//     required this.onDateChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Call Status Details',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1A202C),
//                   ),
//                 ),
//                 _DateBadge(date: selectedDate),
//               ],
//             ),
//           ),
//           const Divider(height: 24, color: Color(0xFFEDF2F7)),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stats column
//                 Expanded(
//                   flex: 5,
//                   child: Column(
//                     children: [
//                       // Time Duration
//                       _StatCard(
//                         color: const Color(0xFFF7FAFC),
//                         borderColor: const Color(0xFFE2E8F0),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                     color: const Color(0xFFE2E8F0)),
//                               ),
//                               child: const Icon(Icons.access_time_outlined,
//                                   color: Color(0xFF4A5568), size: 22),
//                             ),
//                             const SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'TIME DURATION',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF2D3748),
//                                         letterSpacing: 0.5,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     GestureDetector(
//                                       onTap: () {},
//                                       child: const Text(
//                                         'View',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Color(0xFF2B5BA8),
//                                           fontWeight: FontWeight.w600,
//                                           decoration: TextDecoration.underline,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'CLOUD CALL : ${data.cloudCallDuration}',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Color(0xFF718096)),
//                                 ),
//                                 Text(
//                                   'PHONE CALL : ${data.phoneCallDuration}',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Color(0xFF718096)),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Closed
//                       _StatCard(
//                         color: const Color(0xFFF0FFF4),
//                         borderColor: const Color(0xFFC6F6D5),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF48BB78).withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Icon(Icons.celebration_outlined,
//                                   color: Color(0xFF38A169), size: 22),
//                             ),
//                             const SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'CLOSED',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w700,
//                                     color: Color(0xFF276749),
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${data.closedCount}',
//                                   style: const TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.w800,
//                                     color: Color(0xFF276749),
//                                     height: 1.1,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Cost
//                       _StatCard(
//                         color: const Color(0xFFFFF5F7),
//                         borderColor: const Color(0xFFFED7E2),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFFC8181).withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Icon(Icons.receipt_long_outlined,
//                                   color: Color(0xFFE53E3E), size: 22),
//                             ),
//                             const SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'COST',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w700,
//                                     color: Color(0xFF742A2A),
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${data.costAmount}',
//                                   style: const TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.w800,
//                                     color: Color(0xFF742A2A),
//                                     height: 1.1,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Total Called Progress
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'TOTAL CALLED',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700,
//                                   color: Color(0xFF4A5568),
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               Text(
//                                 '${data.totalCalled}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w700,
//                                   color: Color(0xFF1A202C),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: LinearProgressIndicator(
//                               value: data.totalCalled == 0
//                                   ? 0.0
//                                   : data.totalCalled / 100.0,
//                               minHeight: 10,
//                               backgroundColor: const Color(0xFFE2E8F0),
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                   Color(0xFF38B2AC)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Right: Donut chart + legend
//                 Expanded(
//                   flex: 4,
//                   child: Column(
//                     children: [
//                       _DonutChart(leadsByCategory: data.leadsByCategory),
//                       const SizedBox(height: 16),
//                       _LeadLegend(leadsByCategory: data.leadsByCategory),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final Color color;
//   final Color borderColor;
//   final Widget child;

//   const _StatCard({
//     required this.color,
//     required this.borderColor,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: borderColor),
//       ),
//       child: child,
//     );
//   }
// }

class _DateBadge extends StatelessWidget {
  final String date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7FAFC),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: Color(0xFF718096),
          ),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// // ─────────────────────────────────────────────
// // DONUT CHART
// // ─────────────────────────────────────────────

// class _DonutChart extends StatelessWidget {
//   final Map<String, int> leadsByCategory;
//   const _DonutChart({required this.leadsByCategory});

//   @override
//   Widget build(BuildContext context) {
//     final total = leadsByCategory.values.fold(0, (a, b) => a + b);

//     return SizedBox(
//       width: 140,
//       height: 140,
//       child: CustomPaint(
//         painter: _DonutPainter(
//           data: leadsByCategory,
//           total: total,
//           colors: const [
//             Color(0xFF4299E1),
//             Color(0xFF48BB78),
//             Color(0xFFFC8181),
//             Color(0xFF38B2AC),
//             Color(0xFFECC94B),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '$total',
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF1A202C),
//                 ),
//               ),
//               const Text(
//                 'Total\nLeads',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Color(0xFF718096),
//                   height: 1.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DonutPainter extends CustomPainter {
//   final Map<String, int> data;
//   final int total;
//   final List<Color> colors;

//   _DonutPainter({
//     required this.data,
//     required this.total,
//     required this.colors,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = math.min(size.width, size.height) / 2;
//     const strokeWidth = 22.0;

//     final bgPaint = Paint()
//       ..color = const Color(0xFFE2E8F0)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth;

//     canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

//     if (total == 0) return;

//     double startAngle = -math.pi / 2;
//     int idx = 0;
//     for (final entry in data.entries) {
//       if (entry.value == 0) {
//         idx++;
//         continue;
//       }
//       final sweep = (entry.value / total) * 2 * math.pi;
//       final paint = Paint()
//         ..color = colors[idx % colors.length]
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = strokeWidth
//         ..strokeCap = StrokeCap.round;

//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
//         startAngle,
//         sweep,
//         false,
//         paint,
//       );
//       startAngle += sweep;
//       idx++;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

class _LeadLegend extends StatelessWidget {
  final Map<String, int> leadsByCategory;
  const _LeadLegend({required this.leadsByCategory});

  static const _colors = [
    Color(0xFF4299E1),
    Color(0xFF48BB78),
    Color(0xFFFC8181),
    Color(0xFF38B2AC),
    Color(0xFFECC94B),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = leadsByCategory.entries.toList();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${e.value}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECENT ACTIVITY CARD
// ─────────────────────────────────────────────

// class _RecentActivityCard extends StatelessWidget {
//   const _RecentActivityCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Recent Activity',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1A202C),
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2B5BA8).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Today',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF2B5BA8),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 20, color: Color(0xFFEDF2F7)),
//           const Padding(
//             padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
//             child: Row(
//               children: [
//                 Icon(Icons.inbox_outlined, color: Color(0xFFCBD5E0), size: 28),
//                 SizedBox(width: 12),
//                 Text(
//                   'No activities today',
//                   style: TextStyle(
//                     color: Color(0xFF718096),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────
// BACKGROUND PATTERN PAINTER
// ─────────────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ONLY showing UPDATED / NEW PARTS (keep your models same)

/// =============================
/// CALL STATUS (UPDATED UI)
/// =============================
class _CallStatusCard extends StatefulWidget {
  final CallStatusData data;
  final String selectedDate;
  final ValueChanged<String> onDateChanged;

  const _CallStatusCard({
    required this.data,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<_CallStatusCard> createState() => __CallStatusCardState();
}

class __CallStatusCardState extends State<_CallStatusCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const Divider(height: 24),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _leftStats()),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: _rightChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Call Status Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _DateBadge(date: widget.selectedDate),
        ],
      ),
    );
  }

  /// LEFT SIDE
  Widget _leftStats() {
    return Column(
      children: [
        _timeCard(),
        const SizedBox(height: 12),
        _miniStat("Closed", widget.data.closedCount, Colors.green),
        const SizedBox(height: 12),
        _miniStat("Cost", widget.data.costAmount, Colors.purple),
        const SizedBox(height: 16),

        /// ALL PROGRESS BARS (PIXEL MATCH)
        _progress("TOTAL CALLED", 156, 1),
        _progress("NO STATUS UPDATED", 3, 0.02),
        _progress("CONNECTED", 41, 0.3),
        _progress("BUSY", 4, 0.03),
        _progress("REJECTED", 7, 0.05),
        _progress("SWITCHED OFF", 11, 0.08),
        _progress("OUT OF COVERAGE AREA", 4, 0.03),
        _progress("NOT ATTENDED", 86, 0.7),
      ],
    );
  }

  Widget _timeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "TIME DURATION",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              SizedBox(height: 4),
              Text("CLOUD CALL : -"),
              Text("PHONE CALL : -"),
            ],
          ),
          const Spacer(),
          const Text(
            "View",
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: color),
          const SizedBox(width: 10),
          Text(title.toUpperCase()),
          const Spacer(),
          Text(
            "$value",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _progress(String label, int value, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text("$value"),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  /// RIGHT SIDE
  Widget _rightChart() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          width: 200,
          child: _DonutChart(
            leadsByCategory: {"Follow Up": 85, "Rejected": 15},
          ),
        ),
        const SizedBox(height: 20),
        _categoryTable(),
      ],
    );
  }

  Widget _categoryTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _row(true, "Category", "New", "Follow Up", "Rejected", "Closed"),
          _row(false, "Uncategorized", "0", "1", "0", "0"),
          _row(false, "Need Followup", "0", "57", "2", "0"),
          _row(false, "Not Contacted", "0", "67", "19", "0"),
          _row(false, "Fake", "0", "5", "2", "0"),
          _row(false, "Visited", "0", "3", "0", "0"),
        ],
      ),
    );
  }

  Widget _row(
    bool header,
    String c1,
    String c2,
    String c3,
    String c4,
    String c5,
  ) {
    final style = TextStyle(
      fontWeight: header ? FontWeight.bold : FontWeight.normal,
      fontSize: 12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: header ? Colors.grey.shade100 : null,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(c1, style: style)),
          Expanded(child: Text(c2, style: style)),
          Expanded(child: Text(c3, style: style)),
          Expanded(child: Text(c4, style: style)),
          Expanded(child: Text(c5, style: style)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.05)),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final Map<String, int> leadsByCategory;

  const _DonutChart({required this.leadsByCategory});

  @override
  Widget build(BuildContext context) {
    final total = leadsByCategory.values.fold<int>(0, (sum, val) => sum + val);

    final colors = [
      const Color(0xFF4F6BED), // blue
      const Color(0xFF7BC96F), // green
      const Color(0xFFF87171), // red
      const Color(0xFF38B2AC), // teal
      const Color(0xFFECC94B), // yellow
    ];

    final entries = leadsByCategory.entries.toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 2,
            centerSpaceRadius: 45, // 🔥 donut thickness control
            sections: List.generate(entries.length, (i) {
              final value = entries[i].value.toDouble();

              if (value == 0) {
                return PieChartSectionData(value: 0, color: Colors.transparent);
              }

              return PieChartSectionData(
                value: value,
                color: colors[i % colors.length],
                radius: 22,
                showTitle: false,
              );
            }),
          ),
        ),

        /// CENTER TEXT (pixel perfect)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$total",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Total\nLeads",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecentActivityItem {
  final String name;
  final String phone;
  final String description;
  final String subText;
  final String date;

  const RecentActivityItem({
    required this.name,
    required this.phone,
    required this.description,
    required this.subText,
    required this.date,
  });
}

/// =============================
/// MAIN CARD
/// =============================
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _dummyData(); // replace with API later

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const Divider(height: 20),

          ListView.builder(
            itemCount: data.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemBuilder: (context, index) {
              return _TimelineItem(
                item: data[index],
                isLast: index == data.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4F6BED)),
            ),
            child: const Text(
              "Today",
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.05)),
      ],
    );
  }

  /// MOCK DATA (Replace with API)
  List<RecentActivityItem> _dummyData() {
    return const [
      RecentActivityItem(
        name: "Mhd Midlaj",
        phone: "919946093476",
        description:
            "Status changed to Follow Up. Next followup scheduled to 05-05-2026 12:00",
        subText: "Cost Updated from to 0",
        date: "30 Apr 2026 10:04 AM",
      ),
      RecentActivityItem(
        name: "ANSAR",
        phone: "919048260868",
        description:
            "Status changed to Follow Up. Next followup scheduled to 04-05-2026 12:00",
        subText: "Cost Updated from to 0",
        date: "30 Apr 2026 09:58 AM",
      ),
      RecentActivityItem(
        name: "Ashil Ahammed",
        phone: "919207479701",
        description:
            "Status changed to Follow Up. Next followup scheduled to 02-05-2026 12:00",
        subText: "Cost Updated from to 0",
        date: "30 Apr 2026 09:52 AM",
      ),
      RecentActivityItem(
        name: "MUSTHAFA",
        phone: "919567530979",
        description:
            "Status changed to Follow Up. Next followup scheduled to 30-04-2026 12:00",
        subText: "Cost Updated from to 0",
        date: "28 Apr 2026 10:43 AM",
      ),
    ];
  }
}

class _TimelineItem extends StatelessWidget {
  final RecentActivityItem item;
  final bool isLast;

  const _TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT TIMELINE
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

          /// RIGHT CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME + PHONE
                  Text(
                    "${item.name} -${item.phone}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// DESCRIPTION
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2D3748),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// SUB TEXT
                  Text(
                    item.subText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2D3748),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// DATE
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
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE6F4F1),
      ),
      child: const Text(
        "M",
        style: TextStyle(color: Color(0xFF38B2AC), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4;
    const dashSpace = 3;

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
