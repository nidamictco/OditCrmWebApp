import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/screens/widget/calender.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/widget/custom_switch.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/widget/new_alert.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/calender.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/utils/indian_location_service.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/popup_msg.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/widget/field_position_dialog.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/widget/sample_file.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_category/cubit/lead_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_source/cubit/lead_source_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_stage/data/lead_tag_repo.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class ImportLeads extends StatefulWidget {
  const ImportLeads({super.key});

  @override
  State<ImportLeads> createState() => _ImportLeadsState();
}

class _ImportLeadsState extends State<ImportLeads> {
  final TextEditingController _dialogNameCtrl = TextEditingController();

  Uint8List? _pickedCsvBytes;
  String? _pickedFileName;

  final List<String> _priorities = ['High', 'Low', 'Negative', 'Normal'];

  Map<String, List<String>> _stateDistrictMap = {};

  List<LeadsModel> _stageTags = [];
  String? _selectedTag;
  StreamSubscription? _tagSubscription;
  String? _lastStageId;

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
    _tagSubscription?.cancel();
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
        final cubit = context.read<ImportLeadsCubit>();

        log(
          '[Screen] rebuild — selectedLeadStage="${state.selectedLeadStage}" '
          'nextFollowUpDate=${state.nextFollowUpDate}',
        );

        return Scaffold(
          backgroundColor: AppThemeColors.scaffoldBg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildTopHeaderBar(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x14000000),
                          offset: const Offset(0, 1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: CSV Upload Box & Action Buttons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCsvUploadBox(cubit),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => downloadSampleLeadExcel(),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Sample File',
                                      style: AppTextStyle.medium(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ImportLeadsCubit>(),
                                      child: const FieldPositionDialog(),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Field Settings',
                                      style: AppTextStyle.medium(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCountryCodeToggle(state, cubit),
                        const SizedBox(height: 24),

                        // Form Fields Grid (Max 4 per row, dynamic Stage Tag & Category SubCategory)
                        _buildFormGrid(context, state, cubit),

                        const SizedBox(height: 32),

                        // Bottom Right Actions: Clear All & Submit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _pickedCsvBytes = null;
                                  _pickedFileName = null;
                                  _selectedTag = null;
                                  _stageTags = [];
                                  _lastStageId = null;
                                });
                                _tagSubscription?.cancel();
                                cubit.selectLeadStage(null);
                                cubit.selectCategory(null);
                                cubit.selectSubCategory(null);
                                cubit.selectStaff(null);
                                cubit.selectSource(null);
                                cubit.selectPriority(null);
                                cubit.selectState(null);
                                cubit.selectDistrict(null);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'Clear All',
                                style: AppTextStyle.medium(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed:
                                  (_pickedCsvBytes != null &&
                                      !state.isImporting)
                                  ? () =>
                                        _confirmAndImport(context, state, cubit)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (_pickedCsvBytes != null &&
                                        !state.isImporting)
                                    ? const Color(0xFF00C853)
                                    : Colors.grey.shade400,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: state.isImporting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Submit',
                                      style: AppTextStyle.medium(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.5,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
  // CSV UPLOAD BOX
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCsvUploadBox(ImportLeadsCubit cubit) {
    final hasFile = _pickedCsvBytes != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['csv'],
              withData: true,
            );
            if (result == null ||
                result.files.isEmpty ||
                result.files.single.bytes == null) {
              return;
            }

            final file = result.files.single;
            final error = _validateCsvFile(file);
            if (error != null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              return;
            }

            setState(() {
              _pickedCsvBytes = file.bytes!;
              _pickedFileName = file.name;
            });
            cubit.setCsvBytes(file.bytes!);
          },
          child: Container(
            width: 200,
            height: 135,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasFile
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile
                    ? const Color(0xFF10B981)
                    : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasFile
                        ? Icons.check_circle_outline
                        : Icons.insert_drive_file_outlined,
                    color: hasFile
                        ? const Color(0xFF059669)
                        : const Color(0xFF64748B),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasFile
                      ? (_pickedFileName ?? 'File Selected')
                      : 'Import CSV File',
                  style: AppTextStyle.medium(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasFile
                        ? const Color(0xFF047857)
                        : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hasFile
                      ? '${(_pickedCsvBytes!.length / 1024).toStringAsFixed(1)} KB'
                      : 'Drop file or click here to choose file.',
                  style: AppTextStyle.medium(
                    fontSize: 10,
                    color: hasFile
                        ? const Color(0xFF059669)
                        : const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),

        // ── Remove/Cancel button, only visible once a file is selected ──
        if (hasFile)
          Positioned(
            top: -8,
            right: -8,
            child: InkWell(
              onTap: () {
                setState(() {
                  _pickedCsvBytes = null;
                  _pickedFileName = null;
                });
                cubit.clearCsvBytes(); // see note below
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A000000),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FILE VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns an error message if the file is invalid, or null if it's OK.
  String? _validateCsvFile(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    final nameLower = file.name.toLowerCase();

    // 1. Explicit extension check — do NOT rely on FilePicker's
    //    allowedExtensions alone, it is not reliably enforced on web.
    if (ext != 'csv' && !nameLower.endsWith('.csv')) {
      return 'Only CSV files are supported. Please select a .csv file.';
    }

    // 2. Basic size guard (optional, tune as needed).
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return 'The selected file is empty.';
    }

    // 3. Content sanity check — reject binary files that were merely
    //    renamed to .csv (e.g. a .xlsx or image saved with a .csv extension).
    try {
      final decoded = String.fromCharCodes(bytes.take(2048));
      // Binary files usually contain null bytes or a high ratio of
      // non-printable characters; real CSV/text won't.
      if (decoded.contains('\u0000')) {
        return 'This file doesn\'t look like a valid CSV file.';
      }
    } catch (_) {
      return 'This file doesn\'t look like a valid CSV file.';
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COUNTRY CODE TOGGLE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCountryCodeToggle(
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) {
    final isWithCountryCode = state.selectedTab == 0;
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeColors.borderLight),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Country Code',
            style: AppTextStyle.medium(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 8),
          // Transform.scale(
          //   scale: 0.65,
          //   // scaleX: 0.8,
          //   // scaleY: 0.6,
          //   alignment: Alignment.centerRight,
          //   child: Switch(
          //     focusColor: Colors.transparent,
          //     inactiveTrackColor: Colors.white,
          //     inactiveThumbColor: Color(0xFF1E3A8A),
          //     value: isWithCountryCode,
          //     activeTrackColor: Color(0xFF1E3A8A),
          //     activeThumbColor: Colors.white,
          //     trackOutlineWidth: WidgetStateProperty.all(3),
          //     trackOutlineColor: WidgetStateProperty.all(
          //       AppThemeColors.borderLight,
          //     ),

          //     materialTapTargetSize: MaterialTapTargetSize.padded,
          //     onChanged: (val) {
          //       cubit.selectTab(val ? 0 : 1);
          //     },
          //   ),
          // ),
          CustomSwitch(
            value: isWithCountryCode,
            onChanged: (value) {
              cubit.selectTab(value ? 0 : 1);
            },
            inactiveCircleColor: Color(0xFF1E3A8A),
            activeContainerColor: Color(0xFF1E3A8A),
            // width: 46,
            // height: 24,
            // activeColor: AppThemeColors.statusActive,
            // inactiveColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORM GRID (DYNAMIC FIELDS WITH MAXIMUM 4 PER ROW)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNextFollowupDateField(
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) {
    final displayDate =
        state.nextFollowUpDate ?? DateTime.now().add(const Duration(hours: 2));
    final displayText = DateFormat('dd-MM-yyyy hh:mm a').format(displayDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Follow-Up Date',
          style: AppTextStyle.medium(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final result = await showCalendarDialogUsingTimePicker(
              context,
              initialDate: state.nextFollowUpDate,
              mode: CalendarMode.single,
              showTimePicker: true,
              minDate: DateTime.now(),
            );
            log('[UI] date picker result: ${result?.from}');
            if (result != null) {
              cubit.selectNextFollowUpDate(
                result.from,
              ); // <-- pushes into cubit state, no setState needed
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              displayText,
              style: AppTextStyle.medium(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormGrid(
    BuildContext context,
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) {
    // ── Check and listen for tags on selected lead stage ───────────────────
    final matchStage = state.stages.where(
      (s) => s.name == state.selectedLeadStage,
    );
    final stageId = matchStage.isNotEmpty ? matchStage.first.id : null;

    if (stageId != _lastStageId) {
      _lastStageId = stageId;
      _tagSubscription?.cancel();
      _tagSubscription = null;

      if (stageId != null && stageId.isNotEmpty) {
        _tagSubscription = LeadTagRepository(tagId: stageId)
            .watchLeadTags()
            .listen((tags) {
              if (mounted) {
                setState(() {
                  _stageTags = tags;
                  if (_selectedTag != null &&
                      !tags.any((t) => t.name == _selectedTag)) {
                    _selectedTag = null;
                  }
                });
              }
            });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _stageTags = [];
              _selectedTag = null;
            });
          }
        });
      }
    }

    final categoryNames = state.categories
        .map((c) => c.name)
        .where((n) => n.isNotEmpty)
        .toList();

    final sourceNames = state.sources
        .map((s) => s.name)
        .where((n) => n.isNotEmpty)
        .toList();

    final stagesNames = state.stages
        .map((s) => s.name)
        .where((n) => n.isNotEmpty)
        .toList();

    final staffNames = state.staffList
        .map((s) => s.name)
        .where((n) => n.isNotEmpty)
        .toList();

    // ── Construct list of active fields in sequence ────────────────────────
    // final contactField = _buildCountrySelectorField(state, cubit);

    final stageField = Dropdown(
      label: 'Lead Stage',
      hint: 'Select Field',
      items: stagesNames,
      selectedValue: state.selectedLeadStage,
      onChanged: (val) {
        cubit.selectLeadStage(val);
      },
    );

    const addCategoryLabel = '+ Add Category';
    final categoryDropdownItems = [...categoryNames, addCategoryLabel];

    const addSourceLabel = '+ Add Source';
    final sourceDropdownItems = [...sourceNames, addSourceLabel];

    final categoryField = Dropdown(
      label: 'Lead Category',
      hint: 'Select Category',
      items: categoryDropdownItems,
      selectedValue: state.selectedCategory,
      onChanged: (val) {
        if (val == addCategoryLabel) {
          _showAddCategoryDialog();
          return;
        }
        log("gfdfdgvbcbc selectedCategory: $val");
        cubit.selectCategory(val);
      },
      // onAddTap: _showAddCategoryDialog,
    );

    final staffField = Dropdown(
      label: 'Staff',
      hint: 'Select Field',
      items: staffNames,
      selectedValue: state.assignedStaffName.isNotEmpty
          ? state.assignedStaffName
          : state.selectedStaff,
      onChanged: cubit.selectStaff,
      enabled: state.isAdmin,
      showClear: true,
      // isrequered: true,
      showStar: true,
    );

    final sourceField = Dropdown(
      label: 'Lead Source',
      hint: 'Select Source',
      items: sourceDropdownItems,
      selectedValue: state.selectedSource,
      onChanged: (val) {
        if (val == addSourceLabel) {
          _showAddSourceDialog();
          return;
        }
        log("gfdfdgvbcbc selectedSource: $val");
        cubit.selectSource(val);
      },
      // onAddTap: _showAddSourceDialog,
    );

    final priorityField = Dropdown(
      label: 'Priority',
      hint: 'Select Field',
      items: _priorities,
      selectedValue: state.selectedPriority,
      onChanged: cubit.selectPriority,
    );

    final stateField = Dropdown(
      label: 'State',
      hint: 'Select Field',
      items: _stateDistrictMap.keys.toList(),
      selectedValue: state.selectedState,
      onChanged: cubit.selectState,
      showClear: true,
    );

    final districtField = Dropdown(
      label: 'District',
      hint: 'Select Field',
      items: state.selectedState == null
          ? []
          : _stateDistrictMap[state.selectedState] ?? [],
      selectedValue: state.selectedDistrict,
      onChanged: cubit.selectDistrict,
      enabled: state.selectedState != null,
      showClear: true,
    );

    // final List<Widget> activeFields = [contactField, stageField];
    final List<Widget> activeFields = [stageField];
    if (state.selectedTab == 0) {
      activeFields.insert(0, _buildCountrySelectorField(state, cubit));
    }

    // if (state.selectedLeadStage?.toUpperCase() == 'FOLLOWUP') {
    //   activeFields.add(_buildNextFollowupDateField(state, cubit));
    // }

    final normalizedStage = state.selectedLeadStage?.toUpperCase().replaceAll(
      ' ',
      '',
    );
    if (normalizedStage == 'FOLLOWUP') {
      activeFields.add(_buildNextFollowupDateField(state, cubit));
    }

    activeFields.add(categoryField);

    // If selected category has subcategories in Firebase -> insert Sub Category dropdown next to Lead Category
    if (state.subCategories.isNotEmpty) {
      final subCatNames = state.subCategories
          .map((s) => s.name)
          .where((n) => n.isNotEmpty)
          .toList();
      activeFields.add(
        _buildStandardDropdown(
          label: 'Lead Sub Category',
          hint: 'Select Sub Category',
          items: subCatNames,
          selectedValue: state.selectedSubCategory,
          onChanged: cubit.selectSubCategory,
          showClear: true,
        ),
      );
    }

    if (state.isAdmin) {
      activeFields.add(staffField);
    }

    activeFields.addAll([
      sourceField,
      priorityField,
      stateField,
      districtField,
    ]);

    // ── Chunk active fields into rows with maximum 4 fields per row ──────────
    final List<List<Widget>> rows = [];
    for (int i = 0; i < activeFields.length; i += 4) {
      final end = (i + 4 < activeFields.length) ? i + 4 : activeFields.length;
      rows.add(activeFields.sublist(i, end));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int j = 0; j < 4; j++) ...[
                      if (j < rows[i].length)
                        Expanded(child: rows[i][j])
                      else
                        const Expanded(child: SizedBox.shrink()),
                      if (j < 3) const SizedBox(width: 16),
                    ],
                  ],
                ),
              ],
            ],
          );
        }

        final itemWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: activeFields
              .map((field) => SizedBox(width: itemWidth, child: field))
              .toList(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIELD WIDGET BUILDERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCountrySelectorField(
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) {
    if (state.selectedTab != 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country Code',
          style: AppTextStyle.medium(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 5.h,
          width: double.infinity, // stretch to match other fields
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Localizations.override(
            context: context,
            locale: const Locale('en'),
            child: CountryCodePicker(
              onChanged: (country) =>
                  cubit.setDialCode(country.dialCode ?? '+91'),
              initialSelection: 'IN',
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              padding: EdgeInsets.zero,
              textStyle: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              flagWidth: 18,
              dialogBackgroundColor: Colors.white,
              boxDecoration: BoxDecoration(
                border: Border.all(color: const Color(0xff00B16E)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithAddButton({
    required String label,
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required VoidCallback onAddTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppThemeColors.basicGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        (selectedValue != null && items.contains(selectedValue))
                        ? selectedValue
                        : null,
                    hint: Text(
                      hint,
                      style: AppTextStyle.medium(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    isExpanded: true,
                    style: AppTextStyle.medium(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                    items: items
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
    bool showClear = false,
    bool isrequered = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            isrequered == true
                ? Text(
                    " *",
                    style: AppTextStyle.medium(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        (selectedValue != null && items.contains(selectedValue))
                        ? selectedValue
                        : null,
                    hint: Text(
                      hint,
                      style: AppTextStyle.medium(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    icon: showClear && selectedValue != null
                        ? InkWell(
                            onTap: () => onChanged(null),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                          )
                        : const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                    isExpanded: true,
                    style: AppTextStyle.medium(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                    items: items
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
      setState(() {
        _pickedCsvBytes = null;
        _pickedFileName = null;
        _selectedTag = null;
        _stageTags = [];
        _lastStageId = null;
      });
      _tagSubscription?.cancel();
      context.go(RoutePaths.leadsReport);
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
  // DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  // void _showAddCategoryDialog() {
  //   _dialogNameCtrl.clear();
  //   final importCubit = context.read<ImportLeadsCubit>();
  //   final categoryCubit = context.read<LeadCategoryCubit>();

  //   showDialog(
  //     context: context,
  //     builder: (ctx) => LeadSettingsAlert(
  //     fieldLabel: 'Lead Category',
  //     title: 'Add Lead Category',
  //     constrainsWidth: 840,
  //     onSubmit: (String value) async {
  //           final name = _dialogNameCtrl.text.trim();
  //         if (name.isEmpty) return;

  //         await categoryCubit.addCategory(name: name);
  //         await importCubit.refreshCategories();
  //         importCubit.selectCategory(name);

  //         if (ctx.mounted) context.pop(ctx);

  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Category "$name" added.'),
  //               backgroundColor: AppColors.green,
  //               behavior: SnackBarBehavior.floating,
  //             ),
  //           );
  //         }

  //     },
  //   ),
  //     //  AppDialog(
  //     //   width: 400,
  //     //   title: 'Add Lead Category',
  //     //   body: Padding(
  //     //     padding: const EdgeInsets.all(8.0),
  //     //     child: Column(
  //     //       crossAxisAlignment: CrossAxisAlignment.start,
  //     //       mainAxisSize: MainAxisSize.min,
  //     //       children: [
  //     //         const Text(
  //     //           'Lead Category',
  //     //           style: TextStyle(
  //     //             fontSize: 13,
  //     //             fontWeight: FontWeight.w600,
  //     //             color: Color(0xFF475569),
  //     //           ),
  //     //         ),
  //     //         const SizedBox(height: 8),
  //     //         TextField(
  //     //           controller: _dialogNameCtrl,
  //     //           autofocus: true,
  //     //           decoration: InputDecoration(
  //     //             hintText: 'Enter Category',
  //     //             hintStyle: const TextStyle(
  //     //               fontSize: 13,
  //     //               color: Color(0xFF94A3B8),
  //     //             ),
  //     //             border: OutlineInputBorder(
  //     //               borderRadius: BorderRadius.circular(8),
  //     //               borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  //     //             ),
  //     //           ),
  //     //         ),
  //     //       ],
  //     //     ),
  //     //   ),
  //     //   onSubmit: () async {
  //       //   final name = _dialogNameCtrl.text.trim();
  //       //   if (name.isEmpty) return;

  //       //   await categoryCubit.addCategory(name: name);
  //       //   await importCubit.refreshCategories();
  //       //   importCubit.selectCategory(name);

  //       //   if (ctx.mounted) Navigator.pop(ctx);

  //       //   if (mounted) {
  //       //     ScaffoldMessenger.of(context).showSnackBar(
  //       //       SnackBar(
  //       //         content: Text('Category "$name" added.'),
  //       //         backgroundColor: AppColors.green,
  //       //         behavior: SnackBarBehavior.floating,
  //       //       ),
  //       //     );
  //       //   }
  //       // },
  //     // ),
  //   );
  // }

  void _showAddCategoryDialog() {
    final importCubit = context.read<ImportLeadsCubit>();
    final categoryCubit = context.read<LeadCategoryCubit>();

    showDialog(
      context: context,
      builder: (ctx) => LeadSettingsAlert(
        fieldLabel: 'Lead Category',
        title: 'Add Lead Category',
        constrainsWidth: 840,
        onSubmit: (String value) async {
          final name = value.trim();
          if (name.isEmpty) return;

          if (categoryCubit.categoryExists(name)) {
            StatusAlertWidget.show(
              context,
              isSuccess: false,
              title: 'Validation',
              message: 'Category "$name" already exists.',
              onButtonPressed: () {
                context.pop();
              },
            );
            return;
          }

          await categoryCubit.addCategory(name: name);
          await importCubit.refreshCategories();
          importCubit.selectCategory(name);

          if (ctx.mounted) Navigator.pop(ctx);

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

  // void _showAddSourceDialog() {
  //   _dialogNameCtrl.clear();
  //   final importCubit = context.read<ImportLeadsCubit>();
  //   final sourceCubit = context.read<LeadSourceCubit>();

  //   showDialog(
  //     context: context,
  //     builder: (ctx) => LeadSettingsAlert(
  //     fieldLabel: 'Lead Category',
  //     title: 'Add Lead Category',
  //     constrainsWidth: 840,
  //     onSubmit: (String value) async {
  //             final name = _dialogNameCtrl.text.trim();
  //         if (name.isEmpty) return;

  //         await sourceCubit.addSource(name: name);
  //         await importCubit.refreshSources();
  //         importCubit.selectSource(name);

  //         if (ctx.mounted) Navigator.pop(ctx);

  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Source "$name" added.'),
  //               backgroundColor: AppColors.green,
  //               behavior: SnackBarBehavior.floating,
  //             ),
  //           );
  //         }

  //     },
  //   ),
  //     // AppDialog(
  //     //   width: 400,
  //     //   title: 'Add Lead Source',
  //     //   body: Padding(
  //     //     padding: const EdgeInsets.all(8.0),
  //     //     child: Column(
  //     //       crossAxisAlignment: CrossAxisAlignment.start,
  //     //       mainAxisSize: MainAxisSize.min,
  //     //       children: [
  //     //         const Text(
  //     //           'Lead Source',
  //     //           style: TextStyle(
  //     //             fontSize: 13,
  //     //             fontWeight: FontWeight.w600,
  //     //             color: Color(0xFF475569),
  //     //           ),
  //     //         ),
  //     //         const SizedBox(height: 8),
  //     //         TextField(
  //     //           controller: _dialogNameCtrl,
  //     //           autofocus: true,
  //     //           decoration: InputDecoration(
  //     //             hintText: 'Enter Source',
  //     //             hintStyle: const TextStyle(
  //     //               fontSize: 13,
  //     //               color: Color(0xFF94A3B8),
  //     //             ),
  //     //             border: OutlineInputBorder(
  //     //               borderRadius: BorderRadius.circular(8),
  //     //               borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  //     //             ),
  //     //           ),
  //     //         ),
  //     //       ],
  //     //     ),
  //     //   ),
  //     //   onSubmit: () async {
  //         // final name = _dialogNameCtrl.text.trim();
  //         // if (name.isEmpty) return;

  //         // await sourceCubit.addSource(name: name);
  //         // await importCubit.refreshSources();
  //         // importCubit.selectSource(name);

  //         // if (ctx.mounted) Navigator.pop(ctx);

  //         // if (mounted) {
  //         //   ScaffoldMessenger.of(context).showSnackBar(
  //         //     SnackBar(
  //         //       content: Text('Source "$name" added.'),
  //         //       backgroundColor: AppColors.green,
  //         //       behavior: SnackBarBehavior.floating,
  //         //     ),
  //         //   );
  //         // }
  //     //   },
  //     // ),
  //   );
  // }

  void _showAddSourceDialog() {
    final importCubit = context.read<ImportLeadsCubit>();
    final sourceCubit = context.read<LeadSourceCubit>();

    showDialog(
      context: context,
      builder: (ctx) => LeadSettingsAlert(
        fieldLabel: 'Lead Source',
        title: 'Add Lead Source',
        constrainsWidth: 840,
        onSubmit: (String value) async {
          final name = value.trim();
          if (name.isEmpty) return;

          if (sourceCubit.sourceExists(name)) {
            StatusAlertWidget.show(
              context, 
              isSuccess: false,
              title: 'Validation',
              message: 'Source "$name" already exists.',
              onButtonPressed: () {
                context.pop();
              },
            );
            return;
          }

          await sourceCubit.addSource(name: name);
          await importCubit.refreshSources();
          importCubit.selectSource(name);

          if (ctx.mounted) Navigator.pop(ctx);

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
  // CONFIRM AND IMPORT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _confirmAndImport(
    BuildContext context,
    ImportLeadsState state,
    ImportLeadsCubit cubit,
  ) async {
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
      return;
    }

    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    final duplicateCount = await cubit.checkDuplicates(
      csvBytes: _pickedCsvBytes!,
    );

    if (!mounted) return;
    // navigator.pop();
    context.pop();

    if (duplicateCount > 0) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Duplicates Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Duplicates will be skipped. Only unique leads will be imported.',
                        style: TextStyle(
                          fontSize: 12,
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
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
                style: AppTextStyle.medium(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    log(
      '[Screen] About to import — state.nextFollowUpDate=${state.nextFollowUpDate}, '
      'selectedLeadStage=${state.selectedLeadStage}',
    );

    cubit.importLeads(csvBytes: _pickedCsvBytes!);
  }
}
