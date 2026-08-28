import 'dart:developer';

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/widget/new_alert.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/indian_location_service.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/popup_msg.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/screens/widget/calender.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/calender.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_category/cubit/lead_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_source/cubit/lead_source_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Intent used by the form's keyboard shortcuts
// ─────────────────────────────────────────────────────────────────────────────
class _NextFieldIntent extends Intent {
  const _NextFieldIntent();
}

class _PrevFieldIntent extends Intent {
  const _PrevFieldIntent();
}

// ─────────────────────────────────────────────────────────────────────────────
// AddLeadPage
// ─────────────────────────────────────────────────────────────────────────────
class AddLeadPage extends StatefulWidget {
  final AddLeadModel? lead;
  const AddLeadPage({super.key, this.lead});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController _clientNameCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _postOfficeCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _dialogNameCtrl = TextEditingController();
  final TextEditingController nextFollowUpCtrl = TextEditingController(
    // text: DateFormat(
    //   'dd-MM-yyyy hh:mm a',
    // ).format(DateTime.now().add(const Duration(days: 1))),
  );
  DateTime nextFollowUpDate = DateTime.now().add(const Duration(days: 1));
  DateTime calledDateValue = DateTime.now();

  // ── FocusNodes — fixed fields ────────────────────────────────────────────────
  // Declared in tab-order so _orderedNodes is simple to build.
  final FocusNode _clientNameFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();
  final FocusNode _whatsappFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _pinFocus = FocusNode();
  final FocusNode _postOfficeFocus = FocusNode();
  // Dropdown focus nodes
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _districtFocus = FocusNode();
  final FocusNode _assignStaffFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _subCategoryFocus = FocusNode();
  final FocusNode _sourceFocus = FocusNode();
  final FocusNode _priorityFocus = FocusNode();
  final FocusNode _stageFocus = FocusNode();
  final FocusNode _tagsFocus = FocusNode();
  final FocusNode _callResultFocus = FocusNode();
  final FocusNode _remarksFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();

  final Map<String, FocusNode> _additionalFocusMap = {};

  /// Built in [_buildOrderedNodes]
  List<FocusNode> _orderedNodes = [];

  // ── Dropdown values ──────────────────────────────────────────────────────────
  String? _leadStage;
  String? _leadSource;
  String? _leadCategory;
  String? _leadSubCategory;

  String? _leadPriority;
  String? _callResult;
  String? _leadTag;
  String? _selectStaff;

  // ── Additional field controllers keyed by AdditionalFieldModel.id ────────────
  final Map<String, TextEditingController> _additionalCtrlMap = {};

  // Dial codes
  String _contactDialCode = '+91';
  String _whatsappDialCode = '+91';

  final _formKey = GlobalKey<FormState>();

  final List<String> priority = ['High', 'Low', 'Negative', 'Normal'];

  Map<String, List<String>> stateDistrictMap = {};

  bool get _isEditMode => widget.lead != null;

  StaffModel? _currentUser;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _loadCurrentUser() async {
    final user = await SessionService().getSavedUser();
    setState(() {
      _currentUser = user;
      if (user != null && user.staffType == 'Admin') {
        _selectStaff = user.name;
      }
    });
    if (user != null && user.staffType != 'Admin') {
      context.read<AddLeadCubit>().selectAssignedStaff(
        name: user.name ?? '',
        id: user.id ?? '',
      );
    }
    if (user != null && user.staffType == 'Admin') {
      context.read<AddLeadCubit>().selectAssignedStaff(
        name: user.name ?? '',
        id: user.id ?? '',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    context.read<AddLeadCubit>().initialize();
    context.read<AddLeadCubit>().fetchStaff();
    _loadLocations();
    // if (_isEditMode) _prefillIfEditing(widget.lead!);
    if (_isEditMode) {
      _prefillIfEditing(widget.lead!);
    } else {
      _leadPriority = 'Normal';
      _leadStage = 'NEW';
    }
    // Build the initial ordered focus list (no additional fields yet).
    _buildOrderedNodes([]);

    _clientNameFocus.requestFocus();
  }

  /// Re-builds the ordered focus list whenever additional fields change.
  /// Call this from the BlocListener after syncing controllers.
  void _buildOrderedNodes(List<dynamic> additionalFields) {
    final tagsVisible = context.read<AddLeadCubit>().state.leadTag.isNotEmpty;
    final nodes = <FocusNode>[
      _clientNameFocus,
      _contactFocus,
      _whatsappFocus,
      _emailFocus,
      _addressFocus,
      _pinFocus,
      _postOfficeFocus,
      _stateFocus,
      _districtFocus,
    ];

    // Additional fields in order
    for (final field in additionalFields) {
      final id = field.id as String;
      nodes.add(_additionalFocusMap.putIfAbsent(id, () => FocusNode()));
    }

    if (!_isEditMode) {
      nodes.addAll([_assignStaffFocus, _categoryFocus, _sourceFocus]);
    } else {
      nodes.addAll([_categoryFocus, _sourceFocus]);
    }
    nodes.addAll([
      _priorityFocus,
      _stageFocus,
      if (_leadStage != 'NEW' && _leadStage != null && tagsVisible) _tagsFocus,
      if (_leadStage != 'NEW' && _leadStage != null) _callResultFocus,
      _remarksFocus,
      _submitFocus,
    ]);

    setState(() => _orderedNodes = nodes);
  }

  Future<void> _loadLocations() async {
    final map = await IndiaLocationService.loadStateDistricts();
    if (mounted) setState(() => stateDistrictMap = map);
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
    _leadSubCategory = lead.leadSubCategory;
    _leadPriority = lead.priority;
    // nextFollowUpDate =
    //     lead.followUpDate ?? DateTime.now().add(const Duration(days: 1));
    // nextFollowUpCtrl.text = DateFormat('dd-MM-yyyy').format(nextFollowUpDate);
    if (lead.followUpDate != null) {
      nextFollowUpDate = lead.followUpDate!;
      nextFollowUpCtrl.text = DateFormat(
        'dd-MM-yyyy hh:mm a',
      ).format(nextFollowUpDate!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AddLeadCubit>();
      if (lead.state.isNotEmpty) cubit.selectState(lead.state);
      if (lead.district.isNotEmpty) cubit.selectDistrict(lead.district);
      if (lead.leadCategory.isNotEmpty) cubit.selectCategory(lead.leadCategory);
      if (lead.leadSource.isNotEmpty) cubit.selectSource(lead.leadSource);
      if (lead.priority.isNotEmpty) cubit.selectPriority(lead.priority);
      if (lead.leadStage.isNotEmpty) cubit.selectLeadStage(lead.leadStage);
    });
  }

  void _syncAdditionalControllers(List<dynamic> fields) {
    final incomingIds = fields.map((f) => f.id as String).toSet();

    // Remove stale controllers and focus nodes
    _additionalCtrlMap.keys
        .where((id) => !incomingIds.contains(id))
        .toList()
        .forEach((id) {
          _additionalCtrlMap.remove(id)?.dispose();
          _additionalFocusMap.remove(id)?.dispose();
        });

    // Add new ones
    for (final field in fields) {
      final id = field.id as String;
      _additionalCtrlMap.putIfAbsent(id, () => TextEditingController());
      _additionalFocusMap.putIfAbsent(id, () => FocusNode());
    }

    // Rebuild ordered nodes with the new additional fields
    _buildOrderedNodes(fields);
  }

  @override
  void dispose() {
    // Controllers
    _clientNameCtrl.dispose();
    _contactCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _pinCtrl.dispose();
    _postOfficeCtrl.dispose();
    _remarksCtrl.dispose();
    _dialogNameCtrl.dispose();
    nextFollowUpCtrl.dispose();
    for (final c in _additionalCtrlMap.values) c.dispose();

    // Focus nodes — fixed
    _clientNameFocus.dispose();
    _contactFocus.dispose();
    _whatsappFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _pinFocus.dispose();
    _postOfficeFocus.dispose();
    _stateFocus.dispose();
    _districtFocus.dispose();
    _assignStaffFocus.dispose();
    _categoryFocus.dispose();
    _sourceFocus.dispose();
    _priorityFocus.dispose();
    _stageFocus.dispose();
    _tagsFocus.dispose();
    _callResultFocus.dispose();
    _remarksFocus.dispose();
    _submitFocus.dispose();

    // Focus nodes — dynamic
    for (final fn in _additionalFocusMap.values) fn.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Keyboard navigation helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Move focus forward — if we are on the last node, trigger submit.
  void _focusNext(BuildContext context) {
    final current = FocusScope.of(context).focusedChild;
    final idx = _orderedNodes.indexWhere((n) => n == current);

    log("current : $current");
    log("focusNext: $idx");
    if (idx < 0) {
      // Not in our list — let Flutter handle it.
      FocusScope.of(context).nextFocus();
      return;
    }

    if (idx >= _orderedNodes.length - 1) {
      // Last field → submit
      _submit();
    } else {
      final next = _orderedNodes[idx + 1];
      next.requestFocus();
    }
  }

  void _focusPrev(BuildContext context) {
    final current = FocusScope.of(context).focusedChild;
    final idx = _orderedNodes.indexWhere((n) => n == current);

    if (idx <= 0) {
      FocusScope.of(context).previousFocus();
      return;
    }
    _orderedNodes[idx - 1].requestFocus();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();

    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _showError('Enter a valid email address.');
        return;
      }
    }
    if (contact.isEmpty) {
      _showError('Contact Number is required.');
      return;
    }

    if (contact.isNotEmpty) {
      final phoneRegex = _contactDialCode == '+91'
          ? RegExp(r'^[0-9]{10}$')
          : RegExp(r'^[0-9]{6,15}$');
      if (!phoneRegex.hasMatch(contact)) {
        _showError(
          _contactDialCode == '+91'
              ? 'Indian contact number must be exactly 10 digits.'
              : 'Enter a valid contact number.',
        );
        return;
      }
    }

    if (whatsapp.isNotEmpty) {
      final phoneRegex = _whatsappDialCode == '+91'
          ? RegExp(r'^[0-9]{10}$')
          : RegExp(r'^[0-9]{6,15}$');
      if (!phoneRegex.hasMatch(whatsapp)) {
        _showError(
          _whatsappDialCode == '+91'
              ? 'Indian WhatsApp number must be exactly 10 digits.'
              : 'Enter a valid WhatsApp number.',
        );
        return;
      }
    }

    final pinCode = _pinCtrl.text.trim();
    if (pinCode.isNotEmpty) {
      if (!RegExp(r'^[0-9]{6}$').hasMatch(pinCode)) {
        _showError('Pin code must be a 6-digit number.');
        return;
      }
    }

    if (_leadStage == "FOLLOWUP" && nextFollowUpCtrl.text.isEmpty) {
      _showError('Next Follow Up Date is required.');
      return;
    }

    final tag = _leadTag;
    if (!_isEditMode &&
        tag == null &&
        context.read<AddLeadCubit>().state.tagMandatory) {
      _showError('Tag is required.');
      return;
    }

    log("yutyetretetdggh $_callResult");

    if (!_isEditMode &&
        _callResult == null &&
        _leadStage!.toUpperCase() != "NEW") {
      _showError('Call Result is required.');
      return;
    }

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
        leadCategoryId: state.selectedCategoryId ?? widget.lead!.leadCategoryId,
        leadCategory: state.selectedCategory ?? widget.lead!.leadCategory,
        leadSubCategoryId:
            state.selectedSubCategoryId ?? widget.lead!.leadSubCategoryId,
        leadSubCategory:
            state.selectedSubCategory ?? widget.lead!.leadSubCategory,
        leadSource: state.selectedSource ?? widget.lead!.leadSource,
        leadSourceId: state.selectedSourceId ?? widget.lead!.leadSourceId,
        priority: state.selectedPriority ?? widget.lead!.priority,
        leadStage: _leadStage ?? widget.lead!.leadStage,
        leadStageId: state.selectedLeadStageId ?? widget.lead!.leadStageId,
        state: state.selectedState ?? widget.lead!.state,
        district: state.selectedDistrict ?? widget.lead!.district,
        additionalFields: additionalValues.isNotEmpty
            ? additionalValues
            : widget.lead!.additionalFields,
        callResult: state.selectedCallResult ?? widget.lead!.callResult,
        leadTag: state.selectedLeadTag ?? widget.lead!.leadTag,
        followUpDate: nextFollowUpDate,
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
        nextFollowUpDate: nextFollowUpDate,
        additionalFieldValues: additionalValues,
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
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

    setState(() {
      _leadCategory = null;
      _leadSource = null;
      _leadStage = null;
      _leadPriority = null;
      _leadSubCategory = null;
      _contactDialCode = '+91';
      _whatsappDialCode = '+91';
    });

    final cubit = context.read<AddLeadCubit>();
    cubit.selectCategory(null);
    cubit.selectSource(null);
    cubit.selectLeadStage(null);
    cubit.selectPriority(null);
    cubit.selectState(null);
    cubit.selectDistrict(null);
    cubit.selectCallResult(null);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddLeadCubit, AddLeadState>(
      listenWhen: (prev, cur) =>
          cur.errorMessage != prev.errorMessage ||
          cur.successMessage != prev.successMessage ||
          cur.additionalFields != prev.additionalFields ||
          cur.isUpdating != prev.isUpdating,
      listener: (context1, state) {
        if (state.additionalFields.isNotEmpty) {
          _syncAdditionalControllers(state.additionalFields);
        }

        if (state.errorMessage != null) {
          if (state.errorMessage!.contains('already exists')) {
            _showDuplicateAlert(state.errorMessage!);
          } else {
            _showError(state.errorMessage!);
          }
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          log(
            "Success state: status = ${state.status}, message = ${state.successMessage}",
          );
          if (state.status == AddLeadStatus.success) {
            context.read<AddLeadCubit>().clearMessages();

            StatusAlertWidget.show(
              context,
              isSuccess: true,
              title: _isEditMode ? 'LEAD UPDATED!' : 'LEAD CREATED!',
              message: _isEditMode
                  ? 'The lead has been updated successfully.'
                  : 'The lead has been added successfully.',
              onButtonPressed: () {
                if (!mounted) return;
                context.pop();
                if (_isEditMode) {
                  if (context.canPop()) {
                    context.pop(true);
                  } else {
                    Navigator.pop(context);
                    context.go(RoutePaths.leadsReport);
                  }
                } else {
                  context.read<AddLeadCubit>().fetchLeads();
                  context.go(RoutePaths.leadsReport);
                }
              },
            );
          }
        }
      },

      // ── Wrap the entire form in Shortcuts + Actions for Enter navigation ──────
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Enter → next field (unless Shift is held)
          const SingleActivator(LogicalKeyboardKey.enter):
              const _NextFieldIntent(),
          const SingleActivator(LogicalKeyboardKey.enter, control: true):
              const _NextFieldIntent(),
          // Shift+Enter → previous field
          const SingleActivator(LogicalKeyboardKey.enter, shift: true):
              const _PrevFieldIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _NextFieldIntent: CallbackAction<_NextFieldIntent>(
              onInvoke: (_) {
                _focusNext(context);
                return null;
              },
            ),
            _PrevFieldIntent: CallbackAction<_PrevFieldIntent>(
              onInvoke: (_) {
                _focusPrev(context);
                return null;
              },
            ),
          },
          child: Scaffold(
            backgroundColor: AppThemeColors.scaffoldBg,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // SizedBox(height: 2.h),

                        // ── Customer Details ────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: _sectionCard(
                            'Customer Details',
                            Form(key: _formKey, child: _buildCustomerDetails()),
                            Symbols.person,
                          ),
                        ),

                        // ── Additional Details ──────────────────────────────
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

                        // ── Lead Information ────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: _sectionCard(
                            'Lead Information',
                            _buildLeadInformation(context),
                            Symbols.info,
                          ),
                        ),

                        // ── Submit Button ───────────────────────────────────
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Section: Customer Details
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCustomerDetails() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Client Name, Contact Number, Whatsapp Number, Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    'Client Name',
                    true,
                    Icons.person_outline,
                    controller: _clientNameCtrl,
                    focusNode: _clientNameFocus,
                    nextFocusNode: _contactFocus,
                    hint: 'Enter full name',
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: _phoneField(
                    'Contact Number',
                    true,
                    Icons.call_outlined,
                    controller: _contactCtrl,
                    focusNode: _contactFocus,
                    nextFocusNode: _whatsappFocus,
                    onDialCodeChanged: (c) =>
                        setState(() => _contactDialCode = c),
                    initialDialCode: _contactDialCode,
                    hint: 'Enter number',
                    suffixIcon: const Icon(
                      Icons.call_outlined,
                      size: 15,
                      color: Color(0xFF0F3661),
                    ),
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: _phoneField(
                    'Whatsapp Number',
                    false,
                    Icons.call_outlined,
                    controller: _whatsappCtrl,
                    focusNode: _whatsappFocus,
                    nextFocusNode: _emailFocus,
                    onDialCodeChanged: (c) =>
                        setState(() => _whatsappDialCode = c),
                    initialDialCode: _whatsappDialCode,
                    suffixIcon: Image.asset(
                      AssetResources.whatsapp_dark,
                      // scale: 3,
                    ),
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: _field(
                    'Email Address',
                    false,
                    Icons.email_outlined,
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    nextFocusNode: _pinFocus,
                    hint: 'example@gmail.com',
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Row 2: Pin Code, Post Office, State, District
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    'Pin Code',
                    false,
                    Icons.pin_drop_outlined,
                    keyboardtype: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    controller: _pinCtrl,
                    focusNode: _pinFocus,
                    nextFocusNode: _postOfficeFocus,
                    hint: 'Enter code',
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: _field(
                    'Post Office',
                    false,
                    Icons.location_city,
                    controller: _postOfficeCtrl,
                    focusNode: _postOfficeFocus,
                    nextFocusNode: _stateFocus,
                    hint: 'Enter number',
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  // child: stateDistrictMap.isEmpty
                  //     ? Container(
                  //         height: 5.h,
                  //         decoration: BoxDecoration(
                  //           border: Border.all(color: const Color(0xFFCBD5E1)),
                  //           borderRadius: BorderRadius.circular(8),
                  //           color: Colors.white,
                  //         ),
                  //         child: const Center(
                  //           child: SizedBox(
                  //             width: 14,
                  //             height: 14,
                  //             child: CircularProgressIndicator(
                  //               strokeWidth: 2,
                  //               color: AppColors.green,
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     :
                  child: Dropdown(
                    showIcon: true,
                    icon: Icons.location_on_outlined,
                    items: stateDistrictMap.keys.toList(),
                    selectedValue: state.selectedState,
                    focusNode: _stateFocus,
                    nextFocusNode: _districtFocus,
                    onChanged: (v) =>
                        context.read<AddLeadCubit>().selectState(v),
                    label: 'State',
                    hint: 'Select State',
                    showClear: true,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Dropdown(
                    showIcon: true,
                    icon: Icons.location_on_outlined,
                    items: state.selectedState == null
                        ? []
                        : stateDistrictMap[state.selectedState] ?? [],
                    selectedValue: state.selectedDistrict,
                    enabled: state.selectedState != null,
                    focusNode: _districtFocus,
                    nextFocusNode: _addressFocus,
                    // (!_isEditMode &&
                    //     _currentUser != null &&
                    //     _currentUser!.staffType == 'Admin')
                    // ? _assignStaffFocus
                    // : _categoryFocus,
                    onChanged: (v) =>
                        context.read<AddLeadCubit>().selectDistrict(v),
                    label: 'District',
                    hint: 'Select District',
                    showClear: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Row 3: Address
            _multilineField(
              'Address',
              Icons.location_on_outlined,
              controller: _addressCtrl,
              focusNode: _addressFocus,
              nextFocusNode:
                  (!_isEditMode &&
                      _currentUser != null &&
                      _currentUser!.staffType == 'Admin')
                  ? _assignStaffFocus
                  : _categoryFocus,
              hint: 'Enter detailed address',
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Section: Additional Details
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildAdditionalDetails(AddLeadState state) {
    final fields = state.additionalFields;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 1;
        final columnSpacing = 1.5.w;
        const rowSpacing = 16.0;

        final fieldWidgets = fields.map((field) {
          final id = field.id ?? field.fieldName;
          final controller =
              _additionalCtrlMap[id] ??
              (_additionalCtrlMap[id] = TextEditingController());
          final fn =
              _additionalFocusMap[id] ??
              (_additionalFocusMap[id] = FocusNode());

          return _field(
            field.fieldName,
            false,
            Icons.description_outlined,
            controller: controller,
            focusNode: fn,
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
            rows.add(const SizedBox(height: rowSpacing));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Section: Lead Information
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLeadInformation(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        final cubit = context.read<AddLeadCubit>();
        final categoryNames = state.categories.map((e) => e.name).toList();
        final subCategoryName = state.subCategories.map((e) => e.name).toList();
        final sourceNames = state.sources.map((e) => e.name).toList();
        final stagesNames = state.stages.map((e) => e.name).toList();
        final staffList = state.staffList;
        final staffNames = staffList.map((s) => s.name).toList();

        const addCategory = '+ Add Category';
        const addSource = '+ Add Source';
        final categoryItems = [...categoryNames, addCategory];
        final sourceItems = [...sourceNames, addSource];

        if (_isEditMode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Dropdown(
                      label: 'Lead Category',
                      hint: 'Select Category',
                      items: categoryNames,
                      selectedValue: state.selectedCategory,
                      focusNode: _categoryFocus,
                      nextFocusNode: state.subCategories.isNotEmpty
                          ? _subCategoryFocus
                          : _sourceFocus,
                      onChanged: (v) => {
                        context.read<AddLeadCubit>().selectCategory(v),
                      },
                    ),
                  ),
                  if (state.subCategories.isNotEmpty) ...[
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: Dropdown(
                        label: 'Lead Sub Type',
                        hint: 'Select Lead Sub Type',
                        items: subCategoryName,
                        selectedValue: state.selectedSubCategory,
                        focusNode: _subCategoryFocus,
                        nextFocusNode: _sourceFocus,
                        onChanged: (v) =>
                            context.read<AddLeadCubit>().selectSubCategory(v),
                      ),
                    ),
                  ],
                  SizedBox(width: 1.5.w),
                  Expanded(
                    child: Dropdown(
                      label: 'Lead Source',
                      hint: 'Select Lead Source',
                      items: sourceNames,
                      selectedValue: state.selectedSource,
                      focusNode: _sourceFocus,
                      nextFocusNode: _priorityFocus,
                      onChanged: (v) =>
                          context.read<AddLeadCubit>().selectSource(v),
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Expanded(
                    child: Dropdown(
                      label: 'Priority',
                      hint: 'Priority',
                      items: priority,
                      selectedValue: state.selectedPriority,
                      focusNode: _priorityFocus,
                      nextFocusNode: _remarksFocus,
                      onChanged: (v) =>
                          context.read<AddLeadCubit>().selectPriority(v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _multilineField(
                'Remarks',
                Icons.description_outlined,
                controller: _remarksCtrl,
                focusNode: _remarksFocus,
                nextFocusNode: _submitFocus,
                hint: 'Enter remark',
              ),
            ],
          );
        }

        // Add Mode
        List<Widget> conditionalRowChildren = [];
        if (state.subCategories.isNotEmpty) {
          conditionalRowChildren.add(
            Expanded(
              child: Dropdown(
                label: 'Lead Sub Category',
                hint: 'select sub category',
                items: subCategoryName,
                selectedValue: state.selectedSubCategory,
                focusNode: _subCategoryFocus,
                nextFocusNode: _stageFocus,
                onChanged: (v) =>
                    context.read<AddLeadCubit>().selectSubCategory(v),
              ),
            ),
          );
        }

        // Lead Stage (Unconditional in the second row)
        if (conditionalRowChildren.isNotEmpty) {
          conditionalRowChildren.add(SizedBox(width: 1.5.w));
        }
        conditionalRowChildren.add(
          Expanded(
            child: Dropdown(
              icon: Icons.check_box_outlined,
              showIcon: true,
              items: stagesNames,
              selectedValue: _leadStage,
              showClear: false,
              focusNode: _stageFocus,
              nextFocusNode: _leadStage != 'NEW' && _leadStage != null
                  ? (state.leadTag.isNotEmpty ? _tagsFocus : _callResultFocus)
                  : _remarksFocus,
              onChanged: (v) {
                setState(() {
                  _leadStage = v;
                  _leadTag = null;
                  _callResult = null;
                });
                cubit.selectLeadStage(v);
                cubit.selectLeadTag(null);
                _buildOrderedNodes(cubit.state.additionalFields);
              },
              label: 'Lead Stage',
              hint: 'Select Stages',
            ),
          ),
        );

        if (_leadStage == 'FOLLOWUP') {
          if (conditionalRowChildren.isNotEmpty) {
            conditionalRowChildren.add(SizedBox(width: 1.5.w));
          }
          conditionalRowChildren.add(
            Expanded(child: _buildNextFollowUpDateField(context)),
          );
        }
        if (state.leadTag.isNotEmpty) {
          if (conditionalRowChildren.isNotEmpty) {
            conditionalRowChildren.add(SizedBox(width: 1.5.w));
          }
          conditionalRowChildren.add(
            Expanded(
              child: Dropdown(
                label: 'Tags',
                hint: 'Select Tags',
                showStar: true,
                focusNode: _tagsFocus,
                nextFocusNode: _callResultFocus,
                items: state.leadTag.map((e) => e.name).toList(),
                selectedValue: _leadTag,
                onChanged: (v) {
                  setState(() => _leadTag = v);
                  cubit.selectLeadTag(v);
                },
              ),
            ),
          );
        }
        if (_leadStage != 'NEW' && _leadStage != null) {
          if (conditionalRowChildren.isNotEmpty) {
            conditionalRowChildren.add(SizedBox(width: 1.5.w));
          }
          conditionalRowChildren.add(
            Expanded(
              child: Dropdown(
                label: 'Call Result',
                hint: 'Select Call Result',
                showStar: true,
                focusNode: _callResultFocus,
                nextFocusNode: _remarksFocus,
                items: const [
                  'Connected',
                  'Busy',
                  'Not Attended',
                  'Switched Off',
                  'Out Of Coverage',
                  'Wrong Number',
                  'Not Reachable',
                  'Other',
                ],
                selectedValue: _callResult,
                onChanged: (v) {
                  setState(() => _callResult = v);
                  cubit.selectCallResult(v);
                },
              ),
            ),
          );
        }

        if (conditionalRowChildren.isNotEmpty) {
          int row1ColumnsCount = 4;
          int activeFieldsCount =
              (state.subCategories.isNotEmpty ? 1 : 0) +
              1 +
              (_leadStage == 'FOLLOWUP' ? 1 : 0) +
              (state.leadTag.isNotEmpty ? 1 : 0) +
              ((_leadStage != 'NEW' && _leadStage != null) ? 1 : 0);
          int spacersNeeded = row1ColumnsCount - activeFieldsCount;
          for (int i = 0; i < spacersNeeded; i++) {
            conditionalRowChildren.add(SizedBox(width: 1.5.w));
            conditionalRowChildren.add(const Expanded(child: SizedBox()));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Staff, Category, Source, Priority, Stage
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentUser != null) ...[
                  if (_currentUser!.staffType != 'Admin')
                    Expanded(
                      child: _readOnlyField(
                        'Assign Staff',
                        Icons.person_outline,
                        state.assignedStaffName,
                      ),
                    )
                  else
                    Expanded(
                      child: Dropdown(
                        icon: Icons.person_outline,
                        showIcon: true,
                        items: staffNames,
                        selectedValue: _selectStaff,
                        focusNode: _assignStaffFocus,
                        nextFocusNode: _categoryFocus,
                        onChanged: (v) {
                          setState(() => _selectStaff = v);
                          final selected = staffList.firstWhere(
                            (e) => e.name == v,
                          );
                          cubit.selectAssignedStaff(
                            name: selected.name,
                            id: selected.id ?? '',
                          );
                        },
                        label: 'Select Staff',
                        hint: 'Select Staff',
                      ),
                    ),
                ],
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Dropdown(
                    label: 'Lead Category',
                    icon: Icons.layers_outlined,
                    showIcon: false,
                    items: categoryItems,
                    // selectedValue: _leadCategory,
                    selectedValue: state.selectedCategory,
                    focusNode: _categoryFocus,
                    nextFocusNode: state.subCategories.isNotEmpty
                        ? _subCategoryFocus
                        : _sourceFocus,
                    onChanged: (v) {
                      if (v == addCategory) {
                        _showAddCategoryDialog();
                      } else {
                        setState(() => _leadCategory = v);
                        cubit.selectCategory(v);
                        cubit.selectSubCategory(null);
                      }
                    },
                    // onTap: _showAddCategoryDialog,
                    hint: 'select category',
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Dropdown(
                    label: 'Lead Source',
                    showIcon: false,
                    icon: Icons.layers_rounded,
                    items: sourceItems,
                    // selectedValue: _leadSource,
                    selectedValue: state.selectedSource,
                    focusNode: _sourceFocus,
                    nextFocusNode: _priorityFocus,
                    onChanged: (v) {
                      if (v == addSource) {
                        _showAddSourceDialog();
                      } else {
                        setState(() => _leadSource = v);
                        cubit.selectSource(v);
                      }
                    },
                    // onTap: _showAddSourceDialog,
                    hint: 'Select Source',
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Dropdown(
                    icon: Icons.flag_outlined,
                    showIcon: true,
                    items: priority,
                    selectedValue: _leadPriority,
                    focusNode: _priorityFocus,
                    nextFocusNode: _stageFocus,
                    onChanged: (v) {
                      setState(() => _leadPriority = v);
                      cubit.selectPriority(v);
                    },
                    label: 'Priority',
                    hint: 'Select Priority',
                    showClear: false,
                  ),
                ),
              ],
            ),
            if (conditionalRowChildren.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: conditionalRowChildren,
              ),
            ],
            SizedBox(height: 2.h),
            _multilineField(
              'Remarks',
              Icons.note_alt_outlined,
              controller: _remarksCtrl,
              focusNode: _remarksFocus,
              nextFocusNode: _submitFocus,
              hint: 'Enter remark',
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextFollowUpDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Next Follow Up Date', true),
        SizedBox(height: 0.8.h),
        GestureDetector(
          onTap: () async {
            final result = await showCalendarDialogUsingTimePicker(
              context,
              initialDate: nextFollowUpDate,
              mode: CalendarMode.single,
              showTimePicker: true,
              minDate: calledDateValue,
            );
            if (result != null) {
              setState(() {
                nextFollowUpDate = result.from;
                nextFollowUpCtrl.text = DateFormat(
                  'dd-MM-yyyy hh:mm a',
                ).format(result.from);
              });
            }
          },
          child: Container(
            height: 5.h,
            padding: EdgeInsets.symmetric(horizontal: 1.2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                SizedBox(width: 0.5.w),
                Expanded(
                  child: Text(
                    nextFollowUpCtrl.text.isEmpty
                        ? 'Select Date'
                        : nextFollowUpCtrl.text,
                    style: AppTextStyle.body(
                      size: 11,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Submit Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(right: 2.w, bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Clear All Button
          OutlinedButton(
            onPressed: _clearForm,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
            ),
            child: Text(
              'Clear All',
              style: AppTextStyle.medium(
                size: 11.5,
                color: AppColors.red,
                weight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 1.w),
          // Save Lead / Update Button
          BlocBuilder<AddLeadCubit, AddLeadState>(
            buildWhen: (p, c) =>
                p.isSubmitting != c.isSubmitting ||
                p.isUpdating != c.isUpdating,
            builder: (context, state) {
              final isBusy = state.isSubmitting || state.isUpdating;
              return Focus(
                focusNode: _submitFocus,
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _submitFocus.hasFocus
                        ? AppThemeColors.primary
                        : AppThemeColors.basicGreen,
                    disabledBackgroundColor: AppThemeColors.basicGreen
                        .withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  icon: isBusy
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                  label: isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Update' : 'Save Lead',
                          style: AppTextStyle.medium(
                            size: 11.5,
                            color: AppColors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _fieldError(String? message) {
    if (message == null || message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 0.5.h, left: 2),
      child: Text(
        message,
        style: AppTextStyle.small(size: 10, color: AppColors.red),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────────

  // void _showAddCategoryDialog() {
  //   _dialogNameCtrl.clear();
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AppDialog(
  //       width: 35.w,
  //       title: 'Add Lead Category',
  //       body: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 0.5.w),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Lead Category', style: AppTextStyle.medium(size: 11.5)),
  //             SizedBox(height: 2.h),
  //             TextField(
  //               controller: _dialogNameCtrl,
  //               autofocus: true,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter Category',
  //                 hintStyle: AppTextStyle.medium(
  //                   size: 11.5,
  //                   color: AppColors.grey,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       // onSubmit: () async {
  //       //   final name = _dialogNameCtrl.text.trim();
  //       //   if (name.isEmpty) return;
  //       //   context.read<LeadCategoryCubit>().addCategory(name: name);
  //       //   setState(() => _leadCategory = name);
  //       //   context.read<AddLeadCubit>().selectCategory(name);
  //       //   Navigator.pop(ctx);
  //       //   ScaffoldMessenger.of(context).showSnackBar(
  //       //     SnackBar(
  //       //       content: Text('Category "$name" added.'),
  //       //       backgroundColor: AppColors.green,
  //       //       behavior: SnackBarBehavior.floating,
  //       //     ),
  //       //   );
  //       // },
  //       onSubmit: () async {
  //         final name = _dialogNameCtrl.text.trim();
  //         if (name.isEmpty) return;
  //         final normalized = name
  //             .toUpperCase(); // ← match what fromFirestore produces
  //         final newId = await context.read<LeadCategoryCubit>().addCategory(
  //           name: normalized,
  //         );
  //         setState(() => _leadCategory = normalized);
  //         // context.read<AddLeadCubit>().selectCategory(normalized);
  //         context.read<AddLeadCubit>().selectCategoryDirect(
  //           name: normalized,
  //           id: newId,
  //         );
  //         Navigator.pop(ctx);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Category "$normalized" added.'),
  //             backgroundColor: AppColors.green,
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  void _showAddCategoryDialog() {
    final importCubit = context.read<AddLeadCubit>();
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
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AppDialog(
  //       width: 35.w,
  //       title: 'Add Lead Source',
  //       body: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 0.5.w),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Lead Source', style: AppTextStyle.medium(size: 11.5)),
  //             SizedBox(height: 2.h),
  //             TextField(
  //               controller: _dialogNameCtrl,
  //               autofocus: true,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter Source',
  //                 hintStyle: AppTextStyle.medium(
  //                   size: 11.5,
  //                   color: AppColors.grey,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       onSubmit: () async {
  //         final name = _dialogNameCtrl.text.trim();
  //         if (name.isEmpty) return;
  //         final normalized = name.toUpperCase();
  //         final newId = await context.read<LeadSourceCubit>().addSource(
  //           name: normalized,
  //         );
  //         setState(() => _leadSource = normalized);
  //         context.read<AddLeadCubit>().selectSourceDirect(
  //           name: normalized,
  //           id: newId,
  //         );
  //         Navigator.pop(ctx);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Source "$normalized" added.'),
  //             backgroundColor: AppColors.green,
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  void _showAddSourceDialog() {
    final importCubit = context.read<AddLeadCubit>();
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Reusable field widgets
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _sectionCard(String title, Widget child, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      width: double.infinity,
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
      padding: EdgeInsets.all(2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyle.medium(
              size: 12.5,
              color: const Color(0xFF0F2C59),
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    bool required,
    IconData icons, {
    TextInputType? keyboardtype,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required),
        SizedBox(height: 0.8.h),
        SizedBox(
          height: 5.h,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            keyboardType: keyboardtype ?? TextInputType.text,
            inputFormatters: inputFormatters ?? [],
            textInputAction: nextFocusNode != null
                ? TextInputAction.next
                : TextInputAction.done,
            style: AppTextStyle.medium(
              size: 11.5,
              color: AppThemeColors.commonText,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                icons,
                size: 12.5,
                color: AppThemeColors.appPrimaryColor,
              ),
              hintText: hint ?? label,
              hintStyle: AppTextStyle.small(
                size: 11.5,
                color: AppThemeColors.hintColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 1.2.w,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppThemeColors.borderClr.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppThemeColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.red, width: 1.5),
              ),
            ),
            onFieldSubmitted: (_) {
              if (nextFocusNode != null) {
                nextFocusNode.requestFocus();
              } else {
                _focusNext(context);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, IconData icons, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false),
        SizedBox(height: 0.8.h),
        Container(
          height: 5.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(
              color: AppThemeColors.borderClr.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 1.2.w),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(icons, size: 12.5, color: const Color(0xFF64748B)),
              SizedBox(width: 0.5.w),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Loading...' : value,
                  style: value.isEmpty
                      ? AppTextStyle.small(
                          size: 11.5,
                          color: AppThemeColors.hintColor,
                        )
                      : AppTextStyle.body(
                          size: 11.5,
                          color: AppThemeColors.commonText,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phone field — pairs a dial-code picker with a text input.
  Widget _phoneField(
    String label,
    bool required,
    IconData icons, {
    TextEditingController? controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    void Function(String)? onDialCodeChanged,
    String? initialDialCode,
    String? hint,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required),
        SizedBox(height: 0.8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   height: 4.h,
            //   width: 42,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: AppColors.green, width: 1.0),
            //     borderRadius: BorderRadius.circular(8),
            //     color: Colors.white,
            //   ),
            //   // padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            //   child: CountryCodePicker(
            //     onChanged: (country) =>
            //         onDialCodeChanged?.call(country.dialCode ?? '+91'),
            //     initialSelection: initialDialCode ?? 'IN',
            //     showFlag: false,
            //     showCountryOnly: false,
            //     showOnlyCountryWhenClosed: false,
            //     alignLeft: false,
            //     padding: EdgeInsets.all(1),
            //     textStyle: AppTextStyle.body(
            //       size: 11.5,
            //       color: const Color(0xFF0F172A),
            //     ),
            //     flagWidth: 0,
            //     dialogBackgroundColor: AppColors.white,
            //     dialogSize: Size(30.w, 80.h),
            //     dialogTextStyle: AppTextStyle.body(size: 11.5),
            //     searchStyle: AppTextStyle.body(size: 11.5),
            //     searchDecoration: InputDecoration(
            //       hintText: 'Search country',
            //       hintStyle: AppTextStyle.small(
            //         size: 11.5,
            //         color: AppColors.grey,
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: const BorderSide(color: AppColors.divider),
            //       ),
            //       // contentPadding: EdgeInsets.all(1.w),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 0.5.w),
            Expanded(
              child: SizedBox(
                height: 5.h,
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTextStyle.body(
                    size: 11.5,
                    color: AppThemeColors.commonText,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  keyboardType: TextInputType.phone,
                  textInputAction: nextFocusNode != null
                      ? TextInputAction.next
                      : TextInputAction.done,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: hint ?? 'Enter number',
                    hintStyle: AppTextStyle.small(
                      size: 11.5,
                      color: AppThemeColors.hintColor,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 6),
                      child: CountryCodePicker(
                        onChanged: (country) =>
                            onDialCodeChanged?.call(country.dialCode ?? '+91'),
                        initialSelection: initialDialCode ?? 'IN',
                        showFlag: false,
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        padding: EdgeInsets.zero,
                        builder: (country) {
                          return Container(
                            height: 3.8.h,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  country?.dialCode ?? '+91',
                                  style: AppTextStyle.body(
                                    size: 11.5,
                                    color: const Color(0xFF0F172A),
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          );
                        },
                        dialogBackgroundColor: AppColors.white,
                        dialogSize: Size(30.w, 80.h),
                        dialogTextStyle: AppTextStyle.body(size: 11.5),
                        searchStyle: AppTextStyle.body(size: 11.5),
                        searchDecoration: InputDecoration(
                          hintText: 'Search country',
                          hintStyle: AppTextStyle.small(
                            size: 11.5,
                            color: AppThemeColors.hintColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppThemeColors.borderClr.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child:
                          suffixIcon ??
                          Icon(icons, size: 15, color: const Color(0xFF64748B)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppThemeColors.borderClr.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppThemeColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    if (nextFocusNode != null) {
                      nextFocusNode.requestFocus();
                    } else {
                      _focusNext(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Multiline text field — Tab moves focus, Enter inserts a newline (correct
  /// for address / remarks). Shift+Enter still moves backwards via the
  /// Shortcuts ancestor.
  Widget _multilineField(
    String label,
    IconData icons, {
    TextEditingController? controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false),
        SizedBox(height: 0.8.h),
        Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter):
                DoNothingAndStopPropagationTextIntent(),
          },
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            style: AppTextStyle.body(
              size: 11.5,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(
                  icons,
                  size: 12.5,
                  color: AppThemeColors.appPrimaryColor,
                ),
              ),
              hintText: hint ?? label,
              hintStyle: AppTextStyle.small(
                size: 11.5,
                color: AppThemeColors.hintColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 1.2.w,
                vertical: 1.5.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppThemeColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, bool required) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTextStyle.medium(
            size: 11.5,
            color: const Color(0xFF1E293B),
            weight: FontWeight.w500,
          ),
        ),
        if (required)
          Text(
            '*',
            style: AppTextStyle.medium(
              size: 11.5,
              color: AppColors.red,
              weight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  // Widget _buildHeader() {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2.h),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       border: Border(bottom: BorderSide(color: AppColors.divider)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           _isEditMode ? 'EDIT LEAD' : 'ADD NEW LEAD',
  //           style: AppTextStyle.medium(
  //             size: 13.5,
  //             color: AppColors.black.withOpacity(0.77),
  //             weight: FontWeight.w700,
  //           ),
  //         ),
  //         Row(
  //           children: [
  //             Row(
  //               children: [
  //                 Text('Lead Management', style: AppTextStyle.medium()),
  //                 Icon(Icons.chevron_right, size: 16.5),
  //                 Text(
  //                   _isEditMode ? 'Edit Lead' : 'Add Lead',
  //                   style: AppTextStyle.medium(color: AppColors.grey),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(width: 1.w),
  //             MenuHoverButton(),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showDuplicateAlert(String message) {
    final isWhatsapp = message.toLowerCase().contains('whatsapp');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isWhatsapp ? 'Duplicate WhatsApp' : 'Duplicate Contact',
              style: AppTextStyle.medium(size: 13.5, weight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: AppTextStyle.medium(size: 11.5)),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isWhatsapp
                          ? 'Please use a different WhatsApp number or update the existing lead.'
                          : 'Please use a different contact number or update the existing lead instead.',
                      style: AppTextStyle.medium(
                        size: 10.5,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: AppTextStyle.medium(size: 11.5, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomDropdown / CustomDropdownWithAdd
// ─────────────────────────────────────────────────────────────────────────────

class _CustomDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final bool showIcon;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final bool enabled;
  final bool showStar;
  final bool showClear;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const _CustomDropdown({
    required this.label,
    required this.hint,
    this.showIcon = false,
    this.items = const [],
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.showStar = false,
    this.icon = Icons.person_outline,
    this.focusNode,
    this.nextFocusNode,
    this.showClear = true,
  });

  @override
  State<_CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<_CustomDropdown> {
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _popupSearchFocusNode;
  bool _hasFocus = false;
  bool _popupOpen = false;
  final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

  String get _searchText => _searchController.text;

  List<String> _filteredItems(String filter) {
    return widget.items
        .where(
          (item) =>
              filter.isEmpty ||
              item.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _popupSearchFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        return _handlePopupNavKey(event);
      },
    );
    _searchController.addListener(() {
      final visible = _filteredItems(_searchController.text);
      final newIdx = visible.isEmpty ? -1 : 0;
      if (_highlightedIndexNotifier.value != newIdx) {
        _highlightedIndexNotifier.value = newIdx;
      }
    });
  }

  @override
  void dispose() {
    _highlightedIndexNotifier.dispose();
    _popupSearchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (_popupOpen) return;
    _searchController.clear();
    final visible = _filteredItems('');
    final preselect = widget.selectedValue != null
        ? visible.indexOf(widget.selectedValue!)
        : -1;
    setState(() => _popupOpen = true);
    _highlightedIndexNotifier.value = preselect >= 0
        ? preselect
        : (visible.isEmpty ? -1 : 0);
    _dropdownKey.currentState?.openDropDownSearch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _popupSearchFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    _dropdownKey.currentState?.closeDropDownSearch();
  }

  void _selectHighlighted() {
    final visible = _filteredItems(_searchText);
    if (_highlightedIndexNotifier.value >= 0 &&
        _highlightedIndexNotifier.value < visible.length) {
      final selected = visible[_highlightedIndexNotifier.value];
      _closeDropdown();
      widget.onChanged?.call(selected);
      if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      }
    }
  }

  KeyEventResult _handleOuterKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_popupOpen) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _openDropdown();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        final shift = HardwareKeyboard.instance.isShiftPressed;
        if (shift) {
          node.previousFocus();
        } else if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        } else {
          node.nextFocus();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return _handlePopupNavKey(event);
  }

  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final visible = _filteredItems(_searchText);
    final count = visible.length;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value - 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _selectHighlighted();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _closeDropdown();
      final shift = HardwareKeyboard.instance.isShiftPressed;
      if (shift) {
        widget.focusNode?.previousFocus();
      } else if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      } else {
        widget.focusNode?.nextFocus();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _wrapWithTooltip({required Widget child, required String? message}) {
    if (message == null || message.isEmpty) {
      return child;
    }
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: AppTextStyle.small(size: 10.5, color: Colors.white),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AppTextStyle.medium(
                size: 11.5,
                color: const Color(0xFF1E293B),
                weight: FontWeight.w500,
              ),
            ),
            if (widget.showStar)
              Text(
                '*',
                style: AppTextStyle.medium(
                  size: 11.5,
                  color: AppColors.red,
                  weight: FontWeight.w600,
                ),
              ),
          ],
        ),
        SizedBox(height: 0.8.h),
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          onKeyEvent: _handleOuterKeyEvent,
          child: _wrapWithTooltip(
            message: widget.selectedValue,
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _hasFocus
                      ? AppThemeColors.primary
                      : const Color(0xFFCBD5E1),
                  width: _hasFocus ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownSearch<String>(
                      key: _dropdownKey,
                      enabled: widget.enabled,
                      items: (filter, _) => _filteredItems(filter),
                      selectedItem: widget.selectedValue,
                      itemAsString: (item) => item,
                      dropdownBuilder: (context, selectedItem) {
                        if (selectedItem == null) {
                          return Row(
                            children: [
                              if (widget.showIcon) ...[
                                Icon(
                                  widget.icon,
                                  size: 12.5,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6.0),
                              ],
                              Expanded(
                                child: Text(
                                  widget.hint,
                                  style: AppTextStyle.small(
                                    size: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            if (widget.showIcon) ...[
                              Icon(
                                widget.icon,
                                size: 12.5,
                                color: const Color(0xFF64748B),
                              ),
                              // SizedBox(width: 0.5.w),
                            ],
                            Expanded(
                              child: Text(
                                selectedItem,
                                style: AppTextStyle.medium(
                                  size: 11.5,
                                  weight: FontWeight.w400,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                      suffixProps: DropdownSuffixProps(
                        dropdownButtonProps: DropdownButtonProps(
                          constraints:
                              (widget.showClear && widget.selectedValue != null)
                              ? const BoxConstraints.tightFor(
                                  width: 0,
                                  height: 0,
                                )
                              : const BoxConstraints(),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          iconClosed:
                              (widget.showClear && widget.selectedValue != null)
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF64748B),
                                    size: 15,
                                  ),
                                ),
                          iconOpened:
                              (widget.showClear && widget.selectedValue != null)
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        scrollbarProps: ScrollbarProps(
                          thumbVisibility: true,
                          thickness: 6,
                          trackVisibility: true,
                          thumbColor: AppColors.grey,
                          interactive: true,
                        ),
                        showSearchBox: true,
                        showSelectedItems: true,
                        fit: FlexFit.loose,
                        constraints: const BoxConstraints(maxHeight: 200),
                        onDismissed: () {
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() => _popupOpen = false);
                            _highlightedIndexNotifier.value = -1;
                            _searchController.clear();
                          });
                        },
                        itemBuilder: (context, item, isDisabled, isSelected) {
                          final visible = _filteredItems(_searchText);
                          final currentIndex = visible.indexOf(item);
                          return ValueListenableBuilder<int>(
                            valueListenable: _highlightedIndexNotifier,
                            builder: (_, highlightedIndex, __) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                color: isSelected
                                    ? AppThemeColors.primary
                                    : (currentIndex == highlightedIndex
                                          ? AppThemeColors.primary.withOpacity(
                                              0.12,
                                            )
                                          : Colors.white),
                                child: Text(
                                  item,
                                  style: AppTextStyle.medium(
                                    size: 11.5,
                                    weight: FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        menuProps: MenuProps(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        searchFieldProps: TextFieldProps(
                          focusNode: _popupSearchFocusNode,
                          controller: _searchController,
                          style: AppTextStyle.small(
                            size: 11.5,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: AppTextStyle.small(
                              size: 11.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _popupOpen = false);
                          _highlightedIndexNotifier.value = -1;
                          _searchController.clear();
                          widget.onChanged?.call(value);
                          if (widget.nextFocusNode != null) {
                            widget.nextFocusNode!.requestFocus();
                          }
                        });
                      },
                    ),
                  ),
                  if (widget.selectedValue != null && widget.showClear == true)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0, left: 2.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          onPressed: () => widget.onChanged?.call(null),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomDropdownWithAdd extends StatefulWidget {
  final String label;
  final String hint;
  final bool showIcon;
  final IconData? icon;
  final List<String> items;
  final String? selectedValue;
  final VoidCallback onTap;
  final Function(String?) onChanged;
  final bool showStar;
  final bool showClear;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const _CustomDropdownWithAdd({
    required this.label,
    required this.hint,
    this.showIcon = false,
    this.icon,
    required this.items,
    required this.onTap,
    required this.selectedValue,
    required this.onChanged,
    this.showStar = false,
    this.showClear = true,
    this.focusNode,
    this.nextFocusNode,
  });

  @override
  State<_CustomDropdownWithAdd> createState() => _CustomDropdownWithAddState();
}

class _CustomDropdownWithAddState extends State<_CustomDropdownWithAdd> {
  final _dropdownKey = GlobalKey<DropdownSearchState<String>>();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _popupSearchFocusNode;
  bool _hasFocus = false;
  bool _popupOpen = false;
  final ValueNotifier<int> _highlightedIndexNotifier = ValueNotifier<int>(-1);

  String get _searchText => _searchController.text;

  List<String> _filteredItems(String filter) {
    final list = List<String>.from(widget.items);
    if (widget.selectedValue != null && !list.contains(widget.selectedValue)) {
      list.add(widget.selectedValue!);
    }
    return list
        .where(
          (item) =>
              filter.isEmpty ||
              item.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _popupSearchFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        return _handlePopupNavKey(event);
      },
    );
    _searchController.addListener(() {
      final visible = _filteredItems(_searchController.text);
      final newIdx = visible.isEmpty ? -1 : 0;
      if (_highlightedIndexNotifier.value != newIdx) {
        _highlightedIndexNotifier.value = newIdx;
      }
    });
  }

  @override
  void dispose() {
    _highlightedIndexNotifier.dispose();
    _popupSearchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (_popupOpen) return;
    _searchController.clear();
    final visible = _filteredItems('');
    final preselect = widget.selectedValue != null
        ? visible.indexOf(widget.selectedValue!)
        : -1;
    setState(() => _popupOpen = true);
    _highlightedIndexNotifier.value = preselect >= 0
        ? preselect
        : (visible.isEmpty ? -1 : 0);
    _dropdownKey.currentState?.openDropDownSearch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _popupSearchFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    _dropdownKey.currentState?.closeDropDownSearch();
  }

  void _selectHighlighted() {
    final visible = _filteredItems(_searchText);
    if (_highlightedIndexNotifier.value >= 0 &&
        _highlightedIndexNotifier.value < visible.length) {
      final selected = visible[_highlightedIndexNotifier.value];
      _closeDropdown();
      widget.onChanged(selected);
      if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      }
    }
  }

  KeyEventResult _handleOuterKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_popupOpen) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _openDropdown();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        final shift = HardwareKeyboard.instance.isShiftPressed;
        if (shift) {
          node.previousFocus();
        } else if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        } else {
          node.nextFocus();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return _handlePopupNavKey(event);
  }

  KeyEventResult _handlePopupNavKey(KeyEvent event) {
    final visible = _filteredItems(_searchText);
    final count = visible.length;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value + 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (count > 0) {
        _highlightedIndexNotifier.value = (_highlightedIndexNotifier.value - 1)
            .clamp(0, count - 1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _selectHighlighted();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _closeDropdown();
      final shift = HardwareKeyboard.instance.isShiftPressed;
      if (shift) {
        widget.focusNode?.previousFocus();
      } else if (widget.nextFocusNode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.nextFocusNode!.requestFocus();
        });
      } else {
        widget.focusNode?.nextFocus();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _wrapWithTooltip({required Widget child, required String? message}) {
    if (message == null || message.isEmpty) {
      return child;
    }
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: AppTextStyle.small(size: 10.5, color: Colors.white),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AppTextStyle.medium(
                size: 11.5,
                color: const Color(0xFF1E293B),
                weight: FontWeight.w500,
              ),
            ),
            if (widget.showStar)
              Text(
                '*',
                style: AppTextStyle.medium(
                  size: 11.5,
                  color: AppColors.red,
                  weight: FontWeight.w600,
                ),
              ),
          ],
        ),
        SizedBox(height: 0.8.h),
        Focus(
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          onKeyEvent: _handleOuterKeyEvent,
          child: _wrapWithTooltip(
            message: widget.selectedValue,
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _hasFocus
                      ? AppThemeColors.primary
                      : const Color(0xFFCBD5E1),
                  width: _hasFocus ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppThemeColors.basicGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  // SizedBox(width: 0.5.w),
                  Expanded(
                    child: DropdownSearch<String>(
                      key: _dropdownKey,
                      items: (filter, _) => _filteredItems(filter),
                      selectedItem: widget.selectedValue,
                      itemAsString: (item) => item,
                      dropdownBuilder: (context, selectedItem) {
                        if (selectedItem == null) {
                          return Row(
                            children: [
                              if (widget.showIcon && widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  size: 12.5,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6.0),
                              ],
                              Expanded(
                                child: Text(
                                  widget.hint,
                                  style: AppTextStyle.small(
                                    size: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            if (widget.showIcon && widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: 12.5,
                                color: const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6.0),
                            ],
                            Expanded(
                              child: Text(
                                selectedItem,
                                style: AppTextStyle.medium(
                                  size: 11.5,
                                  weight: FontWeight.w400,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                      suffixProps: DropdownSuffixProps(
                        dropdownButtonProps: DropdownButtonProps(
                          constraints:
                              (widget.showClear && widget.selectedValue != null)
                              ? const BoxConstraints.tightFor(
                                  width: 0,
                                  height: 0,
                                )
                              : const BoxConstraints(),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          iconClosed:
                              (widget.showClear && widget.selectedValue != null)
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(right: 1),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                          iconOpened:
                              (widget.showClear && widget.selectedValue != null)
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(right: 1),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        scrollbarProps: ScrollbarProps(
                          thumbVisibility: true,
                          thickness: 6,
                          trackVisibility: true,
                          thumbColor: AppColors.grey,
                          interactive: true,
                        ),
                        showSearchBox: true,
                        showSelectedItems: true,
                        fit: FlexFit.loose,
                        constraints: const BoxConstraints(maxHeight: 200),
                        onDismissed: () {
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() => _popupOpen = false);
                            _highlightedIndexNotifier.value = -1;
                            _searchController.clear();
                          });
                        },
                        itemBuilder: (context, item, isDisabled, isSelected) {
                          final visible = _filteredItems(_searchText);
                          final currentIndex = visible.indexOf(item);
                          return ValueListenableBuilder<int>(
                            valueListenable: _highlightedIndexNotifier,
                            builder: (_, highlightedIndex, __) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                color: isSelected
                                    ? AppThemeColors.primary
                                    : (currentIndex == highlightedIndex
                                          ? AppThemeColors.primary.withOpacity(
                                              0.12,
                                            )
                                          : Colors.white),
                                child: Text(
                                  item,
                                  style: AppTextStyle.medium(
                                    size: 11.5,
                                    weight: FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        menuProps: MenuProps(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        searchFieldProps: TextFieldProps(
                          focusNode: _popupSearchFocusNode,
                          controller: _searchController,
                          style: AppTextStyle.small(
                            size: 11.5,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: AppTextStyle.small(
                              size: 11.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 8,
                            top: 6,
                            bottom: 6,
                            // horizontal: 8,
                            // vertical: 6,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _popupOpen = false);
                          _highlightedIndexNotifier.value = -1;
                          _searchController.clear();
                          widget.onChanged(value);
                          if (widget.nextFocusNode != null) {
                            widget.nextFocusNode!.requestFocus();
                          }
                        });
                      },
                    ),
                  ),
                  if (widget.selectedValue != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onChanged(null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomCalendarPickOne — unchanged from original
// ─────────────────────────────────────────────────────────────────────────────

class CustomCalendarPickOne extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;

  const CustomCalendarPickOne({
    super.key,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<CustomCalendarPickOne> createState() => _CustomCalendarPickOneState();
}

class _CustomCalendarPickOneState extends State<CustomCalendarPickOne> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  void _prevMonth() => setState(
    () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1),
  );

  void _nextMonth() => setState(
    () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1),
  );

  List<DateTime?> _buildDayCells() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final leadingBlanks = firstDay.weekday % 7;
    final cells = <DateTime?>[];
    for (int i = 0; i < leadingBlanks; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    return cells;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) =>
      _selectedDate != null &&
      date.year == _selectedDate!.year &&
      date.month == _selectedDate!.month &&
      date.day == _selectedDate!.day;

  @override
  Widget build(BuildContext context) {
    final cells = _buildDayCells();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeColors.primary,
                  AppThemeColors.primary.withOpacity(0.75),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: Icon(
                    Icons.chevron_left,
                    size: 12.5,
                    color: Colors.white,
                  ),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Column(
                  children: [
                    Text(
                      _months[_focusedMonth.month - 1],
                      style: AppTextStyle.medium(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_focusedMonth.year}',
                      style: AppTextStyle.small(
                        size: 9.5,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    Icons.chevron_right,
                    size: 12.5,
                    color: Colors.white,
                  ),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: _weekDays.map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: AppTextStyle.small(
                            size: 8.5,
                            weight: FontWeight.w700,
                            color: AppThemeColors.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 0.5.h),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.3,
                  children: cells.map((date) {
                    if (date == null) return const SizedBox.shrink();
                    final selected = _isSelected(date);
                    final today = _isToday(date);
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = date);
                        widget.onDateSelected(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppThemeColors.primary
                              : today
                              ? AppThemeColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: AppTextStyle.small(
                              size: 8.5,
                              weight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? Colors.white
                                  : today
                                  ? AppThemeColors.primary
                                  : AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 0.5.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.w,
                        vertical: 0.3.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      final today = DateTime.now();
                      setState(() {
                        _selectedDate = today;
                        _focusedMonth = today;
                      });
                      widget.onDateSelected(today);
                    },
                    child: Text(
                      'Today',
                      style: AppTextStyle.small(
                        size: 9.5,
                        color: AppThemeColors.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
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
