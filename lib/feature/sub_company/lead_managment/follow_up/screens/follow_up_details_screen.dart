import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/utils/custom_calender.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/feature/sub_company/lead_managment/follow_up/screens/widget/calender.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/sub_company/reports/staff_reports/widget/calender.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:sizer/sizer.dart';

import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/core/utils/transfer_lead_alert.dart';
import '../../../sidebar/main_screen.dart';
import '../../leads/data/add_lead_repo.dart';
import '../../leads/model/add_lead_model.dart';
import '../data/activity_repo.dart';
import '../models/follow_up_activities_model.dart';
import '../models/follow_up_details_models.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

import '../models/staff_handler_model.dart';

class FollowUpDetailsScreen extends StatefulWidget {
  AddLeadModel currentLead;
  FollowUpDetailsScreen({super.key, required this.currentLead});
  // final AddLeadModel? lead;
  // const FollowUpDetailsScreen({super.key, this.lead});

  @override
  State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
}

class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  late AddLeadModel _currentLead;

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
    _currentLead = widget.currentLead;
    _tabController = TabController(length: 3, vsync: this);
    // Keep _selectedTab in sync when user swipes (if you ever re-add TabBarView)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    context.read<AddLeadCubit>().initialize();

    // log("widget.currentLead.followUpDate njutrdgghj ${_currentLead.followUp?.first.calledStatus}");
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      debugPrint('[FollowUpDetailsScreen] Failed to reload follow-ups: $e');
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ctx.read<AddLeadCubit>().deleteLead(lead.id!, lead);
              final user = await SessionService().getSavedUser();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    selectedIndex: 12,
                    staff: user,
                    fromCard: 'NEW',
                  ),
                ),
              );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ SingleChildScrollView is the ONE scroll owner for the whole screen.
      // No Expanded / TabBarView inside — zero conflict.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBreadcrumbBar(
              subTitle: 'Details',
              title: 'Dashboard',
              subTitle2: 'Lead List',
              onPressed: () {
                Navigator.pop(context);
              },
              show2ndTitle: true,
              showMenu: true,
            ),

            // Header + TabBar (no TabBarView)
            _buildHeader(),

            // ✅ Inline tab content — each widget uses mainAxisSize.min so
            // it shrink-wraps naturally inside the SingleChildScrollView.
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  // ── Inline tab content switcher ──────────────────────────
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _FollowupTabContent(
          followups: _currentLead.followUp ?? [], // ← use _currentLead
          leadId: _currentLead.id ?? '',
          leadName: _currentLead.clientName ?? '',
          lead: _currentLead,
          // onFollowUpAdded: _reloadFollowUps,           // ✅ pass callback
          onFollowUpAdded: _reloadLead,
          leadCategoryCubit: context.read<LeadCategoryCubit>(),
        );
      case 1:
        return _ActivitiesTabContent(lead: _currentLead);
      case 2:
        return _DetailsTabContent(lead: _currentLead);
      // return _FollowupTabContent(
      //   followups: widget.currentLead.followUp??[],
      //   leadId: widget.currentLead.id ?? '',
      //   leadName: widget.currentLead.clientName ?? '',
      //   lead: widget.currentLead,
      // );
      // case 1:
      //   return _ActivitiesTabContent(lead: widget.currentLead,);
      // case 2:
      //   return _DetailsTabContent(lead: widget.currentLead,);
      default:
        return const SizedBox();
    }
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      // color: const Color(0xFFFFF3E0),
      color: AppColors.background,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 30,
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF888888),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // shrink-wrap
                  children: [
                    // Name row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            // 'Sanidha',
                            _currentLead.clientName ?? '',
                            style: AppTextStyle.heading(
                              size: 20,
                              weight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _PriorityBadge(
                            priority: _currentLead.priority,
                            label: 'Lead priority: ${_currentLead.priority}',
                          ),
                          const Spacer(),
                          // _headerIcon(
                          //   Icons.edit_outlined,
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => MainScreen(
                          //           selectedIndex: 1,
                          //           lead: _currentLead,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // CHANGE TO:
                          _headerIcon(
                            Icons.edit_outlined,
                            onTap: () async {
                              // ← async
                              final didUpdate = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                    selectedIndex: 1,
                                    lead: _currentLead,
                                  ),
                                ),
                              );

                              // ✅ Reload the lead data when edit completes
                              if (didUpdate == true && mounted) {
                                await _reloadLead();
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          _headerIcon(
                            Icons.swap_horiz,
                            onTap: () {
                              showAssignStaffDialog(
                                [_currentLead],
                                context,
                                onSubmit:
                                    (
                                      String? selectedStaffId,
                                      String? selectedStaffName,
                                    ) async {
                                      print("pppppppp");
                                      if (selectedStaffId == null ||
                                          selectedStaffName == null)
                                        return;

                                      // for (final lead in selectedLeads) {
                                      //   await context.read<AddLeadCubit>().assignStaff(
                                      //     leadId: lead.id!,
                                      //     staffId: selectedStaffId!,
                                      //     staffName: selectedStaffName!,
                                      //   );
                                      // }
                                      // for (final lead in selectedLeads) {

                                      await context
                                          .read<AddLeadCubit>()
                                          .transferLead(
                                            leadId: _currentLead.id!,
                                            leadName: _currentLead.clientName,
                                            contactNumber:
                                                _currentLead.contactNumber,
                                            leadCategory:
                                                _currentLead.leadCategory,
                                            leadStage: _currentLead.leadStage,
                                            fromStaffId:
                                                _currentLead.assignedStaffId,
                                            fromStaff:
                                                _currentLead.assignedStaff,
                                            toStaffId: selectedStaffId,
                                            toStaff: selectedStaffName,
                                          );
                                      // }

                                      print("oooooooooooooo");
                                      // await _reloadFollowUps();
                                      await _reloadLead();
                                      setState(() {
                                        _currentLead = _currentLead.copyWith(
                                          assignedStaffId: selectedStaffId,
                                          assignedStaff: selectedStaffName,
                                        );
                                      });
                                      Navigator.pop(context);
                                      // 🔹 Clear selection — assigned leads auto-disappear
                                      // because _filteredLeads filters out assignedStaffId != ''
                                      // setState(() {
                                      //   _selectedIndices = [];
                                      //   _tableKey++; // 🔹 forces CustomTable to rebuild fresh with all boxes unchecked
                                      // });
                                      // context.read<AddLeadCubit>().fetchLeads();
                                    },
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _headerIcon(
                            Icons.add_box_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(selectedIndex: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _headerIcon(
                            Icons.delete_outline,
                            color: Colors.red.shade300,
                            onTap: () {
                              _confirmDelete(context, _currentLead);
                            },
                          ),
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
                          _metaItem(
                            Icons.phone,
                            // '8086287726'
                            _currentLead.contactNumber ?? '',
                          ),
                          _divider(),
                          _metaItem(
                            Icons.location_on_outlined,
                            _currentLead.address,
                          ),
                          _divider(),
                          _metaText(
                            'Create Date : ${DateFormat("dd MMM, yyyy").format(_currentLead.createdAt ?? DateTime.now())}',
                          ),
                          _divider(),
                          _metaText('category : ${_currentLead.leadCategory}'),
                          _divider(),
                          _metaText('Staff : ${_currentLead.assignedStaff}'),
                          _divider(),
                          // _metaText('Cost : 0'),
                          // _divider(),
                          _StatusBadge(
                            label: _currentLead.leadStage,
                            color: Color(0xFF2196F3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _metaText(
                        'Lead Source : ${_currentLead.leadSource}',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
          // ✅ TabBar only — NO TabBarView.
          // onTap drives setState which swaps the inline content below.
          TabBar(
            padding: EdgeInsets.zero,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: const Color(0xFF888888),
            indicatorColor: const Color(0xFF1565C0),
            indicatorWeight: 2,
            labelStyle: AppTextStyle.heading(size: 12),
            unselectedLabelStyle: AppTextStyle.small(size: 12),
            onTap: (i) => setState(() => _selectedTab = i),
            tabs: const [
              Tab(text: 'Followup'),
              Tab(text: 'Activities'),
              Tab(text: 'Details'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(
    IconData icon, {
    Color color = const Color(0xFF555555),
    VoidCallback? onTap,
  }) {
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
          style: AppTextStyle.small(size: 12, color: Color(0xFF555555)),
        ),
      ],
    );
  }

  Widget _metaText(String text) =>
      Text(text, style: AppTextStyle.small(size: 12, color: Color(0xFF555555)));

  Widget _divider() => Text(
    '|',
    style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFFBBBBBB)),
  );
}

// ─────────────────────────────────────────────────────────
// Tab 1 – Followup content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _FollowupTabContent extends StatefulWidget {
  final List<FollowUpModel> followups;
  final String leadId;
  final String leadName;
  final String? leadWhatsappNo;
  final String? leadWhatsappDialCode;
  final AddLeadModel lead;
  final VoidCallback onFollowUpAdded;
  final LeadCategoryCubit leadCategoryCubit;

  const _FollowupTabContent({
    required this.followups,
    required this.leadId,
    required this.leadName,
    this.leadWhatsappNo,
    this.leadWhatsappDialCode,
    required this.lead,
    required this.onFollowUpAdded,
    required this.leadCategoryCubit,
  });

  @override
  State<_FollowupTabContent> createState() => _FollowupTabContentState();
}

// class _FollowupTabContentState extends State<_FollowupTabContent> {
//   final TextEditingController _calledDateCtrl = TextEditingController();
//   final TextEditingController _callStatusCtrl = TextEditingController();
//   // final TextEditingController _leadStagetCtrl = TextEditingController();
//   final TextEditingController _nextFollowUpDateCtrl = TextEditingController();
//   final TextEditingController _costCtrl = TextEditingController();
//   final TextEditingController _WhtsppNoCtrl = TextEditingController();
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _addressm = TextEditingController();
//   final TextEditingController _remarksCtrl = TextEditingController();

//   final TextEditingController _dialogNameCtrl = TextEditingController();

//   final List<String> _leadStages = ['New', 'Follow Up', 'Closed', 'Rejected'];
//   final List<String> _callStatuses = [
//     'Connected',
//     'Not Connected',
//     'Busy',
//     "No Status Updated",
//     "Not Attended",
//     "Out of coverge Area",
//     "Rejected",
//     "Switched Off",
//     "Number Changed",
//     "Not Switched On",
//   ];

//   String? _leadStage;
//   String? _leadCategory;
//   String? _leadPriority;

//   void _confirmDeleteFollowUp(BuildContext context, FollowUpModel followUp) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Follow-up'),
//         content: const Text('Are you sure you want to delete this follow-up?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);

//               await context.read<AddLeadCubit>().deleteFollowUp(
//                 leadId: widget.leadId,
//                 followUpId: followUp.id!,
//                 changedByName: widget.lead.assignedStaff,
//                 changedById: widget.lead.assignedStaffId,
//                 leadName: widget.leadName,
//                 leadPhone: widget.lead.contactNumber,
//               );

//               widget.onFollowUpAdded();

//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Follow-up deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     log("widget.followups.isEmpty ${widget.followups.length}");
//     _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     // widget.onFollowUpAdded();
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     final Widget divider = SizedBox(width: 1.w);

    

//     Future<FollowUpModel> createLeadFollowup() async {
      
//       final user = await SessionService().getSavedUser();
//       return FollowUpModel(
//         leadId: widget.leadId,
//         leadName: widget.leadName,
//         leadWhatsappNo: widget.leadWhatsappNo ?? "",
//         leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
//         nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
//         leadTag: widget.lead.leadTag ?? '',
//         calledStatus: widget.lead.callResult ?? "",
//         calledDate:
//             widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
//         leadStage: widget.lead.leadStage,
//         leadCategory: widget.lead.leadCategory,
//         priority: widget.lead.priority,
//         remarks: widget.lead.remarks,
//         createdById: widget.lead.createdById,
//         adress: widget.lead.address,
//         email: widget.lead.email, assignedStaff: user!.name, assignedStaffId:user.id??'',
//       );
//     }

//     // Group entries by date
//     final Map<String, List<FollowUpModel>> grouped = {};

//     final Map<String, FollowUpModel> followupGroup = {};

//     log("jhhhhhhhhhhhhh ${widget.lead.followUpDate}");

//     if (widget.lead.followUpDate != null &&
//         widget.lead.leadStage.toLowerCase() != 'closed' &&
//         widget.lead.leadStage.toLowerCase() != 'rejected' &&
//         widget.lead.leadStage.toLowerCase() != 'new') {
//       // followupGroup[DateFormat('dd-MM-yyyy').format(widget.lead.followUpDate!)] = createLeadFollowup();
//       followupGroup[DateFormat(
//             'dd-MM-yyyy hh:mm',
//           ).format(widget.lead.followUpDate!)] =
//           createLeadFollowup();
//     }

//     for (final f in widget.followups) {
//       followupGroup[DateFormat('dd-MM-yyyy hh:mm').format(f.calledDate)] = f;
//     }

//     // if(widget.followups.isEmpty) {
//     followupGroup[DateFormat(
//           'dd-MM-yyyy hh:mm',
//         ).format(widget.lead.createdAt!)] =
//         createLeadFollowup();
//     // }

//     ///---------------------------------------------------------------
//     // grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(widget.lead.followUpDate!), () => []).add(FollowUpModel(
//     //     leadId: widget.leadId,
//     //     leadName: widget.leadName,
//     //     leadWhatsappNo: widget.leadWhatsappNo ?? "",
//     //     leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
//     //     nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
//     //     calledStatus: widget.lead.callResult ?? "",
//     //     calledDate: widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
//     //     leadStage: widget.lead.leadStage, leadCategory: widget.lead.leadCategory,
//     //     priority: widget.lead.priority, remarks: widget.lead.remarks, createdById: widget.lead.createdById
//     //
//     // ));
//     //
//     // for (final f in widget.followups) {
//     //   grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(f.calledDate), () => []).add(f);
//     // }
//     //
//     //
//     // if(widget.followups.isEmpty) {
//     //   grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(widget.lead.createdAt!), () => []).add(FollowUpModel(
//     //       leadId: widget.leadId,
//     //       leadName: widget.leadName,
//     //       leadWhatsappNo: widget.leadWhatsappNo ?? "",
//     //       leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
//     //       nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
//     //       calledStatus: widget.lead.callResult ?? "",
//     //       calledDate: widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
//     //       leadStage: widget.lead.leadStage, leadCategory: widget.lead.leadCategory,
//     //       priority: widget.lead.priority, remarks: widget.lead.remarks, createdById: widget.lead.createdById
//     //
//     //   ));
//     // }

//     // final dates = grouped.keys.toList();

//     ///--------------------------------------------------------------------------

//     final dates = followupGroup.keys.toList();
//     log(dates.length.toString());

//     return Container(
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
//         children: [
//           // Action bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//             child: Row(
//               children: [
//                 Text(
//                   'Followup Details',
//                   style: AppTextStyle.heading(
//                     size: 18,
//                     // weight: FontWeight.w700,
//                     color: Color(0xFF495057),
//                   ),
//                   // TextStyle(
//                   //     fontSize: 16,
//                   //     fontWeight: FontWeight.w700,
//                   //     color: Color(0xFF222222)),
//                 ),
//                 const Spacer(),
//                 // Container(
//                 //   decoration: BoxDecoration(
//                 //     color: AppColors.green,
//                 //     borderRadius: BorderRadius.circular(6),
//                 //   ),
//                 //   padding: const EdgeInsets.symmetric(
//                 //     horizontal: 12,
//                 //     vertical: 7,
//                 //   ),
//                 //   child: Row(
//                 //     children: [
//                 //       // Icon(Icons.chat, color: Colors.white, size: 16),
//                 //       Image.asset("assets/icon/whatsapp.png", scale: 2,),
//                 //       const SizedBox(width: 4),
//                 //       const Icon(
//                 //         Icons.keyboard_arrow_down,
//                 //         color: Colors.white,
//                 //         size: 16,
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 // const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     _addFollowUpBottom(context, null, "NEW", widget.lead);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 9,
//                     ),
//                   ),
//                   child: Text(
//                     'Add Follow-up',
//                     style: AppTextStyle.small(size: 13, color: AppColors.white),
//                   ),
//                   // TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ),
//           ),

//           // ✅ Rendered as plain Column children — no ListView required
//           ...dates.map(
//             (date) => _DateGroup(
//               // date: date,
//               date: date.substring(0, 10),
//               entry: followupGroup[date]!,
//               time: DateFormat(
//                 'hh:mm a',
//               ).format(followupGroup[date]!.calledDate),
//               lead: widget.lead,
//               index: dates.indexOf(date),
//               dateCount: dates.length,
//               onEdit: (followup) {
//                 _addFollowUpBottom(context, followup, "EDIT", widget.lead);
//               },
//               onDelete: (followup) {
//                 _confirmDeleteFollowUp(context, followup);
//               },
//             ),
//           ),

//           // ...dates.map(
//           //   (date) => _DateGroup(
//           //     date: date,
//           //     entries: grouped[date]!,
//           //     time: DateFormat('hh:mm a').format(grouped[date]![0].calledDate),
//           //     // entry: grouped[date]![0],
//           //     lead: widget.lead,
//           //   ),
//           // ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
class _FollowupTabContentState extends State<_FollowupTabContent> {
  final TextEditingController _calledDateCtrl = TextEditingController();
  final TextEditingController _callStatusCtrl = TextEditingController();
  final TextEditingController _nextFollowUpDateCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _WhtsppNoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressm = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _dialogNameCtrl = TextEditingController();

  final List<String> _leadStages = ['New', 'Follow Up', 'Closed', 'Rejected'];
  final List<String> _callStatuses = [
    'Connected',
    'Not Connected',
    'Busy',
    "No Status Updated",
    "Not Attended",
    "Out of coverge Area",
    "Rejected",
    "Switched Off",
    "Number Changed",
    "Not Switched On",
  ];

  String? _leadStage;
  String? _leadCategory;
  String? _leadPriority;

  // ── Cached logged-in user ──────────────────────────────────────────────────
  // Loaded once in initState so createLeadFollowup() can stay synchronous.
  String _currentUserName = '';
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    log("widget.followups.isEmpty ${widget.followups.length}");
    _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
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

  // ── Now synchronous — no async/await needed ────────────────────────────────
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
      priority: widget.lead.priority,
      remarks: widget.lead.remarks,
      createdById: widget.lead.createdById,
      adress: widget.lead.address,
      email: widget.lead.email,
      assignedStaff: _currentUserName.isNotEmpty
          ? _currentUserName
          : widget.lead.assignedStaff,
      assignedStaffId: _currentUserId.isNotEmpty
          ? _currentUserId
          : widget.lead.assignedStaffId,
    );
  }

  void _confirmDeleteFollowUp(BuildContext context, FollowUpModel followUp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Follow-up'),
        content: const Text('Are you sure you want to delete this follow-up?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
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

    log("followUpDate: ${widget.lead.followUpDate}");

    // Pending follow-up node (only when stage is active)
    if (widget.lead.followUpDate != null &&
        widget.lead.leadStage.toLowerCase() != 'closed' &&
        widget.lead.leadStage.toLowerCase() != 'rejected' &&
        widget.lead.leadStage.toLowerCase() != 'new') {
      followupGroup[DateFormat(
        'dd-MM-yyyy hh:mm',
      ).format(widget.lead.followUpDate!)] = _createLeadFollowup(); // ✅ sync
    }

    // Existing follow-up records
    for (final f in widget.followups) {
      followupGroup[DateFormat('dd-MM-yyyy hh:mm').format(f.calledDate)] = f;
    }

    // Lead creation node (always last)
    followupGroup[DateFormat(
      'dd-MM-yyyy hh:mm',
    ).format(widget.lead.createdAt!)] = _createLeadFollowup(); // ✅ sync

    final dates = followupGroup.keys.toList();
    log(dates.length.toString());

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              children: [
                Text(
                  'Followup Details',
                  style: AppTextStyle.heading(
                    size: 18,
                    color: const Color(0xFF495057),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _addFollowUpBottom(context, null, "NEW", widget.lead);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                  ),
                  child: Text(
                    'Add Follow-up',
                    style: AppTextStyle.small(size: 13, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),

          // Timeline entries
          ...dates.map(
            (date) => _DateGroup(
              date: date.substring(0, 10),
              entry: followupGroup[date]!,
              time: DateFormat(
                'hh:mm a',
              ).format(followupGroup[date]!.calledDate),
              lead: widget.lead,
              index: dates.indexOf(date),
              dateCount: dates.length,
              onEdit: (followup) {
                _addFollowUpBottom(context, followup, "EDIT", widget.lead);
              },
              onDelete: (followup) {
                _confirmDeleteFollowUp(context, followup);
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Helper: show alert dialog (replaces all SnackBars) ───────────────────
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

  void _addFollowUpBottom(
    BuildContext context,
    FollowUpModel? leadFollowup,
    String from,
    AddLeadModel lead,
  ) {
    final cubit = context.read<AddLeadCubit>();

    cubit.setFollowup4Edit();
    cubit.selectLeadStage(null);
    cubit.selectCategory(null);
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
      cubit.selectLeadStage(leadFollowup!.leadStage);
      cubit.selectCategory(leadFollowup.leadCategory);
      cubit.selectPriority(leadFollowup.leadTag);
      cubit.selectPriority(leadFollowup.priority);
      cubit.selectCallResult(leadFollowup.calledStatus);
      cubit.state.copyWith(successMessage: "", status: AddLeadStatus.initial);

      final editStage = (leadFollowup.leadStage.toUpperCase() == 'NEW')
          ? 'FOLLOWUP'
          : leadFollowup.leadStage;
      cubit.selectLeadStage(editStage);
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
      _leadCategory = lead.leadCategory;
    } else {
      _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _callStatusCtrl.text = '';
      _remarksCtrl.text = '';
      _emailCtrl.text = lead.email;
      _addressm.text = lead.address;
      _WhtsppNoCtrl.text = lead.whatsappNumber;
      cubit.selectLeadStage('FOLLOWUP');
      cubit.selectCategory(
        lead.leadCategory.isEmpty ? null : lead.leadCategory,
      );
      cubit.selectPriority(lead.priority.isEmpty ? null : lead.priority);
    }

    // ✅ Guard: prevent stacking success dialogs
    bool _dialogShown = false;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<AddLeadCubit, AddLeadState>(
          listener: (ctx, state) {
            log(state.status.toString());

            // ── Success ──────────────────────────────────────────────────────
            if (state.status == AddLeadStatus.success &&
                state.successMessage == 'Follow-up added successfully.' &&
                !_dialogShown) {
              _dialogShown = true;

              // 1️⃣ Reload parent data
              widget.onFollowUpAdded();

              // 2️⃣ Close the follow-up form dialog first
              Navigator.pop(dialogContext);

              // 3️⃣ Show success alert AFTER form is closed
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

            // ── Error from cubit ─────────────────────────────────────────────
            if (state.errorMessage != null && !_dialogShown) {
              _dialogShown = true;
              // Reset guard after dialog is dismissed
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
                            _dialogShown = false; // ✅ reset so next error shows
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
                          // ── Validation: call status ───────────────────
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

                          // ── Validation: WhatsApp number ───────────────
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

                          await cubit.submitFollowUp(
                            leadId: widget.leadId,
                            leadName: widget.leadName,
                            leadWhatsappNo: _WhtsppNoCtrl.text.trim(),
                            leadWhatsappDialCode: '+91',
                            calledDate: calledDateValue,
                            nextFollowUpDate: nextFollowUpDate,
                            calledStatus: _callStatusCtrl.text,
                            leadTag: widget.lead.leadTag ?? '',
                            remarks: _remarksCtrl.text.trim(),
                            address: _addressm.text.trim(),
                            email: _emailCtrl.text.trim(),
                            previousStage: widget.lead.leadStage ?? '',
                            previousCategory: widget.lead.leadCategory ?? '',
                            previousPriority: widget.lead.priority ?? '',
                            leadPhone: widget.lead.contactNumber ?? '',
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
                        // ── Row 1: Called Date + Call Status ──────────
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

                        // ── Row 2: Lead Stage + Lead Category ─────────
                        Row(
                          children: [
                            Expanded(
                              child: Dropdown(
                                showHelp: true,
                                showStar: true,
                                items: stagesNames,
                                showClear: false,
                                selectedValue: state.selectedLeadStage,
                                onChanged: (v) => cubit.selectLeadStage(v),
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
                                },
                                onTap: () => _showAddCategoryDialog(),
                              ),
                            ),
                          ],
                        ),

                        // ── Conditional: Next Follow-Up Date ──────────
                        if (state.selectedLeadStage == 'FOLLOWUP') ...[
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                ),
                              ),
                              SizedBox(width: 1.w),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],

                        // ── Conditional: Tags (Rejected) ───────────────
                        if (state.selectedLeadStage == 'REJECTED') ...[
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Expanded(
                                child: Dropdown(
                                  label: 'Tags',
                                  hint: 'Select Tags',
                                  items: [
                                    'Costly',
                                    'Not intrested',
                                    'Not Responding',
                                    'No Budget',
                                    'Wrong Lead',
                                  ],
                                  selectedValue: state.selectedLeadTag,
                                  onChanged: (v) => cubit.selectLeadTag(v),
                                ),
                              ),
                              SizedBox(width: 1.w),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                        SizedBox(height: 1.h),

                        // ── Row 4: Priority + WhatsApp ─────────────────
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

                        // ── Row 5: Email + Address ─────────────────────
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

                        // ── Row 6: Remarks ─────────────────────────────
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

                        // ── Loading indicator ──────────────────────────
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
          widget.leadCategoryCubit.addCategory(name: name);
          // setState(() => _leadCategory = name);

          context.read<AddLeadCubit>().selectCategory(name);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$name" added.'),
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

class _DateGroup extends StatelessWidget {
  final int dateCount;
  final int index;
  final String date;
  final String time;
  // final List<FollowUpModel> entries;
  final FollowUpModel entry;
  final AddLeadModel lead;
  final Function(FollowUpModel) onEdit;
  final Function(FollowUpModel) onDelete;
  const _DateGroup({
    required this.date,
    // required this.entries,
    required this.time,
    required this.entry,
    required this.lead,
    required this.index,
    required this.dateCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              // mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    // color: const Color(0xFFc1c1c1),
                    // borderRadius: BorderRadius.circular(6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      date,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading(
                        size: 13,
                        color: Color(0xFF555555),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 25,
                    width: 1,
                    color: const Color(0xFFDDDDDD),
                  ),
                ),
                Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 200,
                  color: const Color(0xFFDDDDDD),
                ),
                Expanded(
                  child: Container(width: 1, color: const Color(0xFFDDDDDD)),
                ),
              ],
            ),

            // Cards
            // Flexible(
            //   fit: FlexFit.loose,
            Expanded(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("count of entries are $index $dateCount"),
                  index == 0 &&
                          dateCount > 1 &&
                          lead.leadStage.toLowerCase() != 'rejected' &&
                          lead.leadStage.toLowerCase() != "closed" &&
                          //  lead.followUp!.isEmpty
                          lead.leadStage.toLowerCase() != "new"
                      ? _LastFollowupCard(lead: lead)
                      : lead.followUp!.isNotEmpty && index < dateCount - 1
                      ? _FollowupCard(
                          entry: entry,
                          lead: lead,
                          index: index,
                          onEdit: () => onEdit(entry),
                          onDelete: () => onDelete(entry),
                        )
                      : _FirstFollowupCard(
                          lead: lead,
                          needEdit: dateCount == 2,
                          onEdit: () => onEdit(entry),
                        ),
                  // if(index == dateCount - 1 && lead.followUp!.isNotEmpty)
                  //   _FirstFollowupCard(lead: lead,)

                  // SizedBox(height: 20),
                  //   _LastFollowupCard(lead: lead,),
                  // ...entries.map((e) =>
                  //     _FollowupCard(entry: e, lead: lead, entries : entries)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowupCard extends StatelessWidget {
  final FollowUpModel entry;
  final AddLeadModel lead;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FollowupCard({
    required this.entry,
    required this.lead,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 0, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            DateFormat('hh:mm a').format(entry.calledDate),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCDCDC)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFEEEEEE),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ Show who created this follow-up.
                        // Falls back to lead.assignedStaff for older records
                        // that were saved before assignedStaff was added.
                        Text(
                          entry.assignedStaff.isNotEmpty
                              ? entry.assignedStaff
                              : lead.assignedStaff,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const Spacer(),
                        if (index == 1)
                          Row(
                            children: [
                              InkWell(
                                onTap: onEdit,
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: onDelete,
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.leadStage.toLowerCase() != 'rejected' &&
                            entry.leadStage.toLowerCase() != 'closed')
                          _cardRow(
                            'Scheduled Date',
                            DateFormat(
                              'dd-MM-yyyy hh:mm a',
                            ).format(entry.nextFollowUpDate),
                          ),
                        const SizedBox(height: 4),
                        _cardRow(
                          'Called Date',
                          DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(entry.calledDate),
                        ),
                        const SizedBox(height: 4),
                        _cardRow('Call Status', entry.calledStatus),
                        const SizedBox(height: 4),
                        if (entry.leadStage.toLowerCase() == 'rejected')
                          _cardRow('Tags', lead.leadTag!),
                        if (entry.leadStage.toLowerCase() == 'rejected')
                          const SizedBox(height: 4),
                        _remarkRow('-${entry.remarks}'),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ': ',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _StatusChip(label: entry.leadStage),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
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

  Widget _remarkRow(String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            'Remark',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(': '),
        Expanded(child: Text(value, softWrap: true)),
      ],
    );
  }

  Widget _cardRow(String label, String value) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstFollowupCard extends StatelessWidget {
  final bool needEdit;
  final AddLeadModel lead;
  final VoidCallback onEdit;
  const _FirstFollowupCard({
    required this.lead,
    required this.needEdit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            // entry.time,
            DateFormat('hh:mm a').format(lead.createdAt!),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
            // const TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w500,
            //     color: Color(0xFF444444)),
          ),
          SizedBox(height: 25),
          Container(
            // width: 550,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCDCDC)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFEEEEEE),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lead.createdBy,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF222222),
                          ),
                        ),

                        // const Spacer(),
                        // if(needEdit)
                        // Row(
                        //   children: [
                        //     InkWell(
                        //       onTap: onEdit,
                        //       child: Icon(
                        //         Icons.edit_outlined,
                        //         size: 18,
                        //         color: Colors.green.shade600,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 8),
                        //     Icon(
                        //       Icons.delete_outline,
                        //       size: 18,
                        //       color: Colors.red.shade400,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardRow(
                          'Created Date',
                          DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(lead.createdAt!),
                        ),
                        const SizedBox(height: 6),
                        _cardRow('Remark', '-${lead.remarks}'),

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ': ',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _StatusChip(label: "NEW"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // _cardRow('Products', entry.products),
                      ],
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

  Widget _cardRow(String label, String value) {
    return SizedBox(
      // width: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastFollowupCard extends StatelessWidget {
  final AddLeadModel lead;
  const _LastFollowupCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            // entry.time,
            DateFormat('hh:mm a').format(lead.calledDate ?? lead.createdAt!),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
          ),
          SizedBox(height: 25),
          Container(
            // width: MediaQuery.of(context).size.width/4,
            decoration: BoxDecoration(
              // color: Color(0xFFFFF3E0),
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDE2E2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFEEEEEE),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lead.assignedStaff,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF222222),
                          ),
                        ),
                        // const Spacer(),
                        // Icon(
                        //   Icons.edit_outlined,
                        //   size: 18,
                        //   color: Colors.green.shade600,
                        // ),
                        // const SizedBox(width: 8),
                        // Icon(
                        //   Icons.delete_outline,
                        //   size: 18,
                        //   color: Colors.red.shade400,
                        // ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardRow(
                          'Scheduled Date',
                          DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(lead.followUpDate!),
                        ),

                        // const SizedBox(height: 6),
                        // _cardRow('Remark', lead.remarks),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ': ',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Row(
                              children: [
                                _StatusChip(label: lead.leadStage),
                                Text(
                                  "(Pending)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // _cardRow('Products', entry.products),
                      ],
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

  Widget _cardRow(String label, String value) {
    return SizedBox(
      // width: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 2 – Activities content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _ActivitiesTabContent extends StatefulWidget {
  final AddLeadModel lead;
  const _ActivitiesTabContent({required this.lead});

  @override
  State<_ActivitiesTabContent> createState() => _ActivitiesTabContentState();
}

class _ActivitiesTabContentState extends State<_ActivitiesTabContent> {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Activities',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
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
                    .map((a) => _ActivityItem(activity: a))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityItem({required this.activity});

  IconData get _icon {
    switch (activity.type) {
      case ActivityType.leadCreated:
        return Icons.add_circle_outline;
      case ActivityType.statusChanged:
        return Icons.swap_horiz;
      case ActivityType.followupAdded:
        return Icons.phone_callback_outlined;
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
        return Icons.history;
    }
  }

  Color get _iconColor {
    switch (activity.type) {
      case ActivityType.leadCreated:
        return const Color(0xFF4CAF50);
      case ActivityType.statusChanged:
        return const Color(0xFF2196F3);
      case ActivityType.followupAdded:
        return const Color(0xFFFF9800);
      case ActivityType.categoryChanged:
        return const Color(0xFF9C27B0);
      case ActivityType.priorityChanged:
        return const Color(0xFFF44336);
      case ActivityType.costUpdated:
        return const Color(0xFF009688);
      default:
        return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _iconColor.withOpacity(0.12),
                child: Icon(_icon, size: 18, color: _iconColor),
              ),
              Container(width: 1.5, height: 50, color: const Color(0xFFE0E0E0)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent name
                Text(
                  activity.changedBy,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 3),
                // Description (auto-generated sentence)
                Text(
                  activity.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF555555),
                    height: 1.5,
                  ),
                ),

                /// Show value change pill if present
                // if (activity.previousValue != null &&
                //     activity.newValue != null) ...[
                //   const SizedBox(height: 6),
                //   Row(
                //     children: [
                //       _ValueChip(
                //         label: activity.previousValue!,
                //         color: const Color(0xFFEEEEEE),
                //         textColor: const Color(0xFF888888),
                //       ),
                //       const Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 6),
                //         child: Icon(Icons.arrow_forward,
                //             size: 14, color: Color(0xFF888888)),
                //       ),
                //       _ValueChip(
                //         label: activity.newValue!,
                //         color: const Color(0xFFE3F2FD),
                //         textColor: const Color(0xFF1565C0),
                //       ),
                //     ],
                //   ),
                // ],
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd-MM-yyyy hh:mm a').format(activity.changedAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF999999),
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

class _ValueChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _ValueChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: textColor),
      ),
    );
  }
}

// class _ActivitiesTabContent extends StatelessWidget {
//   final List<ActivityEntry> activities;
//   final AddLeadModel lead;
//   const _ActivitiesTabContent({required this.activities, required this.lead});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
//         children: [
//           Text(
//             'Activities',
//             style: GoogleFonts.poppins(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF222222),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // ✅ Spread entries as Column children — no ListView
//           ...activities.map((a) => _ActivityItem(entry: a)),
//         ],
//       ),
//     );
//   }
// }
//
// class _ActivityItem extends StatelessWidget {
//   final ActivityEntry entry;
//   const _ActivityItem({required this.entry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             children: [
//               const CircleAvatar(
//                 radius: 18,
//                 backgroundColor: Color(0xFFEEEEEE),
//                 child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
//               ),
//               Container(width: 1.5, height: 40, color: const Color(0xFFE0E0E0)),
//             ],
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   entry.agent,
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   entry.description,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Color(0xFF555555),
//                     height: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   entry.dateTime,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Color(0xFF999999),
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

///
// ─────────────────────────────────────────────────────────
// Tab 3 – Details content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _DetailsTabContent extends StatefulWidget {
  final AddLeadModel lead;
  const _DetailsTabContent({required this.lead});

  @override
  State<_DetailsTabContent> createState() => _DetailsTabContentState();
}

class _DetailsTabContentState extends State<_DetailsTabContent> {
  late final Future<List<LeadStaffHandler>> _handlersFuture;

  @override
  void initState() {
    super.initState();
    _handlersFuture = AddLeadRepository().getLeadHandledStaffs(widget.lead);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: Color(0xFF888888),
      fontWeight: FontWeight.w500,
    );
    TextStyle valueStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: Color(0xFF222222),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          Text(
            'Details',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          _DetailGrid(
            rows: [
              [
                'Phone',
                (widget.lead.contactNumber),
                'Address',
                (widget.lead.address),
              ],
              [
                'State',
                (widget.lead.state),
                'District',
                (widget.lead.district),
              ],
              [
                'Post office',
                widget.lead.postOffice,
                'Pincode',
                widget.lead.pinCode,
              ],
              [
                'Whatsapp_number',
                (widget.lead.whatsappNumber),
                'Email',
                widget.lead.email,
              ],
              [
                'Created Date',
                DateFormat('dd-MM-yyyy hh:mm').format(widget.lead.createdAt!),
                'Created By',
                widget.lead.createdBy,
              ],
              [
                'Lead Category',
                widget.lead.leadCategory,
                'Assigned Staff',
                widget.lead.assignedStaff,
              ],
              // ['Cost', '0',
              [
                'Call Status',
                widget.lead.callResult ?? "-",
                'Lead Stage',
                widget.lead.leadStage,
              ],
              // ['Products', '', '', ''],
            ],
          ),
          const SizedBox(height: 8),
          _detailRow(
            labelStyle: labelStyle,
            valueStyle: valueStyle,
            left: 'Lead Method',
            leftVal: widget.lead.leadSource,
            right: 'Remarks',
            rightVal: widget.lead.remarks.isEmpty
                ? '-'
                : '-${widget.lead.remarks}',
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Text(
            'Lead handled staffs',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ Dynamic staff list
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

              // Render in rows of 2 — matches your existing layout
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < handlers.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: _StaffCard(handler: handlers[i])),
                          if (i + 1 < handlers.length) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StaffCard(handler: handlers[i + 1]),
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
          // Row(
          //   children: [
          //     Expanded(
          //       child: _StaffCard(
          //         name: 'Oxdo technologies pvt ltd',
          //         phone: '9207554433',
          //         activities: 1,
          //         isStarred: false,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _StaffCard(
          //         name: 'Shahid',
          //         phone: '918089131915',
          //         activities: 2,
          //         isStarred: true,
          //       ),
          //     ),
          //   ],
          // ),
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
              Expanded(
                child: _DetailCell(label: row[0], value: row[1]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailCell(label: row[2], value: row[3]),
              ),
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
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF222222)),
        ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final LeadStaffHandler handler;
  const _StaffCard({required this.handler});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEECC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handler.staffName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222222),
                  ),
                ),
                if (handler.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    handler.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${handler.activityCount}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  handler.activityCount == 1 ? 'Activity' : 'Activities',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          // Star marks current assignee
          if (handler.isCurrentAssignee)
            const Icon(Icons.star, color: Color(0xFFFFA000), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────

Color getPriorityColor(String priority) {
  switch (priority.trim().toLowerCase()) {
    case 'high':
      return const Color(0xffEF4444); // Red
    case 'normal':
      return const Color(0xff22C55E); // Green
    case 'low':
      return const Color(0xffF97316); // Orange-Yellow
    case 'negative':
      return const Color(0xff9CA3AF);
    default:
      return const Color(0xffFFFFFF);
  }
}

class _PriorityBadge extends StatelessWidget {
  final String label;
  final String priority;
  const _PriorityBadge({required this.label, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: getPriorityColor(priority),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.medium(
          color: Colors.white,
          weight: FontWeight.w600,
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
        style: AppTextStyle.heading(
          color: Colors.white,
          size: 11,
          weight: FontWeight.w600,
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
        return const Color(0xFFF59E0B);
      case 'followup':
        return const Color(0xFFF59E0B);
      case 'connected':
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
