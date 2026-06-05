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
    context.read<AddLeadCubit>().initialize();

    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());
  }

  String? _appliedCategory;
  String? _appliedLeadStage;
  String? _appliedSource;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedLeadStage = selectedStatus;
      _appliedSource = selectedSource;
      _appliedFromDate = _parseDate(_fromDateController.text);
      _appliedToDate = _parseDate(_toDateController.text);
      _resetPage();
    });
  }

  DateTime? _parseDate(String text) {
    try {
      return DateFormat('dd-MM-yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  // ── Skip placeholder "Select …" values ──────────────────────────────────────
  bool _isPlaceholder(String? val) =>
      val == null ||
      val.trim().isEmpty ||
      val.toLowerCase().startsWith('select');

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    result = result.where((lead) => lead.assignedStaffId.isEmpty).toList();

    // ── Date range ─────────────────────────────────────────────────────────────
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result
          .where((l) => l.createdAt != null && !l.createdAt!.isBefore(from))
          .toList();
    }
    if (_appliedToDate != null) {
      final to = DateTime(
        _appliedToDate!.year,
        _appliedToDate!.month,
        _appliedToDate!.day,
        23,
        59,
        59,
      );
      result = result
          .where((l) => l.createdAt != null && !l.createdAt!.isAfter(to))
          .toList();
    }

    // ── Lead Category — stored UPPERCASE in Firestore ─────────────────────────
    if (!_isPlaceholder(_appliedCategory)) {
      final cat = _appliedCategory!.trim().toUpperCase();
      result = result
          .where((l) => l.leadCategory.toUpperCase() == cat)
          .toList();
    }

    // ── Lead Stage — stored UPPERCASE in Firestore ────────────────────────────
    if (!_isPlaceholder(_appliedLeadStage)) {
      final stage = _appliedLeadStage!.trim().toUpperCase();
      result = result.where((l) => l.leadStage.toUpperCase() == stage).toList();
    }

    // ── Lead Source — stored UPPERCASE in Firestore ───────────────────────────
    if (!_isPlaceholder(_appliedSource)) {
      final source = _appliedSource!.trim().toUpperCase();
      result = result
          .where((l) => l.leadSource.toUpperCase() == source)
          .toList();
    }

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
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        final categoryItems = state.categories
                            .map((e) => e.name)
                            .toList();
                        final sourceItems = state.sources
                            .map((e) => e.name)
                            .toList();
                        final stageItems = state.stages
                            .map((e) => e.name)
                            .toList();
                        return Padding(
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
                                       message: 'Lead Category is the type\n of product, service, or solution \na potential customer is \ninterested in, helping businesses\n identify and classify inquiries \nfor better follow-up.',
                                      items: categoryItems,
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
                                       message: 'Lead Status lets you track \nthe stage of a lead, and you can \nadd new statuses as needed to match \nyour sales process.',
                                     items: stageItems,
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
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Source",
                                      hint: 'select source',
                                      showHelp: true,
                                       message:'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
                                     items: sourceItems,
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
                                  Expanded(child: SizedBox()),
                                  SizedBox(width: 2.w),
                                  Expanded(child: SizedBox()),
                                  SizedBox(width: 2.w),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => _applyFilters(),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: SizedBox(
                                        width: 7.w,
                                        height: 4.5.h,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: const Color(0xff1BAA90),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                  ),
                                  SizedBox(width: 1.w),
                                  if (selectedCategory != null ||
                                      selectedSource != null ||
                                      selectedStatus != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedSource = null;
                                          selectedStatus = null;
                                          _resetPage();
                                        });
                                      },
                                      child: Container(
                                        width: 7.w,
                                        height: 4.5.h,
                                        padding: EdgeInsets.all(1.h),
                                        margin: EdgeInsets.only(top: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.orange,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Reset Filters',
                                          style: AppTextStyle.small(
                                            size: 10.sp,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                                                'dd-MM-yyyy',
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
                                    : () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please select atleast one lead to delete.',
                                                style: AppTextStyle.medium(
                                                  color: AppColors.white,
                                                  weight: FontWeight.w400,
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppColors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          ),
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
                                    : () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please select atleast one lead to assign staff.',
                                                style: AppTextStyle.medium(
                                                  color: AppColors.white,
                                                  weight: FontWeight.w400,
                                                ),
                                              ), 
                                              backgroundColor:
                                                  AppColors.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          ),
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
                    width: 34.w,
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedLeads.length} lead(s) selected",
                          style: AppTextStyle.medium(
                            color: AppColors.black,
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
                    // onClose: () => Navigator.pop(dialogContext),
                    onSubmit: () async {
                      if (selectedStaffId == null || selectedStaffName == null)
                        return;

Navigator.pop(dialogContext);
                      for (final lead in selectedLeads) {
                        await context.read<AddLeadCubit>().assignStaff(
                          leadId: lead.id!,
                          staffId: selectedStaffId!,
                          staffName: selectedStaffName!,
                        );
                      }

                      Navigator.pop(dialogContext);
                      setState(() {
                        _selectedIndices = [];
                        _tableKey++;
                      });
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
        backgroundColor: Colors.white,
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
