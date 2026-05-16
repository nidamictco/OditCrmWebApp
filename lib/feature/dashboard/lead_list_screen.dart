import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/dashboard/widget/add_leads_button.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:sizer/sizer.dart';

import '../lead_managment/leads/model/add_lead_model.dart';
import '../sidebar/main_screen.dart';

Color getLeadStatusColor(String status) {
  switch (status) {
    case 'FOLLOWUP':
      return const Color(0xFFF59E0B);
    case 'NEW':
      return const Color(0xFF10B981);
    case 'TRANSFERRED':
      return const Color(0xFF3B82F6);
    case 'MISSED':
      return const Color(0xFFEF4444);
    case 'CLOSED':
      return const Color(0xFF0D31E8);
    default:
      return const Color(0xFF10B981);
  }
}

class NewLeadsPage extends StatefulWidget {
  String fromCard;
  NewLeadsPage({super.key, required this.fromCard});

  @override
  State<NewLeadsPage> createState() => _NewLeadsPageState();
}

class _NewLeadsPageState extends State<NewLeadsPage> {
  bool isHovering = false;
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '50', '100', '500', '1000'];

  // List<Lead> _leads = List.from(sampleLeads);
  bool _selectAll = false;
  String _searchQuery = '';
  String _selectedEntries = '10';
  int _currentPage = 1;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  // Total fixed width of the table — must match sum of all column widths
  static const double _tableWidth =
      52 + 40 + 140 + 160 + 180 + 100 + 110 + 160 + 160 + 150;

  // List<Lead> get _filteredLeads {
  //   if (_searchQuery.isEmpty) return _leads;
  //   final q = _searchQuery.toLowerCase();
  //   return _leads.where((l) {
  //     return l.name.toLowerCase().contains(q) ||
  //         l.contactNumber.contains(q) ||
  //         l.leadCategory.toLowerCase().contains(q) ||
  //         l.staff.toLowerCase().contains(q);
  //   }).toList();
  // }

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    if (_searchQuery.isEmpty) return result;

    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                lead.clientName.toLowerCase().contains(q) ||
                lead.contactNumber.contains(q) ||
                lead.leadCategory.toLowerCase().contains(q) ||
                lead.assignedStaff.toLowerCase().contains(q),
          )
          .toList();
    }

    // Entries limit
    // final limit = int.tryParse(_selectedEntries) ?? 10;
    return result;
  }

  int _totalPages(int totalCount) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    if (totalCount == 0) return 1;
    return (totalCount / limit).ceil();
  }

  List<AddLeadModel> _pagedLeads(List<AddLeadModel> allFiltered) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final start = (_currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allFiltered.length);
    if (start >= allFiltered.length) return [];
    return allFiltered.sublist(start, end);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      // _leads = _leads.map((l) => l.copyWith(isSelected: _selectAll)).toList();
    });
  }

  //
  void _toggleSelect(String id, bool? value) {
    // setState(() {
    //   _leads = _leads.map((l) {
    //     if (l.id == id) return l.copyWith(isSelected: value ?? false);
    //     return l;
    //   }).toList();
    //   _selectAll = _leads.every((l) => l.isSelected);
    // });
  }

  void _onView(AddLeadModel lead) {
    _showSnackBar('Viewing ${lead.clientName}', AppTheme.actionView);
  }

  void _onEdit(AddLeadModel lead) {
    _showSnackBar('Editing ${lead.clientName}', AppTheme.actionEdit);
  }

  void _onHistory(AddLeadModel lead) {
    _showSnackBar('History for ${lead.clientName}', AppTheme.actionHistory);
  }

  void _onDelete(AddLeadModel lead) {
    showDialog(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        leadName: lead.clientName,
        onConfirm: () {
          // setState(() => _leads.removeWhere((l) => l.id == lead.id));
          _showSnackBar('${lead.clientName} deleted', AppTheme.actionDelete);
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          // shrinkWrap: true,
          children: [
            TopBreadcrumbBar(title: 'DASHBOARD', subTitle: widget.fromCard.toUpperCase()),
        
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                // height: MediaQuery.of(context).size.height*1.5,
                decoration: _cardBox(),
                child: Column(
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "New Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              AddLeadsButton(),
                              SizedBox(width: 1.w),
                              // Container(
                              //   height: 4.5.h,
                              //   width: 4.5.h,
                              //   decoration: BoxDecoration(
                              //     // border: Border.all(color: Colors.indigo.shade00),
                              //     borderRadius: BorderRadius.circular(4),
                              //     color: Colors.indigo.shade100,
                              //   ),
                              //   child: Icon(
                              //     Icons.print,
                              //     size: 18,
                              //     color: Colors.indigo.shade900,
                              //   ),
                              // ),
                              HoverExportButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
        
                    Divider(color: AppColors.divider),
        
                    /// 🔹 FILTER SECTION
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          /// FIRST ROW
                          Row(
                            children: [
                              Expanded(child: _input("From Date", '20-04-2026')),
                              SizedBox(width: 2.w),
                              Expanded(child: _input("To Date", '20-04-2026')),
                              SizedBox(width: 2.w),
                              Expanded(child: _dropdown("Lead Category")),
                              SizedBox(width: 2.w),
                              Expanded(child: _dropdown("Lead Stage")),
                            ],
                          ),
        
                          SizedBox(height: 2.h),
        
                          /// SECOND ROW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 17.6.w,
                                child: _dropdown("Priority"),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(width: 17.6.w, child: _dropdown("Staff")),
                              SizedBox(width: 2.w),
                              _viewButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
        
                    Divider(color: AppColors.divider),
        
                    /// 🔹 TABLE CONTROLS
                    // Padding(
                    //   padding: EdgeInsets.only(
                    //     top: 1.h,
                    //     left: 2.w,
                    //     right: 2.w,
                    //     bottom: 1.h,
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Text(
                    //             "Show ",
                    //             style: AppTextStyle.medium(size: 11.sp),
                    //           ),
                    //           _smallDropdown(),
                    //           Text(
                    //             " entries",
                    //             style: AppTextStyle.medium(size: 11.sp),
                    //           ),
                    //         ],
                    //       ),
                    //       Row(
                    //         children: [
                    //           Text(
                    //             "Search:",
                    //             style: AppTextStyle.medium(size: 11.sp),
                    //           ),
                    //           SizedBox(width: 1.w),
                    //           Container(
                    //             width: 12.w,
                    //             height: 4.h,
                    //             decoration: _box(),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    ShowEntries(),
        
                    /// 🔹 TABLE HEADER
                    _buildTable(),
                    Divider(color: AppColors.divider),
        
                    /// 🔹 FOOTER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 0 to 0 of 0 entries",
                            style: AppTextStyle.medium(
                              size: 11.sp,
                              weight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.lightGrey),
                                    bottom: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                    left: BorderSide(color: AppColors.lightGrey),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Previous',
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
        
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lightGrey),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Next',
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        
                    /// 🔹 BOTTOM TRANSFER BUTTON
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 3.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: AppColors.red,
                                  size: 1.5.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 0.5.w),
                            Center(child: _bottomButton("Transfer")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================

  BoxDecoration _cardBox() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: AppColors.divider),
  );

  Widget _input(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Container(
          height: 4.5.h,
          decoration: _box(),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            value,
            style: AppTextStyle.small(
              size: 11.sp,
              color: AppColors.black,
              weight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Container(
          height: 4.8.h,
          decoration: _box(),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text("All", style: AppTextStyle.small(size: 10.sp)),
        ),
      ],
    );
  }

  Widget _viewButton() {
    return Container(
      width: 8.w,
      height: 4.5.h,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          "View",
          style: AppTextStyle.small(size: 10.sp, color: Colors.white),
        ),
      ),
    );
  }

  Widget _bottomButton(String text) {
    return Container(
      width: 5.w,
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(size: 11.sp, color: Colors.white),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    border: Border.all(color: AppColors.lightGrey),
    borderRadius: BorderRadius.circular(4),
    color: AppColors.white,
  );

  Widget _buildTableHeader() {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          Container(height: 1, color: AppTheme.border),
          SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: _HeaderRow(
              selectAll: _selectAll,
              onSelectAll: _toggleSelectAll,
            ),
          ),
          Container(height: 1, color: AppTheme.border),
        ],
      ),
    );
  }

  // Widget _buildTableBody() {
  //   final leads = _filteredLeads;
  //   if (leads) {
  //     return _buildEmptyState();
  //   }
  //   return Scrollbar(
  //     controller: _verticalScrollController,
  //     thumbVisibility: true,
  //     child: ListView.separated(
  //       controller: _verticalScrollController,
  //       itemCount: leads.length,
  //       separatorBuilder: (_, __) =>
  //           Container(height: 1, color: AppTheme.border),
  //       itemBuilder: (context, index) {
  //         final lead = leads[index];
  //         return SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           // Share scroll offset with header
  //           child: _LeadRow(
  //             lead: lead,
  //             isEven: index.isEven,
  //             onToggleSelect: _toggleSelect,
  //             onView: _onView,
  //             onEdit: _onEdit,
  //             onHistory: _onHistory,
  //             onDelete: _onDelete,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.search_off_rounded,
          size: 56,
          color: AppTheme.textMuted.withOpacity(0.5),
        ),
        const SizedBox(height: 10),
        const Text(
          'No leads found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        // const Text(
        //   'Try adjusting your search query',
        //   style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        // ),
      ],
    );
  }

  Widget _buildTable() {
    // final leads = _filteredLeads(leadList);
    //
    // if (leads.isEmpty) {
    //   return _buildEmptyState();
    // }

    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      notificationPredicate: (n) => n.depth == 0, // horizontal scrollbar
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        // ── fixed-width column that holds header + body ──
        child: SizedBox(
          width: _tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sticky header ──
              Container(
                color: AppTheme.surface,
                child: Column(
                  children: [
                    Container(height: 1, color: AppTheme.border),
                    _HeaderRow(
                      selectAll: _selectAll,
                      onSelectAll: _toggleSelectAll,
                    ),
                    Container(height: 1, color: AppTheme.border),
                  ],
                ),
              ),
              // ── Vertically scrollable body ──
              // Expanded(
                // child: Scrollbar(
                //   controller: _verticalScrollController,
                //   thumbVisibility: true,
                //   notificationPredicate: (n) => n.depth == 0,
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 56,          // at least one row height
                  // maxHeight: 56 * 10,     // cap at 10 rows max if you want a scroll limit
                ),
                child: BlocBuilder<AddLeadCubit, AddLeadState>(
                  builder: (context, state) {
                    // Loading
                    if (state.listStatus == LeadListStatus.loading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    // Error
                    if (state.listStatus == LeadListStatus.failure) {
                      return Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          state.listError ?? 'Something went wrong.',
                          style: AppTextStyle.medium(color: Colors.red),
                        ),
                      );
                    }

                    final List<AddLeadModel> rawList =
                        state.listStatus == LeadListStatus.loaded
                        ? state.leads
                        : [];

                    final List<AddLeadModel> leads = rawList
                        .where(
                          (e) =>
                              e.leadStage.toLowerCase() ==
                              widget.fromCard.toLowerCase(),
                        )
                        .toList();

                    final allFiltered = _filteredLeads(leads);
                    final totalCount = allFiltered.length;
                    final totalPages = _totalPages(totalCount);
                    final limit = int.tryParse(_selectedEntries) ?? 10;
                    if (_currentPage > totalPages) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _currentPage = totalPages);
                      });
                    }
                    final pagedList = _pagedLeads(allFiltered);

                    // "Showing X to Y of Z entries"
                    final showFrom = totalCount == 0
                        ? 0
                        : (_currentPage - 1) * limit + 1;
                    final showTo = (showFrom + pagedList.length - 1).clamp(
                      0,
                      totalCount,
                    );

                    print("ppppppppppppppppppp");

                    if (pagedList.isEmpty) {
                      return Center(child: _buildEmptyState());
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      // controller: _verticalScrollController,
                      itemCount: pagedList.length,
                      separatorBuilder: (_, __) =>
                          Container(height: 1, color: AppTheme.border),
                      itemBuilder: (context, index) {
                        final lead = pagedList[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainScreen(selectedIndex: 31),
                              ),
                            );
                          },
                          child: _LeadRow(
                            lead: lead,
                            isEven: index.isEven,
                            onToggleSelect: _toggleSelect,
                            onView: _onView,
                            onEdit: _onEdit,
                            onHistory: _onHistory,
                            onDelete: _onDelete,
                          ),
                        );
                      },
                    );
                  },
                ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverExportButton extends StatefulWidget {
  const HoverExportButton({super.key});

  @override
  State<HoverExportButton> createState() => _HoverExportButtonState();
}

class _HoverExportButtonState extends State<HoverExportButton> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 10.w,
        top: position.dy + renderBox.size.height + 5,
        child: MouseRegion(
          onEnter: (_) => _isHovering = true,
          onExit: (_) => _hideOverlay(),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _item(Icons.table_chart, "Export Excel"),
                  _item(Icons.picture_as_pdf, "Export PDF"),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_isHovering) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Widget _item(IconData icon, String text) {
    return InkWell(
      onTap: () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isHovering = true;
        _showOverlay();
      },
      onExit: (_) {
        _isHovering = false;
        _hideOverlay();
      },
      child: Container(
        height: 4.5.h,
        width: 4.5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.indigo.shade100,
        ),
        child: Icon(Icons.print, size: 18, color: Colors.indigo.shade900),
      ),
    );
  }
}

///...........................................
// ─────────────────────────────────────────────
// HEADER ROW
// ─────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final bool selectAll;
  final ValueChanged<bool?> onSelectAll;

  const _HeaderRow({required this.selectAll, required this.onSelectAll});

  static const _style = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppTheme.textSecondary,
    letterSpacing: 0.6,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      color: const Color(0xFFF1F5F9),
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Center(
              child: Checkbox(
                value: selectAll,
                onChanged: onSelectAll,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _cell('#', 40),
          _cell('NAME', 140),
          _cell('CONTACT NUMBER', 160),
          _cell('LEAD CATEGORY', 180),
          _cell('STAFF', 100),
          _cell('STATUS', 110),
          _cell('FOLLOWUP DATE', 160),
          _cell('CALLED DATE', 160),
          _cell('ACTION', 130),
        ],
      ),
    );
  }

  Widget _cell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label, style: _style),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA ROW
// ─────────────────────────────────────────────

class _LeadRow extends StatefulWidget {
  final AddLeadModel lead;
  final bool isEven;
  final void Function(String, bool?) onToggleSelect;
  final void Function(AddLeadModel) onView;
  final void Function(AddLeadModel) onEdit;
  final void Function(AddLeadModel) onHistory;
  final void Function(AddLeadModel) onDelete;

  const _LeadRow({
    required this.lead,
    required this.isEven,
    required this.onToggleSelect,
    required this.onView,
    required this.onEdit,
    required this.onHistory,
    required this.onDelete,
  });

  @override
  State<_LeadRow> createState() => _LeadRowState();
}

class _LeadRowState extends State<_LeadRow> {
  bool _hovered = false;

  static final DateFormat _fmt = DateFormat('dd-MM-yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color:
            // lead.isSelected ? AppTheme.primaryLight :
            _hovered
            ? const Color(0xFFF8FAFC)
            : widget.isEven
            ? AppTheme.surface
            : const Color(0xFFFAFAFA),
        // height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Checkbox(
                      value: false, //lead.isSelected,
                      onChanged: (v) => widget.onToggleSelect(lead.id!, v),
                      activeColor: AppTheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              // #
              _textCell(
                '${lead.id}',
                40,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Name
              _textCell(
                lead.clientName,
                140,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Contact
              SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: lead.contactNumber),
                      );
                    },
                    child: Text(
                      lead.contactNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Category
              _textCell(
                lead.leadCategory,
                180,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              // Staff
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.border,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          lead.assignedStaff,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status
              SizedBox(
                width: 110,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _StatusBadge(status: lead.leadStage),
                ),
              ),
              // FollowUp Date
              lead.followUpDate == null
                  ? _textCell(
                      _fmt.format(DateTime.now()),
                      160,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : _textCell(
                      _fmt.format(lead.followUpDate!),
                      160,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
              // Called Date
              lead.calledDate == null
                  ? _textCell(
                      _fmt.format(DateTime.now()),
                      160,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : _textCell(
                      _fmt.format(lead.calledDate!),
                      160,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
              // Actions
              SizedBox(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.visibility_rounded,
                        color: AppTheme.actionView,
                        tooltip: 'View',
                        onTap: () => widget.onView(lead),
                      ),
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        color: AppTheme.actionEdit,
                        tooltip: 'Edit',
                        onTap: () => widget.onEdit(lead),
                      ),
                      _ActionButton(
                        icon: Icons.history_rounded,
                        color: AppTheme.actionHistory,
                        tooltip: 'History',
                        onTap: () => widget.onHistory(lead),
                      ),
                      _ActionButton(
                        icon: Icons.delete_rounded,
                        color: AppTheme.actionDelete,
                        tooltip: 'Delete',
                        onTap: () => widget.onDelete(lead),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textCell(String text, double width, {required TextStyle style}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(text, style: style, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  // final LeadStatus status;
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: getLeadStatusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getLeadStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: getLeadStatusColor(status),
          letterSpacing: 0.2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DELETE CONFIRM DIALOG
// ─────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final String leadName;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({required this.leadName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Lead',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "$leadName"? This action cannot be undone.',
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.actionDelete,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
