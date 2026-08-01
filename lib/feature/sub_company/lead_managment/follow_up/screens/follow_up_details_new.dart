import 'dart:developer';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/dotted_down_arrow.dart';
import 'package:Odit_CRM/core/utils/follow_up_left_notch.dart';
import 'package:Odit_CRM/core/utils/functions.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/utils/custom_calender.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/dropdown_with_add.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/popup_msg.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/screens/widget/calender.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/calender.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/shared_preference/session_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/top_bread_crumb_bar.dart';
import '../../../../../core/utils/transfer_lead_alert.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import '../../leads/data/add_lead_repo.dart';
import '../../leads/model/add_lead_model.dart';
import '../data/activity_repo.dart';
import '../models/follow_up_activities_model.dart';
import '../models/follow_up_details_models.dart';
import '../../../../../core/theme/app_text_style.dart';

import '../models/staff_handler_model.dart';

class FollowUpDetailsNewScreen extends StatefulWidget {
  final AddLeadModel currentLead;
  final String? fromCard;

  const FollowUpDetailsNewScreen({
    super.key,
    required this.currentLead,
    this.fromCard,
  });

  @override
  State<FollowUpDetailsNewScreen> createState() =>
      _FollowUpDetailsNewScreenState();
}

class _FollowUpDetailsNewScreenState extends State<FollowUpDetailsNewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  late AddLeadModel _currentLead;

  final TextEditingController _calledDateCtrl = TextEditingController();
  final TextEditingController _callStatusCtrl = TextEditingController();
  final TextEditingController _nextFollowUpDateCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _WhtsppNoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressm = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _dialogNameCtrl = TextEditingController();

  final List<String> _callStatuses = [
    'Connected',
    'Busy',
    'Not Attended',
    'Switched Off',
    'Out Of Coverage',
    'Wrong Number',
    'Not Reachable',
    'Other',
  ];

  String? _leadStage;
  String? _leadCategory;
  String? _leadPriority;
  String? _leadSubCategory;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.currentLead;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    context.read<AddLeadCubit>().initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calledDateCtrl.dispose();
    _callStatusCtrl.dispose();
    _nextFollowUpDateCtrl.dispose();
    _costCtrl.dispose();
    _WhtsppNoCtrl.dispose();
    _emailCtrl.dispose();
    _addressm.dispose();
    _remarksCtrl.dispose();
    _dialogNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _reloadFollowUps() async {
    log("_reloadFollowUps called");
    try {
      final snap = await FirebaseFirestore.instance
          .collection('LEADS')
          .doc(_currentLead.id)
          .collection('FOLLOW_UPS')
          .orderBy('createdAt', descending: true)
          .get();

      final followUps = snap.docs
          .map((d) => FollowUpModel.fromFirestore(d.data(), d.id))
          .toList();

      if (mounted) {
        setState(() {
          _currentLead = _currentLead.copyWith(followUp: followUps);
        });
      }
    } catch (e) {
      debugPrint('[FollowUpDetailsNewScreen] Failed to reload follow-ups: $e');
    }
    setState(() {});
  }

  Future<void> _reloadLead() async {
    try {
      final lead = await context.read<AddLeadCubit>().getLeadById(
        _currentLead.id!,
      );

      if (!mounted) return;

      setState(() {
        _currentLead = lead!;
      });
    } catch (e) {
      debugPrint("Failed to reload lead: $e");
    }
  }

  void _confirmDelete(BuildContext ctx, AddLeadModel lead) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Lead', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${lead.clientName}"? This action cannot be undone.',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ctx.read<AddLeadCubit>().deleteLead(lead.id!, lead);

              context.pop(ctx);

              final user = await SessionService().getSavedUser();
              context.read<AddLeadCubit>().fetchDashboardLeads(
                staffId: user?.id! ?? "",
                role: user?.staffType ?? "",
                fromCard: widget.fromCard ?? "NEW",
              );

              final path = Uri(
                path: RoutePaths.newLeads,
                queryParameters: {
                  'fromCard': widget.fromCard ?? "NEW",
                  if (user?.id != null) 'staffId': user?.id!,
                },
              ).toString();

              context.go(path);
            },
            child: Text(
              'Delete',
              style: AppTextStyle.medium(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TopBreadcrumbBar(
              //   subTitle: 'Details',
              //   title: 'Dashboard',
              //   subTitle2: 'Lead List',
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   show2ndTitle: true,
              //   showMenu: true,
              // ),
              _buildHeader(),
              SizedBox(height: 15),
              _buildTabBar(),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );

    if (kIsWeb) {
      return scaffold;
    }
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(RoutePaths.dashboard);
        }
      },
      child: scaffold,
    );
  }

  // ── Inline tab content switcher ──────────────────────────
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _NewFollowupTabContent(
          followups: _currentLead.followUp ?? [],
          leadId: _currentLead.id ?? '',
          leadName: _currentLead.clientName ?? '',
          lead: _currentLead,
          onFollowUpAdded: _reloadLead,
          leadCategoryCubit: context.read<LeadCategoryCubit>(),
          onEditFollowUp: (followup) {
            _addFollowUpButton(context, followup, "EDIT", _currentLead);
          },
        );
      case 1:
        return _NewActivitiesTabContent(lead: _currentLead);
      case 2:
        return _NewDetailsTabContent(lead: _currentLead);
      default:
        return const SizedBox();
    }
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        final categoryName = resolveLeadName(
          list: state.categories,
          id: _currentLead.leadCategoryId,
          fallback: _currentLead.leadCategory,
          idOf: (c) => c.id,
          nameOf: (c) => c.name,
        );

        final subCategoryName = resolveLeadName(
          list: state.subCategories,
          id: _currentLead.leadSubCategoryId,
          fallback: _currentLead.leadSubCategory,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        );

        final stageName = resolveLeadName(
          list: state.stages,
          id: _currentLead.leadStageId,
          fallback: _currentLead.leadStage,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        );

        final sourceName = resolveLeadName(
          list: state.sources,
          id: _currentLead.leadSourceId,
          fallback: _currentLead.leadSource,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        );

        return Container(
          padding: EdgeInsets.all(1.8.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000), // #00000014 (8% opacity)
                offset: const Offset(0, 1),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          // color: AppThemeColors.scaffoldBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 8),
              // ── Priority badge + Action buttons row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Badge
                  _NewPriorityBadge(
                    priority: _currentLead.priority,
                    label: 'Lead Priority: ${_currentLead.priority}',
                  ),
                  const Spacer(),
                  // Action Buttons
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: const Color(0xFF017EFB),
                        borderColor: const Color(0xFF017EFB),
                        onTap: () async {
                          final didUpdate = await context.push<bool>(
                            RoutePaths.leadEditPath(_currentLead.id!),
                          );
                          if (didUpdate == true && mounted) {
                            await _reloadLead();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: Colors.red.shade600,
                        borderColor: Colors.red.shade400,
                        iconColor: Colors.red.shade600,
                        onTap: () => _confirmDelete(context, _currentLead),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.swap_vert,
                        label: 'Transfer',
                        color: AppThemeColors.appPrimaryColor,
                        borderColor: AppThemeColors.appPrimaryColor,
                        // trailing: const Icon(
                        //   Icons.filter_list,
                        //   size: 14,
                        //   color: Color(0xFF334155),
                        // ),
                        onTap: () {
                          showAssignStaffDialog(
                            'followup',
                            [_currentLead],
                            context,
                            onSubmit:
                                (
                                  String? selectedStaffId,
                                  String? selectedStaffName,
                                ) async {
                                  if (selectedStaffId == null ||
                                      selectedStaffName == null)
                                    return;

                                  String _resolveTransferredStageId(
                                    BuildContext context,
                                  ) {
                                    final stages = context
                                        .read<AddLeadCubit>()
                                        .state
                                        .stages;
                                    final match = stages.where(
                                      (s) =>
                                          s.name.trim().toUpperCase() ==
                                          'TRANSFERRED',
                                    );
                                    if (match.isEmpty) {
                                      log(
                                        '[Transfer] Could not resolve "TRANSFERRED" stage id — '
                                        'stages loaded=${stages.map((s) => s.name).toList()}',
                                      );
                                      return '';
                                    }
                                    return match.first.id;
                                  }

                                  await context
                                      .read<AddLeadCubit>()
                                      .transferLead(
                                        leadId: _currentLead.id!,
                                        leadName: _currentLead.clientName,
                                        contactNumber:
                                            _currentLead.contactNumber,
                                        leadCategory: _currentLead.leadCategory,
                                        leadCategoryId:
                                            _currentLead.leadCategoryId,
                                        leadSubCategory:
                                            _currentLead.leadSubCategory,
                                        leadSubCategoryId:
                                            _currentLead.leadSubCategoryId,
                                        leadStage: "TRANSFERRED",
                                        leadStageId: _resolveTransferredStageId(
                                          context,
                                        ),
                                        fromStaffId:
                                            _currentLead.assignedStaffId,
                                        fromStaff: _currentLead.assignedStaff,
                                        toStaffId: selectedStaffId,
                                        toStaff: selectedStaffName,
                                      );

                                  await _reloadLead();
                                  setState(() {
                                    _currentLead = _currentLead.copyWith(
                                      assignedStaffId: selectedStaffId,
                                      assignedStaff: selectedStaffName,
                                    );
                                  });
                                  context.pop();
                                  context.pop();
                                  context.read<AddLeadCubit>().fetchLeads();
                                },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.add,
                        label: 'Add',
                        color: AppThemeColors.basicGreen,
                        borderColor: AppThemeColors.basicGreen,
                        onTap: () => context.push(RoutePaths.addLead),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Lead Name ──
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _currentLead.clientName,
                      style: AppTextStyle.heading(
                        size: 16,
                        weight: FontWeight.w700,
                        color: const Color(0xFF3D3D3D),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),

                  // const Spacer(),
                  // Follow-up button
                ],
              ),
              const SizedBox(height: 10),

              // ── Meta Row ──
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _metaChip(
                          Icons.calendar_today_outlined,
                          'Create Date: ${DateFormat("dd MMM, yyyy").format(_currentLead.createdAt ?? DateTime.now())}',
                        ),
                        _metaChip(
                          Icons.phone_outlined,
                          '+91 ${_currentLead.contactNumber ?? ''}',
                        ),
                        _metaChip(
                          Icons.location_on_outlined,
                          _currentLead.address.isNotEmpty
                              ? _currentLead.address
                              : '-',
                        ),
                        _metaChip(
                          Icons.grid_view_outlined,
                          subCategoryName.isNotEmpty
                              ? 'Category: $categoryName - $subCategoryName'
                              : 'Category: $categoryName',
                        ),
                        _metaChip(
                          Icons.link_outlined,
                          'Lead Source: $sourceName',
                        ),
                        _metaChip(
                          Icons.person_outline,
                          'Staff: ${_currentLead.assignedStaff}',
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),
                  Container(
                    // height: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: getStageColor(_currentLead.leadStage),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _currentLead.leadStage == 'FOLLOWUP'
                          ? "Follow-Up"
                          : capitalizeFirstLetter(
                              resolveLeadName(
                                list: state.stages,
                                id: _currentLead.leadStageId,
                                fallback: _currentLead.leadStage,
                                idOf: (s) => s.id,
                                nameOf: (s) => s.name,
                              ),
                            ),
                      style: AppTextStyle.small(
                        size: 12,
                        color: Colors.white,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Tab Bar + Add Follow-Up Button ──

              // const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        return Container(
          height: 63,
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xffF4F6F8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  labelPadding: EdgeInsets.symmetric(horizontal: 10),
                  indicatorPadding: EdgeInsets.zero,

                  padding: EdgeInsets.zero,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  labelColor: const Color(0xFF1565C0),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  indicatorColor: const Color(0xFF1565C0),
                  indicatorWeight: 2,
                  labelStyle: AppTextStyle.heading(
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTextStyle.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: (i) => setState(() => _selectedTab = i),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  tabs: const [
                    Tab(height: 32, text: 'Follow-up'),
                    Tab(height: 32, text: 'Activities'),
                    Tab(height: 32, text: 'Details'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _addFollowUpButton(context, null, "NEW", _currentLead);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.appPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Add Follow-Up',
                  style: AppTextStyle.small(
                    size: 12,
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    Color? iconColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 23,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyle.small(
                size: 10,
                color: color,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 13, color: iconColor ?? color),
            // if (trailing != null) ...[const SizedBox(width: 4), trailing],
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: AppTextStyle.small(
              size: 11,
              color: const Color(0xFF4B5563),
              weight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // ── Helper: show alert dialog ───────────────────────
  void _showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    Color titleColor = const Color(0xFF222222),
    IconData icon = Icons.info_outline,
    Color iconColor = const Color(0xFF2196F3),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.greyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Icon(icon, color: iconColor, size: 85)],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyle.medium(
            color: const Color(0xFF555555),
            size: 12.5.sp,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: AppTextStyle.medium(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addFollowUpButton(
    BuildContext context,
    FollowUpModel? leadFollowup,
    String from,
    AddLeadModel lead,
  ) {
    final cubit = context.read<AddLeadCubit>();

    cubit.setFollowup4Edit();
    cubit.selectLeadStage(null);
    cubit.selectCategory(null);
    cubit.selectSubCategory(null);
    cubit.selectPriority(null);
    cubit.resetStatus();

    final TextEditingController nextFollowUpCtrl = TextEditingController(
      text: DateFormat(
        'dd-MM-yyyy hh:mm a',
      ).format(DateTime.now().add(const Duration(days: 1))),
    );

    DateTime nextFollowUpDate = DateTime.now().add(const Duration(days: 1));
    DateTime calledDateValue = DateTime.now();

    if (from == 'EDIT') {
      cubit.selectCategory(
        resolveLeadName(
          list: cubit.state.categories,
          id: leadFollowup!.leadCategoryId,
          fallback: leadFollowup.leadCategory,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
        pendingSubCategory: resolveLeadName(
          list: cubit.state.subCategories,
          id: leadFollowup.leadSubCategoryId,
          fallback: leadFollowup.leadSubCategory,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
      );
      cubit.selectLeadStage(
        resolveLeadName(
          list: cubit.state.stages,
          id: leadFollowup.leadStageId,
          fallback: leadFollowup.leadStage,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
        pendingTag: resolveLeadName(
          list: cubit.state.leadTag,
          id: leadFollowup.leadTagId,
          fallback: leadFollowup.leadTag,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
      );
      cubit.selectPriority(leadFollowup.priority);
      cubit.selectCallResult(leadFollowup.calledStatus);
      cubit.state.copyWith(successMessage: "", status: AddLeadStatus.initial);

      final editStage =
          (resolveLeadName(
                list: cubit.state.stages,
                id: leadFollowup.leadStageId,
                fallback: leadFollowup.leadStage,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              ).toUpperCase() ==
              'NEW')
          ? 'FOLLOWUP'
          : resolveLeadName(
              list: cubit.state.stages,
              id: leadFollowup.leadStageId,
              fallback: leadFollowup.leadStage,
              idOf: (s) => s.id,
              nameOf: (s) => s.name,
            );
      cubit.selectLeadStage(
        editStage,
        pendingTag: resolveLeadName(
          list: cubit.state.leadTag,
          id: leadFollowup.leadTagId,
          fallback: leadFollowup.leadTag,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
      );
      nextFollowUpCtrl.text = DateFormat(
        'dd-MM-yyyy',
      ).format(leadFollowup.nextFollowUpDate);
      _calledDateCtrl.text = DateFormat(
        'dd-MM-yyyy',
      ).format(leadFollowup.calledDate);
      _callStatusCtrl.text = leadFollowup.calledStatus;
      _remarksCtrl.text = leadFollowup.remarks;
      _emailCtrl.text = lead.email;
      _addressm.text = lead.address;
      _WhtsppNoCtrl.text = lead.whatsappNumber;
      nextFollowUpDate = leadFollowup.nextFollowUpDate;
      calledDateValue = leadFollowup.calledDate;
      _leadPriority = lead.priority;
      _leadCategory = resolveLeadName(
        list: cubit.state.categories,
        id: lead.leadCategoryId,
        fallback: lead.leadCategory,
        idOf: (s) => s.id,
        nameOf: (s) => s.name,
      );
      _leadSubCategory = resolveLeadName(
        list: cubit.state.subCategories,
        id: lead.leadSubCategoryId,
        fallback: lead.leadSubCategory,
        idOf: (s) => s.id,
        nameOf: (s) => s.name,
      );
    } else {
      _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _callStatusCtrl.text = '';
      _remarksCtrl.text = '';
      _emailCtrl.text = lead.email;
      _addressm.text = lead.address;
      _WhtsppNoCtrl.text = lead.whatsappNumber;
      cubit.selectLeadStage('FOLLOWUP');
      cubit.selectCategory(
        resolveLeadName(
          list: cubit.state.categories,
          id: lead.leadCategoryId,
          fallback: lead.leadCategory,
          idOf: (s) => s.id,
          nameOf: (s) => s.name,
        ),
        pendingSubCategory:
            resolveLeadName(
              list: cubit.state.categories,
              id: lead.leadCategoryId,
              fallback: lead.leadCategory,
              idOf: (s) => s.id,
              nameOf: (s) => s.name,
            ).isEmpty
            ? null
            : resolveLeadName(
                list: cubit.state.categories,
                id: lead.leadCategoryId,
                fallback: lead.leadCategory,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              ),
      );
      cubit.selectPriority(lead.priority.isEmpty ? null : lead.priority);
    }

    bool _dialogShown = false;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<AddLeadCubit, AddLeadState>(
          listener: (ctx, state) async {
            if (state.status == AddLeadStatus.success &&
                state.successMessage == 'Follow-up added successfully.' &&
                !_dialogShown) {
              _dialogShown = true;
              await _reloadLead();
              await cubit.fetchDashboardCounts(
                DateTime.now(),
                forceFetch: true,
              );
              Navigator.pop(dialogContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showAlertDialog(
                    context,
                    title: 'Success',
                    message: 'Follow-up added successfully!',
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    titleColor: Colors.green.shade700,
                  );
                }
              });
            }

            if (state.errorMessage != null && !_dialogShown) {
              _dialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ctx.mounted) {
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (alertCtx) => AlertDialog(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Error',
                            style: AppTextStyle.heading(
                              size: 15,
                              weight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        state.errorMessage!,
                        style: AppTextStyle.medium(
                          color: const Color(0xFF555555),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            _dialogShown = false;
                            Navigator.pop(alertCtx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: AppTextStyle.medium(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ).then((_) => _dialogShown = false);
                }
              });
            }
          },
          builder: (ctx, state) {
            final categoryNames = state.categories.map((e) => e.name).toList();
            final subCategoryName = state.subCategories
                .map((e) => e.name)
                .toList();
            final stagesNames = state.stages
                .map((e) => e.name)
                .where((name) => name.toUpperCase() != 'NEW')
                .toList();
            const priority = ['High', 'Low', 'Negative', 'Normal'];

            return StatefulBuilder(
              builder: (sbContext, sbSetState) {
                return AppDialog(
                  title: 'Add Follow-Up',
                  width: 60.w,
                  onSubmit: state.isSubmitting
                      ? null
                      : () async {
                          if (_callStatusCtrl.text.trim().isEmpty) {
                            _showAlertDialog(
                              sbContext,
                              title: 'Validation',
                              message: 'Please enter called status.',
                              icon: Icons.warning_amber_outlined,
                              iconColor: Colors.orange,
                              titleColor: Colors.orange.shade700,
                            );
                            return;
                          }

                          if (_WhtsppNoCtrl.text.isNotEmpty &&
                              _WhtsppNoCtrl.text.trim().length < 10) {
                            _showAlertDialog(
                              sbContext,
                              title: 'Validation',
                              message: 'Please enter a valid WhatsApp number.',
                              icon: Icons.warning_amber_outlined,
                              iconColor: Colors.orange,
                              titleColor: Colors.orange.shade700,
                            );
                            return;
                          }

                          if (state.selectedLeadTag == null &&
                              state.tagMandatory) {
                            _showAlertDialog(
                              sbContext,
                              title: 'Validation',
                              message: 'Please select tag for rejected lead.',
                              icon: Icons.warning_amber_outlined,
                              iconColor: Colors.orange,
                              titleColor: Colors.orange.shade700,
                            );
                            return;
                          }

                          await cubit.submitFollowUp(
                            leadId: lead.id ?? '',
                            leadName: lead.clientName,
                            leadWhatsappNo: _WhtsppNoCtrl.text.trim(),
                            leadWhatsappDialCode: '+91',
                            calledDate: calledDateValue,
                            nextFollowUpDate: nextFollowUpDate,
                            calledStatus: _callStatusCtrl.text,
                            leadTag: lead.leadTag ?? '',
                            remarks: _remarksCtrl.text.trim(),
                            address: _addressm.text.trim(),
                            email: _emailCtrl.text.trim(),
                            previousStage: lead.leadStage,
                            previousCategory: lead.leadCategory,
                            previousPriority: lead.priority,
                            leadPhone: lead.contactNumber,
                            fromPage: from,
                            editId: leadFollowup != null
                                ? leadFollowup.id ?? ""
                                : "",
                          );
                        },
                  body: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.w,
                      vertical: 1.h,
                    ),
                    child: Column(
                      children: [
                        // Row 1: Called Date + Call Status
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Called Date',
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        '*',
                                        style: AppTextStyle.medium(
                                          size: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  GestureDetector(
                                    onTap: () async {
                                      final result =
                                          await showCalendarDialogUsingTimePicker(
                                            sbContext,
                                            initialDate: calledDateValue,
                                            mode: CalendarMode.single,
                                          );
                                      if (result != null) {
                                        sbSetState(() {
                                          calledDateValue = result.from;
                                          _calledDateCtrl.text = DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(result.from);
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 5.2.h,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyCard,
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: _calledDateCtrl,
                                          readOnly: true,
                                          style: AppTextStyle.small(
                                            size: 11.sp,
                                            color: AppColors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: _calledDateCtrl.text,
                                            hintStyle: AppTextStyle.small(
                                              size: 11.sp,
                                              color: AppColors.black,
                                            ),
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Dropdown(
                                showStar: true,
                                items: _callStatuses,
                                selectedValue: _callStatusCtrl.text.isEmpty
                                    ? null
                                    : _callStatusCtrl.text,
                                onChanged: (v) => sbSetState(
                                  () => _callStatusCtrl.text = v ?? '',
                                ),
                                label: 'Called Status',
                                hint: 'Select Call Status',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // Row 2: Lead Stage + Lead Category
                        Row(
                          children: [
                            Expanded(
                              child: Dropdown(
                                showHelp: true,
                                showStar: true,
                                items: stagesNames,
                                showClear: false,
                                selectedValue: state.selectedLeadStage,
                                onChanged: (v) {
                                  setState(() {
                                    _leadStage = v;
                                  });
                                  cubit.selectLeadStage(v);
                                  cubit.selectLeadTag(null);
                                },
                                label: 'Lead Stage',
                                hint: stagesNames.isEmpty
                                    ? 'Loading...'
                                    : 'Select',
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: DropdownWithAdd(
                                label: 'Lead Category',
                                icon: Icons.layers_outlined,
                                items: categoryNames,
                                selectedValue:
                                    state.selectedCategory ?? _leadCategory,
                                onChanged: (v) {
                                  setState(() => _leadCategory = v);
                                  cubit.selectCategory(v);
                                  sbSetState(() {});
                                  cubit.selectSubCategory(null);
                                },
                                onTap: () => _showAddCategoryDialog(),
                              ),
                            ),
                          ],
                        ),

                        // Conditional: Stage-specific + Sub Category
                        Builder(
                          builder: (_) {
                            Widget leftContainer;
                            if (state.selectedLeadStage == 'FOLLOWUP') {
                              leftContainer = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next Follow-Up Date',
                                    style: AppTextStyle.medium(),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  GestureDetector(
                                    onTap: () async {
                                      final result =
                                          await showCalendarDialogUsingTimePicker(
                                            sbContext,
                                            initialDate: nextFollowUpDate,
                                            mode: CalendarMode.single,
                                            showTimePicker: true,
                                            minDate: calledDateValue,
                                          );
                                      if (result != null) {
                                        sbSetState(() {
                                          nextFollowUpDate = result.from;
                                          nextFollowUpCtrl.text = DateFormat(
                                            'dd-MM-yyyy hh:mm a',
                                          ).format(result.from);
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 5.2.h,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyCard,
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: nextFollowUpCtrl,
                                          readOnly: true,
                                          style: AppTextStyle.small(
                                            size: 11.sp,
                                            color: AppColors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: nextFollowUpCtrl.text,
                                            hintStyle: AppTextStyle.small(
                                              size: 11.sp,
                                              color: AppColors.black,
                                            ),
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else if (state.leadTag.isNotEmpty) {
                              leftContainer = Dropdown(
                                label: 'Tags',
                                hint: 'Select Tags',
                                showStar: state.tagMandatory,
                                items: state.leadTag
                                    .map((e) => e.name)
                                    .toList(),
                                selectedValue: state.selectedLeadTag,
                                onChanged: (v) {
                                  cubit.selectLeadTag(v);
                                },
                              );
                            } else {
                              leftContainer = const SizedBox();
                            }

                            final hasSubCategories =
                                state.subCategories.isNotEmpty;
                            final rightContainer = hasSubCategories
                                ? Dropdown(
                                    label: 'Lead Sub Type',
                                    hint: 'Select Lead Sub Type',
                                    items: subCategoryName,
                                    selectedValue: state.selectedSubCategory,
                                    onChanged: (v) => context
                                        .read<AddLeadCubit>()
                                        .selectSubCategory(v),
                                  )
                                : const SizedBox();

                            return Column(
                              children: [
                                SizedBox(height: 1.h),
                                Row(
                                  children: [
                                    Expanded(child: leftContainer),
                                    SizedBox(width: 1.w),
                                    Expanded(child: rightContainer),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 1.h),

                        // Row 4: Priority + WhatsApp
                        Row(
                          children: [
                            Expanded(
                              child: Dropdown(
                                icon: Icons.flag_outlined,
                                showIcon: true,
                                showHelp: true,
                                items: priority,
                                selectedValue:
                                    state.selectedPriority ?? _leadPriority,
                                onChanged: (v) {
                                  _leadPriority = v;
                                  cubit.selectPriority(v);
                                },
                                label: 'Priority',
                                hint: 'Select Priority',
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: _phoneField(
                                'Whatsapp Number',
                                false,
                                Icons.call_outlined,
                                controller: _WhtsppNoCtrl,
                                onDialCodeChanged: (c) =>
                                    sbSetState(() => _WhtsppNoCtrl.text = c),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // Row 5: Email + Address
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'Email',
                                false,
                                null,
                                controller: _emailCtrl,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: _field(
                                'Address',
                                false,
                                null,
                                controller: _addressm,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // Row 6: Remarks
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'Remark',
                                false,
                                null,
                                controller: _remarksCtrl,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        if (state.isSubmitting)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    _dialogNameCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        width: 35.w,
        title: 'Add Lead Category',
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lead Category', style: AppTextStyle.medium(size: 11.sp)),
              SizedBox(height: 2.h),
              TextField(
                controller: _dialogNameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter Category',
                  hintStyle: AppTextStyle.medium(
                    size: 11.sp,
                    color: AppColors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        onSubmit: () async {
          final name = _dialogNameCtrl.text.trim();
          if (name.isEmpty) return;
          final normalized = name.toUpperCase();
          final newId = await context.read<LeadCategoryCubit>().addCategory(
            name: normalized,
          );
          setState(() => _leadCategory = normalized);
          context.read<AddLeadCubit>().selectCategoryDirect(
            name: normalized,
            id: newId,
          );
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$normalized" added.'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    String label,
    bool required,
    IconData? icons, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(4),
            color: AppColors.greyCard,
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyle.body(size: 11.sp),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(1.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, bool required, IconData? icons) {
    return Row(
      children: [
        Icon(icons, size: 12.sp, color: AppColors.green),
        SizedBox(width: 0.5.w),
        Text(text, style: AppTextStyle.medium()),
        if (required)
          Text(
            '*',
            style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
          ),
      ],
    );
  }

  Widget _phoneField(
    String label,
    bool required,
    IconData icons, {
    TextEditingController? controller,
    void Function(String)? onDialCodeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            SizedBox(
              height: 5.h,
              width: 7.5.w,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: CountryCodePicker(
                  onChanged: (country) =>
                      onDialCodeChanged?.call(country.dialCode ?? '+91'),
                  initialSelection: 'IN',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: true,
                  padding: EdgeInsets.zero,
                  textStyle: AppTextStyle.body(size: 11.sp),
                  flagWidth: 16,
                  dialogBackgroundColor: AppColors.white,
                  dialogSize: Size(30.w, 80.h),
                  dialogTextStyle: AppTextStyle.body(size: 11.sp),
                  searchStyle: AppTextStyle.body(size: 11.sp),
                  searchDecoration: InputDecoration(
                    hintText: 'Search country',
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),
            SizedBox(width: 0.25.w),
            Expanded(
              child: Container(
                height: 5.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.greyCard,
                ),
                child: TextField(
                  controller: controller,
                  style: AppTextStyle.body(size: 11.sp),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter number',
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
        return const Color(0xFFF59E0B);
      case 'followup':
        return const Color(0xFFF59E0B);
      case 'connected':
        return const Color(0xFF4CAF50);
      case 'closed':
        return const Color(0xFF4CAF50);
      case 'new':
        return const Color(0xFF10B981);
      case 'transferred':
        return const Color(0xFF3B82F6);
      case 'missed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: AppTextStyle.medium(
              color: _color,
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
        ),
        if (label == "new")
          Text(
            "(Pending)",
            style: AppTextStyle.medium(
              color: Colors.red,
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 1 – Follow-up Content (New Timeline Design)
// ─────────────────────────────────────────────────────────

class _NewFollowupTabContent extends StatefulWidget {
  final List<FollowUpModel> followups;
  final String leadId;
  final String leadName;
  final String? leadWhatsappNo;
  final String? leadWhatsappDialCode;
  final AddLeadModel lead;
  final VoidCallback onFollowUpAdded;
  final LeadCategoryCubit leadCategoryCubit;
  final Function(FollowUpModel) onEditFollowUp;

  const _NewFollowupTabContent({
    required this.followups,
    required this.leadId,
    required this.leadName,
    this.leadWhatsappNo,
    this.leadWhatsappDialCode,
    required this.lead,
    required this.onFollowUpAdded,
    required this.leadCategoryCubit,
    required this.onEditFollowUp,
  });

  @override
  State<_NewFollowupTabContent> createState() => _NewFollowupTabContentState();
}

class _NewFollowupTabContentState extends State<_NewFollowupTabContent> {
  String _currentUserName = '';
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await SessionService().getSavedUser();
    if (mounted && user != null) {
      setState(() {
        _currentUserName = user.name;
        _currentUserId = user.id ?? '';
      });
    }
  }

  FollowUpModel _createLeadFollowup() {
    return FollowUpModel(
      leadId: widget.leadId,
      leadName: widget.leadName,
      leadWhatsappNo: widget.leadWhatsappNo ?? '',
      leadWhatsappDialCode: widget.leadWhatsappDialCode ?? '',
      nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
      leadTag: widget.lead.leadTag ?? '',
      calledStatus: widget.lead.callResult ?? '',
      calledDate:
          widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
      leadStage: widget.lead.leadStage,
      leadCategory: widget.lead.leadCategory,
      leadSubCategory: widget.lead.leadSubCategory,
      priority: widget.lead.priority,
      remarks: widget.lead.remarks,
      createdById: widget.lead.createdById,
      adress: widget.lead.address,
      email: widget.lead.email,
      assignedStaff: widget.lead.assignedStaff,
      assignedStaffId: widget.lead.assignedStaffId,
    );
  }

  void _confirmDeleteFollowUp(BuildContext context, FollowUpModel followUp) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Follow-up'),
        content: const Text('Are you sure you want to delete this follow-up?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AddLeadCubit>().deleteFollowUp(
                leadId: widget.leadId,
                followUpId: followUp.id!,
                changedByName: widget.lead.assignedStaff,
                changedById: widget.lead.assignedStaffId,
                leadName: widget.leadName,
                leadPhone: widget.lead.contactNumber,
              );
              widget.onFollowUpAdded();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Follow-up deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, FollowUpModel> followupGroup = {};

    // Pending follow-up node
    if (widget.lead.followUpDate != null &&
        widget.lead.leadStage.toLowerCase() != 'closed' &&
        widget.lead.leadStage.toLowerCase() != 'rejected' &&
        widget.lead.leadStage.toLowerCase() != 'new') {
      followupGroup[DateFormat(
            'dd-MM-yyyy hh:mm',
          ).format(widget.lead.followUpDate!)] =
          _createLeadFollowup();
    }

    // Existing follow-up records
    for (final f in widget.followups) {
      followupGroup[DateFormat('dd-MM-yyyy hh:mm:ss').format(f.calledDate)] = f;
    }

    // Lead creation node (always last)
    followupGroup[DateFormat(
          'dd-MM-yyyy hh:mm',
        ).format(widget.lead.createdAt!)] =
        _createLeadFollowup();

    final dates = followupGroup.keys.toList();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Timeline entries
          ...dates.asMap().entries.map((mapEntry) {
            final idx = mapEntry.key;
            final date = mapEntry.value;
            final entry = followupGroup[date]!;
            final isFirst = idx == 0;
            final isLast = idx == dates.length - 1;
            final isPending =
                isFirst &&
                dates.length > 1 &&
                widget.lead.leadStage.toLowerCase() != 'rejected' &&
                widget.lead.leadStage.toLowerCase() != 'closed' &&
                widget.lead.leadStage.toLowerCase() != 'new';
            final isCreation =
                isLast &&
                widget.lead.followUp!.isNotEmpty &&
                idx >= dates.length - 1;

            return _NewTimelineDateGroup(
              date: date.substring(0, 10),
              entry: entry,
              lead: widget.lead,
              index: idx,
              dateCount: dates.length,
              isPending: isPending,
              isCreationNode: isLast && dates.length > 1
                  ? true
                  : (dates.length == 1),
              isLast: isLast,
              onEdit: (followup) {
                widget.onEditFollowUp(followup);
              },
              onDelete: (followup) {
                _confirmDeleteFollowUp(context, followup);
              },
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// NEW Timeline Date Group Widget
// ─────────────────────────────────────────────────────────

class _NewTimelineDateGroup extends StatelessWidget {
  final String date;
  final FollowUpModel entry;
  final AddLeadModel lead;
  final int index;
  final int dateCount;
  final bool isPending;
  final bool isCreationNode;
  final bool isLast;
  final Function(FollowUpModel) onEdit;
  final Function(FollowUpModel) onDelete;

  const _NewTimelineDateGroup({
    required this.date,
    required this.entry,
    required this.lead,
    required this.index,
    required this.dateCount,
    required this.isPending,
    required this.isCreationNode,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Parse date parts
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    } catch (_) {}

    final dayStr = parsedDate != null
        ? DateFormat('dd').format(parsedDate)
        : '';
    final monthStr = parsedDate != null
        ? DateFormat('MMM').format(parsedDate).toUpperCase()
        : '';
    final weekdayStr = parsedDate != null
        ? DateFormat('EEE').format(parsedDate).toUpperCase()
        : '';

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: Timeline column ──
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Date circle
                    Container(
                      width: 78,
                      height: 80,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPending
                            ? AppThemeColors.appPrimaryColor
                            : AppThemeColors.followupDateCardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayStr, $monthStr',
                            style: AppTextStyle.small(
                              size: 10,
                              color: isPending
                                  ? Colors.white
                                  : AppThemeColors.sidebarTxtClr,
                              weight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$weekdayStr, $dayStr',
                            style: AppTextStyle.small(
                              size: 10,
                              color: isPending
                                  ? Colors.white
                                  : AppThemeColors.sidebarTxtClr,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Connector line + arrow
                    if (!isLast) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: const DottedArrowDown(
                            height: 140,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                      // Container(
                      //   width: 1.5,
                      //   height: 16,
                      //   color: const Color(0xFFCBD5E1),
                      //   transform: Matrix4.translationValues(0, 12, 0),
                      // ),

                      // Expanded(
                      //   child: Container(
                      //     width: 1.5,
                      //     color: const Color(0xFFCBD5E1),
                      //   ),
                      // ),
                      // const Icon(
                      //   Icons.keyboard_arrow_down,
                      //   size: 16,
                      //   color: Color(0xFFCBD5E1),
                      // ),
                    ] else ...[
                      // Container(
                      //   width: 1.5,
                      //   height: 16,
                      //   color: const Color(0xFFCBD5E1),
                      // ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: const DottedArrowDown(
                            height: 140,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // ── Right: Follow-up card ──
              Expanded(
                child: isPending
                    ? _buildPendingCard(context)
                    : isCreationNode && index == dateCount - 1
                    ? _buildCreationCard(context)
                    : _buildFollowupCard(context),
              ),
              const SizedBox(width: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowupCard(BuildContext context) {
    final state = context.watch<AddLeadCubit>().state;
    final showEditDelete =
        index == 1 &&
        lead.leadStage.toUpperCase() != 'REJECTED' &&
        lead.leadStage.toUpperCase() != 'CLOSED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: NotchedCard(
            borderColor: AppThemeColors.followupCardBorder,
            backgroundColor: Colors.white,
            notchWidth: 12,
            notchHeight: 24,
            notchTop: 18,
            child: IntrinsicWidth(
              stepWidth: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar + Name + Badge + Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.assignedStaff.isNotEmpty
                                ? entry.assignedStaff
                                : 'Unknown',
                            style: AppTextStyle.body(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),

                        _NewStatusChip(
                          label:
                              capitalizeFirstLetter(
                                    resolveLeadName(
                                      list: state.stages,
                                      id: entry.leadStageId,
                                      fallback: entry.leadStage,
                                      idOf: (s) => s.id,
                                      nameOf: (s) => s.name,
                                    ),
                                  ) ==
                                  'Followup'
                              ? "Follow-Up"
                              : capitalizeFirstLetter(
                                  resolveLeadName(
                                    list: state.stages,
                                    id: entry.leadStageId,
                                    fallback: entry.leadStage,
                                    idOf: (s) => s.id,
                                    nameOf: (s) => s.name,
                                  ),
                                ),
                        ),

                        // const Spacer(),
                        if (showEditDelete) ...[
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => onEdit(entry),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeColors.appPrimaryColor,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: AppThemeColors.appPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => onDelete(entry),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 13,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Detail rows
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.leadStage.toLowerCase() != 'rejected' &&
                            entry.leadStage.toLowerCase() != 'closed')
                          _detailRow(
                            Icons.calendar_today_outlined,
                            'Scheduled Date:',
                            DateFormat(
                              'dd-MM-yyyy, hh:mm a',
                            ).format(entry.nextFollowUpDate),
                          ),
                        if (entry.leadStage.toLowerCase() != 'rejected' &&
                            entry.leadStage.toLowerCase() != 'closed')
                          const SizedBox(height: 8),
                        _detailRow(
                          Icons.phone_outlined,
                          'Called Date:',
                          DateFormat(
                            'dd-MM-yyyy, hh:mm a',
                          ).format(entry.calledDate),
                        ),
                        const SizedBox(height: 8),
                        _detailRow(
                          Icons.people_outline,
                          'Call Status:',
                          entry.calledStatus,
                          valueColor:
                              entry.calledStatus.toLowerCase() == 'connected'
                              ? AppThemeColors.basicGreen
                              : Colors.red.shade300,
                        ),
                        if (resolveLeadName(
                          list: state.leadTag,
                          id: lead.leadTagId,
                          fallback: lead.leadTag ?? '',
                          idOf: (s) => s.id,
                          nameOf: (s) => s.name,
                        ).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailRow(
                            Icons.label_outline,
                            'Tags:',
                            resolveLeadName(
                              list: state.leadTag,
                              id: lead.leadTagId,
                              fallback: lead.leadTag,
                              idOf: (s) => s.id,
                              nameOf: (s) => s.name,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        // Remarks
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remarks:  ',
                                style: AppTextStyle.body(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppThemeColors.cardText,
                                ),
                              ),

                              TextSpan(
                                text: entry.remarks,
                                style: AppTextStyle.body(
                                  fontSize: 11.5,
                                  color: AppThemeColors.cardText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Widget _buildPendingCard(BuildContext context) {
  //   final state = context.watch<AddLeadCubit>().state;
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 16, bottom: 8),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: const Color(0xFFFFFBEB),
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: const Color(0xFFFDE68A)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.03),
  //             blurRadius: 6,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
  //             child: Row(
  //               children: [
  //                 const CircleAvatar(
  //                   radius: 16,
  //                   backgroundColor: Color(0xFFFEF3C7),
  //                   child: Icon(
  //                     Icons.person,
  //                     size: 18,
  //                     color: Color(0xFFD97706),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Text(
  //                   lead.assignedStaff,
  //                   style: AppTextStyle.body(
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                     color: const Color(0xFF1E293B),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const Divider(height: 1, color: Color(0xFFFDE68A)),
  //           Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 _detailRow(
  //                   Icons.calendar_today_outlined,
  //                   'Scheduled Date:',
  //                   DateFormat(
  //                     'dd-MM-yyyy, hh:mm a',
  //                   ).format(lead.followUpDate!),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.info_outline,
  //                       size: 14,
  //                       color: const Color(0xFF6B7280),
  //                     ),
  //                     const SizedBox(width: 6),
  //                     Text(
  //                       'Status:',
  //                       style: AppTextStyle.body(
  //                         fontSize: 12,
  //                         color: const Color(0xFF6B7280),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     _NewStatusChip(
  //                       label: resolveLeadName(
  //                         list: state.stages,
  //                         id: lead.leadStageId,
  //                         fallback: lead.leadStage,
  //                         idOf: (s) => s.id,
  //                         nameOf: (s) => s.name,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 4),
  //                     Text(
  //                       '(Pending)',
  //                       style: AppTextStyle.body(
  //                         fontSize: 12,
  //                         color: const Color(0xFFD97706),
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCreationCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: NotchedCard(
            borderColor: AppThemeColors.followupCardBorder,
            backgroundColor: Colors.white,
            notchWidth: 12,
            notchHeight: 24,
            notchTop: 18,
            child: IntrinsicWidth(
              stepWidth: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lead.createdBy,
                            style: AppTextStyle.body(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        _NewStatusChip(label: 'NEW'),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(
                          Icons.calendar_today_outlined,
                          'Created Date:',
                          DateFormat(
                            'dd-MM-yyyy, hh:mm a',
                          ).format(lead.createdAt!),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remarks: ',
                                style: AppTextStyle.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppThemeColors.cardText,
                                ),
                              ),
                              TextSpan(
                                text: lead.remarks.isNotEmpty
                                    ? lead.remarks
                                    : '-',
                                style: AppTextStyle.body(
                                  fontSize: 11,
                                  color: AppThemeColors.cardText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.info_outline,
                        //       size: 14,
                        //       color: const Color(0xFF6B7280),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       'Status:',
                        //       style: AppTextStyle.body(
                        //         fontSize: 12,
                        //         color: const Color(0xFF6B7280),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 8),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyle.body(
            fontSize: 11,
            color: AppThemeColors.cardText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyle.body(
            fontSize: 11,
            color: valueColor ?? AppThemeColors.cardText,
            fontWeight: valueColor != null ? FontWeight.w500 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    // final state = context.watch<AddLeadCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: NotchedCard(
            borderColor: const Color(0xFF00B16E).withValues(alpha: 0.5),
            backgroundColor: Colors.white,
            notchWidth: 12,
            notchHeight: 24,
            notchTop: 18,
            child: IntrinsicWidth(
              stepWidth: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person, size: 18),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            lead.assignedStaff,
                            style: AppTextStyle.body(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xff374151),
                            ),
                          ),
                        ),

                        Text(
                          "Pending",
                          style: AppTextStyle.body(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey.shade200),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: _detailRow(
                      Icons.calendar_today_outlined,
                      "Scheduled Date:",
                      DateFormat(
                        'dd-MM-yyyy, hh:mm a',
                      ).format(lead.followUpDate!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 2 – Activities (New Timeline Design)
// ─────────────────────────────────────────────────────────

class _NewActivitiesTabContent extends StatefulWidget {
  final AddLeadModel lead;
  const _NewActivitiesTabContent({required this.lead});

  @override
  State<_NewActivitiesTabContent> createState() =>
      _NewActivitiesTabContentState();
}

class _NewActivitiesTabContentState extends State<_NewActivitiesTabContent> {
  late final Future<List<ActivityModel>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ActivityRepository().getActivities(
      widget.lead.id ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<List<ActivityModel>>(
            future: _activitiesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snap.hasError) {
                return Text('Error loading activities: ${snap.error}');
              }
              final activities = snap.data ?? [];
              if (activities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No activities yet.')),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: activities
                    .asMap()
                    .entries
                    .map(
                      (e) => _NewActivityItem(
                        activity: e.value,
                        isLast: e.key == activities.length - 1,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewActivityItem extends StatelessWidget {
  final ActivityModel activity;
  final bool isLast;
  const _NewActivityItem({required this.activity, required this.isLast});

  IconData get _icon {
    switch (activity.type) {
      case ActivityType.leadCreated:
        return Icons.add_circle_outline;
      case ActivityType.statusChanged:
        return Icons.swap_horiz;
      case ActivityType.followupAdded:
        return Icons.phone_outlined;
      case ActivityType.categoryChanged:
        return Icons.layers_outlined;
      case ActivityType.priorityChanged:
        return Icons.flag_outlined;
      case ActivityType.staffAssigned:
        return Icons.person_add_outlined;
      case ActivityType.costUpdated:
        return Icons.currency_rupee;
      case ActivityType.remarkUpdated:
        return Icons.edit_note_outlined;
      default:
        return Icons.phone_outlined;
    }
  }

  Color get _iconBgColor {
    switch (activity.type) {
      case ActivityType.followupAdded:
        return const Color(0xFF0F766E);
      case ActivityType.leadCreated:
        return const Color(0xFF059669);
      case ActivityType.statusChanged:
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF0F766E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Icon + Connector
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, size: 18, color: Colors.white),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right: Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Date
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activity.changedBy,
                          style: AppTextStyle.body(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat(
                            'dd-MM-yyyy, hh:mm a',
                          ).format(activity.changedAt),
                          style: AppTextStyle.body(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Description
                    Text(
                      activity.description,
                      style: AppTextStyle.body(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
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

// ─────────────────────────────────────────────────────────
// Tab 3 – Details (New Two-Column Layout)
// ─────────────────────────────────────────────────────────

class _NewDetailsTabContent extends StatefulWidget {
  final AddLeadModel lead;
  const _NewDetailsTabContent({required this.lead});

  @override
  State<_NewDetailsTabContent> createState() => _NewDetailsTabContentState();
}

class _NewDetailsTabContentState extends State<_NewDetailsTabContent> {
  late final Future<List<LeadStaffHandler>> _handlersFuture;

  @override
  void initState() {
    super.initState();
    _handlersFuture = AddLeadRepository().getLeadHandledStaffs(widget.lead);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddLeadCubit>().state;

    final categoryName = resolveLeadName(
      list: state.categories,
      id: widget.lead.leadCategoryId,
      fallback: widget.lead.leadCategory,
      idOf: (s) => s.id,
      nameOf: (s) => s.name,
    );

    final stageName = resolveLeadName(
      list: state.stages,
      id: widget.lead.leadStageId,
      fallback: widget.lead.leadStage,
      idOf: (s) => s.id,
      nameOf: (s) => s.name,
    );

    final sourceName = resolveLeadName(
      list: state.sources,
      id: widget.lead.leadSourceId,
      fallback: widget.lead.leadSource,
      idOf: (s) => s.id,
      nameOf: (s) => s.name,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Two-column details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Lead Details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEAD DETAILS',
                        style: AppTextStyle.heading(
                          size: 14,
                          weight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _detailItem('Lead Category:', categoryName),
                      const SizedBox(height: 14),
                      _detailItemWithBadge('Lead Stage:', stageName),
                      const SizedBox(height: 14),
                      _detailItem('Lead Source:', sourceName ?? '-'),
                      const SizedBox(height: 14),
                      _detailItem(
                        'Create Date:',
                        DateFormat(
                          'dd-MM-yyyy, hh:mm a',
                        ).format(widget.lead.createdAt ?? DateTime.now()),
                      ),
                      const SizedBox(height: 14),
                      _detailItem('Create By:', widget.lead.createdBy),
                      const SizedBox(height: 14),
                      _detailItem('Assigned Staff:', widget.lead.assignedStaff),
                      const SizedBox(height: 18),
                      Text(
                        'Remark:',
                        style: AppTextStyle.body(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.lead.remarks.isNotEmpty
                            ? widget.lead.remarks
                            : '-',
                        style: AppTextStyle.body(
                          fontSize: 13,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right Column: Contact Information
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTACT INFORMATION',
                        style: AppTextStyle.heading(
                          size: 14,
                          weight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _detailItem(
                        'WhatsApp Number:',
                        widget.lead.whatsappNumber.isNotEmpty
                            ? widget.lead.whatsappNumber
                            : widget.lead.contactNumber,
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'Email Address:',
                        widget.lead.email.isNotEmpty ? widget.lead.email : '-',
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'Address:',
                        widget.lead.address.isNotEmpty
                            ? widget.lead.address
                            : '-',
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'State:',
                        widget.lead.state.isNotEmpty ? widget.lead.state : '-',
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'District:',
                        widget.lead.district.isNotEmpty
                            ? widget.lead.district
                            : '-',
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'City:',
                        widget.lead.address.isNotEmpty
                            ? widget.lead.address
                            : '-',
                      ),
                      const SizedBox(height: 14),
                      _detailItem(
                        'Pincode:',
                        widget.lead.pinCode.isNotEmpty
                            ? widget.lead.pinCode
                            : '-',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lead Handle Staff
          Text(
            'LEAD HANDLE STAFF',
            style: AppTextStyle.heading(
              size: 14,
              weight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<LeadStaffHandler>>(
            future: _handlersFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Text('Error: ${snap.error}');
              }
              final handlers = snap.data ?? [];
              if (handlers.isEmpty) {
                return const Text('No staff records found.');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < handlers.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: _NewStaffCard(handler: handlers[i])),
                          if (i + 1 < handlers.length) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _NewStaffCard(handler: handlers[i + 1]),
                            ),
                          ] else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTextStyle.body(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyle.body(
              fontSize: 13,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailItemWithBadge(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTextStyle.body(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        _NewStatusChip(label: value),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// New Staff Card
// ─────────────────────────────────────────────────────────

class _NewStaffCard extends StatelessWidget {
  final LeadStaffHandler handler;
  const _NewStaffCard({required this.handler});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, size: 22, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handler.staffName,
                  style: AppTextStyle.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (handler.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+91 ${handler.phone}',
                    style: AppTextStyle.body(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${handler.activityCount.toString().padLeft(2, '0')}',
                style: AppTextStyle.heading(
                  size: 16,
                  weight: FontWeight.w700,
                  color: const Color(0xFF0F766E),
                ),
              ),
              Text(
                handler.activityCount == 1 ? 'Activity' : 'Activities',
                style: AppTextStyle.body(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────

Color _getNewPriorityColor(String priority) {
  switch (priority.trim().toLowerCase()) {
    case 'high':
      return const Color(0xffEF4444);
    case 'normal':
      return AppThemeColors.basicGreen;
    case 'low':
      return const Color(0xffF97316);
    case 'negative':
      return const Color(0xff9CA3AF);
    default:
      return const Color(0xff22C55E);
  }
}

class _NewPriorityBadge extends StatelessWidget {
  final String label;
  final String priority;
  const _NewPriorityBadge({required this.label, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getNewPriorityColor(priority),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTextStyle.small(
          size: 11,
          color: Colors.white,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NewStatusChip extends StatelessWidget {
  final String label;
  const _NewStatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: getStageColor(label),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyle.small(
          size: 11,
          color: Colors.white,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
