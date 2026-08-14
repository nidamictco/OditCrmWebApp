import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/models/follow_up_activities_model.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_state.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/donut_chart.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/notes_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';

class StaffInfo {
  final String name;
  final String role;
  final String mobile;
  final String email;
  final String address;
  final String joiningDate;
  final String createdDate;
  final String status;

  const StaffInfo({
    required this.name,
    required this.role,
    required this.mobile,
    required this.email,
    required this.address,
    required this.joiningDate,
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
  final Map<String, int> callResultCounts;

  const CallStatusData({
    required this.cloudCallDuration,
    required this.phoneCallDuration,
    required this.closedCount,
    required this.costAmount,
    required this.totalCalled,
    required this.leadsByCategory,
    this.connectedCount = 0,
    this.notConnectedCount = 0,
    this.callResultCounts = const {},
  });
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.year}';

String _formatDateDisplay(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')} '
    '${_monthName(dt.month)}, '
    '${dt.year}';

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

StaffInfo _staffInfoFromModel(StaffModel model) => StaffInfo(
  name: model.name,
  role: model.designation ?? model.staffType ?? '—',
  mobile: model.phone,
  email: model.email ?? '',
  address: '',
  joiningDate: model.joiningDate ?? '',
  createdDate: model.createdAt != null ? _formatDate(model.createdAt!) : '—',
  status: model.status,
);

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class StaffProfileScreen extends StatefulWidget {
  final StaffModel staff;

  const StaffProfileScreen({super.key, required this.staff});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  DateTime? _selectedDateValue;
  DateTime? _toDateValue;

  late StaffModel _liveModel;

  static const _defaultLeadsByCategory = <String, int>{
    'New': 0,
    'Follow Up': 0,
    'Rejected': 0,
    'Closed': 0,
    'Transferred': 0,
  };

  static const _categoryColors = <String, Color>{
    'New': Color(0xFF0085FF),
    'Follow-Up': Color(0xFF00B16E),
    'Follow Up': Color(0xFF00B16E),
    'Rejected': Color(0xFFEF4444),
    'Closed': Color(0xFF00B4D8),
    'Transferred': Color(0xFFF97316),
    'Pending': Color(0xFFF97316),
  };

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _refreshCounts() {
    final staffId = _liveModel.id ?? '';
    final role = _liveModel.staffType ?? '';
    final date = _selectedDateValue ?? DateTime.now();

    context.read<AddLeadCubit>().fetchLeadChartCounts(
      staffId: staffId,
      role: role,
      selectedDate: date,
      toDate: _toDateValue,
    );

    context.read<AddLeadCubit>().fetchProfileCounts(
      date,
      staffId: staffId,
      role: role,
    );

    context.read<AddLeadCubit>().fetchCallStatusCounts(
      staffId: staffId,
      role: role,
      selectedDate: _selectedDateValue,
      toDate: _toDateValue,
    );
  }

  @override
  void didUpdateWidget(covariant StaffProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.staff.id != oldWidget.staff.id) {
      setState(() {
        _liveModel = widget.staff;
      });
      _refreshCounts();
    }
  }

  @override
  void initState() {
    super.initState();
    _liveModel = widget.staff;
    _selectedDateValue = DateTime.now();
    _toDateValue = null;

    if (widget.staff.id != null) {
      context.read<StaffCubit>().getStaff(widget.staff.id!);
    }

    _refreshCounts();

    if (widget.staff.id != null) {
      context.read<StaffActivityCubit>().load(widget.staff.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddLeadCubit, AddLeadState>(
      listener: (context, leadState) {
        if (leadState.status == AddLeadStatus.success &&
            leadState.successMessage != null &&
            leadState.successMessage!.toLowerCase().contains('follow-up')) {
          _refreshCounts();
        }
      },
      child: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state is StaffLoaded) {
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
          final staffInfo = _staffInfoFromModel(_liveModel);

          final isInitialLoad =
              state is StaffLoading && _liveModel == widget.staff;

          if (isInitialLoad) {
            return Scaffold(
              backgroundColor: AppThemeColors.scaffoldBg,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppThemeColors.scaffoldBg,
            endDrawer: NotesDrawer(staffId: widget.staff.id!),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Header Card ──
                  _buildProfileHeaderCard(staffInfo),
                  const SizedBox(height: 12),
                  // ── Stats Summary Row ──
                  _buildStatsRow(),
                  const SizedBox(height: 12),
                  // ── 3-Column Body ──
                  _buildThreeColumnBody(staffInfo),
                  const SizedBox(height: 12),
                  // ── Bottom Row: Category Table + Recent Activity ──
                  _buildBottomRow(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── PROFILE HEADER CARD ───────────────────────────────────
  Widget _buildProfileHeaderCard(StaffInfo staffInfo) {
    final hasImage =
        _liveModel.imageUrl != null && _liveModel.imageUrl!.trim().isNotEmpty;
    final isActive = staffInfo.status.toLowerCase() == 'active';
    final memberSince = _liveModel.createdAt != null
        ? _formatDateDisplay(_liveModel.createdAt!)
        : '—';

    final maskedPassword = _liveModel.password.isNotEmpty
        ? (_liveModel.password.length > 4
              ? '***${_liveModel.password.substring(_liveModel.password.length - 4)}'
              : _liveModel.password)
        : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(hasImage),
              const SizedBox(width: 16),
              // Name, designation, status badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          staffInfo.name.isNotEmpty ? staffInfo.name : '—',
                          style: AppTextStyle.medium(
                            size: 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            // Deactivate / Activate Profile button
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () async {
                                  final newStatus = isActive
                                      ? 'Inactive'
                                      : 'Active';
                                  if (_liveModel.id != null) {
                                    await context
                                        .read<StaffCubit>()
                                        .updateStatus(
                                          _liveModel.id!,
                                          newStatus,
                                        );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isActive
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFF10B981),
                                    ),
                                  ),
                                  child: Text(
                                    isActive
                                        ? 'Deactivate Profile'
                                        : 'Activate Profile',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isActive
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Edit Profile button
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  context.push(
                                    RoutePaths.staffEditPath(_liveModel.id!),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF002660),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 12,
                                        color: Color(0xFF1E293B),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF002660),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add Note button
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  context.read<StaffCubit>().fetchNotes(
                                    widget.staff.id!,
                                  );
                                  _scaffoldKey.currentState?.openEndDrawer();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F8FCE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.post_add_outlined,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add Note',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staffInfo.role.isNotEmpty ? staffInfo.role : '—',
                      style: AppTextStyle.medium(
                        size: 11.5,
                        color: AppThemeColors.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Active badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF10B981)
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Phone
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: AppThemeColors.commonText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              staffInfo.mobile.isNotEmpty
                                  ? staffInfo.mobile
                                  : '—',
                              style: AppTextStyle.medium(
                                size: 11.5,
                                color: AppThemeColors.commonText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Email
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 13,
                              color: AppThemeColors.commonText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              staffInfo.email.isNotEmpty
                                  ? staffInfo.email
                                  : '—',
                              style: AppTextStyle.medium(
                                size: 11.5,
                                color: AppThemeColors.commonText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Member since
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppThemeColors.commonText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Member Since: $memberSince',
                              style: AppTextStyle.medium(
                                size: 11.5,
                                color: AppThemeColors.commonText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Password & Change link
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 13,
                              color: AppThemeColors.appPrimaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Password',
                              style: AppTextStyle.medium(
                                size: 11.5,
                                color: AppThemeColors.appPrimaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              maskedPassword,
                              style: AppTextStyle.medium(
                                size: 11.5,
                                color: AppThemeColors.commonText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .push(
                                        RoutePaths.changePasswordPath(
                                          _liveModel.id!,
                                        ),
                                      )
                                      .then((_) {
                                        if (context.mounted) {
                                          context.read<StaffCubit>().fetchAll();
                                        }
                                      });
                                },
                                child: Text(
                                  'Change?',
                                  style: AppTextStyle.medium(
                                    size: 11.5,
                                    color: const Color(0xFF017EFB),
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF017EFB),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisSize: MainAxisSize.max,
              //   children: [
              //     Row(
              //       children: [
              //         // Deactivate / Activate Profile button
              //         MouseRegion(
              //           cursor: SystemMouseCursors.click,
              //           child: GestureDetector(
              //             onTap: () async {
              //               final newStatus = isActive ? 'Inactive' : 'Active';
              //               if (_liveModel.id != null) {
              //                 await context.read<StaffCubit>().updateStatus(
              //                   _liveModel.id!,
              //                   newStatus,
              //                 );
              //               }
              //             },
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 8,
              //                 vertical: 4,
              //               ),
              //               decoration: BoxDecoration(
              //                 color: Colors.white,
              //                 borderRadius: BorderRadius.circular(6),
              //                 border: Border.all(
              //                   color: isActive
              //                       ? const Color(0xFFFCA5A5)
              //                       : const Color(0xFF10B981),
              //                 ),
              //               ),
              //               child: Text(
              //                 isActive
              //                     ? 'Deactivate Profile'
              //                     : 'Activate Profile',
              //                 style: TextStyle(
              //                   fontSize: 10,
              //                   fontWeight: FontWeight.w500,
              //                   color: isActive
              //                       ? const Color(0xFFEF4444)
              //                       : const Color(0xFF10B981),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 8),
              //         // Edit Profile button
              //         MouseRegion(
              //           cursor: SystemMouseCursors.click,
              //           child: GestureDetector(
              //             onTap: () {
              //               context.push(
              //                 RoutePaths.staffEditPath(_liveModel.id!),
              //               );
              //             },
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 8,
              //                 vertical: 4,
              //               ),
              //               decoration: BoxDecoration(
              //                 color: Colors.white,
              //                 borderRadius: BorderRadius.circular(6),
              //                 border: Border.all(
              //                   color: const Color(0xFF002660),
              //                 ),
              //               ),
              //               child: const Row(
              //                 children: [
              //                   Icon(
              //                     Icons.edit_outlined,
              //                     size: 12,
              //                     color: Color(0xFF1E293B),
              //                   ),
              //                   SizedBox(width: 4),
              //                   Text(
              //                     'Edit Profile',
              //                     style: TextStyle(
              //                       fontSize: 10,
              //                       fontWeight: FontWeight.w500,
              //                       color: Color(0xFF002660),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 8),
              //         // Add Note button
              //         MouseRegion(
              //           cursor: SystemMouseCursors.click,
              //           child: GestureDetector(
              //             onTap: () {
              //               context.read<StaffCubit>().fetchNotes(
              //                 widget.staff.id!,
              //               );
              //               _scaffoldKey.currentState?.openEndDrawer();
              //             },
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 8,
              //                 vertical: 4,
              //               ),
              //               decoration: BoxDecoration(
              //                 color: const Color(0xFF2F8FCE),
              //                 borderRadius: BorderRadius.circular(6),
              //               ),
              //               child: const Row(
              //                 children: [
              //                   Icon(
              //                     Icons.post_add_outlined,
              //                     size: 12,
              //                     color: Colors.white,
              //                   ),
              //                   SizedBox(width: 4),
              //                   Text(
              //                     'Add Note',
              //                     style: TextStyle(
              //                       fontSize: 10,
              //                       fontWeight: FontWeight.w500,
              //                       color: Colors.white,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),

              //     const SizedBox(height: 28),
              //     Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         const Icon(
              //           Icons.lock_outlined,
              //           size: 16,
              //           color: Color(0xFF002660),
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           'Password',
              //           style: AppTextStyle.medium(
              //             size: 12.5,
              //             color: const Color(0xFF002660),
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         Text(
              //           maskedPassword,
              //           style: AppTextStyle.medium(
              //             size: 12.5,
              //             color: const Color(0xFF334155),
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         MouseRegion(
              //           cursor: SystemMouseCursors.click,
              //           child: GestureDetector(
              //             onTap: () async {
              //               final staffCubit = context.read<StaffCubit>();
              //               await context.push(
              //                 RoutePaths.changePasswordPath(_liveModel.id!),
              //               );
              //               if (mounted) {
              //                 staffCubit.fetchAll();
              //               }
              //             },
              //             child: Text(
              //               'Change?',
              //               style: AppTextStyle.medium(
              //                 size: 12.5,
              //                 color: const Color(0xFF017EFB),
              //                 fontWeight: FontWeight.w500,
              //                 decoration: TextDecoration.underline,
              //                 decorationColor: const Color(0xFF017EFB),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
          // const SizedBox(height: 10),
          // Contact & Security metadata strip
          // Row(
          //   children: [
          //     // Phone
          //     Row(
          //       children: [
          //         const Icon(
          //           Icons.phone_outlined,
          //           size: 13,
          //           color: AppThemeColors.commonText,
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           staffInfo.mobile.isNotEmpty ? staffInfo.mobile : '—',
          //           style: AppTextStyle.medium(
          //             size: 11.5,
          //             color: AppThemeColors.commonText,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ],
          //     ),
          //     const SizedBox(width: 20),
          //     // Email
          //     Row(
          //       children: [
          //         const Icon(
          //           Icons.email_outlined,
          //           size: 13,
          //           color: AppThemeColors.commonText,
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           staffInfo.email.isNotEmpty ? staffInfo.email : '—',
          //           style: AppTextStyle.medium(
          //             size: 11.5,
          //             color: AppThemeColors.commonText,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ],
          //     ),
          //     const SizedBox(width: 20),
          //     // Member since
          //     Row(
          //       children: [
          //         const Icon(
          //           Icons.calendar_today_outlined,
          //           size: 13,
          //           color: AppThemeColors.commonText,
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           'Member Since: $memberSince',
          //           style: AppTextStyle.medium(
          //             size: 11.5,
          //             color: AppThemeColors.commonText,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ],
          //     ),
          //     const Spacer(),
          //     // Password & Change link
          //     Row(
          //       children: [
          //         const Icon(
          //           Icons.lock_outline,
          //           size: 13,
          //           color: AppThemeColors.appPrimaryColor,
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           'Password',
          //           style: AppTextStyle.medium(
          //             size: 11.5,
          //             color: AppThemeColors.appPrimaryColor,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           maskedPassword,
          //           style: AppTextStyle.medium(
          //             size: 11.5,
          //             color: AppThemeColors.commonText,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //         const SizedBox(width: 6),
          //         MouseRegion(
          //           cursor: SystemMouseCursors.click,
          //           child: GestureDetector(
          //             onTap: () {
          //               context
          //                   .push(RoutePaths.changePasswordPath(_liveModel.id!))
          //                   .then((_) {
          //                     if (context.mounted) {
          //                       context.read<StaffCubit>().fetchAll();
          //                     }
          //                   });
          //             },
          //             child: Text(
          //               'Change?',
          //               style: AppTextStyle.medium(
          //                 size: 11.5,
          //                 color: const Color(0xFF017EFB),
          //                 fontWeight: FontWeight.w500,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: const Color(0xFF017EFB),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool hasImage) {
    if (!hasImage) {
      return const CircleAvatar(
        radius: 32,
        backgroundColor: Color(0xFFE2E8F0),
        child: Icon(Icons.person, size: 36, color: Color(0xFF94A3B8)),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFFE2E8F0),
      child: ClipOval(
        child: Image.network(
          _liveModel.imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            return const Icon(Icons.person, size: 36, color: Color(0xFF94A3B8));
          },
        ),
      ),
    );
  }

  // ─── STATS ROW ───────────────────────────────────────────
  Widget _buildStatsRow() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, leadState) {
        final totalCalled =
            int.tryParse(leadState.profileTotalCalledCount) ?? 0;
        final completed = int.tryParse(leadState.profileConnectedCount) ?? 0;
        final closed = int.tryParse(leadState.profileClosedCount) ?? 0;

        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.phone_in_talk,
                iconBgColor: const Color(0xFF0085FF),
                label: 'Total Called',
                value: totalCalled.toString().padLeft(2, '0'),
                cardColor: const Color(0xFFEEF6FF),
                borderColor: const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                icon: Icons.check_circle_outline,
                iconBgColor: const Color(0xFF00B16E),
                label: 'Completed',
                value: completed.toString().padLeft(2, '0'),
                cardColor: const Color(0xFFE6F9F3),
                borderColor: const Color(0xFFA7F3D0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                icon: Icons.folder_outlined,
                iconBgColor: const Color(0xFF8B5CF6),
                label: 'Closed',
                value: closed.toString().padLeft(2, '0'),
                cardColor: const Color(0xFFF3EEFF),
                borderColor: const Color(0xFFDDD6FE),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBgColor,
    required String label,
    required String value,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.medium(
                  size: 10.5,
                  color: AppThemeColors.commonText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconBgColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 3-COLUMN BODY ───────────────────────────────────────
  Widget _buildThreeColumnBody(StaffInfo staffInfo) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, leadState) {
        final liveCallData = CallStatusData(
          cloudCallDuration: '-',
          phoneCallDuration: '-',
          closedCount: int.tryParse(leadState.profileClosedCount) ?? 0,
          costAmount: 0,
          totalCalled: int.tryParse(leadState.profileTotalCalledCount) ?? 0,
          leadsByCategory: leadState.leadChartCounts.isNotEmpty
              ? leadState.leadChartCounts
              : _defaultLeadsByCategory,
          connectedCount: int.tryParse(leadState.profileConnectedCount) ?? 0,
          notConnectedCount:
              int.tryParse(leadState.profileNotConnectedCount) ?? 0,
          callResultCounts: leadState.profileCallResultCounts,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Information
              Expanded(flex: 3, child: _buildInformationSection(staffInfo)),
              // Vertical divider
              Container(
                width: 1,
                height: 260,
                color: const Color(0xFFF1F5F9),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              // Column 2: Call Status Details
              Expanded(flex: 4, child: _buildCallStatusSection(liveCallData)),
              // Vertical divider
              Container(
                width: 1,
                height: 260,
                color: const Color(0xFFF1F5F9),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              // Column 3: Lead Status
              Expanded(flex: 3, child: _buildLeadStatusSection(liveCallData)),
            ],
          ),
        );
      },
    );
  }

  // ─── INFORMATION SECTION ───────────────────────────────────
  Widget _buildInformationSection(StaffInfo staffInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMATION',
          style: AppTextStyle.medium(
            size: 11.5,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.appPrimaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        _infoRow('Name:', staffInfo.name.isNotEmpty ? staffInfo.name : '—'),
        _infoRow(
          'Mobile:',
          staffInfo.mobile.isNotEmpty ? staffInfo.mobile : '—',
        ),
        _infoRow('Email:', staffInfo.email.isNotEmpty ? staffInfo.email : '—'),
        _infoRow(
          'Join Date:',
          staffInfo.joiningDate.isNotEmpty ? staffInfo.joiningDate : '—',
        ),
        _infoRow('Created Date:', staffInfo.createdDate),
        const SizedBox(height: 12),
        _infoRow(
          'Address:',
          staffInfo.address.isNotEmpty ? staffInfo.address : '—',
          isMultiLine: true,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.medium(
                size: 11.5,
                color: AppThemeColors.commonText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.medium(
                size: 11.5,
                color: AppThemeColors.commonText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CALL STATUS SECTION ───────────────────────────────────
  Widget _buildCallStatusSection(CallStatusData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CALL STATUS DETAILS',
          style: AppTextStyle.medium(
            size: 11.5,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.appPrimaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        _callStatusRow(
          'Total Called',
          data.totalCalled,
          data.totalCalled,
          const Color(0xFF0F2442), // Dark Navy
        ),
        const SizedBox(height: 14),
        _callStatusRow(
          'Connected',
          data.connectedCount,
          data.totalCalled,
          const Color(0xFF00B16E), // Green
        ),
        const SizedBox(height: 14),
        _callStatusRow(
          'Closed',
          data.closedCount,
          data.totalCalled,
          const Color(0xFF8B5CF6), // Purple
        ),
        const SizedBox(height: 14),
        _callStatusRow(
          'Total Connected',
          data.notConnectedCount,
          data.totalCalled,
          const Color(0xFF00B4D8), // Teal/Cyan
        ),
      ],
    );
  }

  Widget _callStatusRow(String label, int value, int total, Color barColor) {
    final percent = total > 0
        ? (value / total * 100).round()
        : (value > 0 ? 100 : 0);
    final fraction = '$value/$total';
    final progress = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyle.medium(
                size: 11.5,
                color: AppThemeColors.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              fraction,
              style: AppTextStyle.medium(
                size: 12.5,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress == 0 ? 0.0 : progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── LEAD STATUS SECTION ───────────────────────────────────
  Widget _buildLeadStatusSection(CallStatusData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEAD STATUS',
          style: AppTextStyle.medium(
            size: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Donut chart
        Center(
          child: SizedBox(
            height: 130,
            width: 130,
            child: DonutChart(leadsByCategory: data.leadsByCategory),
          ),
        ),
        const SizedBox(height: 12),
        // Dynamic Grid legend
        _buildLeadLegendGrid(data.leadsByCategory),
      ],
    );
  }

  Widget _buildLeadLegendGrid(Map<String, int> leadsByCategory) {
    final entries = leadsByCategory.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> rows = [];
    for (int i = 0; i < entries.length; i += 2) {
      final item1 = entries[i];
      final item2 = i + 1 < entries.length ? entries[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(child: _legendItem(item1.key, item1.value, total, i)),
            if (item2 != null)
              Expanded(child: _legendItem(item2.key, item2.value, total, i + 1))
            else
              const Spacer(),
          ],
        ),
      );
      if (i + 2 < entries.length) {
        rows.add(const SizedBox(height: 6));
      }
    }

    return Column(children: rows);
  }

  Widget _legendItem(String label, int count, int total, int colorIndex) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    const fallbackColors = [
      Color(0xFF0085FF),
      Color(0xFF00B16E),
      Color(0xFFEF4444),
      Color(0xFF00B4D8),
      Color(0xFFF97316),
      Color(0xFF8B5CF6),
    ];
    final color =
        _categoryColors[label] ??
        fallbackColors[colorIndex % fallbackColors.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '$count ($pct%)',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── BOTTOM ROW ───────────────────────────────────────────
  Widget _buildBottomRow() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, leadState) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Lead Category Status
            Expanded(
              flex: 5,
              child: _buildCategoryStatusSection(
                leadState.leadCategoryTableRows,
              ),
            ),
            const SizedBox(width: 16),
            // Right: Recent Activity
            Expanded(flex: 5, child: _buildRecentActivitySection()),
          ],
        );
      },
    );
  }

  // ─── LEAD CATEGORY STATUS TABLE ───────────────────────────
  Widget _buildCategoryStatusSection(List<LeadCategoryTableRow> categoryRows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEAD CATEGORY STATUS',
            style: AppTextStyle.medium(
              size: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          // Table header strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'New',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Followup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Reject',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Close',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Table Rows from Cubit/Repo
          if (categoryRows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No data',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
            )
          else
            ...categoryRows.map(
              (r) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.newCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.followUpCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.rejectedCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.closedCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
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

  // ─── RECENT ACTIVITY SECTION ───────────────────────────────
  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: AppTextStyle.medium(
                  size: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View All',
                    style: AppTextStyle.medium(
                      size: 12.5,
                      color: const Color(0xFF2F8FCE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<StaffActivityCubit, StaffActivityState>(
            builder: (context, state) {
              if (state is StaffActivityLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final items = state is StaffActivityLoaded
                  ? state.activities
                  : <ActivityModel>[];

              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 32,
                          color: Color(0xFFCBD5E0),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'No recent activity',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final displayItems = items.take(4).toList();

              return Column(
                children: displayItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return _activityItem(
                    activity,
                    isLast: index == displayItems.length - 1,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _activityItem(ActivityModel activity, {bool isLast = false}) {
    final name = activity.leadName ?? activity.changedBy;
    final phone = activity.leadPhone ?? '';
    final description = activity.description;
    final date = _formatActivityDateTime(activity.changedAt);

    Color avatarBgColor = const Color(0xFF0085FF);
    if (description.toLowerCase().contains('call')) {
      avatarBgColor = const Color(0xFF00B16E);
    } else if (description.toLowerCase().contains('lead')) {
      avatarBgColor = const Color(0xFF0085FF);
    } else if (description.toLowerCase().contains('profile') ||
        description.toLowerCase().contains('update')) {
      avatarBgColor = const Color(0xFF8B5CF6);
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarBgColor,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone.isNotEmpty ? '$name-$phone' : name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  String _formatActivityDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────
// LEAD CATEGORY TABLE ROW
// ─────────────────────────────────────────────

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
