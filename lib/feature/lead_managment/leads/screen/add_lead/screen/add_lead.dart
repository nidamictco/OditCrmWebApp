// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:oxdo/core/shared_preference/session_service.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/core/utils/dropdown.dart';
// import 'package:oxdo/core/utils/menu_hover_bottun.dart';
// import 'package:oxdo/core/utils/popup_msg.dart';
// import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
// import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
// import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
// import 'package:oxdo/core/utils/dropdown_with_add.dart';
// import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
// import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
// import 'package:oxdo/feature/sidebar/main_screen.dart';
// import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
// import 'package:sizer/sizer.dart';
//
// class AddLeadPage extends StatefulWidget {
//   final AddLeadModel? lead;
//   const AddLeadPage({super.key, this.lead});
//
//   @override
//   State<AddLeadPage> createState() => _AddLeadPageState();
// }
//
// class _AddLeadPageState extends State<AddLeadPage> {
//   // ── Standard Controllers ───────────────────────────────────────────────────
//   final TextEditingController _clientNameCtrl = TextEditingController();
//   final TextEditingController _contactCtrl = TextEditingController();
//   final TextEditingController _whatsappCtrl = TextEditingController();
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _addressCtrl = TextEditingController();
//   final TextEditingController _pinCtrl = TextEditingController();
//   final TextEditingController _postOfficeCtrl = TextEditingController();
//   final TextEditingController _remarksCtrl = TextEditingController();
//   final TextEditingController _dialogNameCtrl = TextEditingController();
//   final TextEditingController nextFollowUpCtrl = TextEditingController(
//     text: DateFormat(
//       'dd-MM-yyyy',
//     ).format(DateTime.now().add(const Duration(days: 1))),
//   );
//   DateTime nextFollowUpDate = DateTime.now().add(const Duration(days: 1));
//   DateTime calledDateValue = DateTime.now();
//
//   String? _leadStage;
//   String? _leadSource;
//   String? _leadCategory;
//   String? _leadPriority;
//   String? _callResult;
//   String? _leadTag;
//   String? _selectStaff;
//
//   // ── Additional field controllers — keyed by AdditionalFieldModel.id ────────
//   final Map<String, TextEditingController> _additionalCtrlMap = {};
//
//   // Dial codes
//   String _contactDialCode = '+91';
//   String _whatsappDialCode = '+91';
//
//   final _formKey = GlobalKey<FormState>();
//
//   final List<String> priority = ['High', 'Low', 'Negative', 'Normal'];
//
//   final Map<String, List<String>> stateDistrictMap = {
//     'Kerala': [
//       'Ernakulam',
//       'Kottayam',
//       'Kozhikode',
//       'Thiruvananthapuram',
//       'Thrissur',
//       'Malappuram',
//       'Palakkad',
//       'Kollam',
//       'Alappuzha',
//       'Kannur',
//       'Kasaragod',
//       'Wayanad',
//       'Idukki',
//       'Pathanamthitta',
//     ],
//     'Tamil Nadu': ['Chennai', 'Madurai', 'Coimbatore', 'Salem'],
//     'Arunachal Pradesh': ['Tawang', 'Papum Pare', 'West Kameng'],
//     'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi'],
//     'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
//   };
//
//   bool get _isEditMode => widget.lead != null;
//
//   // ── Lifecycle ──────────────────────────────────────────────────────────────
//   StaffModel? _currentUser;
//
//   Future<void> _loadCurrentUser() async {
//     final user = await SessionService().getSavedUser();
//     setState(() {
//       _currentUser = user;
//       if (user != null && user.staffType == 'Admin') {
//         _selectStaff = user.name;
//       }
//     });
//
//     if (user != null && user.staffType != 'Admin') {
//       context.read<AddLeadCubit>().selectAssignedStaff(
//         name: user.name ?? '',
//         id: user.id ?? '',
//       );
//     }
//
//     // ✅ FIX: admin default — also seed their own id as default selection
//     if (user != null && user.staffType == 'Admin') {
//       context.read<AddLeadCubit>().selectAssignedStaff(
//         name: user.name ?? '',
//         id: user.id ?? '',
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     context.read<AddLeadCubit>().initialize();
//     context.read<AddLeadCubit>().fetchStaff();
//     // if (_isEditMode) _prefillIfEditing(widget.lead!);
//     if (_isEditMode) {
//       _prefillIfEditing(widget.lead!);
//     } else {
//       _leadPriority = 'Normal';
//       _leadStage = 'NEW';
//     }
//   }
//
//   void _prefillIfEditing(AddLeadModel lead) {
//     _clientNameCtrl.text = lead.clientName;
//     _contactCtrl.text = lead.contactNumber;
//     _whatsappCtrl.text = lead.whatsappNumber;
//     _emailCtrl.text = lead.email;
//     _addressCtrl.text = lead.address;
//     _pinCtrl.text = lead.pinCode;
//     _postOfficeCtrl.text = lead.postOffice;
//     _remarksCtrl.text = lead.remarks;
//     _leadStage = lead.leadStage;
//     _leadSource = lead.leadSource;
//     _leadCategory = lead.leadCategory;
//     _leadPriority = lead.priority;
//     nextFollowUpDate =
//         lead.followUpDate ?? DateTime.now().add(const Duration(days: 1));
//     nextFollowUpCtrl.text = DateFormat('dd-MM-yyyy').format(nextFollowUpDate);
//
//     // // Pre-select state and district in cubit
//     // if (lead.state.isNotEmpty) {
//     //   context.read<AddLeadCubit>().selectState(lead.state);
//     // }
//     // if (lead.district.isNotEmpty) {
//     //   context.read<AddLeadCubit>().selectDistrict(lead.district);
//     // }
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final cubit = context.read<AddLeadCubit>();
//
//       if (lead.state.isNotEmpty) cubit.selectState(lead.state);
//       if (lead.district.isNotEmpty) cubit.selectDistrict(lead.district);
//
//       // ✅ These three were missing — edit mode dropdowns read from cubit state
//       if (lead.leadCategory.isNotEmpty) cubit.selectCategory(lead.leadCategory);
//       if (lead.leadSource.isNotEmpty) cubit.selectSource(lead.leadSource);
//       if (lead.priority.isNotEmpty) cubit.selectPriority(lead.priority);
//     });
//   }
//
//   void _syncAdditionalControllers(List<dynamic> fields) {
//     final incomingIds = fields.map((f) => f.id as String).toSet();
//
//     // Remove stale controllers
//     _additionalCtrlMap.keys
//         .where((id) => !incomingIds.contains(id))
//         .toList()
//         .forEach((id) {
//           _additionalCtrlMap.remove(id)?.dispose();
//         });
//
//     // Add new ones
//     for (final field in fields) {
//       final id = field.id as String;
//       _additionalCtrlMap.putIfAbsent(id, () => TextEditingController());
//     }
//   }
//
//   @override
//   void dispose() {
//     _clientNameCtrl.dispose();
//     _contactCtrl.dispose();
//     _whatsappCtrl.dispose();
//     _emailCtrl.dispose();
//     _addressCtrl.dispose();
//     _pinCtrl.dispose();
//     _postOfficeCtrl.dispose();
//     _remarksCtrl.dispose();
//     _dialogNameCtrl.dispose();
//     nextFollowUpCtrl.dispose();
//     for (final c in _additionalCtrlMap.values) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ── Submit ─────────────────────────────────────────────────────────────────
//
//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;
//     final email = _emailCtrl.text.trim();
//   final contact = _contactCtrl.text.trim();
//   final whatsapp = _whatsappCtrl.text.trim();
//
//   // Email validation
//   if (email.isNotEmpty) {
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(email)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Enter a valid email address.'),
//           backgroundColor: AppColors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//   }
//
//   // Contact number validation
// if (contact.isNotEmpty) {
//   final phoneRegex = _contactDialCode == '+91'
//       ? RegExp(r'^[0-9]{10}$')        // India: exactly 10 digits
//       : RegExp(r'^[0-9]{6,15}$');     // Others: 6–15 digits
//   if (!phoneRegex.hasMatch(contact)) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _contactDialCode == '+91'
//               ? 'Indian contact number must be exactly 10 digits.'
//               : 'Enter a valid contact number.',
//         ),
//         backgroundColor: AppColors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//     return;
//   }
// }
//
// // WhatsApp number validation
// if (whatsapp.isNotEmpty) {
//   final phoneRegex = _whatsappDialCode == '+91'
//       ? RegExp(r'^[0-9]{10}$')
//       : RegExp(r'^[0-9]{6,15}$');
//   if (!phoneRegex.hasMatch(whatsapp)) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _whatsappDialCode == '+91'
//               ? 'Indian WhatsApp number must be exactly 10 digits.'
//               : 'Enter a valid WhatsApp number.',
//         ),
//         backgroundColor: AppColors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//     return;
//   }
// }
//
//   final pinCode = _pinCtrl.text.trim();
// if (pinCode.isNotEmpty) {
//   final pinRegex = RegExp(r'^[0-9]{6}$');
//   if (!pinRegex.hasMatch(pinCode)) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Pin code must be a 6-digit number.'),
//         backgroundColor: AppColors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//     return;
//   }
// }
//
//
//     final cubit = context.read<AddLeadCubit>();
//     final state = cubit.state;
//
//     final additionalValues = <String, String>{};
//     for (final field in state.additionalFields) {
//       final id = field.id;
//       if (id != null) {
//         additionalValues[field.fieldName] =
//             _additionalCtrlMap[id]?.text.trim() ?? '';
//       }
//     }
//
//     if (_isEditMode) {
//       final updated = widget.lead!.copyWith(
//         clientName: _clientNameCtrl.text,
//         contactNumber: _contactCtrl.text,
//         contactDialCode: _contactDialCode,
//         whatsappNumber: _whatsappCtrl.text,
//         whatsappDialCode: _whatsappDialCode,
//         email: _emailCtrl.text,
//         address: _addressCtrl.text,
//         pinCode: _pinCtrl.text,
//         postOffice: _postOfficeCtrl.text,
//         remarks: _remarksCtrl.text,
//         leadCategory: state.selectedCategory ?? widget.lead!.leadCategory,
//         leadSource: state.selectedSource ?? widget.lead!.leadSource,
//         priority: state.selectedPriority ?? widget.lead!.priority,
//         leadStage: _leadStage ?? widget.lead!.leadStage,
//         state: state.selectedState ?? widget.lead!.state,
//         district: state.selectedDistrict ?? widget.lead!.district,
//         additionalFields: additionalValues.isNotEmpty
//             ? additionalValues
//             : widget.lead!.additionalFields,
//         callResult: state.selectedCallResult ?? widget.lead!.callResult,
//         leadTag: state.selectedLeadTag ?? widget.lead!.leadTag,
//         followUpDate: nextFollowUpDate,
//
//         // calledDate: state.selectedCalledDate ?? widget.lead!.calledDate,
//       );
//       cubit.updateLead(widget.lead!.id!, updated);
//     } else {
//       cubit.submitLead(
//         clientName: _clientNameCtrl.text,
//         contactNumber: _contactCtrl.text,
//         contactDialCode: _contactDialCode,
//         whatsappNumber: _whatsappCtrl.text,
//         whatsappDialCode: _whatsappDialCode,
//         email: _emailCtrl.text,
//         address: _addressCtrl.text,
//         pinCode: _pinCtrl.text,
//         postOffice: _postOfficeCtrl.text,
//         remarks: _remarksCtrl.text,
//         nextFollowUpDate: nextFollowUpDate,
//         additionalFieldValues: additionalValues,
//       );
//     }
//
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 2)),
//     // );
//   }
//
//   void _clearForm() {
//     _clientNameCtrl.clear();
//     _contactCtrl.clear();
//     _whatsappCtrl.clear();
//     _emailCtrl.clear();
//     _addressCtrl.clear();
//     _pinCtrl.clear();
//     _postOfficeCtrl.clear();
//     _remarksCtrl.clear();
//
//     for (final c in _additionalCtrlMap.values) {
//       c.clear();
//     }
//
//     //  local state variables
//     setState(() {
//       _leadCategory = null;
//       _leadSource = null;
//       _leadStage = null;
//       _leadPriority = null;
//       _contactDialCode = '+91';
//       _whatsappDialCode = '+91';
//     });
//
//     // dropdowns read from state, not local vars
//     final cubit = context.read<AddLeadCubit>();
//     cubit.selectCategory(null);
//     cubit.selectSource(null);
//     cubit.selectLeadStage(null);
//     cubit.selectPriority(null);
//     cubit.selectState(null);
//     cubit.selectDistrict(null);
//     cubit.selectCallResult(null);
//   }
//
//   // ── Build ──────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AddLeadCubit, AddLeadState>(
//       listenWhen: (prev, cur) =>
//           cur.errorMessage != prev.errorMessage ||
//           cur.successMessage != prev.successMessage ||
//           cur.additionalFields != prev.additionalFields ||
//           cur.isUpdating != prev.isUpdating,
//       listener: (context, state) {
//         if (state.additionalFields.isNotEmpty) {
//           _syncAdditionalControllers(state.additionalFields);
//         }
//
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: AppColors.red,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//
//         if (state.successMessage != null) {
//           if (_isEditMode) {
//             // ✅ navigate after update confirmed
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MainScreen(selectedIndex: 2),
//               ),
//             );
//           } else {
//             // ✅ navigate after add confirmed, then fetch fresh list
//             context.read<AddLeadCubit>().fetchLeads();
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MainScreen(selectedIndex: 2),
//               ),
//             );
//           }
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SizedBox(height: 2.h),
//
//                     // ── Customer Details ──────────────────────────────────
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 2.w),
//                       child: _sectionCard(
//                         'Customer Details',
//                         Form(key: _formKey, child: _buildCustomerDetails()),
//                         Symbols.person,
//                       ),
//                     ),
//
//                     // ── Additional Details (only if fields exist) ─────────
//                     BlocBuilder<AddLeadCubit, AddLeadState>(
//                       buildWhen: (p, c) =>
//                           p.additionalFields != c.additionalFields ||
//                           p.isLoadingAdditionalFields !=
//                               c.isLoadingAdditionalFields,
//                       builder: (context, state) {
//                         if (state.isLoadingAdditionalFields) {
//                           return Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 2.w),
//                             child: _sectionCard(
//                               'Additional Details',
//                               SizedBox(
//                                 height: 8.h,
//                                 child: const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               ),
//                               Icons.add_circle_outline_rounded,
//                             ),
//                           );
//                         }
//
//                         if (state.additionalFields.isEmpty) {
//                           return const SizedBox.shrink();
//                         }
//
//                         return Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 2.w),
//                           child: _sectionCard(
//                             'Additional Details',
//                             _buildAdditionalDetails(state),
//                             Icons.add_circle_outline_rounded,
//                           ),
//                         );
//                       },
//                     ),
//
//                     SizedBox(height: 2.h),
//
//                     // ── Lead Information ──────────────────────────────────
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 2.w),
//                       child: _sectionCard(
//                         'Lead Information',
//                         _buildLeadInformation(context),
//                         Symbols.info,
//                       ),
//                     ),
//
//                     // ── Submit Button ─────────────────────────────────────
//                     _buildSubmitButton(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Section: Additional Details ────────────────────────────────────────────
//
//   Widget _buildAdditionalDetails(AddLeadState state) {
//     final fields = state.additionalFields;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
//         final columnSpacing = 2.w;
//         const rowSpacing = 12.0;
//
//         final fieldWidgets = fields.map((field) {
//           final id = field.id ?? field.fieldName;
//           final controller =
//               _additionalCtrlMap[id] ??
//               (_additionalCtrlMap[id] = TextEditingController());
//
//           return _field(
//             field.fieldName,
//             false,
//             Icons.description_outlined,
//             controller: controller,
//           );
//         }).toList();
//
//         final rows = <Widget>[];
//         for (var i = 0; i < fieldWidgets.length; i += crossAxisCount) {
//           final rowChildren = <Widget>[];
//           for (var j = 0; j < crossAxisCount; j++) {
//             final idx = i + j;
//             if (idx < fieldWidgets.length) {
//               rowChildren.add(Expanded(child: fieldWidgets[idx]));
//             } else {
//               rowChildren.add(const Expanded(child: SizedBox.shrink()));
//             }
//             if (j < crossAxisCount - 1) {
//               rowChildren.add(SizedBox(width: columnSpacing));
//             }
//           }
//           rows.add(
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: rowChildren,
//             ),
//           );
//           if (i + crossAxisCount < fieldWidgets.length) {
//             rows.add(SizedBox(height: rowSpacing));
//           }
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: rows,
//         );
//       },
//     );
//   }
//
//   // ── Section: Customer Details ──────────────────────────────────────────────
//
//   Widget _buildCustomerDetails() {
//     return BlocBuilder<AddLeadCubit, AddLeadState>(
//       buildWhen: (p, c) =>
//           p.selectedState != c.selectedState ||
//           p.selectedDistrict != c.selectedDistrict,
//       builder: (context, state) {
//         return Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: _field(
//                     'Client Name',
//                     true,
//                     Icons.person_outline,
//                     controller: _clientNameCtrl,
//                   ),
//                 ),
//                 SizedBox(width: 2.w),
//                 Expanded(
//                   child: _phoneField(
//                     'Contact Number',
//                     true,
//                     Icons.call_outlined,
//                     controller: _contactCtrl,
//                     onDialCodeChanged: (c) =>
//                         setState(() => _contactDialCode = c),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 1.5.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: _phoneField(
//                     'Whatsapp Number',
//                     false,
//                     Icons.call_outlined,
//                     controller: _whatsappCtrl,
//                     onDialCodeChanged: (c) =>
//                         setState(() => _whatsappDialCode = c),
//                   ),
//                 ),
//                 SizedBox(width: 2.w),
//                 Expanded(
//                   child: _field(
//                     'Email',
//                     false,
//                     Icons.email_outlined,
//                     controller: _emailCtrl,
//                     // validator: (value) {
//                     //   if (value == null || value.isEmpty) {
//                     //     return null; // Not required
//                     //   }
//                     //   final emailRegex = RegExp(
//                     //     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     //   );
//                     //   if (!emailRegex.hasMatch(value)) {
//                     //     return 'Enter a valid email';
//                     //   }
//                     //   return null;
//                     // },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 1.5.h),
//             _multilineField(
//               'Address',
//               Icons.location_on_outlined,
//               controller: _addressCtrl,
//             ),
//             SizedBox(height: 1.5.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: _field(
//                     'Pin Code',
//                   keyboardtype: TextInputType.number,
//                     false,
//                     Icons.pin_drop_outlined,
//                     controller: _pinCtrl,
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Expanded(
//                   child: _field(
//                     'Post Office',
//                     false,
//                     Icons.location_city,
//                     controller: _postOfficeCtrl,
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Expanded(
//                   child: Dropdown(
//                     showIcon: true,
//                     icon: Icons.location_on_outlined,
//                     items: stateDistrictMap.keys.toList(),
//                     selectedValue: state.selectedState,
//                     onChanged: (v) =>
//                         context.read<AddLeadCubit>().selectState(v),
//                     label: 'State',
//                     hint: 'Select State',
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Expanded(
//                   child: Dropdown(
//                     showIcon: true,
//                     icon: Icons.location_on_outlined,
//                     items: state.selectedState == null
//                         ? []
//                         : stateDistrictMap[state.selectedState] ?? [],
//                     selectedValue: state.selectedDistrict,
//                     enabled: state.selectedState != null,
//                     onChanged: (v) =>
//                         context.read<AddLeadCubit>().selectDistrict(v),
//                     label: 'District',
//                     hint: 'Select District',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // ── Section: Lead Information ──────────────────────────────────────────────
//
//   Widget _buildLeadInformation(BuildContext context) {
//     return BlocBuilder<AddLeadCubit, AddLeadState>(
//       builder: (context, state) {
//         final cubit = context.read<AddLeadCubit>();
//         final categoryNames = state.categories.map((e) => e.name).toList();
//         final sourceNames = state.sources.map((e) => e.name).toList();
//         final stagesNames = state.stages.map((e) => e.name).toList();
//         final staffList = state.staffList;
//         final staffNames = staffList.map((s) => s.name).toList();
//
//         return _isEditMode
//             ? Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Dropdown(
//                           label: 'lead Category',
//                           hint: 'Select lead Category',
//                           items: categoryNames,
//                           selectedValue: state.selectedCategory,
//                           onChanged: (v) =>
//                               context.read<AddLeadCubit>().selectCategory(v),
//                         ),
//                       ),
//                       SizedBox(width: 1.w),
//                       Expanded(
//                         child: Dropdown(
//                           label: 'lead Source',
//                           hint: 'Select lead Source',
//                           items: sourceNames,
//                           selectedValue: state.selectedSource,
//                           onChanged: (v) =>
//                               context.read<AddLeadCubit>().selectSource(v),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         // width: 18.w,
//                         child: Dropdown(
//                           label: 'Priority',
//                           hint: 'Priority',
//                           items: priority,
//                           selectedValue: state.selectedPriority,
//                           onChanged: (v) =>
//                               context.read<AddLeadCubit>().selectPriority(v),
//                         ),
//                       ),
//                       SizedBox(width: 0.5.h),
//                       Expanded(child: SizedBox()),
//                     ],
//                   ),
//                   SizedBox(height: 0.5.h),
//                   _multilineField(
//                     'Remarks',
//                     Icons.description_outlined,
//                     controller: _remarksCtrl,
//                   ),
//                 ],
//               )
//             : Column(
//                 children: [
//                   Row(
//                     children: [
//                       if (_currentUser != null) ...[
//                         if (_currentUser!.staffType != 'Admin')
//                           Expanded(
//                             child: _readOnlyField(
//                               'Assign Staff',
//                               Icons.person_outline,
//                               state.assignedStaffName,
//                             ),
//                           )
//                         else
//                           Expanded(
//                             child: Dropdown(
//                               icon: Icons.person_outline,
//                               showIcon: true,
//                               items: staffNames,
//                               selectedValue: _selectStaff,
//                               // onChanged: (v) {
//                               //   setState(() => _selectStaff = v);
//                               // },
//                               onChanged: (v) {
//                                 setState(() {
//                                   _selectStaff = v;
//                                 });
//
//                                 final selected = staffList.firstWhere(
//                                   (e) => e.name == v,
//                                 );
//
//                                 cubit.selectAssignedStaff(
//                                   name: selected.name,
//
//                                   id: selected.id ?? '',
//                                 );
//                               },
//                               label: 'SelectStaff',
//                               hint: 'Select Staff',
//                             ),
//                           ),
//                       ],
//                       SizedBox(width: 2.w),
//                       Expanded(
//                         child: DropdownWithAdd(
//                           label: 'Lead Category',
//                           icon: Icons.layers_outlined,
//                           showIcon: true,
//                           items: categoryNames,
//                           selectedValue: _leadCategory,
//                           onChanged: (v) {
//                             setState(() => _leadCategory = v);
//                             cubit.selectCategory(v);
//                           },
//                           onTap: _showAddCategoryDialog,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 1.5.h),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownWithAdd(
//                           label: 'Lead Source',
//                           showIcon: true,
//                           icon: Icons.layers_rounded,
//                           items: sourceNames,
//                           selectedValue: _leadSource,
//                           onChanged: (v) {
//                             setState(() => _leadSource = v);
//                             cubit.selectSource(v);
//                           },
//                           onTap: _showAddSourceDialog,
//                         ),
//                       ),
//                       SizedBox(width: 2.w),
//                       Expanded(
//                         child: Dropdown(
//                           icon: Icons.flag_outlined,
//                           showIcon: true,
//                           showHelp: true,
//                           items: priority,
//                           selectedValue: _leadPriority,
//                           onChanged: (v) {
//                             setState(() => _leadPriority = v);
//                             cubit.selectPriority(v);
//                           },
//                           label: 'Priority',
//                           hint: 'Select Priority',
//                         ),
//                       ),
//                       SizedBox(width: 2.w),
//                       Expanded(
//                         child: Dropdown(
//                           showHelp: true,
//                           items: stagesNames,
//                           selectedValue: _leadStage,
//                           onChanged: (v) {
//                             setState(() => _leadStage = v);
//                             cubit.selectLeadStage(v);
//                           },
//                           label: 'Lead Stage',
//                           hint: 'Select Stages',
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (_leadStage != "NEW" && _leadStage != null)
//                     Column(
//                       children: [
//                         SizedBox(height: 1.5.h),
//                         if (_leadStage == "FOLLOWUP")
//                           Row(
//                             children: [
//                               SizedBox(
//                                 width: 24.w,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Next Follow-Up Date',
//                                       style: AppTextStyle.medium(),
//                                     ),
//                                     SizedBox(height: 0.5.h),
//                                     GestureDetector(
//                                       onTap: () {
//                                         showDialog(
//                                           context: context,
//                                           barrierColor: Colors.black
//                                               .withOpacity(0.4),
//                                           builder: (_) => Dialog(
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: SizedBox(
//                                               width: 28.w, // ✅ compact width
//                                               child: CustomCalendarPickOne(
//                                                 initialDate: nextFollowUpDate,
//                                                 onDateSelected: (date) {
//                                                   setState(() {
//                                                     nextFollowUpDate = date;
//                                                     nextFollowUpCtrl.text =
//                                                         DateFormat(
//                                                           'dd-MM-yyyy',
//                                                         ).format(date);
//                                                   });
//                                                   Navigator.pop(
//                                                     context,
//                                                   ); // ✅ use ctx not context
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         height: 5.2.h,
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 24,
//                                           vertical: 5,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.greyCard,
//                                           border: Border.all(
//                                             color: AppColors.divider,
//                                             width: 1,
//                                           ),
//                                           borderRadius: BorderRadius.circular(
//                                             4,
//                                           ),
//                                         ),
//                                         child: IgnorePointer(
//                                           child: TextField(
//                                             controller: nextFollowUpCtrl,
//                                             readOnly: true,
//                                             style: AppTextStyle.small(
//                                               size: 11.sp,
//                                               color: AppColors.black,
//                                             ),
//                                             decoration: InputDecoration(
//                                               border: InputBorder.none,
//                                               hintText: nextFollowUpCtrl.text,
//                                               hintStyle: AppTextStyle.small(
//                                                 size: 11.sp,
//                                                 color: AppColors.black,
//                                               ),
//                                               isCollapsed: true,
//                                               contentPadding: EdgeInsets.zero,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         Row(
//                           children: [
//                             if (_leadStage == "REJECTED")
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 24.w,
//                                     child: Dropdown(
//                                       label: 'Tags',
//                                       hint: 'Select Tags',
//                                       items: [
//                                         'Costly',
//                                         'Not intrested',
//                                         'Not Responding',
//                                         'No Budget',
//                                         'Wrong Lead',
//                                       ],
//                                       selectedValue: _leadTag,
//                                       onChanged: (v) {
//                                         setState(() => _leadTag = v);
//                                         cubit.selectLeadTag(v);
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(width: 2.w),
//                                 ],
//                               ),
//
//                             SizedBox(
//                               width: 24.w,
//                               child: Dropdown(
//                                 label: 'Call Result',
//                                 hint: 'Select Call Result',
//                                 icon: Icons.phone_enabled_outlined,
//                                 showStar: true,
//                                 items: [
//                                   'Busy',
//                                   'Connected',
//                                   'Not Attended',
//                                   'Out of Coverage Area',
//                                   'Rejected',
//                                   'Switched Off',
//                                 ],
//                                 selectedValue: _callResult,
//                                 onChanged: (v) {
//                                   setState(() => _callResult = v);
//                                   cubit.selectCallResult(v);
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                   SizedBox(height: 1.5.h),
//                   _multilineField(
//                     'Remarks',
//                     Icons.note_alt_outlined,
//                     controller: _remarksCtrl,
//                   ),
//                 ],
//               );
//       },
//     );
//   }
//
//   // ── Submit Button ──────────────────────────────────────────────────────────
//
//   Widget _buildSubmitButton() {
//     return Padding(
//       padding: EdgeInsets.only(right: 2.w),
//       child: Container(
//         margin: EdgeInsets.all(2.w),
//         width: double.infinity,
//         height: 10.h,
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(3),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
//         child: Align(
//           alignment: Alignment.centerRight,
//           child: BlocBuilder<AddLeadCubit, AddLeadState>(
//             buildWhen: (p, c) =>
//                 p.isSubmitting != c.isSubmitting ||
//                 p.isUpdating != c.isUpdating,
//             builder: (context, state) {
//               final isBusy = state.isSubmitting || state.isUpdating;
//               return SizedBox(
//                 height: 5.h,
//                 child: ElevatedButton(
//                   onPressed: isBusy ? null : _submit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.green,
//                     disabledBackgroundColor: AppColors.green.withOpacity(0.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   child: isBusy
//                       ? SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.white,
//                           ),
//                         )
//                       : Text(
//                           _isEditMode ? 'Update' : 'Submit',
//                           style: AppTextStyle.medium(
//                             size: 11.sp,
//                             color: AppColors.white,
//                           ),
//                         ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Dialogs ────────────────────────────────────────────────────────────────
//
//   void _showAddCategoryDialog() {
//     _dialogNameCtrl.clear();
//     showDialog(
//       context: context,
//       builder: (ctx) => AppDialog(
//         width: 35.w,
//         title: 'Add Lead Category',
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 0.5.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Lead Category', style: AppTextStyle.medium(size: 11.sp)),
//               SizedBox(height: 2.h),
//               TextField(
//                 controller: _dialogNameCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'Enter Category',
//                   hintStyle: AppTextStyle.medium(
//                     size: 11.sp,
//                     color: AppColors.grey,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         onSubmit: () async {
//           final name = _dialogNameCtrl.text.trim();
//           if (name.isEmpty) return;
//           context.read<LeadCategoryCubit>().addCategory(name: name);
//           setState(() => _leadCategory = name);
//         context.read<AddLeadCubit>().selectCategory(name);
//           Navigator.pop(ctx);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Category "$name" added.'),
//               backgroundColor: AppColors.green,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showAddSourceDialog() {
//     _dialogNameCtrl.clear();
//     showDialog(
//       context: context,
//       builder: (ctx) => AppDialog(
//         width: 35.w,
//         title: 'Add Lead Source',
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 0.5.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Lead Source', style: AppTextStyle.medium(size: 11.sp)),
//               SizedBox(height: 2.h),
//               TextField(
//                 controller: _dialogNameCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'Enter Source',
//                   hintStyle: AppTextStyle.medium(
//                     size: 11.sp,
//                     color: AppColors.grey,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         onSubmit: () async {
//           final name = _dialogNameCtrl.text.trim();
//           if (name.isEmpty) return;
//           context.read<LeadSourceCubit>().addSource(name: name);
//            setState(() => _leadSource = name);
//   context.read<AddLeadCubit>().selectSource(name);
//
//           Navigator.pop(ctx);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Source "$name" added.'),
//               backgroundColor: AppColors.green,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ── Reusable Widgets ───────────────────────────────────────────────────────
//
//   Widget _sectionCard(String title, Widget child, IconData icon) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 2.h),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border.all(color: AppColors.divider),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
//             decoration: BoxDecoration(
//               color: AppColors.grey.withValues(alpha: 0.3),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(6),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, size: 13.sp, weight: 600, color: AppColors.green),
//                 SizedBox(width: 1.w),
//                 Text(
//                   title,
//                   style: AppTextStyle.medium(
//                     size: 11.sp,
//                     color: AppColors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(padding: EdgeInsets.all(2.w), child: child),
//         ],
//       ),
//     );
//   }
//
//   Widget _field(
//     String label,
//     bool required,
//     IconData icons, {
//     TextInputType? keyboardtype,
//     TextEditingController? controller,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label(label, required, icons),
//         SizedBox(height: 0.5.h),
//         Container(
//           height: 5.h,
//           decoration: _box(),
//           child: TextFormField(
//             controller: controller,
//             validator: validator,
//             keyboardType:keyboardtype ?? TextInputType.text,
//             style: AppTextStyle.body(size: 11.sp),
//             decoration: InputDecoration(
//               hintText: label,
//               hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(1.w),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _readOnlyField(String label, IconData icons, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label(label, false, icons),
//         SizedBox(height: 0.5.h),
//         Container(
//           height: 5.h,
//           decoration: _box(),
//           padding: EdgeInsets.symmetric(horizontal: 1.w),
//           alignment: Alignment.centerLeft,
//           child: Text(
//             value.isEmpty ? 'Loading...' : value,
//             style: value.isEmpty
//                 ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
//                 : AppTextStyle.body(size: 11.sp),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _phoneField(
//     String label,
//     bool required,
//     IconData icons, {
//     TextEditingController? controller,
//     void Function(String)? onDialCodeChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label(label, required, icons),
//         SizedBox(height: 0.5.h),
//         Row(
//           children: [
//             SizedBox(
//               height: 5.h,
//               width: 7.5.w,
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.divider),
//                   borderRadius: BorderRadius.circular(4),
//                   color: AppColors.grey.withValues(alpha: 0.2),
//                 ),
//                 child: CountryCodePicker(
//                   onChanged: (country) =>
//                       onDialCodeChanged?.call(country.dialCode ?? '+91'),
//                   initialSelection: 'IN',
//                   showCountryOnly: false,
//                   showOnlyCountryWhenClosed: false,
//                   alignLeft: true,
//                   padding: EdgeInsets.zero,
//                   textStyle: AppTextStyle.body(size: 11.sp),
//                   flagWidth: 16,
//                   dialogBackgroundColor: AppColors.white,
//                   dialogSize: Size(30.w, 80.h),
//                   dialogTextStyle: AppTextStyle.body(size: 11.sp),
//                   searchStyle: AppTextStyle.body(size: 11.sp),
//                   searchDecoration: InputDecoration(
//                     hintText: 'Search country',
//                     hintStyle: AppTextStyle.small(
//                       size: 11.sp,
//                       color: AppColors.grey,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(color: AppColors.divider),
//                     ),
//                     contentPadding: EdgeInsets.all(1.w),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 0.25.w),
//             Expanded(
//               child: Container(
//                 height: 5.h,
//                 decoration: _box(),
//                 child: TextFormField(
//                   controller: controller,
//
//                   // validator: (value) {
//                   //   if (value == null || value.isEmpty) {
//                   //     return null; // Not required
//                   //   }
//                   //   final phoneRegex = RegExp(r'^[0-9]{6,15}$');
//                   //   if (!phoneRegex.hasMatch(value)) {
//                   //     return 'Enter a valid phone number';
//                   //   }
//                   //   return null;
//                   // },
//                   style: AppTextStyle.body(size: 11.sp),
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     hintText: 'Enter number',
//                     hintStyle: AppTextStyle.small(
//                       size: 11.sp,
//                       color: AppColors.grey,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(1.w),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _multilineField(
//     String label,
//     IconData icons, {
//     TextEditingController? controller,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label(label, false, icons),
//         SizedBox(height: 0.5.h),
//         Container(
//           height: 10.h,
//           decoration: _box(),
//           child: TextField(
//             controller: controller,
//             maxLines: null,
//             style: AppTextStyle.body(size: 11.sp),
//             decoration: InputDecoration(
//               hintText: label,
//               hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(1.w),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _label(String text, bool required, IconData icons) {
//     return Row(
//       children: [
//         Icon(icons, size: 12.sp, color: AppColors.green),
//         SizedBox(width: 0.5.w),
//         Text(text, style: AppTextStyle.medium()),
//         if (required)
//           Text(
//             '*',
//             style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
//           ),
//       ],
//     );
//   }
//
//   BoxDecoration _box() {
//     return BoxDecoration(
//       border: Border.all(color: AppColors.divider),
//       borderRadius: BorderRadius.circular(4),
//       color: AppColors.greyCard,
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2.h),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(bottom: BorderSide(color: AppColors.divider)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             _isEditMode ? 'EDIT LEAD' : 'ADD NEW LEAD',
//             style: AppTextStyle.medium(
//               size: 13.sp,
//               color: AppColors.black.withOpacity(0.77),
//               weight: FontWeight.w700,
//             ),
//           ),
//           Row(
//             children: [
//               Row(
//                 children: [
//                   Text('Lead Management', style: AppTextStyle.medium()),
//                   Icon(Icons.chevron_right, size: 16.sp),
//                   Text(
//                     _isEditMode ? 'Edit Lead' : 'Add Lead',
//                     style: AppTextStyle.medium(color: AppColors.grey),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 1.w),
//               MenuHoverButton(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomCalendarPickOne extends StatefulWidget {
//   final Function(DateTime) onDateSelected;
//   final DateTime? initialDate;
//
//   const CustomCalendarPickOne({
//     super.key,
//     required this.onDateSelected,
//     this.initialDate,
//   });
//
//   @override
//   State<CustomCalendarPickOne> createState() => _CustomCalendarPickOneState();
// }
//
// class _CustomCalendarPickOneState extends State<CustomCalendarPickOne> {
//   late DateTime _focusedMonth;
//   DateTime? _selectedDate;
//
//   final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//   final List<String> _months = [
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = widget.initialDate;
//     _focusedMonth = widget.initialDate ?? DateTime.now();
//   }
//
//   void _prevMonth() => setState(() {
//     _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
//   });
//
//   void _nextMonth() => setState(() {
//     _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
//   });
//
//   List<DateTime?> _buildDayCells() {
//     final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
//     final daysInMonth = DateUtils.getDaysInMonth(
//       _focusedMonth.year,
//       _focusedMonth.month,
//     );
//     final leadingBlanks = firstDay.weekday % 7;
//
//     final cells = <DateTime?>[];
//     for (int i = 0; i < leadingBlanks; i++) cells.add(null);
//     for (int d = 1; d <= daysInMonth; d++) {
//       cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
//     }
//     return cells;
//   }
//
//   bool _isToday(DateTime date) {
//     final now = DateTime.now();
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }
//
//   bool _isSelected(DateTime date) =>
//       _selectedDate != null &&
//       date.year == _selectedDate!.year &&
//       date.month == _selectedDate!.month &&
//       date.day == _selectedDate!.day;
//
//   @override
//   Widget build(BuildContext context) {
//     final cells = _buildDayCells();
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Colored header ─────────────────────────────────────────────
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.2.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primary,
//                   AppColors.primary.withOpacity(0.75),
//                 ],
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   onPressed: _prevMonth,
//                   icon: Icon(
//                     Icons.chevron_left,
//                     size: 12.sp,
//                     color: Colors.white,
//                   ),
//                   splashRadius: 16,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//                 Column(
//                   children: [
//                     Text(
//                       _months[_focusedMonth.month - 1],
//                       style: AppTextStyle.medium(
//                         size: 11.sp,
//                         weight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '${_focusedMonth.year}',
//                       style: AppTextStyle.small(
//                         size: 9.sp,
//                         color: Colors.white.withOpacity(0.85),
//                       ),
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                   onPressed: _nextMonth,
//                   icon: Icon(
//                     Icons.chevron_right,
//                     size: 12.sp,
//                     color: Colors.white,
//                   ),
//                   splashRadius: 16,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Body ───────────────────────────────────────────────────────
//           Container(
//             color: Colors.white,
//             padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.8.h),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Weekday row
//                 Row(
//                   children: _weekDays.map((day) {
//                     return Expanded(
//                       child: Center(
//                         child: Text(
//                           day,
//                           style: AppTextStyle.small(
//                             size: 8.5.sp,
//                             weight: FontWeight.w700,
//                             color: AppColors.primary.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//
//                 SizedBox(height: 0.5.h),
//
//                 // Day grid
//                 GridView.count(
//                   crossAxisCount: 7,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   mainAxisSpacing: 2,
//                   crossAxisSpacing: 2,
//                   childAspectRatio: 1.3,
//                   children: cells.map((date) {
//                     if (date == null) return const SizedBox.shrink();
//
//                     final selected = _isSelected(date);
//                     final today = _isToday(date);
//
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() => _selectedDate = date);
//                         widget.onDateSelected(date);
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 150),
//                         decoration: BoxDecoration(
//                           color: selected
//                               ? AppColors.primary
//                               : today
//                               ? AppColors.primary.withOpacity(0.12)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${date.day}',
//                             style: AppTextStyle.small(
//                               size: 8.5.sp,
//                               weight: selected
//                                   ? FontWeight.w700
//                                   : FontWeight.w400,
//                               color: selected
//                                   ? Colors.white
//                                   : today
//                                   ? AppColors.primary
//                                   : AppColors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//
//                 SizedBox(height: 0.5.h),
//
//                 // Today button
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 1.w,
//                         vertical: 0.3.h,
//                       ),
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     onPressed: () {
//                       final today = DateTime.now();
//                       setState(() {
//                         _selectedDate = today;
//                         _focusedMonth = today;
//                       });
//                       widget.onDateSelected(today);
//                     },
//                     child: Text(
//                       'Today',
//                       style: AppTextStyle.small(
//                         size: 9.sp,
//                         color: AppColors.primary,
//                         weight: FontWeight.w600,
//                       ),
//                     ),
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

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/indian_location_service.dart';
import 'package:oxdo/core/utils/menu_hover_bottun.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
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
    text: DateFormat('dd-MM-yyyy')
        .format(DateTime.now().add(const Duration(days: 1))),
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
  final FocusNode _sourceFocus = FocusNode();
  final FocusNode _priorityFocus = FocusNode();
  final FocusNode _stageFocus = FocusNode();
  final FocusNode _tagsFocus = FocusNode();
  final FocusNode _callResultFocus = FocusNode();
  final FocusNode _remarksFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();

  // Dynamic additional field focus nodes keyed by field id
  final Map<String, FocusNode> _additionalFocusMap = {};

  /// The ordered list of FocusNodes used for Enter-key navigation.
  /// Built in [_buildOrderedNodes] so additional-field nodes can be injected.
  List<FocusNode> _orderedNodes = [];

  // ── Dropdown values ──────────────────────────────────────────────────────────
  String? _leadStage;
  String? _leadSource;
  String? _leadCategory;
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

   Map<String, List<String>> stateDistrictMap = {
  };

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
      nodes.add(
        _additionalFocusMap.putIfAbsent(id, () => FocusNode()),
      );
    }

    if (!_isEditMode) {
      nodes.addAll([_assignStaffFocus, _categoryFocus, _sourceFocus]);
    } else {
      nodes.addAll([_categoryFocus, _sourceFocus]);
    }
    nodes.addAll([
      _priorityFocus,
      _stageFocus,
      if (_leadStage == 'REJECTED') _tagsFocus,
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
    _leadPriority = lead.priority;
    nextFollowUpDate =
        lead.followUpDate ?? DateTime.now().add(const Duration(days: 1));
    nextFollowUpCtrl.text = DateFormat('dd-MM-yyyy').format(nextFollowUpDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AddLeadCubit>();
      if (lead.state.isNotEmpty) cubit.selectState(lead.state);
      if (lead.district.isNotEmpty) cubit.selectDistrict(lead.district);
      if (lead.leadCategory.isNotEmpty) cubit.selectCategory(lead.leadCategory);
      if (lead.leadSource.isNotEmpty) cubit.selectSource(lead.leadSource);
      if (lead.priority.isNotEmpty) cubit.selectPriority(lead.priority);
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

    if (contact.isNotEmpty) {
      final phoneRegex = _contactDialCode == '+91'
          ? RegExp(r'^[0-9]{10}$')
          : RegExp(r'^[0-9]{6,15}$');
      if (!phoneRegex.hasMatch(contact)) {
        _showError(_contactDialCode == '+91'
            ? 'Indian contact number must be exactly 10 digits.'
            : 'Enter a valid contact number.');
        return;
      }
    }

    if (whatsapp.isNotEmpty) {
      final phoneRegex = _whatsappDialCode == '+91'
          ? RegExp(r'^[0-9]{10}$')
          : RegExp(r'^[0-9]{6,15}$');
      if (!phoneRegex.hasMatch(whatsapp)) {
        _showError(_whatsappDialCode == '+91'
            ? 'Indian WhatsApp number must be exactly 10 digits.'
            : 'Enter a valid WhatsApp number.');
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
        leadCategory: state.selectedCategory ?? widget.lead!.leadCategory,
        leadSource: state.selectedSource ?? widget.lead!.leadSource,
        priority: state.selectedPriority ?? widget.lead!.priority,
        leadStage: _leadStage ?? widget.lead!.leadStage,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
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
      listener: (context, state) {
        if (state.additionalFields.isNotEmpty) {
          _syncAdditionalControllers(state.additionalFields);
        }

        if (state.errorMessage != null) {
          _showError(state.errorMessage!);
        }

        if (state.successMessage != null) {
          if (_isEditMode) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(selectedIndex: 2)),
            );
          } else {
            context.read<AddLeadCubit>().fetchLeads();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(selectedIndex: 2)),
            );
          }
        }
      },

      // ── Wrap the entire form in Shortcuts + Actions for Enter navigation ──────
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Enter → next field (unless Shift is held)
          const SingleActivator(LogicalKeyboardKey.enter): const _NextFieldIntent(),
          const SingleActivator(LogicalKeyboardKey.enter,control: true): const _NextFieldIntent(),
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
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),

                        // ── Customer Details ────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: _sectionCard(
                            'Customer Details',
                            Form(
                                key: _formKey,
                                child: _buildCustomerDetails()),
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
                                padding:
                                EdgeInsets.symmetric(horizontal: 2.w),
                                child: _sectionCard(
                                  'Additional Details',
                                  SizedBox(
                                    height: 8.h,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  Icons.add_circle_outline_rounded,
                                ),
                              );
                            }
                            if (state.additionalFields.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 2.w),
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
      //buildWhen: (p, c) =>
      //     p.selectedState != c.selectedState ||
      //     p.selectedDistrict != c.selectedDistrict,
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
                    focusNode: _clientNameFocus,
                    nextFocusNode: _contactFocus,
                  ),
                ),
                SizedBox(width: 2.w),
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
                    focusNode: _whatsappFocus,
                    nextFocusNode: _emailFocus,
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
                    focusNode: _emailFocus,
                    nextFocusNode: _addressFocus,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            _multilineField(
              'Address',
              Icons.location_on_outlined,
              controller: _addressCtrl,
              focusNode: _addressFocus,
              nextFocusNode: _pinFocus,
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Pin Code',
                    false,
                    Icons.pin_drop_outlined,
                    keyboardtype: TextInputType.number,
                    controller: _pinCtrl,
                    focusNode: _pinFocus,
                    nextFocusNode: _postOfficeFocus,
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: _field(
                    'Post Office',
                    false,
                    Icons.location_city,
                    controller: _postOfficeCtrl,
                    focusNode: _postOfficeFocus,
                    nextFocusNode: _stateFocus,
                  ),
                ),
                SizedBox(width: 1.w),
                // Expanded(
                //   child: Dropdown(
                //     showIcon: true,
                //     icon: Icons.location_on_outlined,
                //     items: stateDistrictMap.keys.toList(),
                //     selectedValue: state.selectedState,
                //     onChanged: (v) =>
                //         context.read<AddLeadCubit>().selectState(v),
                //     label: 'State',
                //     hint: 'Select State',
                //   ),
                // ),
                // In AddLeadPage — wrap state dropdown to show loading state
Expanded(
  child: stateDistrictMap.isEmpty
      ? Container(
          height: 5.h,
          decoration: _box(),
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.green,
              ),
            ),
          ),
        )
      : Dropdown(
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
                    focusNode: _districtFocus,
                    // Next depends on whether there are additional fields;
                    // using _buildOrderedNodes handles this automatically.
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Section: Additional Details
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildAdditionalDetails(AddLeadState state) {
    final fields = state.additionalFields;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
        final columnSpacing = 2.w;
        const rowSpacing = 12.0;

        final fieldWidgets = fields.map((field) {
          final id = field.id ?? field.fieldName;
          final controller = _additionalCtrlMap[id] ??
              (_additionalCtrlMap[id] = TextEditingController());
          final fn = _additionalFocusMap[id] ??
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
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ));
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Section: Lead Information
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLeadInformation(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        final cubit = context.read<AddLeadCubit>();
        final categoryNames = state.categories.map((e) => e.name).toList();
        final sourceNames = state.sources.map((e) => e.name).toList();
        final stagesNames = state.stages.map((e) => e.name).toList();
        final staffList = state.staffList;
        final staffNames = staffList.map((s) => s.name).toList();

        return _isEditMode
            ? Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Dropdown(
                    label: 'Lead Category',
                    hint: 'Select Lead Category',
                    items: categoryNames,
                    selectedValue: state.selectedCategory,
                    focusNode: _categoryFocus,
                    nextFocusNode: _sourceFocus,
                    onChanged: (v) =>
                        context.read<AddLeadCubit>().selectCategory(v),
                  ),
                ),
                SizedBox(width: 1.w),
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
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
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
                SizedBox(width: 0.5.h),
                const Expanded(child: SizedBox()),
              ],
            ),
            SizedBox(height: 0.5.h),
            _multilineField(
              'Remarks',
              Icons.description_outlined,
              controller: _remarksCtrl,
              focusNode: _remarksFocus,
              nextFocusNode: _submitFocus,
            ),
          ],
        )
            : Column(
          children: [
            Row(
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
                          final selected =
                          staffList.firstWhere((e) => e.name == v);
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
                SizedBox(width: 2.w),
                Expanded(
                  child: DropdownWithAdd(
                    label: 'Lead Category',
                    icon: Icons.layers_outlined,
                    showIcon: true,
                    items: categoryNames,
                    selectedValue: _leadCategory,
                    focusNode: _categoryFocus,
                    nextFocusNode: _sourceFocus,
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
                    focusNode: _sourceFocus,
                    nextFocusNode: _priorityFocus,
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
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Dropdown(
                    icon: Icons.check_box_outlined,
                          showIcon: true,
                    items: stagesNames,
                    selectedValue: _leadStage,
                    focusNode: _stageFocus,
                    nextFocusNode: _leadStage != 'NEW' && _leadStage != null
                        ? (_leadStage == 'REJECTED'
                        ? _tagsFocus
                        : _callResultFocus)
                        : _remarksFocus,
                    onChanged: (v) {
                      setState(() => _leadStage = v);
                      cubit.selectLeadStage(v);
                      // Rebuild node order when stage changes conditional fields
                      _buildOrderedNodes(
                          context.read<AddLeadCubit>().state.additionalFields);
                    },
                    label: 'Lead Stage',
                    hint: 'Select Stages',
                  ),
                ),
              ],
            ),

            // ── Conditional stage fields ─────────────────────────────
            if (_leadStage != 'NEW' && _leadStage != null)
              Column(
                children: [
                  SizedBox(height: 1.5.h),
                  if (_leadStage == 'FOLLOWUP')
                    Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Next Follow-Up Date',
                                  style: AppTextStyle.medium()),
                              SizedBox(height: 0.5.h),
                              GestureDetector(
                                onTap: () => _pickFollowUpDate(context),
                                child: Container(
                                  height: 5.2.h,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyCard,
                                    border: Border.all(
                                        color: AppColors.divider,
                                        width: 1),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: nextFollowUpCtrl,
                                      readOnly: true,
                                      style: AppTextStyle.small(
                                          size: 11.sp,
                                          color: AppColors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: nextFollowUpCtrl.text,
                                        hintStyle: AppTextStyle.small(
                                            size: 11.sp,
                                            color: AppColors.black),
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
                      ],
                    ),
                  Row(
                    children: [
                      if (_leadStage == 'REJECTED')
                        Row(
                          children: [
                            SizedBox(
                              width: 24.w,
                              child: Dropdown(
                                label: 'Tags',
                                hint: 'Select Tags',
                                focusNode: _tagsFocus,
                                nextFocusNode: _callResultFocus,
                                items: const [
                                  'Costly',
                                  'Not interested',
                                  'Bad Quality',
                                  'Pending',
                                  'Rejected',
                                  'Switched Off',
                                ],
                                selectedValue: _leadTag,
                                onChanged: (v) {
                                  setState(() => _leadTag = v);
                                  cubit.selectLeadTag(v);
                                },
                              ),
                            ),
                          ],
                        ),
                      SizedBox(width: 1.w),
                      SizedBox(
                        width: 24.w,
                        child: Dropdown(
                          label: 'Call Result',
                          hint: 'Select Call Result',
                          focusNode: _callResultFocus,
                          nextFocusNode: _remarksFocus,
                          items: const [
                            'Answered',
                            'Busy',
                            'No Answer',
                            'Rejected',
                            'Switched Off',
                          ],
                          selectedValue: _callResult,
                          onChanged: (v) {
                            setState(() => _callResult = v);
                            cubit.selectCallResult(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            SizedBox(height: 1.5.h),
            _multilineField(
              'Remarks',
              Icons.note_alt_outlined,
              controller: _remarksCtrl,
              focusNode: _remarksFocus,
              nextFocusNode: _submitFocus,
            ),
          ],
        );
      },
    );
  }

  void _pickFollowUpDate(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 28.w,
          child: CustomCalendarPickOne(
            initialDate: nextFollowUpDate,
            onDateSelected: (date) {
              setState(() {
                nextFollowUpDate = date;
                nextFollowUpCtrl.text =
                    DateFormat('dd-MM-yyyy').format(date);
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Submit Button
  // ─────────────────────────────────────────────────────────────────────────────

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
                child: Focus(
                  focusNode: _submitFocus,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      disabledBackgroundColor:
                      AppColors.green.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: isBusy
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                        : Text(
                      _isEditMode ? 'Update' : 'Submit',
                      style: AppTextStyle.medium(
                          size: 11.sp, color: AppColors.white),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────────

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
                  hintStyle:
                  AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        onSubmit: () async {
          final name = _dialogNameCtrl.text.trim();
          if (name.isEmpty) return;
          context.read<LeadCategoryCubit>().addCategory(name: name);
          setState(() => _leadCategory = name);
          context.read<AddLeadCubit>().selectCategory(name);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Category "$name" added.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ));
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
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter Source',
                  hintStyle:
                  AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        onSubmit: () async {
          final name = _dialogNameCtrl.text.trim();
          if (name.isEmpty) return;
          context.read<LeadSourceCubit>().addSource(name: name);
          setState(() => _leadSource = name);
          context.read<AddLeadCubit>().selectSource(name);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Source "$name" added.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ));
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
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 13.sp, weight: 600, color: AppColors.green),
                SizedBox(width: 1.w),
                Text(title,
                    style: AppTextStyle.medium(
                        size: 11.sp, color: AppColors.black)),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(2.w), child: child),
        ],
      ),
    );
  }

  /// Standard single-line text field with Enter-key navigation support.
  Widget _field(
      String label,
      bool required,
      IconData icons, {
        TextInputType? keyboardtype,
        TextEditingController? controller,
        String? Function(String?)? validator,
        FocusNode? focusNode,
        FocusNode? nextFocusNode,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: _box(),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            keyboardType: keyboardtype ?? TextInputType.text,
            textInputAction: nextFocusNode != null
                ? TextInputAction.next
                : TextInputAction.done,
            style: AppTextStyle.body(size: 11.sp),
            decoration: InputDecoration(
              hintText: label,
              hintStyle:
              AppTextStyle.small(size: 11.sp, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(1.w),
            ),
            // Enter key moves to the next node in _orderedNodes
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

  /// Phone field — pairs a dial-code picker with a text input.
  Widget _phoneField(
      String label,
      bool required,
      IconData icons, {
        TextEditingController? controller,
        FocusNode? focusNode,
        FocusNode? nextFocusNode,
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
                        size: 11.sp, color: AppColors.grey),
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
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTextStyle.body(size: 11.sp),
                  keyboardType: TextInputType.phone,
                  textInputAction: nextFocusNode != null
                      ? TextInputAction.next
                      : TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter number',
                    hintStyle: AppTextStyle.small(
                        size: 11.sp, color: AppColors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(1.w),
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
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 10.h,
          decoration: _box(),
          // Override the Shortcuts ancestor for Enter inside multiline fields
          // so Enter still inserts newlines here.
          child: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.enter): DoNothingAndStopPropagationTextIntent(),
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              style: AppTextStyle.body(size: 11.sp),
              decoration: InputDecoration(
                hintText: label,
                hintStyle:
                AppTextStyle.small(size: 11.sp, color: AppColors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(1.w),
              ),
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
          Text('*',
              style: AppTextStyle.small(size: 11.sp, color: AppColors.red)),
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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  void _prevMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  List<DateTime?> _buildDayCells() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
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
            padding:
            EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.75),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: Icon(Icons.chevron_left,
                      size: 12.sp, color: Colors.white),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Column(
                  children: [
                    Text(
                      _months[_focusedMonth.month - 1],
                      style: AppTextStyle.medium(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Text(
                      '${_focusedMonth.year}',
                      style: AppTextStyle.small(
                          size: 9.sp,
                          color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(Icons.chevron_right,
                      size: 12.sp, color: Colors.white),
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
            padding:
            EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.8.h),
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
                            size: 8.5.sp,
                            weight: FontWeight.w700,
                            color: AppColors.primary.withOpacity(0.7),
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
                              ? AppColors.primary
                              : today
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: AppTextStyle.small(
                              size: 8.5.sp,
                              weight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? Colors.white
                                  : today
                                  ? AppColors.primary
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
                          horizontal: 1.w, vertical: 0.3.h),
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
                          size: 9.sp,
                          color: AppColors.primary,
                          weight: FontWeight.w600),
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