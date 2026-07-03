import 'dart:typed_data';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/file_picker_field.dart';
import 'package:Odit_CRM/core/utils/indian_location_service.dart';
import 'package:Odit_CRM/core/utils/popup_msg.dart';
import 'package:Odit_CRM/core/utils/tool_tips.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/core/utils/dropdown_with_add.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/widget/field_position_dialog.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/widget/sample_file.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class ImportLeads extends StatefulWidget {
  const ImportLeads({super.key});

  @override
  State<ImportLeads> createState() => _ImportLeadsState();
}

class _ImportLeadsState extends State<ImportLeads> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dialogNameCtrl = TextEditingController();

  Uint8List? _pickedCsvBytes;

  final List<String> _priorities = ['High', 'Low', 'Negative', 'Normal'];

  Map<String, List<String>> _stateDistrictMap = {};

  @override
  void initState() {
    super.initState();
    final s = context.read<ImportLeadsCubit>().state;
    if (!s.isReady) {
      context.read<ImportLeadsCubit>().initialize();
    }
    _loadLocations();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _sourceController.dispose();
    _costController.dispose();
    _dialogNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final map = await IndiaLocationService.loadStateDistricts();
    if (mounted) setState(() => _stateDistrictMap = map);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImportLeadsCubit, ImportLeadsState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                TopBreadcrumbBar(
                  subTitle: 'Import Leads',
                  title: 'Leads Management',
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    children: [
                      _tabs(state),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            _titleBar(context),
                            Divider(color: AppColors.divider),
                            SizedBox(height: 2.h),
                            _description(),
                            SizedBox(height: 3.h),
                            _formBody(context, state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LISTENER
  // ─────────────────────────────────────────────────────────────────────────

  void _onStateChanged(BuildContext context, ImportLeadsState state) {
    if (state.status == ImportLeadsStatus.success &&
        state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.successMessage!),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _pickedCsvBytes = null);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(selectedIndex: 2)),
      );
    }

    if (state.status == ImportLeadsStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI SECTIONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Import Leads',
            style: AppTextStyle.medium(
              size: 13.6.sp,
              color: AppColors.black.withOpacity(0.77),
              weight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () => downloadSampleLeadExcel(),
                child: _topButton(
                  'Sample File',
                  Colors.orange.shade50,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 1.w),
              InkWell(
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => BlocProvider.value(
                    value: context.read<ImportLeadsCubit>(),
                    child: const FieldPositionDialog(),
                  ),
                ),
                child: _topButton('Field Settings', Colors.blue, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _description() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        'There are two methods available for importing leads. The first option '
        'is to refer to the provided sample CSV format and use it directly. '
        'Alternatively, you can modify the field settings according to the '
        'recommended format before importing the leads.',
        style: AppTextStyle.medium(size: 11.sp, weight: FontWeight.w400),
      ),
    );
  }

  Widget _formBody(BuildContext context, ImportLeadsState state) {
    final cubit = context.read<ImportLeadsCubit>();

    final categoryNames = state.categories
        .map((c) => c.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final sourceNames = state.sources
        .map((s) => s.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final stagesNames = state.stages
        .map((s) => s.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final staffNames = state.staffList
        .map((s) => s.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 40.w, bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.selectedTab == 0) ...[
            _countryCodeField(cubit),
            SizedBox(height: 2.h),
          ],

          Dropdown(
            items: stagesNames,
            selectedValue: state.selectedLeadStage,
            onChanged: cubit.selectLeadStage,
            label: 'Lead Stage',
            showClear: false,
            hint: 'Select Lead Stage',
          ),
          SizedBox(height: 2.h),

          DropdownWithAdd(
            showHelp: true,
            message:
                'Lead Category is the type of \nproduct, service, or solution a \npotential customer is interested in, helping \nbusinesses identify and classify\n inquiries for better FOLLOWUP.',
            label: 'Lead Category',
            icon: Icons.layers_outlined,
            items: categoryNames,
            selectedValue: state.selectedCategory,
            onChanged: cubit.selectCategory,
            onTap: () => _showAddCategoryDialog(),
          ),
          SizedBox(height: 2.h),

          // state.isLoading
          //     ? _loadingDropdown('Staff')
          //     : Dropdown(
          //         label: 'Staff',
          //         hint: 'Select Staff',
          //         items: staffNames,
          //         showStar: true,
          //         selectedValue: state.assignedStaffName,
          //         onChanged: cubit.selectStaff,
          //       ),
          // SizedBox(height: 2.h),
          if (state.isAdmin) ...[
            state.isLoading
                ? _loadingDropdown('Staff')
                : Dropdown(
                    label: 'Staff',
                    hint: 'Select Staff',
                    items: staffNames,
                    showStar: true,
                    selectedValue: state.assignedStaffName.isNotEmpty
                        ? state.assignedStaffName
                        : state.selectedStaff,
                    onChanged: cubit.selectStaff,
                  ),
            SizedBox(height: 2.h),
          ],

          DropdownWithAdd(
            showHelp: true,
            message:
                'Lead Source refers to \nhow the potential customer discovered \nor engaged with the business, \nsuch as through marketing campaigns,\n social media, referrals, events,\n or website inquiries.',
            label: 'Lead Source',
            icon: Icons.layers_rounded,
            items: sourceNames,
            selectedValue: state.selectedSource,
            onChanged: cubit.selectSource,
            onTap: () => _showAddSourceDialog(),
          ),
          SizedBox(height: 2.h),

          Dropdown(
            items: _priorities,
            onChanged: cubit.selectPriority,
            label: 'Priority',
            hint: 'Select Priority',
            selectedValue: state.selectedPriority,
            showClear: false,
          ),
          SizedBox(height: 2.h),

          Dropdown(
            showIcon: true,
            label: 'State',
            hint: 'Select State',
            items: _stateDistrictMap.keys.toList(),
            selectedValue: state.selectedState,
            onChanged: cubit.selectState,
          ),
          SizedBox(height: 2.h),

          Dropdown(
            showIcon: true,
            label: 'District',
            hint: 'Select District',
            items: state.selectedState == null
                ? []
                : _stateDistrictMap[state.selectedState] ?? [],
            selectedValue: state.selectedDistrict,
            enabled: state.selectedState != null,
            onChanged: cubit.selectDistrict,
          ),
          SizedBox(height: 2.h),

          _label('CSV file '),
          FilePickerField(
            allowedExtensions: ['csv'],
            onFilePicked: (file) async {
              if (file != null && file.bytes != null) {
                final bytes = file.bytes!;
                setState(() => _pickedCsvBytes = bytes);
                cubit.setCsvBytes(bytes);
              }
            },
          ),
          Text(
            'Limit CSV file to 1000 rows.',
            style: AppTextStyle.medium(
              size: 10.sp,
              color: Colors.lightBlue.shade900,
            ),
          ),
          SizedBox(height: 3.h),

          _submitButton(context, state, cubit),
          SizedBox(height: 2.w),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOGS — fixed
  // ─────────────────────────────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    _dialogNameCtrl.clear();

    // ✅ Capture both cubits from the PARENT context before dialog opens.
    //    The dialog's builder context has no BlocProviders, so
    //    context.read<X>() inside the dialog would throw.
    final importCubit = context.read<ImportLeadsCubit>();
    final categoryCubit = context.read<LeadCategoryCubit>();

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

          // Step 1: write to Firestore via LeadCategoryCubit
          await categoryCubit.addCategory(name: name);

          // Step 2: ✅ re-fetch into ImportLeadsCubit so dropdown updates NOW
          await importCubit.refreshCategories();

          // ✅ Auto-select the newly added category
          importCubit.selectCategory(name);

          Navigator.pop(ctx);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Category "$name" added.'),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    _dialogNameCtrl.clear();

    // ✅ Capture both cubits from the PARENT context before dialog opens
    final importCubit = context.read<ImportLeadsCubit>();
    final sourceCubit = context.read<LeadSourceCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        width: 35.w,
        title: 'Add Lead Source',
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lead Source', style: AppTextStyle.medium(size: 11.sp)),
              SizedBox(height: 2.h),
              TextField(
                controller: _dialogNameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter Source',
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

          // Step 1: write to Firestore via LeadSourceCubit
          await sourceCubit.addSource(name: name);

          // Step 2: ✅ re-fetch into ImportLeadsCubit so dropdown updates NOW
          await importCubit.refreshSources();

          // ✅ Auto-select the newly added source
          importCubit.selectSource(name);

          Navigator.pop(ctx);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Source "$name" added.'),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SMALL WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _countryCodeField(ImportLeadsCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Country Code', style: AppTextStyle.medium()),
            Text(
              '*',
              style: AppTextStyle.medium(
                size: 11.sp,
                weight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 5.h,
          width: 45.w,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(3),
              color: AppColors.greyCard,
            ),
            child: Localizations.override(
              context: context,
              locale: const Locale('en'),
              child: CountryCodePicker(
                onChanged: (country) =>
                    cubit.setDialCode(country.dialCode ?? '+91'),
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
        ),
      ],
    );
  }

  Widget _submitButton(
    BuildContext context,
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) {
    final bool canSubmit = !state.isImporting && _pickedCsvBytes != null;

    return SizedBox(
      width: 10.w,
      height: 5.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? AppColors.green : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        // onPressed: canSubmit
        //     ? () => cubit.importLeads(csvBytes: _pickedCsvBytes!)
        //     : null,
        onPressed: canSubmit
            ? () => _confirmAndImport(context, state, cubit)
            : null,
        child: state.isImporting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Submit',
                style: AppTextStyle.medium(size: 10.sp, color: AppColors.white),
              ),
      ),
    );
  }

  Widget _loadingDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.medium()),
        SizedBox(height: 0.8.h),
        Container(
          height: 5.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(4),
            color: AppColors.greyCard,
          ),
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.orange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        children: [
          Text(text, style: AppTextStyle.medium()),
          Text(
            '*',
            style: AppTextStyle.medium(
              size: 11.sp,
              weight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
          ToolTipWidget(
            message:
                'Ensure that the file is uploaded\nonly in '
                'comma-separated\nvalues (csv) format',
          ),
        ],
      ),
    );
  }

  Widget _topButton(String text, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: AppTextStyle.medium(color: textColor)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _tabs(ImportLeadsState state) {
    return Row(
      children: [
        _tabItem('With Country Code', 0, state.selectedTab),
        SizedBox(width: 1.w),
        _tabItem('Without Country Code', 1, state.selectedTab),
      ],
    );
  }

  Widget _tabItem(String title, int index, int selectedTab) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => context.read<ImportLeadsCubit>().selectTab(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.medium(
              color: isSelected ? AppColors.primary : AppColors.grey,
              weight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.7.h),
          Container(
            height: 2,
            width: 10.w,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndImport(
    BuildContext context,
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) async {
    // ── Client-side validation: Admin must pick a staff member ───────────────
    if (state.isAdmin &&
        (state.selectedStaff == null || state.selectedStaff!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select a staff member before importing leads.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; // stop here — don't even open the loading dialog
    }

    // Show loading while checking duplicates
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final duplicateCount = await cubit.checkDuplicates(
      csvBytes: _pickedCsvBytes!,
    );

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (duplicateCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Duplicates Found',
                style: AppTextStyle.medium(
                  size: 13.sp,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your file contains $duplicateCount existing '
                'lead${duplicateCount == 1 ? '' : 's'} with phone '
                'numbers already in the system.',
                style: AppTextStyle.medium(size: 11.sp),
              ),
              SizedBox(height: 1.5.h),
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Duplicates will be skipped. Only unique leads will be imported.',
                        style: AppTextStyle.medium(
                          size: 10.sp,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Import Anyway',
                style: AppTextStyle.medium(size: 11.sp, color: AppColors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    cubit.importLeads(csvBytes: _pickedCsvBytes!);
  }
}
