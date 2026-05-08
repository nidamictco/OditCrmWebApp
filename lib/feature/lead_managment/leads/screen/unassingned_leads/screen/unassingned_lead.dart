import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class UnassingnedLead extends StatefulWidget {
  const UnassingnedLead({super.key});

  @override
  State<UnassingnedLead> createState() => _UnassingnedLeadState();
}

class _UnassingnedLeadState extends State<UnassingnedLead> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();



  final List<String> leadCategory = [
    "Select lead Type ",
    "Need Further Followup",
    "Not Contacted",
    "Fake",
    "Visited",
    "May vist",
    "Not Interested",
    "Converted",
    "Lost",
  ];

  final List<String> status = [
    "Select Status",
    "In Progress",
    "Not Contacted",
    "Fake",
    "Visited",
    "May Vist",
    "Not Interested",
    "Converted",
    "Lost",
  ];

  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];

  String? selectedCategory;
  String? selectedStatus;
  String? selectedSource;

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchLeads();
    context.read<AddLeadCubit>().fetchStaff();
  }

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    result = result.where((lead) => lead.assignedStaffId.isEmpty).toList();

    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                (lead.clientName).toLowerCase().contains(q) ||
                (lead.contactNumber).toLowerCase().contains(q),
          )
          .toList();
    }

    // Entries limit
    // final limit = int.tryParse(_selectedEntries) ?? 10;
    return result;
  }

  List<AddLeadModel> _pagedLeads(List<AddLeadModel> allFiltered) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final start = (_currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allFiltered.length);
    if (start >= allFiltered.length) return [];
    return allFiltered.sublist(start, end);
  }

  int _totalPages(int totalCount) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    if (totalCount == 0) return 1;
    return (totalCount / limit).ceil();
  }

  void _goToPage(int page, int total) {
    final tp = _totalPages(total);
    if (page < 1 || page > tp) return;
    setState(() {
      _currentPage = page;
      _selectedIndices = [];
      _tableKey++;
    });
  }

  void _resetPage() {
    _currentPage = 1;
    _selectedIndices = [];
    _tableKey++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              title: 'Leads Management',
              subTitle: 'Unassigned Leads',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    ///TITLE BAR
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Unassigned Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(selectedIndex: 14),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.4.w,
                                vertical: 1.2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Import",
                                style: AppTextStyle.medium(
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),

                    ///FILTERS
                    Padding(
                      padding: EdgeInsets.only(
                        left: 2.w,
                        right: 2.w,
                        top: 2.w,
                        bottom: 1.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InputDate(
                                  label: "From Date",
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: true,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: "To Date",
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: false,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  showHelp: true,
                                  items: leadCategory,
                                  selectedValue: selectedCategory,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCategory = val;
                                      _resetPage();
                                    });
                                  },
                                  label: "Lead Category",
                                  hint: 'select category',
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Lead Status",
                                  hint: 'select status',
                                  showHelp: true,
                                  items: status,
                                  selectedValue: selectedStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStatus = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          Row(
                            children: [
                              SizedBox(
                                width: 17.45.w,
                                child: Dropdown(
                                  label: "Lead Source",
                                  hint: 'select source',
                                  showHelp: true,
                                  items: leadSource,
                                  selectedValue: selectedSource,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedSource = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),

                              SizedBox(width: 2.w),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: SizedBox(
                                  width: 7.w,
                                  height: 4.5.h,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xff1BAA90),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
                                        style: AppTextStyle.small(
                                          size: 10.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    ///TABLE CONTROLS
                    ShowEntries(
                      initialSearch: _searchQuery,
                      initialEntries: _selectedEntries,
                      onSearchChanged: (v) => setState(() {
                        _searchQuery = v;
                        _resetPage();
                      }),
                      onEntriesChanged: (v) => setState(() {
                        _selectedEntries = v;
                        _resetPage();
                      }),
                    ),

                    ///TABLE
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        // Loading
                        if (state.listStatus == LeadListStatus.loading) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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

                        final allFiltered = _filteredLeads(rawList);
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
                        // Loaded with data
                        if (state.listStatus == LeadListStatus.loaded) {
                          return Column(
                            children: [
                              SizedBox(
                                child: CustomTable(
                                  key: ValueKey(_tableKey),
                                  columns: [
                                    TableColumn(title: "#", flex: 1),
                                    TableColumn(title: "Name", flex: 4),
                                    TableColumn(
                                      title: "Contact Number",
                                      flex: 4,
                                    ),
                                    TableColumn(
                                      title: "Lead Category",
                                      flex: 4,
                                    ),
                                    TableColumn(title: "Lead Status", flex: 4),
                                    TableColumn(title: "Created Date", flex: 4),
                                    TableColumn(title: "Action", flex: 2),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final lead = entry.value;
                                    final serial =
                                        (_currentPage - 1) * limit + index + 1;
                                    return [
                                      Text(
                                        '$serial',
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        lead.clientName,
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        lead.contactNumber,
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        lead.leadCategory,
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        lead.leadStage,
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        lead.createdAt != null
                                            ? DateFormat(
                                                'dd MMM yyyy',
                                              ).format(lead.createdAt!)
                                            : '-',
                                        style: AppTextStyle.medium(),
                                      ),

                                      /// ACTION
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MainScreen(
                                                selectedIndex: 1,
                                                lead: lead,
                                              ),
                                            ),
                                          );
                                          if (context.mounted) {
                                            context
                                                .read<AddLeadCubit>()
                                                .fetchLeads();
                                          }
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          size: 14.sp,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ];
                                  }).toList(),
                                  showCheckboxes: true,
                                  // key: ValueKey(filteredList.length),
                                  onCheckChanged: (rowIndex, isChecked) {
                                    setState(() {
                                      if (isChecked) {
                                        if (!_selectedIndices.contains(
                                          rowIndex,
                                        )) {
                                          _selectedIndices.add(rowIndex);
                                        }
                                      } else {
                                        _selectedIndices.remove(rowIndex);
                                      }
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Showing $showFrom to $showTo of $totalCount entries",
                                      style: AppTextStyle.medium(
                                        weight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        PageButton(
                                          label: 'Previous',
                                          enabled: _currentPage > 1,
                                          isLeft: true,
                                          onTap: () => _goToPage(
                                            _currentPage - 1,
                                            totalCount,
                                          ),
                                        ),
                                        ..._buildPageNumbers(
                                          totalPages,
                                          totalCount,
                                        ),
                                        PageButton(
                                          label: 'Next',
                                          enabled: _currentPage < totalPages,
                                          isRight: true,
                                          onTap: () => _goToPage(
                                            _currentPage + 1,
                                            totalCount,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox();
                      },
                    ),

                    /// 🔹 FOOTER
                    SizedBox(height: 2.h),

                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        final List<AddLeadModel> rawList =
                            state.listStatus == LeadListStatus.loaded
                            ? state.leads
                            : [];
                        final filteredList = _filteredLeads(rawList);

                        // 🔹 Map selected indices → actual lead objects
                        final selectedLeads = _selectedIndices
                            .where((i) => i < filteredList.length)
                            .map((i) => filteredList[i])
                            .toList();

                        final hasSelection = selectedLeads.isNotEmpty;
                        // final staff=state.assignedStaffName.map((e) => e.name).toList();
                        return Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: hasSelection
                                    ? () => _deleteSelectedLeads(selectedLeads)
                                    : null,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 1.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.delete_forever,
                                    size: 14.sp,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                              SizedBox(width: 0.5.w),
                              GestureDetector(
                                onTap: hasSelection
                                    ? () =>
                                          _showAssignStaffDialog(selectedLeads)
                                    : null,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 1.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Assign Staff',
                                    style: AppTextStyle.small(
                                      size: 11.sp,
                                      color: AppColors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignStaffDialog(List<AddLeadModel> selectedLeads) {
    String? selectedStaffId;
    String? selectedStaffName;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<AddLeadCubit>(),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return BlocBuilder<AddLeadCubit, AddLeadState>(
                builder: (context, state) {
                  // 🔹 Use staffList directly from AddLeadState
                  final staffList = state.staffList;
                  final staffNames = staffList.map((s) => s.name).toList();

                  return AppDialog(
                    title: 'Assign Staff',
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedLeads.length} lead(s) selected",
                          style: AppTextStyle.medium(
                            color: AppColors.grey,
                            weight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Dropdown(
                          label: 'Staff',
                          hint: 'Select Staff',
                          items: staffNames,
                          selectedValue: selectedStaffName,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedStaffName = val;
                              selectedStaffId = staffList
                                  .firstWhere((s) => s.name == val)
                                  .id;
                            });
                          },
                        ),
                      ],
                    ),
                    onClose: () => Navigator.pop(dialogContext),
                    onSubmit: () async {
                      if (selectedStaffId == null || selectedStaffName == null)
                        return;

                      for (final lead in selectedLeads) {
                        await context.read<AddLeadCubit>().assignStaff(
                          leadId: lead.id!,
                          staffId: selectedStaffId!,
                          staffName: selectedStaffName!,
                        );
                      }

                      Navigator.pop(dialogContext);
                      // 🔹 Clear selection — assigned leads auto-disappear
                      // because _filteredLeads filters out assignedStaffId != ''
                      setState(() {
                        _selectedIndices = [];
                        _tableKey++; // 🔹 forces CustomTable to rebuild fresh with all boxes unchecked
                      });
                      // context.read<AddLeadCubit>().fetchLeads();
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _deleteSelectedLeads(List<AddLeadModel> selectedLeads) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Leads"),
        content: Text(
          "Are you sure you want to delete ${selectedLeads.length} lead(s)?",
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              for (final lead in selectedLeads) {
                await context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
              }
              Navigator.pop(dialogContext);
              setState(() => _selectedIndices = []);
              context.read<AddLeadCubit>().fetchLeads();
            },
            child: Text("Delete", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // ── Page number chips ───────────────────────
  List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
    if (totalPages <= 1) return [];

    final List<Widget> widgets = [];

    // Show at most 5 page buttons centered around current page
    int start = (_currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    if (end - start < 4) start = (end - 4).clamp(1, totalPages);

    for (int page = start; page <= end; page++) {
      final isActive = page == _currentPage;
      widgets.add(
        GestureDetector(
          onTap: () => _goToPage(page, totalCount),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0.2.w),
            padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.white,
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Text(
              '$page',
              style: AppTextStyle.small(
                size: 11.sp,
                color: isActive ? AppColors.white : AppColors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

