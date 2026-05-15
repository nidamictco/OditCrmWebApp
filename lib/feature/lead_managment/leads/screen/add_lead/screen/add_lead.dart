import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/menu_hover_bottun.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class AddLeadPage extends StatefulWidget {
  final AddLeadModel? lead;
  const AddLeadPage({super.key, this.lead});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  // ── Standard Controllers ───────────────────────────────────────────────────
  final TextEditingController _clientNameCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _postOfficeCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _dialogNameCtrl = TextEditingController();

  String? _leadStage;
  String? _leadSource;
  String? _leadCategory;
  String? _leadPriority;

  // ── Additional field controllers — keyed by AdditionalFieldModel.id ────────
  final Map<String, TextEditingController> _additionalCtrlMap = {};

  // Dial codes
  String _contactDialCode = '+91';
  String _whatsappDialCode = '+91';

  final List<String> priority = ['High', 'Low', 'Negative', 'Normal'];

  final Map<String, List<String>> stateDistrictMap = {
    'Kerala': [
      'Ernakulam',
      'Kottayam',
      'Kozhikode',
      'Thiruvananthapuram',
      'Thrissur',
      'Malappuram',
      'Palakkad',
      'Kollam',
      'Alappuzha',
      'Kannur',
      'Kasaragod',
      'Wayanad',
      'Idukki',
      'Pathanamthitta',
    ],
    'Tamil Nadu': ['Chennai', 'Madurai', 'Coimbatore', 'Salem'],
    'Arunachal Pradesh': ['Tawang', 'Papum Pare', 'West Kameng'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
  };

  bool get _isEditMode => widget.lead != null;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().initialize();
    if (_isEditMode) _prefillIfEditing(widget.lead!);
  }

  void _prefillIfEditing(AddLeadModel lead) {
    _clientNameCtrl.text = lead.clientName;
    _contactCtrl.text = lead.contactNumber;
    _whatsappCtrl.text = lead.whatsappNumber;
    _emailCtrl.text = lead.email;
    _addressCtrl.text = lead.address;
    _pinCtrl.text = lead.pinCode;
    _postOfficeCtrl.text = lead.postOffice;
    _remarksCtrl.text = lead.remarks;
    _leadStage = lead.leadStage;
    _leadSource = lead.leadSource;
    _leadCategory = lead.leadCategory;
    _leadPriority = lead.priority;

    // Pre-select state and district in cubit
    if (lead.state.isNotEmpty) {
      context.read<AddLeadCubit>().selectState(lead.state);
    }
    if (lead.district.isNotEmpty) {
      context.read<AddLeadCubit>().selectDistrict(lead.district);
    }
  }

  void _syncAdditionalControllers(List<dynamic> fields) {
    final incomingIds = fields.map((f) => f.id as String).toSet();

    // Remove stale controllers
    _additionalCtrlMap.keys
        .where((id) => !incomingIds.contains(id))
        .toList()
        .forEach((id) {
          _additionalCtrlMap.remove(id)?.dispose();
        });

    // Add new ones
    for (final field in fields) {
      final id = field.id as String;
      _additionalCtrlMap.putIfAbsent(id, () => TextEditingController());
    }
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _contactCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _pinCtrl.dispose();
    _postOfficeCtrl.dispose();
    _remarksCtrl.dispose();
    _dialogNameCtrl.dispose();
    for (final c in _additionalCtrlMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submit() {
    final cubit = context.read<AddLeadCubit>();
    final state = cubit.state;

    final additionalValues = <String, String>{};
    for (final field in state.additionalFields) {
      final id = field.id;
      if (id != null) {
        additionalValues[field.fieldName] =
            _additionalCtrlMap[id]?.text.trim() ?? '';
      }
    }

    if (_isEditMode) {
      final updated = widget.lead!.copyWith(
        clientName: _clientNameCtrl.text,
        contactNumber: _contactCtrl.text,
        contactDialCode: _contactDialCode,
        whatsappNumber: _whatsappCtrl.text,
        whatsappDialCode: _whatsappDialCode,
        email: _emailCtrl.text,
        address: _addressCtrl.text,
        pinCode: _pinCtrl.text,
        postOffice: _postOfficeCtrl.text,
        remarks: _remarksCtrl.text,
        leadCategory: _leadCategory ?? widget.lead!.leadCategory,
        leadSource: _leadSource ?? widget.lead!.leadSource,
        priority: _leadPriority ?? widget.lead!.priority,
        leadStage: _leadStage ?? widget.lead!.leadStage,
        state: state.selectedState ?? widget.lead!.state,
        district: state.selectedDistrict ?? widget.lead!.district,
        additionalFields: additionalValues.isNotEmpty
            ? additionalValues
            : widget.lead!.additionalFields,
      );
      cubit.updateLead(widget.lead!.id!, updated);
    } else {
      cubit.submitLead(
        clientName: _clientNameCtrl.text,
        contactNumber: _contactCtrl.text,
        contactDialCode: _contactDialCode,
        whatsappNumber: _whatsappCtrl.text,
        whatsappDialCode: _whatsappDialCode,
        email: _emailCtrl.text,
        address: _addressCtrl.text,
        pinCode: _pinCtrl.text,
        postOffice: _postOfficeCtrl.text,
        remarks: _remarksCtrl.text,
        additionalFieldValues: additionalValues,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 2)),
    );
  }

  void _clearForm() {
    _clientNameCtrl.clear();
    _contactCtrl.clear();
    _whatsappCtrl.clear();
    _emailCtrl.clear();
    _addressCtrl.clear();
    _pinCtrl.clear();
    _postOfficeCtrl.clear();
    _remarksCtrl.clear();

    for (final c in _additionalCtrlMap.values) {
      c.clear();
    }

    //  local state variables
    setState(() {
      _leadCategory = null;
      _leadSource = null;
      _leadStage = null;
      _leadPriority = null;
      _contactDialCode = '+91';
      _whatsappDialCode = '+91';
    });

    // dropdowns read from state, not local vars
    final cubit = context.read<AddLeadCubit>();
    cubit.selectCategory(null);
    cubit.selectSource(null);
    cubit.selectLeadStage(null);
    cubit.selectPriority(null);
    cubit.selectState(null);
    cubit.selectDistrict(null);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddLeadCubit, AddLeadState>(
      listenWhen: (prev, cur) =>
          cur.errorMessage != prev.errorMessage ||
          cur.successMessage != prev.successMessage ||
          cur.additionalFields != prev.additionalFields ||
          cur.isUpdating != prev.isUpdating,
      listener: (context, state) {
        if (state.additionalFields.isNotEmpty) {
          _syncAdditionalControllers(state.additionalFields);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.successMessage != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(state.successMessage!),
          //     backgroundColor: AppColors.green,
          //     behavior: SnackBarBehavior.floating,
          //   ),
          // );
          if (!_isEditMode) {
            _clearForm();
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // ── Customer Details ──────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: _sectionCard(
                        'Customer Details',
                        _buildCustomerDetails(),
                        Symbols.person,
                      ),
                    ),

                    // ── Additional Details (only if fields exist) ─────────
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      buildWhen: (p, c) =>
                          p.additionalFields != c.additionalFields ||
                          p.isLoadingAdditionalFields !=
                              c.isLoadingAdditionalFields,
                      builder: (context, state) {
                        if (state.isLoadingAdditionalFields) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: _sectionCard(
                              'Additional Details',
                              SizedBox(
                                height: 8.h,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              Icons.add_circle_outline_rounded,
                            ),
                          );
                        }

                        if (state.additionalFields.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: _sectionCard(
                            'Additional Details',
                            _buildAdditionalDetails(state),
                            Icons.add_circle_outline_rounded,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    // ── Lead Information ──────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: _sectionCard(
                        'Lead Information',
                        _buildLeadInformation(),
                        Symbols.info,
                      ),
                    ),

                    // ── Submit Button ─────────────────────────────────────
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section: Additional Details ────────────────────────────────────────────

  Widget _buildAdditionalDetails(AddLeadState state) {
    final fields = state.additionalFields;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
        final columnSpacing = 2.w;
        const rowSpacing = 12.0;

        final fieldWidgets = fields.map((field) {
          final id = field.id ?? field.fieldName;
          final controller =
              _additionalCtrlMap[id] ??
              (_additionalCtrlMap[id] = TextEditingController());

          return _field(
            field.fieldName,
            false,
            Icons.description_outlined,
            controller: controller,
          );
        }).toList();

        final rows = <Widget>[];
        for (var i = 0; i < fieldWidgets.length; i += crossAxisCount) {
          final rowChildren = <Widget>[];
          for (var j = 0; j < crossAxisCount; j++) {
            final idx = i + j;
            if (idx < fieldWidgets.length) {
              rowChildren.add(Expanded(child: fieldWidgets[idx]));
            } else {
              rowChildren.add(const Expanded(child: SizedBox.shrink()));
            }
            if (j < crossAxisCount - 1) {
              rowChildren.add(SizedBox(width: columnSpacing));
            }
          }
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );
          if (i + crossAxisCount < fieldWidgets.length) {
            rows.add(SizedBox(height: rowSpacing));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  // ── Section: Customer Details ──────────────────────────────────────────────

  Widget _buildCustomerDetails() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      buildWhen: (p, c) =>
          p.selectedState != c.selectedState ||
          p.selectedDistrict != c.selectedDistrict,
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Client Name',
                    true,
                    Icons.person_outline,
                    controller: _clientNameCtrl,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _phoneField(
                    'Contact Number',
                    true,
                    Icons.call_outlined,
                    controller: _contactCtrl,
                    onDialCodeChanged: (c) =>
                        setState(() => _contactDialCode = c),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child: _phoneField(
                    'Whatsapp Number',
                    false,
                    Icons.call_outlined,
                    controller: _whatsappCtrl,
                    onDialCodeChanged: (c) =>
                        setState(() => _whatsappDialCode = c),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _field(
                    'Email',
                    false,
                    Icons.email_outlined,
                    controller: _emailCtrl,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            _multilineField(
              'Address',
              Icons.location_on_outlined,
              controller: _addressCtrl,
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Pin Code',
                    false,
                    Icons.pin_drop_outlined,
                    controller: _pinCtrl,
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: _field(
                    'Post Office',
                    false,
                    Icons.location_city,
                    controller: _postOfficeCtrl,
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Dropdown(
                    showIcon: true,
                    icon: Icons.location_on_outlined,
                    items: stateDistrictMap.keys.toList(),
                    selectedValue: state.selectedState,
                    onChanged: (v) =>
                        context.read<AddLeadCubit>().selectState(v),
                    label: 'State',
                    hint: 'Select State',
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Dropdown(
                    showIcon: true,
                    icon: Icons.location_on_outlined,
                    items: state.selectedState == null
                        ? []
                        : stateDistrictMap[state.selectedState] ?? [],
                    selectedValue: state.selectedDistrict,
                    enabled: state.selectedState != null,
                    onChanged: (v) =>
                        context.read<AddLeadCubit>().selectDistrict(v),
                    label: 'District',
                    hint: 'Select District',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Section: Lead Information ──────────────────────────────────────────────

  Widget _buildLeadInformation() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        final cubit = context.read<AddLeadCubit>();
        final categoryNames = state.categories.map((e) => e.name).toList();
        final sourceNames = state.sources.map((e) => e.name).toList();
        final stagesNames = state.stages.map((e) => e.name).toList();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _readOnlyField(
                    'Assign Staff',
                    Icons.person_outline,
                    state.assignedStaffName,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: DropdownWithAdd(
                    label: 'Lead Category',
                    icon: Icons.layers_outlined,
                    showIcon: true,
                    items: categoryNames,
                    selectedValue: _leadCategory,
                    onChanged: (v) {
                      setState(() => _leadCategory = v);
                      cubit.selectCategory(v);
                    },
                    onTap: _showAddCategoryDialog,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child: DropdownWithAdd(
                    label: 'Lead Source',
                    showIcon: true,
                    icon: Icons.layers_rounded,
                    items: sourceNames,
                    selectedValue: _leadSource,
                    onChanged: (v) {
                      setState(() => _leadSource = v);
                      cubit.selectSource(v);
                    },
                    onTap: _showAddSourceDialog,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Dropdown(
                    icon: Icons.flag_outlined,
                    showIcon: true,
                    showHelp: true,
                    items: priority,
                    selectedValue: _leadPriority,
                    onChanged: (v) {
                      setState(() => _leadPriority = v);
                      cubit.selectPriority(v);
                    },
                    label: 'Priority',
                    hint: 'Select Priority',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Dropdown(
                    showHelp: true,
                    items: stagesNames,
                    selectedValue: _leadStage,
                    onChanged: (v) {
                      setState(() => _leadStage = v);
                      cubit.selectLeadStage(v);
                    },
                    label: 'Lead Stage',
                    hint: 'Select Stages',
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            _multilineField(
              'Remarks',
              Icons.note_alt_outlined,
              controller: _remarksCtrl,
            ),
          ],
        );
      },
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: Container(
        margin: EdgeInsets.all(2.w),
        width: double.infinity,
        height: 10.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        child: Align(
          alignment: Alignment.centerRight,
          child: BlocBuilder<AddLeadCubit, AddLeadState>(
            buildWhen: (p, c) =>
                p.isSubmitting != c.isSubmitting ||
                p.isUpdating != c.isUpdating,
            builder: (context, state) {
              final isBusy = state.isSubmitting || state.isUpdating;
              return SizedBox(
                height: 5.h,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    disabledBackgroundColor: AppColors.green.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Update' : 'Submit',
                          style: AppTextStyle.medium(
                            size: 11.sp,
                            color: AppColors.white,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

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
          context.read<LeadCategoryCubit>().addCategory(name: name);
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

  void _showAddSourceDialog() {
    _dialogNameCtrl.clear();
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
          context.read<LeadSourceCubit>().addSource(name: name);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Source "$name" added.'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────────────────

  Widget _sectionCard(String title, Widget child, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 13.sp, weight: 600, color: AppColors.green),
                SizedBox(width: 1.w),
                Text(
                  title,
                  style: AppTextStyle.medium(
                    size: 11.sp,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(2.w), child: child),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    bool required,
    IconData icons, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: _box(),
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

  Widget _readOnlyField(String label, IconData icons, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: _box(),
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          alignment: Alignment.centerLeft,
          child: Text(
            value.isEmpty ? 'Loading...' : value,
            style: value.isEmpty
                ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
                : AppTextStyle.body(size: 11.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                decoration: _box(),
                child: TextField(
                  controller: controller,
                  style: AppTextStyle.body(size: 11.sp),
                  keyboardType: TextInputType.phone,
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

  Widget _multilineField(
    String label,
    IconData icons, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 10.h,
          decoration: _box(),
          child: TextField(
            controller: controller,
            maxLines: null,
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

  Widget _label(String text, bool required, IconData icons) {
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

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.greyCard,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isEditMode ? 'EDIT LEAD' : 'ADD NEW LEAD',
            style: AppTextStyle.medium(
              size: 13.sp,
              color: AppColors.black.withOpacity(0.77),
              weight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Row(
                children: [
                  Text('Lead Management', style: AppTextStyle.medium()),
                  Icon(Icons.chevron_right, size: 16.sp),
                  Text(
                    _isEditMode ? 'Edit Lead' : 'Add Lead',
                    style: AppTextStyle.medium(color: AppColors.grey),
                  ),
                ],
              ),
              SizedBox(width: 1.w),
              MenuHoverButton(),
            ],
          ),
        ],
      ),
    );
  }
}
