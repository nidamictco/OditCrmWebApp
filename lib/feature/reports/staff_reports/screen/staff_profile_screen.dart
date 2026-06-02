import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/custom_date_range_picker.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/lead_managment/follow_up/models/follow_up_activities_model.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/reports/staff_reports/cubit/staff_activity_cubit.dart';
import 'package:oxdo/feature/reports/staff_reports/cubit/staff_activity_state.dart';
import 'package:oxdo/feature/reports/staff_reports/widget/calender.dart';
import 'package:oxdo/feature/reports/staff_reports/widget/donut_chart.dart';
import 'package:oxdo/feature/reports/staff_reports/widget/note_dialog.dart';
import 'package:oxdo/feature/reports/staff_reports/widget/recent_activity_items.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class StaffInfo {
  final String name;
  final String role;
  final String mobile;
  final String email;
  final String address;
  final String joiningDate;
  // final String createdBy;
  final String createdDate;
  final String status;

  const StaffInfo({
    required this.name,
    required this.role,
    required this.mobile,
    required this.email,
    required this.address,
    required this.joiningDate,
    // required this.createdBy,
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
  final int connectedCount;
  final int notConnectedCount;

  const CallStatusData({
    required this.cloudCallDuration,
    required this.phoneCallDuration,
    required this.closedCount,
    required this.costAmount,
    required this.totalCalled,
    required this.leadsByCategory,
    this.connectedCount = 0,
    this.notConnectedCount = 0,
  });
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.year}';

StaffInfo _staffInfoFromModel(StaffModel model) => StaffInfo(
  name: model.name,
  role: model.designation ?? model.staffType ?? '—',
  mobile: model.phone,
  email: model.email ?? '',
  address: '',
  joiningDate: model.joiningDate ?? '',
  // createdBy: model.createdBY ?? '',
  createdDate: model.createdAt != null ? _formatDate(model.createdAt!) : '—',
  status: model.status,
);

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class StaffProfileScreen extends StatefulWidget {
  /// Pass the staff model from the list screen.
  final StaffModel staff;

  const StaffProfileScreen({super.key, required this.staff});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  late String _selectedDate;

  late StaffModel _liveModel;

  // Placeholder call data — wire up your calls API here when ready
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
    _liveModel = widget.staff;
    _selectedDate = _formatDate(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });

    // Refresh latest staff data from Firestore
    if (widget.staff.id != null) {
      context.read<StaffCubit>().getStaff(widget.staff.id!);
    }
    context.read<AddLeadCubit>().fetchLeadChartCounts(
      staffId: widget.staff.id ?? '',
      role: widget.staff.staffType ?? '',
      selectedDate: DateTime.now(),
    );
    context.read<AddLeadCubit>().fetchDashboardCounts(
      DateTime.now(),
      staffId: widget.staff.id,
      role: widget.staff.staffType,
    );

    if (widget.staff.id != null) {
      context.read<StaffActivityCubit>().load(widget.staff.id!);
    }

    context.read<AddLeadCubit>().fetchCallStatusCounts(
      staffId: widget.staff.id ?? '',
      role: widget.staff.staffType ?? '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return BlocConsumer<StaffCubit, StaffState>(
  //     listener: (context, state) {
  //        if (state is StaffLoaded) {
  //       setState(() => _liveModel = state.staff);
  //     }
  //       if (state is StaffError) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(state.message),
  //             backgroundColor: Colors.red.shade700,
  //           ),
  //         );
  //       }
  //     },
  //     builder: (context, state) {

  //       // Use freshly loaded staff if available, fall back to widget.staff
  //       final liveModel = state is StaffLoaded ? state.staff : widget.staff;
  //       final staffInfo = _staffInfoFromModel(liveModel);

  //       if (state is StaffLoading) {
  //         return Scaffold(
  //           backgroundColor: const Color(0xFFF5F6FA),
  //           body: Column(
  //             children: [
  //               // Keep the header visible while loading
  //               Container(
  //                 height: 15.h,
  //                 decoration: const BoxDecoration(
  //                   gradient: LinearGradient(
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                     colors: [
  //                       Color(0xFF0F2442),
  //                       Color(0xFF1E3A5F),
  //                       Color(0xFF2D5F8A),
  //                     ],
  //                   ),
  //                 ),
  //                 child: SafeArea(
  //                   child: Row(
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(
  //                           Icons.arrow_back_ios_new,
  //                           color: Colors.white,
  //                         ),
  //                         onPressed: () => Navigator.pop(context),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               const Expanded(
  //                 child: Center(child: CircularProgressIndicator()),
  //               ),
  //             ],
  //           ),
  //         );
  //       }

  //       return Scaffold(
  //         backgroundColor: const Color(0xFFF5F6FA),
  //         body: NestedScrollView(
  //           headerSliverBuilder: (context, innerBoxIsScrolled) => [
  //             _buildSliverHeader(innerBoxIsScrolled, staffInfo, liveModel),
  //           ],
  //           body: TabBarView(
  //             controller: _tabController,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.all(0.8.w),
  //                 child: _buildOverviewTab(staffInfo),
  //               ),
  //               _buildDocumentsTab(liveModel),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffLoaded) {
          // ✅ Update cached model whenever fresh data arrives
          setState(() => _liveModel = state.staff);
        }
        if (state is StaffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        // ✅ Always use _liveModel — immune to NotesLoading/NotesLoaded/etc
        final staffInfo = _staffInfoFromModel(_liveModel);

        // Only show full loading screen before we have any live data
        final isInitialLoad =
            state is StaffLoading && _liveModel == widget.staff;

        if (isInitialLoad) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                Container(
                  height: 15.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F2442),
                        Color(0xFF1E3A5F),
                        Color(0xFF2D5F8A),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverHeader(innerBoxIsScrolled, staffInfo, _liveModel),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: EdgeInsets.all(0.8.w),
                  child: _buildOverviewTab(staffInfo),
                ),
                _buildDocumentsTab(_liveModel),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── SLIVER HEADER ───────────────────────────────────────

  SliverAppBar _buildSliverHeader(
    bool innerBoxIsScrolled,
    StaffInfo staffInfo,
    StaffModel liveModel,
  ) {
    return SliverAppBar(
      expandedHeight: 35.h,
      pinned: true,
      backgroundColor: const Color(0xFF1E3A5F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _StatusDropdown(status: staffInfo.status, staffId: widget.staff.id),
        SizedBox(width: 1.w),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => BlocProvider.value(
                value: context.read<StaffCubit>()..fetchNotes(widget.staff.id!),
                child: NotesDialog(id: widget.staff.id!),
              ),
            );
          },
          icon: const Icon(Icons.note_alt_outlined, size: 16),
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
                  builder: (context) =>
                      MainScreen(selectedIndex: 15, staff: liveModel),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _ProfileHeader(staff: staffInfo, user: liveModel),
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
                    color: AppColors.white,
                    size: 11.sp,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Staff Document',
                  style: AppTextStyle.medium(
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

  // Widget _buildOverviewTab(StaffInfo staffInfo) {
  //   return SingleChildScrollView(
  //     padding: EdgeInsets.all(2.h),
  //     child: Column(
  //       children: [
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Left: Information Card
  //             Expanded(flex: 4, child: _InformationCard(staff: staffInfo)),
  //             SizedBox(width: 1.7.w),
  //             // Right: Call Status + Recent Activity
  //             Expanded(
  //               flex: 6,
  //               child: Column(
  //                 children: [
  //                   _CallStatusCard(
  //                     data: _callData,
  //                     selectedDate: _selectedDate,
  //                     onDateChanged: (d) => setState(() => _selectedDate = d),
  //                   ),
  //                   SizedBox(height: 3.w),
  //                   const RecentActivityCard(),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOverviewTab(StaffInfo staffInfo) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, leadState) {
        // Use live counts if available, fall back to zeros
        // final liveCallData = CallStatusData(
        //   cloudCallDuration: _callData.cloudCallDuration,
        //   phoneCallDuration: _callData.phoneCallDuration,
        //   closedCount: int.tryParse(leadState.closedLeadCount) ?? 0,
        //   costAmount: _callData.costAmount,
        //   totalCalled: int.tryParse(leadState.totalCalledCount) ?? 0,
        //   leadsByCategory: leadState.leadChartCounts.isNotEmpty
        //       ? leadState.leadChartCounts
        //       : _callData.leadsByCategory,
        // );
        final liveCallData = CallStatusData(
          cloudCallDuration: _callData.cloudCallDuration,
          phoneCallDuration: _callData.phoneCallDuration,
          closedCount: int.tryParse(leadState.closedLeadCount) ?? 0,
          costAmount: _callData.costAmount,
          totalCalled: int.tryParse(leadState.totalCalledCount) ?? 0,
          leadsByCategory: leadState.leadChartCounts.isNotEmpty
              ? leadState.leadChartCounts
              : _callData.leadsByCategory,
          connectedCount: int.tryParse(leadState.connectedCount) ?? 0,
          notConnectedCount: int.tryParse(leadState.notConnectedCount) ?? 0,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(2.h),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _InformationCard(staff: staffInfo)),
                  SizedBox(width: 1.7.w),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        _CallStatusCard(
                          data: liveCallData,
                          selectedDate: _selectedDate,
                          categoryRows: leadState.leadCategoryTableRows,
                          onDateChanged: (date) {
                            // date is now DateTime
                            setState(() => _selectedDate = _formatDate(date));

                            // fetch chart counts for the selected single date
                            context.read<AddLeadCubit>().fetchLeadChartCounts(
                              staffId: widget.staff.id ?? '',
                              role: widget.staff.staffType ?? '',
                              selectedDate: date, // ← actual selected date
                            );

                            // fetch call status for the selected single date
                            context.read<AddLeadCubit>().fetchCallStatusCounts(
                              staffId: widget.staff.id ?? '',
                              role: widget.staff.staffType ?? '',
                              selectedDate:
                                  date, // ← pass if your repo supports it
                            );
                          },
                          onRangeChanged: (from, to) {
                            setState(
                              () => _selectedDate =
                                  '${_formatDate(from)} - ${_formatDate(to)}',
                            );

                            // fetch chart counts for the date range
                            context.read<AddLeadCubit>().fetchLeadChartCounts(
                              staffId: widget.staff.id ?? '',
                              role: widget.staff.staffType ?? '',
                              selectedDate:
                                  from, // pass from; add a `toDate` param if your repo supports range
                              toDate: to, // uncomment when repo supports range
                            );

                            context.read<AddLeadCubit>().fetchCallStatusCounts(
                              staffId: widget.staff.id ?? '',
                              role: widget.staff.staffType ?? '',
                              selectedDate: from,
                              toDate: to,
                            );
                          },
                        ),
                        SizedBox(height: 3.w),
                        // const RecentActivityCard(),
                        BlocBuilder<StaffActivityCubit, StaffActivityState>(
                          builder: (context, state) {
                            if (state is StaffActivityError) {
                              return Text(
                                'Error: ${state.message}',
                              ); // ← add this
                            }
                            final items = state is StaffActivityLoaded
                                ? state.activities
                                : <ActivityModel>[];
                            return RecentActivityCard(
                              activities: items,
                              isLoading: state is StaffActivityLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── DOCUMENTS TAB ───────────────────────────────────────

  Widget _buildDocumentsTab(StaffModel staff) {
    final hasDoc = staff.documentUrl != null && staff.documentName != null;

    final rows = hasDoc
        ? [
            [
              staff.documentName!.contains('.')
                  ? staff.documentName!.split('.').last.toUpperCase()
                  : '—',
              staff.documentName!,
              staff.createdAt != null ? _formatDate(staff.createdAt!) : '—',
              staff.documentUrl!,
            ],
          ]
        : <List<String>>[];

    return Container(
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
            children: [
              // Header row
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
                  Container(
                    height: 5.h,
                    width: 6.5.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'Upload',
                        style: AppTextStyle.medium(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Empty state
              if (rows.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'No documents uploaded',
                          style: AppTextStyle.medium(
                            color: AppColors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                CustomTable(
                  columns: [
                    TableColumn(title: 'File Type', flex: 4),
                    TableColumn(title: 'FileName', flex: 4),
                    TableColumn(title: 'Date Modified', flex: 4),
                    TableColumn(title: 'Action', flex: 2),
                  ],
                  rows: rows.map((row) {
                    return [
                      Text(row[0], style: AppTextStyle.medium()),
                      Text(row[1], style: AppTextStyle.medium()),
                      Text(row[2], style: AppTextStyle.medium()),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: launchUrl(Uri.parse(row[3]));
                          },
                          child: Icon(
                            Icons.remove_red_eye,
                            size: 14.sp,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ];
                  }).toList(),
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
  final StaffModel user;
  const _ProfileHeader({required this.staff, required this.user});

  @override
  Widget build(BuildContext context) {
    final hasImage = user.imageUrl != null && user.imageUrl!.trim().isNotEmpty;

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
          // Background grid pattern
          Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 6.h, 2.w, 6.h),
            child: Row(
              children: [
                // Avatar
                _buildProfileImage(hasImage, user),
                SizedBox(width: 1.5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      staff.name,
                      style: AppTextStyle.medium(
                        color: Colors.white,
                        size: 16.sp,
                        weight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Role badge
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
                    // Email row
                    Row(
                      children: [
                        const Icon(
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

  Widget _buildProfileImage(bool hasImage, StaffModel user) {
    if (!hasImage) {
      return CircleAvatar(
        radius: 7.h,
        backgroundColor: const Color(0xFF2D5F8A),
        child: Icon(Icons.person, size: 24.sp, color: Colors.white54),
      );
    }

    return CircleAvatar(
      radius: 7.5.h,
      // backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          user.imageUrl!,
          width: 17.h,
          height: 17.h,
          fit: BoxFit.cover,
          // Shows a subtle shimmer/spinner while loading on web
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
          // Falls back to person icon if URL is broken or CORS fails
          errorBuilder: (context, error, stack) {
            return Icon(Icons.person, size: 12.sp, color: Colors.grey);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS DROPDOWN
// ─────────────────────────────────────────────

class _StatusDropdown extends StatefulWidget {
  final String status;
  final String? staffId;
  const _StatusDropdown({required this.status, required this.staffId});

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  late String _current;
  final GlobalKey _key = GlobalKey(); // 👈 to find widget position

  @override
  void initState() {
    super.initState();
    _current = widget.status;
  }

  @override
  void didUpdateWidget(_StatusDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      setState(() => _current = widget.status);
    }
  }

  void _showDropdown() async {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // 👇 position menu exactly below the widget
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height, // below the widget
      offset.dx + size.width,
      0,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: ['Active', 'Inactive']
          .map(
            (s) => PopupMenuItem<String>(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: s == 'Active' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selected != null && selected != _current) {
      setState(() => _current = selected);
      if (widget.staffId != null) {
        context.read<StaffCubit>().updateStatus(widget.staffId!, selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _current.toLowerCase() == 'active';

    return GestureDetector(
      key: _key, // 👈 attach key here
      onTap: _showDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _current,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? Colors.green : Colors.red,
            ),
          ],
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
                // _InfoRow(label: 'Created By', value: staff.createdBy),
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

// ─────────────────────────────────────────────
// DATE BADGE
// ─────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  final String date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //      showDialog(
        //   context: context,
        //   barrierColor: Colors.black.withOpacity(0.25),
        //   builder: (_) => CustomDateRangePicker(
        //     initialFromDate: _parse(widget.fromController.text),
        //     initialToDate: _parse(widget.toController.text),
        //     onRangeSelected: (from, to) {
        //       // No setState needed here — listeners handle it
        //       widget.fromController.text = DateFormat('dd-MM-yyyy').format(from);
        //       widget.toController.text = DateFormat('dd-MM-yyyy').format(to);
        //     },
        //   ),
        // );
      },
      child: Container(
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CALL STATUS CARD
// ─────────────────────────────────────────────

class _CallStatusCard extends StatefulWidget {
  final CallStatusData data;
  final String selectedDate;
  final List<LeadCategoryTableRow> categoryRows;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(DateTime from, DateTime to)? onRangeChanged;

  const _CallStatusCard({
    required this.data,
    required this.selectedDate,
    required this.categoryRows,
    required this.onDateChanged,
    this.onRangeChanged,
  });

  @override
  State<_CallStatusCard> createState() => __CallStatusCardState();
}

class __CallStatusCardState extends State<_CallStatusCard> {
  late String _displayLabel; // ← add this

  @override
  void initState() {
    super.initState();
    _displayLabel = widget.selectedDate; // ← initialize from prop
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Divider(height: 4.h),
          Padding(
            padding: EdgeInsets.only(bottom: 1.w, left: 2.w, right: 2.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _leftStats()),
                SizedBox(width: 2.w),
                Expanded(flex: 5, child: _rightChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _header() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Text(
  //           'Call Status Details',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  //         ),
  //         _DateBadge(date: widget.selectedDate),
  //       ],
  //     ),
  //   );
  // }
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Call Status Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          // ← replace _DateBadge with this
          InkWell(
            onTap: () async {
              final result = await showCalendarDialog(context);
              if (result == null) return;

              final label = result.isRange
                  ? '${_formatDate(result.from)} - ${_formatDate(result.to)}'
                  : _formatDate(result.from);

              setState(() => _displayLabel = label);

              if (result.isRange) {
                widget.onRangeChanged?.call(result.from, result.to);
              } else {
                widget.onDateChanged(result.from);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
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
                    // widget.selectedDate,
                    _displayLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
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

  Widget _leftStats() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(0.8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFf5f5f5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // _timeCard(),
              // SizedBox(height: 1.w),
              _miniStat(
                'Closed',
                widget.data.closedCount,
                Colors.green,
                const Color(0xFFbbdbb2),
              ),
              // SizedBox(height: 1.w),
              // _miniStat(
              //   'Cost',
              //   widget.data.costAmount,
              //   Colors.purple,
              //   const Color(0xFFf3d5fd),
              // ),
              SizedBox(height: 1.w),
            ],
          ),
        ),
        SizedBox(height: 1.w),
        // _progress('TOTAL CALLED', 0, 1),
        _progress('TOTAL CALLED', widget.data.totalCalled, 1.0),
        _progress(
          'CONNECTED',
          widget.data.connectedCount,
          widget.data.totalCalled > 0
              ? widget.data.connectedCount / widget.data.totalCalled
              : 0,
        ),
        _progress(
          'NOT CONNECTED',
          widget.data.notConnectedCount,
          widget.data.totalCalled > 0
              ? widget.data.notConnectedCount / widget.data.totalCalled
              : 0,
        ),
        SizedBox(height: 1.w),
      ],
    );
  }

  Widget _timeCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.w),
      decoration: BoxDecoration(
        color: const Color(0xFFe4e4e4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TIME DURATION',
                style: AppTextStyle.medium(
                  color: const Color(0xFF495057),
                  size: 12.sp,
                  weight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(selectedIndex: 30),
                    ),
                  );
                },
                child: Text(
                  'View',
                  style: AppTextStyle.link(
                    color: Colors.blue[900],
                    size: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 40),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'CLOUD CALL : ${widget.data.cloudCallDuration}',
                    style: AppTextStyle.medium(size: 11.sp),
                  ),
                  Text(
                    'PHONE CALL : ${widget.data.phoneCallDuration}',
                    style: AppTextStyle.medium(size: 11.sp),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, int value, Color color, Color containerColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.w),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: color),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: AppTextStyle.medium(size: 11)),
          const Spacer(),
          Text(
            '$value',
            style: AppTextStyle.number(size: 12.sp, weight: FontWeight.bold),
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
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.medium(
                    // size: 1.sp,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '$value',
                style: AppTextStyle.number(
                  size: 11.sp,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.6.h),
          LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  // Widget _rightChart() {
  //   log('Lead categories for chart: ${widget.data.leadsByCategory}');
  //   return Column(
  //     children: [
  //       SizedBox(height: 2.h),
  //       SizedBox(
  //         height: 10.w,
  //         width: 10.w,
  //         // child: _DonutChart(
  //         //   leadsByCategory: widget.data.leadsByCategory.isEmpty
  //         //       ? const {'Follow Up': 85, 'Rejected': 15}
  //         //       : widget.data.leadsByCategory,
  //         // ),
  //         child: DonutChart(
  //           leadsByCategory:
  //               widget.data.leadsByCategory.values.every((v) => v == 0)
  //               ? const {'No Data': 1} // shows a grey slice when all zeros
  //               : widget.data.leadsByCategory,
  //         ),
  //       ),
  //       SizedBox(height: 2.h),
  //       _LeadLegend(leadsByCategory: widget.data.leadsByCategory),
  //       SizedBox(height: 2.h),
  //       _categoryTable(),
  //     ],
  //   );
  // }
  Widget _rightChart() {
    final allZero = widget.data.leadsByCategory.values.every((v) => v == 0);

    return Column(
      children: [
        SizedBox(height: 2.h),
        SizedBox(
          height: 10.w,
          width: 10.w,
          child: allZero
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 9.w,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                )
              : DonutChart(leadsByCategory: widget.data.leadsByCategory),
        ),
        SizedBox(height: 2.h),
        // ✅ Only show legend when there's real data
        if (!allZero) _LeadLegend(leadsByCategory: widget.data.leadsByCategory),
        if (allZero)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No leads available',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
        SizedBox(height: 2.h),
        _categoryTable(),
      ],
    );
  }

  // Widget _categoryTable() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Column(
  //       children: [
  //         _row(true, 'Category', 'New', 'Follow Up', 'Rejected', 'Closed'),
  //         _row(false, 'Uncategorized', '0', '1', '0', '0'),
  //         _row(false, 'Need Followup', '0', '57', '2', '0'),
  //         _row(false, 'Not Contacted', '0', '67', '19', '0'),
  //         _row(false, 'Fake', '0', '5', '2', '0'),
  //         _row(false, 'Visited', '0', '3', '0', '0'),
  //       ],
  //     ),
  //   );
  // }

  Widget _categoryTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _row(true, 'Category', 'New', 'Follow Up', 'Rejected', 'Closed'),
          if (widget.categoryRows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'No data',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            )
          else
            ...widget.categoryRows.map(
              (r) => _row(
                false,
                r.category,
                '${r.newCount}',
                '${r.followUpCount}',
                '${r.rejectedCount}',
                '${r.closedCount}',
              ),
            ),
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
    final style = AppTextStyle.medium(
      size: header ? 10.5.sp : 9.5.sp,
      weight: header ? FontWeight.w500 : FontWeight.w400,
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

class _LeadLegend extends StatelessWidget {
  final Map<String, int> leadsByCategory;
  const _LeadLegend({required this.leadsByCategory});

  // ← must match _DonutChart._colors exactly
  static const _colors = [
    Color(0xFF4F6BED), // New
    Color(0xFF7BC96F), // Follow Up
    Color(0xFFF87171), // Rejected
    Color(0xFF38B2AC), // Closed
    Color(0xFFECC94B), // Pending
    Color(0xFF9F7AEA), // fallback
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
                        color: _colors[i % _colors.length], // ← same index
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
// PAINTERS
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

class LeadCategoryTableRow {
  final String category;
  final int newCount;
  final int followUpCount;
  final int rejectedCount;
  final int closedCount;

  const LeadCategoryTableRow({
    required this.category,
    this.newCount = 0,
    this.followUpCount = 0,
    this.rejectedCount = 0,
    this.closedCount = 0,
  });
}
