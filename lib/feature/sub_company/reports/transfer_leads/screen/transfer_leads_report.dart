// import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:Odit_CRM/core/theme/app_colors.dart';
// import 'package:Odit_CRM/core/theme/app_text_style.dart';
// import 'package:Odit_CRM/core/utils/dropdown.dart';
// import 'package:Odit_CRM/core/utils/footer.dart';
// import 'package:Odit_CRM/core/utils/input_date.dart';
// import 'package:Odit_CRM/core/utils/page_button.dart';
// import 'package:Odit_CRM/core/utils/show_entries.dart';
// import 'package:Odit_CRM/core/utils/staff_top_bar.dart';
// import 'package:Odit_CRM/core/utils/table.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
// import 'package:sizer/sizer.dart';

// class TransferLeadsReport extends StatefulWidget {
//   final String currentUserId;
//   final String currentUserRole;
//   final String currentUserName;
//   const TransferLeadsReport({
//     super.key,
//     required this.currentUserId,
//     required this.currentUserRole,
//     required this.currentUserName,
//   });

//   @override
//   State<TransferLeadsReport> createState() => _TransferLeadsReportState();
// }

// class _TransferLeadsReportState extends State<TransferLeadsReport> {
//   final TextEditingController _fromDateController = TextEditingController();
//   final TextEditingController _toDateController = TextEditingController();

//   String? selectedStatus;
//   String? selectedCategory;
//   String? selectedfromstaff;
//   String? selectedtostaff;

//  List<String> selectedCategories = [];
//   List<String> selectedStatuses = [];
//   List<String> selectedfromstaffs = [];
//   List<String> selectedtostaffs = [];

//   String _searchQuery = '';
//   String _selectedEntries = '10';



//   List<int> _selectedIndices = [];
//   int _tableKey = 0;
//   int _currentPage = 1;

//   // Static variables to preserve filter state across screen navigation
//   static bool _hasSavedState = false;
//   static String? _staticFromDate;
//   static String? _staticToDate;
//   static String? _staticStatus;
//   static String? _staticCategory;
//   static String? _staticFromStaff;
//   static String? _staticToStaff;
//   static String _staticSearchQuery = '';
//   static String _staticSelectedEntries = '10';
//   static int _staticCurrentPage = 1;

//   // Static variables for applied (active) filter state
//   static String? _staticAppliedCategory;
//   static String? _staticAppliedLeadStatus;
//   static String? _staticAppliedFromStaff;
//   static String? _staticAppliedToStaff;
//   static DateTime? _staticAppliedFromDate;
//   static DateTime? _staticAppliedToDate;

//   List<TransferDetails> _getTransfersForRole(List<AddLeadModel> leads) {
//     final allTransfers = leads
//         .where((l) => l.transferLeads != null && l.transferLeads!.isNotEmpty)
//         .expand((l) => l.transferLeads!)
//         .where(
//           (t) =>
//               t.fromStaff.trim().toLowerCase() !=
//               t.toStaff.trim().toLowerCase(),
//         )
//         .toList();

//     if (widget.currentUserRole.toLowerCase() == 'admin') {
//       // Admin sees all transfers
//       return allTransfers;
//     } else {
//       // Staff sees only transfers they were involved in
//       return allTransfers
//           .where(
//             (t) =>
//                 t.fromStaffId == widget.currentUserId ||
//                 t.toStaffId == widget.currentUserId,
//           )
//           .toList();
//     }
//   }

//   @override
//   void dispose() {
//     // Save current filter state to static variables before widget disposal
//     _staticFromDate = _fromDateController.text;
//     _staticToDate = _toDateController.text;
//     _staticStatus = selectedStatus;
//     _staticCategory = selectedCategory;
//     _staticFromStaff = selectedfromstaff;
//     _staticToStaff = selectedtostaff;

//     _staticSearchQuery = _searchQuery;
//     _staticSelectedEntries = _selectedEntries;
//     _staticCurrentPage = _currentPage;

//     _staticAppliedCategory = _appliedCategory;
//     _staticAppliedLeadStatus = _appliedLeadStatus;
//     _staticAppliedFromStaff = _appliedfromstaff;
//     _staticAppliedToStaff = _appliedtostaff;
//     _staticAppliedFromDate = _appliedFromDate;
//     _staticAppliedToDate = _appliedToDate;

//     _hasSavedState = true;

//     _fromDateController.dispose();
//     _toDateController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     final cubit = context.read<AddLeadCubit>();
//     cubit.initialize();
//     cubit.fetchLeads();
//     cubit.fetchStaff();

//     if (_hasSavedState) {
//       // Restore filter state from static variables
//       _fromDateController.text = _staticFromDate ?? '';
//       _toDateController.text = _staticToDate ?? '';
//       selectedStatus = _staticStatus;
//       selectedCategory = _staticCategory;
//       selectedfromstaff = _staticFromStaff;
//       selectedtostaff = _staticToStaff;

//       _searchQuery = _staticSearchQuery;
//       _selectedEntries = _staticSelectedEntries;
//       _currentPage = _staticCurrentPage;

//       _appliedCategory = _staticAppliedCategory;
//       _appliedLeadStatus = _staticAppliedLeadStatus;
//       _appliedfromstaff = _staticAppliedFromStaff;
//       _appliedtostaff = _staticAppliedToStaff;
//       _appliedFromDate = _staticAppliedFromDate;
//       _appliedToDate = _staticAppliedToDate;
//     } else {
//       _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AddLeadCubit>().fetchLeads(); // ← only once
//       if (!_hasSavedState) {
//         _applyFilters();
//       }
//     });
//   }

//   bool _hasActiveFilters() {
//     return selectedCategory != null ||
//         selectedStatus != null ||
//         selectedfromstaff != null ||
//         selectedtostaff != null ||
//         _fromDateController.text.isNotEmpty ||
//         _toDateController.text.isNotEmpty;
//   }

//   void _clearFilters() {
//     setState(() {
//       selectedCategory = null;
//       selectedStatus = null;
//       selectedfromstaff = null;
//       selectedtostaff = null;
//       _fromDateController.clear();
//       _toDateController.clear();

//       _appliedCategory = null;
//       _appliedLeadStatus = null;
//       _appliedfromstaff = null;
//       _appliedtostaff = null;
//       _appliedFromDate = null;
//       _appliedToDate = null;

//       _hasSavedState = false;

//       _resetPage();
//     });
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   context.read<AddLeadCubit>().fetchLeads();
//   // }

//   // ── Snapshot fields (add alongside your existing selected* fields) ──────────
//   String? _appliedCategory;
//   String? _appliedLeadStatus;
//   String? _appliedfromstaff;
//   String? _appliedtostaff;
//   DateTime? _appliedFromDate;
//   DateTime? _appliedToDate;

//   // ── Called ONLY when "View" is tapped ───────────────────────────────────────
//   void _applyFilters() {
//     setState(() {
//       _appliedCategory = selectedCategory;
//       _appliedLeadStatus = selectedStatus;
//       _appliedfromstaff = selectedfromstaff;
//       _appliedtostaff = selectedtostaff;
//       _appliedFromDate = _parseDate(_fromDateController.text);
//       _appliedToDate = _parseDate(_toDateController.text);

//       _resetPage();
//     });
//   }

//   DateTime? _parseDate(String text) {
//     try {
//       return DateFormat('dd-MM-yyyy').parse(text);
//     } catch (_) {
//       return null;
//     }
//   }

//   // ── Skip placeholder "Select …" values ──────────────────────────────────────
//   bool _isPlaceholder(String? val) =>
//       val == null ||
//       val.trim().isEmpty ||
//       val.toLowerCase().startsWith('select');

//   List<TransferDetails> _filteredLeads(List<TransferDetails> transfers) {
//     List<TransferDetails> result = transfers;

//     // ── Date range ────────────────────────────────────────────────────────────
//     if (_appliedFromDate != null) {
//       final from = DateTime(
//         _appliedFromDate!.year,
//         _appliedFromDate!.month,
//         _appliedFromDate!.day,
//       );
//       result = result
//           .where(
//             (t) => t.transferTime != null && !t.transferTime!.isBefore(from),
//           )
//           .toList();
//     }
//     if (_appliedToDate != null) {
//       final to = DateTime(
//         _appliedToDate!.year,
//         _appliedToDate!.month,
//         _appliedToDate!.day,
//         23,
//         59,
//         59,
//       );
//       result = result
//           .where((t) => t.transferTime != null && !t.transferTime!.isAfter(to))
//           .toList();
//     }

//     // ── Lead Category ─────────────────────────────────────────────────────────
//     if (!_isPlaceholder(_appliedCategory)) {
//       final cat = _appliedCategory!.trim().toUpperCase();
//       result = result
//           .where((t) => t.leadCategory.toUpperCase() == cat)
//           .toList();
//     }

//     // ── Lead Status ─────────────────────────────────────────────────────────
//     if (!_isPlaceholder(_appliedLeadStatus)) {
//       final status = _appliedLeadStatus!.trim().toUpperCase();
//       result = result
//           .where((t) => t.leadStage.toUpperCase() == status)
//           .toList();
//     }

//     // ── From Staff ────────────────────────────────────────────────────────────
//     if (!_isPlaceholder(_appliedfromstaff)) {
//       result = result
//           .where(
//             (t) =>
//                 t.fromStaff.toLowerCase() ==
//                 _appliedfromstaff!.trim().toLowerCase(),
//           )
//           .toList();
//     }

//     // ── To Staff ──────────────────────────────────────────────────────────────
//     if (!_isPlaceholder(_appliedtostaff)) {
//       result = result
//           .where(
//             (t) =>
//                 t.toStaff.toLowerCase() ==
//                 _appliedtostaff!.trim().toLowerCase(),
//           )
//           .toList();
//     }

//     // ── Search ────────────────────────────────────────────────────────────────
//     final q = _searchQuery.trim().toLowerCase();
//     if (q.isNotEmpty) {
//       result = result
//           .where(
//             (t) =>
//                 t.leadName.toLowerCase().contains(q) ||
//                 t.contactNumber.toLowerCase().contains(q),
//           )
//           .toList();
//     }

//     return result;
//   }

//   List<TransferDetails> _pagedLeads(List<TransferDetails> allFiltered) {
//     final limit = int.tryParse(_selectedEntries) ?? 10;
//     final start = (_currentPage - 1) * limit;
//     final end = (start + limit).clamp(0, allFiltered.length);
//     if (start >= allFiltered.length) return [];
//     return allFiltered.sublist(start, end);
//   }

//   int _totalPages(int totalCount) {
//     final limit = int.tryParse(_selectedEntries) ?? 10;
//     if (totalCount == 0) return 1;
//     return (totalCount / limit).ceil();
//   }

//   void _goToPage(int page, int total) {
//     final tp = _totalPages(total);
//     if (page < 1 || page > tp) return;
//     setState(() {
//       _currentPage = page;
//       _selectedIndices = [];
//       _tableKey++;
//     });
//   }

//   void _resetPage() {
//     _currentPage = 1;
//     _selectedIndices = [];
//     _tableKey++;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             StaffTopBar(
//               title: 'Transferred Leads Report',
//               parent: 'Reports',
//               current: 'Transferred Leads',
//             ),
//             Padding(
//               padding: EdgeInsets.all(2.w),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 2.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: AppColors.divider),
//                 ),
//                 child: BlocBuilder<AddLeadCubit, AddLeadState>(
//                   builder: (context, state) {
//                     final categoryItems = state.categories
//                         .map((e) => e.name)
//                         .toList();
//                     final stageItems = state.stages.map((e) => e.name).toList();
//                     final staffItems = state.staffList
//                         .map((e) => e.name)
//                         .toList();
//                     return Column(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 2.w),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: InputDate(
//                                   label: 'From Date',
//                                   fromController: _fromDateController,
//                                   toController: _toDateController,
//                                   isFrom: true,
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),
//                               Expanded(
//                                 child: InputDate(
//                                   label: 'To Date',
//                                   fromController: _fromDateController,
//                                   toController: _toDateController,
//                                   isFrom: false,
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),
//                               Expanded(
//                                 child: MultiSelectDropdown(
//                                   hint: 'select category',
//                                   items: categoryItems,
//                                   selectedValues: selectedCategories,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       selectedCategories = val;
//                                       _resetPage();
//                                     });
//                                   },
//                                   label: "Lead Category",
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),
//                               Expanded(
//                                 child: MultiSelectDropdown(
//                                   label: "Status",
//                                   hint: ' select status',
//                                   showHelp: false,
//                                   items: stageItems,
//                                   selectedValues: selectedStatuses,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       selectedStatuses = val;
//                                       _resetPage();
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 1.h),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 2.w),
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 width: 17.45.w,
//                                 child: MultiSelectDropdown(
//                                   label: "From Staff",
//                                   hint: "select staff",
//                                   items: staffItems,
//                                   selectedValues: selectedfromstaffs,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       selectedfromstaffs = val;
//                                       _resetPage();
//                                     });
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),
//                               SizedBox(
//                                 width: 17.45.w,
//                                 child: MultiSelectDropdown(
//                                   label: "To Staff",
//                                   hint: "select staff",
//                                   items: staffItems,
//                                   selectedValues: selectedtostaffs,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       selectedtostaffs = val;
//                                       _resetPage();
//                                     });
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),

//                               /// 🔥 VIEW BUTTON (perfect aligned)
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: _applyFilters,
//                                     child: Padding(
//                                       padding: EdgeInsets.only(top: 2.h),
//                                       child: SizedBox(
//                                         width: 7.w,
//                                         height: 4.5.h,
//                                         child: DecoratedBox(
//                                           decoration: BoxDecoration(
//                                             color: const Color(0xff1BAA90),
//                                             borderRadius: BorderRadius.circular(
//                                               6,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               "View",
//                                               style: AppTextStyle.small(
//                                                 size: 10.sp,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 1.w),
//                                   if (_hasActiveFilters())
//                                     InkWell(
//                                       onTap: _clearFilters,
//                                       child: Container(
//                                         // width: 7.w,
//                                         height: 4.5.h,
//                                         padding: EdgeInsets.all(1.h),
//                                         margin: EdgeInsets.only(top: 2.h),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.orange,
//                                           borderRadius: BorderRadius.circular(
//                                             6,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           'Reset Filters',
//                                           style: AppTextStyle.small(
//                                             size: 10.sp,
//                                             color: Colors.white,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(height: 1.w),
//                         Divider(color: AppColors.divider),
//                         ShowEntries(
//                           initialSearch: _searchQuery,
//                           initialEntries: _selectedEntries,
//                           onSearchChanged: (v) => setState(() {
//                             _searchQuery = v;
//                             _resetPage();
//                           }),
//                           onEntriesChanged: (v) => setState(() {
//                             _selectedEntries = v;
//                             _resetPage();
//                           }),
//                         ),
//                         BlocBuilder<AddLeadCubit, AddLeadState>(
//                           builder: (context, state) {
//                             // Loading
//                             if (state.listStatus == LeadListStatus.loading) {
//                               return Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 6.h),
//                                 child: const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               );
//                             }
//                             // Error
//                             if (state.listStatus == LeadListStatus.failure) {
//                               return Padding(
//                                 padding: EdgeInsets.all(4.w),
//                                 child: Text(
//                                   state.listError ?? 'Something went wrong.',
//                                   style: AppTextStyle.medium(color: Colors.red),
//                                 ),
//                               );
//                             }
//                             final List<AddLeadModel> rawList =
//                                 state.listStatus == LeadListStatus.loaded
//                                 ? state.leads.toList()
//                                 : [];
//                             // final List<TransferDetails> allTransfers =
//                             //     rawList
//                             //         .where(
//                             //           (l) =>
//                             //               l.transferLeads != null &&
//                             //               l.transferLeads!.isNotEmpty,
//                             //         )
//                             //         .expand((l) => l.transferLeads!)
//                             //         .where(
//                             //           (t) =>
//                             //               t.fromStaff.trim().toLowerCase() !=
//                             //               t.toStaff.trim().toLowerCase(),
//                             //         )
//                             //         .toList()
//                             //       ..sort((a, b) {
//                             //         // nulls go to the end
//                             //         if (a.transferTime == null &&
//                             //             b.transferTime == null)
//                             //           return 0;
//                             //         if (a.transferTime == null) return 1;
//                             //         if (b.transferTime == null) return -1;
//                             //         // latest first
//                             //         return b.transferTime!.compareTo(
//                             //           a.transferTime!,
//                             //         );
//                             //       });
//                             final List<TransferDetails> allTransfers =
//                                 _getTransfersForRole(rawList)..sort((a, b) {
//                                   if (a.transferTime == null &&
//                                       b.transferTime == null)
//                                     return 0;
//                                   if (a.transferTime == null) return 1;
//                                   if (b.transferTime == null) return -1;
//                                   return b.transferTime!.compareTo(
//                                     a.transferTime!,
//                                   );
//                                 });

//                             final allFiltered = _filteredLeads(allTransfers);
//                             final totalCount = allFiltered.length;
//                             final totalPages = _totalPages(totalCount);
//                             final limit = int.tryParse(_selectedEntries) ?? 10;
//                             if (_currentPage > totalPages) {
//                               WidgetsBinding.instance.addPostFrameCallback((_) {
//                                 setState(() => _currentPage = totalPages);
//                               });
//                             }
//                             final pagedList = _pagedLeads(allFiltered);

//                             // "Showing X to Y of Z entries"
//                             final showFrom = totalCount == 0
//                                 ? 0
//                                 : (_currentPage - 1) * limit + 1;
//                             final showTo = (showFrom + pagedList.length - 1)
//                                 .clamp(0, totalCount);

//                             // Loaded with data
//                             if (state.listStatus == LeadListStatus.loaded) {
//                               return Column(
//                                 children: [
//                                   SizedBox(
//                                     child: CustomTable(
//                                       columns: [
//                                         TableColumn(title: "Sl No.", flex: 1),
//                                         TableColumn(title: "Name", flex: 4),
//                                         TableColumn(
//                                           title: "Contact Number",
//                                           flex: 4,
//                                         ),
//                                         TableColumn(
//                                           title: "From Staff",
//                                           flex: 4,
//                                         ),
//                                         TableColumn(title: "To Staff", flex: 4),
//                                         TableColumn(
//                                           title: "Lead Category",
//                                           flex: 4,
//                                         ),
//                                         TableColumn(
//                                           title: "Transfer Date",
//                                           flex: 4,
//                                         ),
//                                       ],
//                                       rows: pagedList.asMap().entries.map((
//                                         entry,
//                                       ) {
//                                         final index = entry.key;
//                                         final transfer = entry.value;
//                                         final serial =
//                                             (_currentPage - 1) * limit +
//                                             index +
//                                             1;

//                                         return [
//                                           Text(
//                                             serial.toString(),
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.leadName,
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.contactNumber.toString(),
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.fromStaff,
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.toStaff,
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.leadCategory,
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                           Text(
//                                             transfer.transferTime != null
//                                                 ? DateFormat(
//                                                     'dd-MM-yyyy hh:mm a',
//                                                   ).format(
//                                                     transfer.transferTime!,
//                                                   )
//                                                 : '-',
//                                             style: AppTextStyle.medium(),
//                                           ),
//                                         ];
//                                       }).toList(),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 2.w,
//                                       vertical: 1.5.h,
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "Showing $showFrom to $showTo of $totalCount entries",
//                                           style: AppTextStyle.medium(
//                                             weight: FontWeight.w400,
//                                           ),
//                                         ),
//                                         Row(
//                                           children: [
//                                             PageButton(
//                                               label: 'Previous',
//                                               enabled: _currentPage > 1,
//                                               isLeft: true,
//                                               onTap: () => _goToPage(
//                                                 _currentPage - 1,
//                                                 totalCount,
//                                               ),
//                                             ),
//                                             ..._buildPageNumbers(
//                                               totalPages,
//                                               totalCount,
//                                             ),
//                                             PageButton(
//                                               label: 'Next',
//                                               enabled:
//                                                   _currentPage < totalPages,
//                                               isRight: true,
//                                               onTap: () => _goToPage(
//                                                 _currentPage + 1,
//                                                 totalCount,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                             return SizedBox.shrink();
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Page number chips ───────────────────────
//   List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
//     if (totalPages <= 1) return [];

//     return [
//       GestureDetector(
//         onTap: () {}, // already on this page
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 0.2.w),
//           padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.h),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             border: Border.all(color: AppColors.lightGrey),
//           ),
//           child: Text(
//             '$_currentPage',
//             style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
//           ),
//         ),
//       ),
//     ];
//   }
// }


import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/footer.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/staff_top_bar.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class TransferLeadsReport extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  final String currentUserName;
  const TransferLeadsReport({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
    required this.currentUserName,
  });

  @override
  State<TransferLeadsReport> createState() => _TransferLeadsReportState();
}

class _TransferLeadsReportState extends State<TransferLeadsReport> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // ── Multi-select filter selections (temporary, pending "View" tap) ────────
  List<String> selectedCategories = [];
  List<String> selectedStatuses = [];
  List<String> selectedfromstaffs = [];
  List<String> selectedtostaffs = [];

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  // Static variables to preserve filter state across screen navigation
  static bool _hasSavedState = false;
  static String? _staticFromDate;
  static String? _staticToDate;
  static List<String> _staticCategories = [];
  static List<String> _staticStatuses = [];
  static List<String> _staticFromStaffs = [];
  static List<String> _staticToStaffs = [];
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedLeadStatuses = [];
  static List<String> _staticAppliedFromStaffs = [];
  static List<String> _staticAppliedToStaffs = [];
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;

  // ── Snapshot fields (applied only when "View" is tapped) ────────────────────
  List<String> _appliedCategories = [];
  List<String> _appliedLeadStatuses = [];
  List<String> _appliedfromstaffs = [];
  List<String> _appliedtostaffs = [];
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  List<TransferDetails> _getTransfersForRole(List<AddLeadModel> leads) {
    final allTransfers = leads
        .where((l) => l.transferLeads != null && l.transferLeads!.isNotEmpty)
        .expand((l) => l.transferLeads!)
        .where(
          (t) =>
              t.fromStaff.trim().toLowerCase() !=
              t.toStaff.trim().toLowerCase(),
        )
        .toList();

    if (widget.currentUserRole.toLowerCase() == 'admin') {
      // Admin sees all transfers
      return allTransfers;
    } else {
      // Staff sees only transfers they were involved in
      return allTransfers
          .where(
            (t) =>
                t.fromStaffId == widget.currentUserId ||
                t.toStaffId == widget.currentUserId,
          )
          .toList();
    }
  }

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = _fromDateController.text;
    _staticToDate = _toDateController.text;
    _staticCategories = List<String>.from(selectedCategories);
    _staticStatuses = List<String>.from(selectedStatuses);
    _staticFromStaffs = List<String>.from(selectedfromstaffs);
    _staticToStaffs = List<String>.from(selectedtostaffs);

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _staticAppliedCategories = List<String>.from(_appliedCategories);
    _staticAppliedLeadStatuses = List<String>.from(_appliedLeadStatuses);
    _staticAppliedFromStaffs = List<String>.from(_appliedfromstaffs);
    _staticAppliedToStaffs = List<String>.from(_appliedtostaffs);
    _staticAppliedFromDate = _appliedFromDate;
    _staticAppliedToDate = _appliedToDate;

    _hasSavedState = true;

    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddLeadCubit>();
    cubit.initialize();
    cubit.fetchLeads();
    cubit.fetchStaff();

    if (_hasSavedState) {
      // Restore filter state from static variables
      _fromDateController.text = _staticFromDate ?? '';
      _toDateController.text = _staticToDate ?? '';
      selectedCategories = List<String>.from(_staticCategories);
      selectedStatuses = List<String>.from(_staticStatuses);
      selectedfromstaffs = List<String>.from(_staticFromStaffs);
      selectedtostaffs = List<String>.from(_staticToStaffs);

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;

      _appliedCategories = List<String>.from(_staticAppliedCategories);
      _appliedLeadStatuses = List<String>.from(_staticAppliedLeadStatuses);
      _appliedfromstaffs = List<String>.from(_staticAppliedFromStaffs);
      _appliedtostaffs = List<String>.from(_staticAppliedToStaffs);
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;
    } else {
      _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddLeadCubit>().fetchLeads(); // ← only once
      if (!_hasSavedState) {
        _applyFilters();
      }
    });
  }

  bool _hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        selectedStatuses.isNotEmpty ||
        selectedfromstaffs.isNotEmpty ||
        selectedtostaffs.isNotEmpty ||
        _fromDateController.text.isNotEmpty ||
        _toDateController.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedStatuses = [];
      selectedfromstaffs = [];
      selectedtostaffs = [];
      _fromDateController.clear();
      _toDateController.clear();

      _appliedCategories = [];
      _appliedLeadStatuses = [];
      _appliedfromstaffs = [];
      _appliedtostaffs = [];
      _appliedFromDate = null;
      _appliedToDate = null;

      _hasSavedState = false;

      _resetPage();
    });
  }

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategories = List<String>.from(selectedCategories);
      _appliedLeadStatuses = List<String>.from(selectedStatuses);
      _appliedfromstaffs = List<String>.from(selectedfromstaffs);
      _appliedtostaffs = List<String>.from(selectedtostaffs);
      _appliedFromDate = _fromDateController.text.trim().isEmpty
          ? null
          : _parseDate(_fromDateController.text);
      _appliedToDate = _toDateController.text.trim().isEmpty
          ? null
          : _parseDate(_toDateController.text);

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

  List<TransferDetails> _filteredLeads(List<TransferDetails> transfers) {
    List<TransferDetails> result = transfers;

    // ── Date range ────────────────────────────────────────────────────────────
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result
          .where(
            (t) => t.transferTime != null && !t.transferTime!.isBefore(from),
          )
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
          .where((t) => t.transferTime != null && !t.transferTime!.isAfter(to))
          .toList();
    }

    // ── Lead Category — match ANY selected ───────────────────────────────────
    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((t) => cats.contains(t.leadCategory.toUpperCase()))
          .toList();
    }

    // ── Lead Status — match ANY selected ─────────────────────────────────────
    if (_appliedLeadStatuses.isNotEmpty) {
      final statuses = _appliedLeadStatuses
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((t) => statuses.contains(t.leadStage.toUpperCase()))
          .toList();
    }

    // ── From Staff — match ANY selected ──────────────────────────────────────
    if (_appliedfromstaffs.isNotEmpty) {
      final fromSet = _appliedfromstaffs
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((t) => fromSet.contains(t.fromStaff.toLowerCase()))
          .toList();
    }

    // ── To Staff — match ANY selected ────────────────────────────────────────
    if (_appliedtostaffs.isNotEmpty) {
      final toSet = _appliedtostaffs
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((t) => toSet.contains(t.toStaff.toLowerCase()))
          .toList();
    }

    // ── Search ────────────────────────────────────────────────────────────────
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.leadName.toLowerCase().contains(q) ||
                t.contactNumber.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  List<TransferDetails> _pagedLeads(List<TransferDetails> allFiltered) {
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
            StaffTopBar(
              title: 'Transferred Leads Report',
              parent: 'Reports',
              current: 'Transferred Leads',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: BlocBuilder<AddLeadCubit, AddLeadState>(
                  builder: (context, state) {
                    final categoryItems = state.categories
                        .map((e) => e.name)
                        .toList();
                    final stageItems = state.stages.map((e) => e.name).toList();
                    final staffItems = state.staffList
                        .map((e) => e.name)
                        .toList();
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: InputDate(
                                  label: 'From Date',
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: true,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: 'To Date',
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: false,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: MultiSelectDropdown(
                                  hint: 'select category',
                                  items: categoryItems,
                                  selectedValues: selectedCategories,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCategories = val;
                                      _resetPage();
                                    });
                                  },
                                  label: "Lead Category",
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: MultiSelectDropdown(
                                  label: "Status",
                                  hint: ' select status',
                                  showHelp: false,
                                  items: stageItems,
                                  selectedValues: selectedStatuses,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStatuses = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 17.45.w,
                                child: MultiSelectDropdown(
                                  label: "From Staff",
                                  hint: "select staff",
                                  items: staffItems,
                                  selectedValues: selectedfromstaffs,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedfromstaffs = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.45.w,
                                child: MultiSelectDropdown(
                                  label: "To Staff",
                                  hint: "select staff",
                                  items: staffItems,
                                  selectedValues: selectedtostaffs,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedtostaffs = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),

                              /// 🔥 VIEW BUTTON (perfect aligned)
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _applyFilters,
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
                                  if (_hasActiveFilters())
                                    InkWell(
                                      onTap: _clearFilters,
                                      child: Container(
                                        // width: 7.w,
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
                        ),

                        SizedBox(height: 1.w),
                        Divider(color: AppColors.divider),
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
                                ? state.leads.toList()
                                : [];

                            final List<TransferDetails> allTransfers =
                                _getTransfersForRole(rawList)..sort((a, b) {
                                  if (a.transferTime == null &&
                                      b.transferTime == null)
                                    return 0;
                                  if (a.transferTime == null) return 1;
                                  if (b.transferTime == null) return -1;
                                  return b.transferTime!.compareTo(
                                    a.transferTime!,
                                  );
                                });

                            final allFiltered = _filteredLeads(allTransfers);
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
                            final showTo = (showFrom + pagedList.length - 1)
                                .clamp(0, totalCount);

                            // Loaded with data
                            if (state.listStatus == LeadListStatus.loaded) {
                              return Column(
                                children: [
                                  SizedBox(
                                    child: CustomTable(
                                      key: ValueKey(_tableKey),
                                      columns: [
                                        TableColumn(title: "Sl No.", flex: 1),
                                        TableColumn(title: "Name", flex: 4),
                                        TableColumn(
                                          title: "Contact Number",
                                          flex: 4,
                                        ),
                                        TableColumn(
                                          title: "From Staff",
                                          flex: 4,
                                        ),
                                        TableColumn(title: "To Staff", flex: 4),
                                        TableColumn(
                                          title: "Lead Category",
                                          flex: 4,
                                        ),
                                        TableColumn(
                                          title: "Transfer Date",
                                          flex: 4,
                                        ),
                                      ],
                                      rows: pagedList.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final transfer = entry.value;
                                        final serial =
                                            (_currentPage - 1) * limit +
                                            index +
                                            1;

                                        return [
                                          Text(
                                            serial.toString(),
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.leadName,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.contactNumber.toString(),
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.fromStaff,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.toStaff,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.leadCategory,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.transferTime != null
                                                ? DateFormat(
                                                    'dd-MM-yyyy hh:mm a',
                                                  ).format(
                                                    transfer.transferTime!,
                                                  )
                                                : '-',
                                            style: AppTextStyle.medium(),
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
                                              enabled:
                                                  _currentPage < totalPages,
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
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page number chips ───────────────────────
  List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
    if (totalPages <= 1) return [];

    return [
      GestureDetector(
        onTap: () {}, // already on this page
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.2.w),
          padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Text(
            '$_currentPage',
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }
}