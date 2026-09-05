import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:Odit_CRM/core/utils/dropdown_without_search.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_style.dart';
import '../../../../../../auth/cubit/auth/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import '../../../cubit/add_staff_cubit.dart';
import '../../../cubit/add_staff_state.dart';
import '../../../model/staff_model.dart';
import '../../../../designation/cubit/designation_cubit.dart';
import '../../../../designation/screen/add_designation_screen.dart';

class AddStaff extends StatefulWidget {
  final StaffModel? staff;
  const AddStaff({super.key, this.staff});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  // ─── Controllers ──────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _openingBalCtrl = TextEditingController();
  final _openingBalDateCtrl = TextEditingController();
  final _joiningDateCtrl = TextEditingController();

  // ─── State ────────────────────────────────────────────────────────────────
  bool _salaryAccount = true;
  bool _pettyCash = false;
  bool _whatsapp = false;
  bool _callLog = false;
  bool _obscurePassword = true;

  String? _selectedDocuments;
  String? _staffType;
  String? _accessibleUsers;

  String? _designation;
  String? _designationId;

  // ─── Image / Document ─────────────────────────────────────────────────────
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  File? _selectedDocument;
  Uint8List? _selectedDocumentBytes;

  String _imageFileName = 'No file chosen';
  String _docFileName = 'No file chosen';
  bool _existingImageRemoved = false;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.staff != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final cubit = context.read<DesignationCubit>();
        cubit.fetchAll();
      } catch (e) {
        log('❌ DesignationCubit NOT found: $e');
      }
    });

    if (_isEditMode) {
      _prefill(widget.staff!);
    } else {
      _clearAll();
    }
  }

  void _prefill(StaffModel s) {
    _nameCtrl.text = s.name;
    _passwordCtrl.text = s.password;
    _phoneCtrl.text = s.phone;
    _emailCtrl.text = s.email ?? '';
    _salaryCtrl.text = s.salary ?? '';
    _openingBalCtrl.text = s.openingBalance ?? '';
    _openingBalDateCtrl.text = s.openingBalanceDate ?? '';
    _joiningDateCtrl.text = s.joiningDate ?? '';
    _staffType = s.staffType;
    _designation = s.designation;
    _designationId = s.designationId;
    _accessibleUsers = s.accessibleUsers;
    _whatsapp = s.accessWhatsapp;
    _callLog = s.accessCallLog;
    _salaryAccount = s.hasSalaryAccount;
    _pettyCash = s.hasPettyCash;
    _imageFileName = s.imageUrl != null ? 'Existing image' : 'No file chosen';
    _docFileName =
        s.documentName ??
        (s.documentUrl != null ? 'Existing doc' : 'No file chosen');
    _selectedDocuments = s.documentName;
  }

  void _clearAll() {
    _nameCtrl.clear();
    _passwordCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _salaryCtrl.clear();
    _openingBalCtrl.clear();
    _openingBalDateCtrl.clear();
    _joiningDateCtrl.clear();

    _salaryAccount = true;
    _pettyCash = false;
    _whatsapp = false;
    _callLog = false;

    _selectedDocuments = null;
    _staffType = null;
    _accessibleUsers = null;
    _designation = null;
    _designationId = null;

    _selectedImage = null;
    _selectedImageBytes = null;
    _selectedDocument = null;
    _selectedDocumentBytes = null;

    _imageFileName = 'No file chosen';
    _docFileName = 'No file chosen';
    _existingImageRemoved = false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _salaryCtrl.dispose();
    _openingBalCtrl.dispose();
    _openingBalDateCtrl.dispose();
    _joiningDateCtrl.dispose();
    super.dispose();
  }

  // ─── File Pickers ─────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        if (!kIsWeb) _selectedImage = File(picked.path);
        _imageFileName = picked.name;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _imageFileName = 'No file chosen';
      _existingImageRemoved = true;
    });
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Name is required';

    if (_passwordCtrl.text.trim().isEmpty) return 'Password is required';
    if (_passwordCtrl.text.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (_phoneCtrl.text.trim().isEmpty) return 'Phone number is required';

    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Phone number must be exactly 10 digits';
    }
    if (phone.length > 12 || !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Phone number must be less than 12 digits';
    }

    if(_emailCtrl.text.trim().isEmpty){
      return 'Email is required';
    }

    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    }

    if (_staffType == null || _staffType!.isEmpty) {
      return 'Please select a staff type';
    }

    if (_designation == null || _designation!.isEmpty) {
      return 'Please select a designation';
    }

    return null;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    final isCompanyAdmin =
        _isEditMode && widget.staff?.designation == "Company_Admin";

    final model = StaffModel(
      id: widget.staff?.id,
      name: _nameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      designation: isCompanyAdmin ? widget.staff?.designation : _designation,
      designationId: isCompanyAdmin
          ? widget.staff?.designationId
          : _designationId,
      staffType: isCompanyAdmin ? widget.staff?.staffType : _staffType,
      joiningDate: _joiningDateCtrl.text.trim().isEmpty
          ? null
          : _joiningDateCtrl.text.trim(),
      salary: _salaryCtrl.text.trim().isEmpty ? null : _salaryCtrl.text.trim(),
      openingBalance: _openingBalCtrl.text.trim().isEmpty
          ? null
          : _openingBalCtrl.text.trim(),
      openingBalanceDate: _openingBalDateCtrl.text.trim().isEmpty
          ? null
          : _openingBalDateCtrl.text.trim(),
      accessWhatsapp: _whatsapp,
      accessCallLog: _callLog,
      hasSalaryAccount: _salaryAccount,
      hasPettyCash: _pettyCash,
      imageUrl: _existingImageRemoved ? null : widget.staff?.imageUrl,
      documentName: _selectedDocuments,
      documentUrl: widget.staff?.documentUrl,
      accessibleUsers: _accessibleUsers,
      status: widget.staff?.status ?? 'Active',
    );

    final imageFile = kIsWeb ? null : _selectedImage;
    final documentFile = kIsWeb ? null : _selectedDocument;

    if (_isEditMode) {
      await context.read<StaffCubit>().updateStaff(
        model,
        imageFile: imageFile,
        imageBytes: kIsWeb ? _selectedImageBytes : null,
        imageFileName: kIsWeb ? _imageFileName : null,
        documentFile: documentFile,
        documentBytes: kIsWeb ? _selectedDocumentBytes : null,
        documentFileName: kIsWeb ? _docFileName : null,
      );
    } else {
      await context.read<StaffCubit>().addStaff(
        model,
        imageFile: imageFile,
        imageBytes: kIsWeb ? _selectedImageBytes : null,
        imageFileName: kIsWeb ? _imageFileName : null,
        documentFile: documentFile,
        documentBytes: kIsWeb ? _selectedDocumentBytes : null,
        documentFileName: kIsWeb ? _docFileName : null,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       message,
    //       style: AppTextStyle.body(color: AppColors.white),
    //     ),
    //     backgroundColor: isError ? AppColors.red : AppColors.green,
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //   ),
    // );
     StatusAlertWidget.show(
                    context,
                    isSuccess: false,
                    title: "Validation",
                    message: message,
                    onButtonPressed: () {
                      if (!context.mounted) return;
                      // Navigator.pop(context); // just dismiss the status alert
                      context.pop();
                     
                    },
                  );
  }

  // ─── Open Designation Dialog ──────────────────────────────────────────────

  // void _openDesignationDialog() async {
  //   final designationCubit = context.read<DesignationCubit>();

  //   final result = await showDialog<Map<String, dynamic>>(
  //     context: context,
  //     builder: (_) => BlocProvider.value(
  //       value: designationCubit,
  //       child: const Dialog(child: DesignationPermissionsScreen()),
  //     ),
  //   );

  //   if (mounted) {
  //     await designationCubit.fetchAll();
  //     if (result != null && result['name'] != null && result['id'] != null) {
  //       setState(() {
  //         _designation = result['name'] as String;
  //         _designationId = result['id'] as String;
  //       });
  //     }
  //   }
  // }
void _openDesignationDialog() async {
  final designationCubit = context.read<DesignationCubit>();

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: designationCubit,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const DesignationPermissionsScreen(),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (mounted) {
    await designationCubit.fetchAll();
    if (result != null && result['name'] != null && result['id'] != null) {
      setState(() {
        _designation = result['name'] as String;
        _designationId = result['id'] as String;
      });
    }
  }
}
  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listenWhen: (previous, current) =>
          current is StaffSaved || current is StaffError,
      listener: (context, state) {
        if (state is StaffSaved) {
          if (_isEditMode) {
            final authState = context.read<AuthCubit>().state;
            if (authState is Authenticated) {
              final loggedInId = authState.user.id;
              final editingId = widget.staff?.id;
              if (loggedInId != null && loggedInId == editingId) {
                context.read<AuthCubit>().refreshUser(loggedInId);
              }
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: _isEditMode
                  ? const Text('Staff updated successfully.')
                  : const Text('Staff added successfully.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.green,
            ),
          );

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            context.go(RoutePaths.viewStaff);
          }
        }
        if (state is StaffError) {
          final rawMsg = state.message;
          var friendlyMsg = rawMsg.startsWith('Exception: ')
              ? rawMsg.substring('Exception: '.length)
              : rawMsg;
          if (friendlyMsg.contains("Phone number already exists.")) {
            friendlyMsg =
                "This phone number is already registered. Please use a different phone number.";
          }
          _showSnack(friendlyMsg, isError: true);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Image Upload Box ───────────────────────────────────────
                  _buildUploadImageBox(),

                  const SizedBox(height: 20),

                  // ─── Form Fields (Two Columns) ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildStaffNameField(),
                            const SizedBox(height: 12),
                            _buildPasswordField(),
                            const SizedBox(height: 12),
                            _buildStaffTypeField(),
                            const SizedBox(height: 12),
                            _buildJoiningDateField(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildContactNumberField(),
                            const SizedBox(height: 12),
                            _buildDesignationField(),
                            const SizedBox(height: 12),
                            _buildEmailField(),
                            const SizedBox(height: 12),
                            _buildSalaryField(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ─── Action Buttons (Cancel & Submit) ───────────────────────
                  BlocBuilder<StaffCubit, StaffState>(
                    builder: (context, state) {
                      final isSaving = state is StaffSaving;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyle.medium(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF344054),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isSaving ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeColors.basicGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isEditMode ? 'Update' : 'Submit',
                                    style: AppTextStyle.medium(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Image Upload Widget ───────────────────────────────────────────────────

  Widget _buildUploadImageBox() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        color: AppThemeColors.borderClr.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashPattern: const [2, 2],
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.staff?.imageUrl != null && !_existingImageRemoved) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.staff!.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  'Failed to load image',
                  style: AppTextStyle.medium(fontSize: 11.5),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_outline_rounded,
          size: 28,
          color: Color(0xFF667085),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload Image',
          style: AppTextStyle.medium(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Drop file or click here to choose file.',
            textAlign: TextAlign.center,
            style: AppTextStyle.medium(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF667085),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Fields Implementation ────────────────────────────────────────────────

  Widget _buildStaffNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Staff Name',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344054),
              ),
            ),
            Text(
              '*',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFD92D20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter full name',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Number',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344054),
              ),
            ),
            Text(
              '*',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFD92D20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF00B16E),
                      width: .5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇮🇳', style: AppTextStyle.medium(fontSize: 11.5)),
                      const SizedBox(width: 4),
                      Text(
                        '+91',
                        style: AppTextStyle.medium(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF344054),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: '0000 0000 00',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12, left: 8),
                child: Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344054),
              ),
            ),
            Text('*',style: AppTextStyle.medium(fontSize: 11.5,color: AppColors.red),)
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: const Color(0xFF667085),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildDesignationField() {
  return BlocBuilder<DesignationCubit, DesignationState>(
    builder: (context, state) {
      List<String> designationItems = [];
      Map<String, String> designationMap = {};

      if (state is DesignationListLoaded) {
        for (final d in state.designations) {
          designationItems.add(d.designationName);
          if (d.id != null) {
            designationMap[d.designationName] = d.id!;
          }
        }
      }

      if (_designation != null &&
          _designation!.isNotEmpty &&
          !designationItems.contains(_designation)) {
        designationItems.insert(0, _designation!);
      }

      const addNewLabel = '+ Add New Designation';
      designationItems.add(addNewLabel);

      final isCompanyAdmin =
          _isEditMode && widget.staff?.designation == "Company_Admin";

      return SimpleDropdown(
        label: 'Designation',
        hint: 'Select Designation',
        showStar: true,
        showClear: false,
        enabled: !isCompanyAdmin,
        items: designationItems,
        selectedValue: _designation,
        onChanged: (val) {
          if (val == addNewLabel) {
            _openDesignationDialog();
            return;
          }
          setState(() {
            _designation = val;
            _designationId = val == null ? null : designationMap[val];
          });
        },
      );
    },
  );
}

Widget _buildStaffTypeField() {
  final isCompanyAdmin =
      _isEditMode && widget.staff?.designation == "Company_Admin";
  final staffTypeItems = const [
    'Admin',
    'Marketing',
    'Team Lead',
    'Technical',
    'Telecalling',
  ];

  return SimpleDropdown(
    label: 'Staff Type',
    hint: 'Select Staff Type',
    showStar: true,
    showClear: false,
    enabled: !isCompanyAdmin,
    items: staffTypeItems,
    selectedValue: _staffType,
    onChanged: (val) => setState(() => _staffType = val),
  );
}

  // Widget _buildDesignationField() {
  //   return BlocBuilder<DesignationCubit, DesignationState>(
  //     builder: (context, state) {
  //       List<String> designationItems = [];
  //       Map<String, String> designationMap = {};

  //       if (state is DesignationListLoaded) {
  //         for (final d in state.designations) {
  //           designationItems.add(d.designationName);
  //           if (d.id != null) {
  //             designationMap[d.designationName] = d.id!;
  //           }
  //         }
  //       }

  //       if (_designation != null &&
  //           _designation!.isNotEmpty &&
  //           !designationItems.contains(_designation)) {
  //         designationItems.insert(0, _designation!);
  //       }

  //       final isCompanyAdmin =
  //           _isEditMode && widget.staff?.designation == "Company_Admin";

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Text(
  //                 'Designation',
  //                 style: AppTextStyle.medium(
  //                   fontSize: 11.5,
  //                   fontWeight: FontWeight.w500,
  //                   color: const Color(0xFF344054),
  //                 ),
  //               ),
  //               Text('*',style: AppTextStyle.medium(fontSize: 11.5,color: AppColors.red),)
  //             ],
  //           ),
  //           const SizedBox(height: 5),
  //           PopupMenuButton<String>(
  //             enabled: !isCompanyAdmin,
  //             onSelected: (val) {
  //               if (val == '__ADD_NEW__') {
  //                 _openDesignationDialog();
  //               } else {
  //                 setState(() {
  //                   _designation = val;
  //                   _designationId = designationMap[val];
  //                 });
  //               }
  //             },
  //             itemBuilder: (context) => [
  //               ...designationItems.map(
  //                 (item) => PopupMenuItem<String>(
  //                   value: item,
  //                   child: Text(
  //                     item,
  //                     style: AppTextStyle.medium(fontSize: 11.5),
  //                   ),
  //                 ),
  //               ),
  //               const PopupMenuDivider(),
  //               PopupMenuItem<String>(
  //                 value: '__ADD_NEW__',
  //                 child: Row(
  //                   children: [
  //                     const Icon(
  //                       Icons.add,
  //                       size: 16,
  //                       color: AppThemeColors.basicGreen,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       'Add New Designation',
  //                       style: AppTextStyle.medium(
  //                         fontSize: 11.5,
  //                         color: const Color(0xFF00B074),
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //             child: Container(
  //               height: 40,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: AppThemeColors.textfieldBorder),
  //               ),
  //               padding: const EdgeInsets.symmetric(horizontal: 12),
  //               child: Row(
  //                 children: [
  //                   GestureDetector(
  //                     onTap: isCompanyAdmin ? null : _openDesignationDialog,
  //                     child: Container(
  //                       width: 20,
  //                       height: 20,
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFF00B074),
  //                         borderRadius: BorderRadius.circular(4),
  //                       ),
  //                       child: const Icon(
  //                         Icons.add,
  //                         size: 14,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Text(
  //                       _designation ?? 'Select Designation',
  //                       style: AppTextStyle.medium(
  //                         fontSize: 11.5,
  //                         color: _designation != null
  //                             ? const Color(0xFF101828)
  //                             : const Color(0xFF98A2B3),
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   const Icon(
  //                     Icons.keyboard_arrow_down_rounded,
  //                     size: 20,
  //                     color: Color(0xFF667085),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildStaffTypeField() {
  //   final isCompanyAdmin =
  //       _isEditMode && widget.staff?.designation == "Company_Admin";
  //   final staffTypeItems = const [
  //     'Admin',
  //     'Marketing',
  //     'Team Lead',
  //     'Technical',
  //     'Telecalling',
  //   ];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             'Staff Type',
  //             style: AppTextStyle.medium(
  //               fontSize: 11.5,
  //               fontWeight: FontWeight.w500,
  //               color: const Color(0xFF344054),
  //             ),
  //           ),
  //           Text('*',style: AppTextStyle.medium(fontSize: 11.5,color: AppColors.red),)
  //         ],
  //       ),
  //       const SizedBox(height: 5),
  //       PopupMenuButton<String>(
  //         enabled: !isCompanyAdmin,
  //         onSelected: (val) => setState(() => _staffType = val),
  //         itemBuilder: (context) => staffTypeItems
  //             .map(
  //               (item) => PopupMenuItem<String>(
  //                 value: item,
  //                 child: Text(item, style: AppTextStyle.medium(fontSize: 11.5)),
  //               ),
  //             )
  //             .toList(),
  //         child: Container(
  //           height: 40,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: AppThemeColors.textfieldBorder),
  //           ),
  //           padding: const EdgeInsets.symmetric(horizontal: 12),
  //           child: Row(
  //             children: [
  //               const Icon(
  //                 Icons.person_outline_rounded,
  //                 size: 18,
  //                 color: Color(0xFF667085),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   _staffType ?? 'Select staff type',
  //                   style: AppTextStyle.medium(
  //                     fontSize: 11.5,
  //                     color: _staffType != null
  //                         ? const Color(0xFF101828)
  //                         : const Color(0xFF98A2B3),
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               const Icon(
  //                 Icons.keyboard_arrow_down_rounded,
  //                 size: 20,
  //                 color: Color(0xFF667085),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Email Id',
              style: AppTextStyle.medium(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344054),
              ),
            ),
            Text('*',style: AppTextStyle.medium(fontSize: 11.5,color: AppColors.red),)
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email id',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoiningDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Joining Date',
          style: AppTextStyle.medium(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _joiningDateCtrl,
                  readOnly: true,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final day = picked.day.toString().padLeft(2, '0');
                      final month = picked.month.toString().padLeft(2, '0');
                      final year = picked.year;
                      setState(() {
                        _joiningDateCtrl.text = '$day-$month-$year';
                      });
                    }
                  },
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: '25-06-2026',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary',
          style: AppTextStyle.medium(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppThemeColors.textfieldBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _salaryCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyle.medium(
                    fontSize: 11.5,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w400,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter Salary',
                    hintStyle: AppTextStyle.medium(
                      fontSize: 11.5,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }
}
