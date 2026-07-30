import 'dart:developer';

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/custom_calender.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/add_leads_button.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/dashboard_card.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/recent_lead_activity_tile.dart';
import 'package:Odit_CRM/main.dart';
import 'package:sizer/sizer.dart';

import '../lead_managment/leads/cubit/add_lead_cubit.dart';
import '../lead_managment/leads/cubit/add_lead_state.dart';
import 'leads_migration_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  final TextEditingController _dateController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text = DateFormat('dd-MM-yyyy').format(today);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AddLeadCubit>().fetchDashboardCounts(today);
      context.read<AddLeadCubit>().fetchRecentActivities();
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final user = await SessionService().getSavedUser();
    // log("hghghghghghhgghhg wwww ${user?.toJson()}");
    if (mounted) {
      setState(() {
        _isAdmin = user?.designation?.toLowerCase() == 'company_admin';
      });
    }
  }

  Future<void> addDesignationToSubCompanyUsers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get only users where companyType == "sub_company"
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('USERS')
          .where('companyType', isEqualTo: 'sub_company')
          .get();

      if (snapshot.docs.isEmpty) {
        print('No sub_company users found.');
        return;
      }

      // Use batch to update all matching documents
      WriteBatch batch = firestore.batch();

      int operationCount = 0;

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'designation': 'Company_Admin',
          'designationId': 'Company_Admin',
        });

        operationCount++;

        // Commit every 500 operations
        if (operationCount == 500) {
          await batch.commit();

          batch = firestore.batch();
          operationCount = 0;
        }
      }

      // Commit remaining updates
      if (operationCount > 0) {
        await batch.commit();
      }

      print('Successfully updated ${snapshot.docs.length} sub_company users.');
    } catch (e, stackTrace) {
      print('Error updating users: $e');
      print(stackTrace);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final today = _dateController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(_dateController.text)
        : null;
    context.read<AddLeadCubit>().fetchDashboardCounts(today, forceFetch: true);
    context.read<AddLeadCubit>().fetchRecentActivities();
  }

  @override
  Widget build(BuildContext context) {
    final addLeadCubit = context.read<AddLeadCubit>();
    log("ghgghghhhhgh ${_isAdmin}");

    return Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: AppThemeColors.scaffoldBg,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Admin-Only Package Banner
                    if (_isAdmin)
                      BlocBuilder<AddLeadCubit, AddLeadState>(
                        builder: (context, state) {
                          return AdminPackageBanner(
                            planName: state.subscriptionPlan,
                            startDate: state.subscriptionStartDate,
                            endDate: state.subscriptionEndDate,
                            userCount: state.companyUserCount,
                          );
                        },
                      ),

                    // 2. Lead Management Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Title + Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lead Management",
                              style: AppTextStyle.heading(size: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Calling features that give you wings that fast..",
                              style: AppTextStyle.small(
                                color: AppColors.grey.withOpacity(0.8),
                                size: 11.5.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Right: Date selector dropdown + Add Leads button
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (dialogContext) {
                                    return Stack(
                                      children: [
                                        Positioned(
                                          top: 20.h,
                                          right: 5.w,
                                          child: CustomCalendar(
                                            initialSelectedDate:
                                                _dateController.text.isNotEmpty
                                                ? DateFormat(
                                                    'dd-MM-yyyy',
                                                  ).parse(_dateController.text)
                                                : null,
                                            onDateSelected: (date) {
                                              setState(() {
                                                _dateController.text =
                                                    DateFormat(
                                                      'dd-MM-yyyy',
                                                    ).format(date);
                                              });
                                              addLeadCubit
                                                  .updateSelectedDashboardDate(
                                                    date,
                                                  );
                                              addLeadCubit.fetchDashboardCounts(
                                                date,
                                                forceFetch: true,
                                              );
                                              Navigator.pop(dialogContext);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.lightGrey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: AppColors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _dateController.text.isNotEmpty
                                          ? _dateController.text
                                          : 'Select Date',
                                      style: AppTextStyle.medium(
                                        size: 13,
                                        color: AppColors.black,
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_dateController.text.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _dateController.clear();
                                          });
                                          addLeadCubit
                                              .updateSelectedDashboardDate(
                                                null,
                                              );
                                          addLeadCubit.fetchDashboardCounts(
                                            null,
                                            forceFetch: true,
                                          );
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: AppColors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(width: 16),
                            // const AddLeadsButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Stat Cards Grid
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      buildWhen: (previous, current) =>
                          previous.isLoadingCounts != current.isLoadingCounts,
                      builder: (context, state) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            double cardWidth;
                            if (totalWidth > 1200) {
                              cardWidth = (totalWidth - 5 * 16) / 6;
                            } else if (totalWidth > 500) {
                              cardWidth = (totalWidth - 2 * 16) / 6.5;
                              // } else if (totalWidth > 500) {
                              //   cardWidth = (totalWidth - 1 * 16) / 9;
                            } else {
                              cardWidth = totalWidth;
                            }

                            if (state.isLoadingCounts) {
                              return SizedBox(
                                height: 130,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 6,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: _SkeletonCard(width: cardWidth),
                                    );
                                  },
                                ),
                              );
                            }

                            final cards = [
                              DashboardCard(
                                title: "New Leads",
                                message:
                                    'The combined count of new\nleads and unattended leads.',
                                fromCard: 'NEW',
                                width: cardWidth,
                              ),
                              DashboardCard(
                                title: "Follow-up",
                                message:
                                    'The current count of leads assigned \nfor today, including missed follow-up leads.',
                                fromCard: 'FOLLOWUP',
                                width: cardWidth,
                              ),
                              DashboardCard(
                                title: "Closed Leads",
                                message:
                                    'Closed leads can be filtered using a specific \ndate range to determine the count of \nclosed leads within that period.',
                                fromCard: 'CLOSED',
                                width: cardWidth,
                              ),
                              DashboardCard(
                                title: "Total Called",
                                message:
                                    'Total called can be filtered \nusing a specific date range to determine \nthe count of total leads within that period.',
                                fromCard: 'TOTAL',
                                dateText: _dateController.text,
                                width: cardWidth,
                              ),
                              DashboardCard(
                                title: "Missed Leads",
                                message: 'Missed Leads',
                                fromCard: 'MISSED',
                                width: cardWidth,
                              ),
                              DashboardCard(
                                title: "Transferred",
                                message:
                                    'Count of total leads \ntransferred to you.',
                                fromCard: 'TRANSFERRED',
                                width: cardWidth,
                              ),
                            ];

                            return SizedBox(
                              height: 130,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cards.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: cards[index],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // 4. Recent Lead Activities List Panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recent Lead Activities",
                            style: AppTextStyle.medium(
                              size: 15,
                              weight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<AddLeadCubit, AddLeadState>(
                            builder: (context, state) {
                              if (state.isLoadingActivities) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (state.recentActivities.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "No recent activities found.",
                                      style: AppTextStyle.small(
                                        size: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.recentActivities.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: AppColors.lightGrey.withOpacity(0.5),
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final activity =
                                      state.recentActivities[index];
                                  return RecentLeadActivityTile(
                                    activity: activity,
                                  );
                                },
                              );
                            },
                          ),
                        ],
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

class AdminPackageBanner extends StatelessWidget {
  final String planName;
  final String startDate;
  final String endDate;
  final String userCount;

  const AdminPackageBanner({
    super.key,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.userCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetResources.dashboard_banner),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xff1d4ed8), // deep blue-purple gradient
            Color(0xff6b21a8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  planName.toUpperCase(),
                  style: AppTextStyle.small(
                    size: 11,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "START DATE",
                        style: AppTextStyle.small(
                          size: 10,
                          weight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startDate.isNotEmpty ? startDate : '--/--/----',
                        style: AppTextStyle.medium(
                          size: 13,
                          weight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "END DATE",
                        style: AppTextStyle.small(
                          size: 10,
                          weight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        endDate.isNotEmpty ? endDate : '--/--/----',
                        style: AppTextStyle.medium(
                          size: 13,
                          weight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  "$userCount USERS",
                  style: AppTextStyle.medium(
                    size: 12,
                    weight: FontWeight.w500,
                    color: Colors.white,
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

class _SkeletonCard extends StatelessWidget {
  final double width;
  const _SkeletonCard({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.dashboardCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 12, width: 80, color: Colors.grey[100]),
          const SizedBox(height: 8),
          Container(height: 24, width: 40, color: Colors.grey[200]),
        ],
      ),
    );
  }
}

class MigrateLeadsButton extends StatefulWidget {
  const MigrateLeadsButton({super.key});

  @override
  State<MigrateLeadsButton> createState() => _MigrateLeadsButtonState();
}

class _MigrateLeadsButtonState extends State<MigrateLeadsButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: () => LeadsMigrationHelper.migrateLeads(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 6.h,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.amber[800]
                : Colors.amber[800]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.amber[800]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.settings_backup_restore,
                color: isHovering ? Colors.white : Colors.amber[800],
                size: 2.5.h,
              ),
              const SizedBox(width: 5),
              Text(
                "Migrate Leads",
                style: AppTextStyle.small(
                  color: isHovering ? Colors.white : Colors.amber[800],
                  size: 11.sp,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
