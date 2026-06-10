import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/inputfield_for_psswrd.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:oxdo/feature/sub_company/sidebar/main_screen.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/screen/add_designation_screen.dart';
import 'package:sizer/sizer.dart';

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

  String? _selectedDocuments;
  String? _staffType;
  String? _accessibleUsers;

  String? _designation;
  String? _designationId;

  // ─── Image / Document ─────────────────────────────────────────────────────
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // used for preview on all platforms
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

    context.read<StaffCubit>().reset();
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
      _clearAll(); // 👈 explicitly clear everything
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

  Future<void> _pickDocument() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedDocumentBytes = bytes;
        if (!kIsWeb) _selectedDocument = File(picked.path);
        _docFileName = picked.name;
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
    if (_passwordCtrl.text.trim().length < 6)
      return 'Password must be at least 6 characters';

    if (_phoneCtrl.text.trim().isEmpty) return 'Phone number is required';

    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) return 'Phone number must be exactly 10 digits';
    if (phone.length > 10) return 'Phone number must be exactly 10 digits';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone))
      return 'Phone number must be 10 digits only';

    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';

    if (_staffType == null || _staffType!.isEmpty)
      return 'Please select a staff type';

    if (_designation == null || _designation!.isEmpty)
      return 'Please select a designation';

    if (_joiningDateCtrl.text.trim().isNotEmpty) {
      final dateText = _joiningDateCtrl.text.trim();

      final regex = RegExp(
        r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(19|20)\d{2}$',
      );

      if (!regex.hasMatch(dateText)) {
        return 'Joining Date must be in DD-MM-YYYY format';
      }

      try {
        final parts = dateText.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final date = DateTime(year, month, day);

        if (date.day != day || date.month != month || date.year != year) {
          return 'Please enter a valid date';
        }
      } catch (_) {
        return 'Please enter a valid date';
      }
    }

    return null;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _handleSubmit() {
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    final model = StaffModel(
      id: widget.staff?.id,
      name: _nameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      designation: _designation,
      designationId: _designationId,
      staffType: _staffType,
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
      imageUrl:_existingImageRemoved ? null : widget.staff?.imageUrl,
      documentName: _selectedDocuments,
      documentUrl: widget.staff?.documentUrl,
      accessibleUsers: _accessibleUsers,
    );

    // On web, File is not available — pass null for file args
    final imageFile = kIsWeb ? null : _selectedImage;
    final documentFile = kIsWeb ? null : _selectedDocument;

    if (_isEditMode) {
      context.read<StaffCubit>().updateStaff(
        model,
        imageFile: kIsWeb ? null : _selectedImage,
        imageBytes: kIsWeb ? _selectedImageBytes : null,
        imageFileName: kIsWeb ? _imageFileName : null,
        documentFile: kIsWeb ? null : _selectedDocument,
        documentBytes: kIsWeb ? _selectedDocumentBytes : null,
        documentFileName: kIsWeb ? _docFileName : null,
      );
    } else {
      context.read<StaffCubit>().addStaff(
        model,
        imageFile: kIsWeb ? null : _selectedImage,
        imageBytes: kIsWeb ? _selectedImageBytes : null,
        imageFileName: kIsWeb ? _imageFileName : null,
        documentFile: kIsWeb ? null : _selectedDocument,
        documentBytes: kIsWeb ? _selectedDocumentBytes : null,
        documentFileName: kIsWeb ? _docFileName : null,
      );
    }

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 16)),
    // );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyle.body(color: AppColors.white),
        ),
        backgroundColor: isError ? AppColors.red : AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─── Open Designation Dialog ──────────────────────────────────────────────

  void _openDesignationDialog() async {
    final designationCubit = context.read<DesignationCubit>();

    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: designationCubit,
        child: const Dialog(child: DesignationPermissionsScreen()),
      ),
    );

    if (mounted) {
      await designationCubit.fetchAll();
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
           // ── Refresh TopBar profile image if editing the logged-in user ──
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 16)),
          );
        }
        if (state is StaffError) {
          _showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StaffTopBar(
                title: _isEditMode ? 'Edit Staff' : 'Add Staff',
                current: _isEditMode ? 'Edit Staff' : 'Add Staff',
                parent: 'Staff Management',
                parent2: _isEditMode ? 'View Staff' : '',
                onPressed: _isEditMode
                    ? () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => MainScreen(selectedIndex: 16),
                        //   ),
                        // );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainScreen(selectedIndex: 16),
                            ),
                          );
                        });
                      }
                    : null,
                parent2True: _isEditMode ? true : false,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
                child: Column(
                  children: [
                    // ── Main Form Card ───────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _leftSection()),
                          SizedBox(width: 2.w),
                          Expanded(child: _middleSection()),
                          SizedBox(width: 2.w),
                          Expanded(child: _rightSection()),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // ── Submit Button ────────────────────────────────────
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Left Section ─────────────────────────────────────────────────────────

  Widget _leftSection() {
    return Column(
      children: [
        InputField(
          label: 'Name',
          showStar: true,
          hint: 'Enter Full Name',
          controller: _nameCtrl,
        ),
        InputFieldForPsswrd(
          label: 'Password',
          showStar: true,
          hint: 'Password',
          controller: _passwordCtrl,
        ),
        Dropdown(
          showStar: true,
          label: 'Staff Type',
          hint: 'Select staff type',
          items: const [
            'Admin',
            'Marketing',
            'Team Lead',
            'Technical',
            'Telecalling',
          ],
          selectedValue: _staffType,
          onChanged: (v) => setState(() => _staffType = v),
        ),
        SizedBox(height: 0.8.h),
        InputField(
          label: 'Joining Date',
          hint: 'DD-MM-YYYY',
          controller: _joiningDateCtrl,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  // ─── Middle Section ───────────────────────────────────────────────────────

  Widget _middleSection() {
    return Column(
      children: [
        InputField(
          label: 'Phone Number',
          showStar: true,
          hint: 'Enter Phone Number',
          controller: _phoneCtrl,
          isPhone: true,
        ),
        BlocBuilder<DesignationCubit, DesignationState>(
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

            return DropdownWithAdd(
              label: 'Designation',
              items: designationItems,
              selectedValue: _designation,
              showStar: true,
              onTap: _openDesignationDialog,
              onChanged: (v) => setState(() {
                _designation = v;
                _designationId = v != null ? designationMap[v] : null;
              }),
            );
          },
        ),
        SizedBox(height: 0.8.h),
        InputField(
          showStar: true,
          label: 'Email Id',
          hint: 'Enter Your Email',
          controller: _emailCtrl,
        ),
        InputField(
          label: 'Salary',
          hint: 'Enter Salary',
          controller: _salaryCtrl,
        ),
      ],
    );
  }

  // ─── Right Section ────────────────────────────────────────────────────────

  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Staff Image', style: AppTextStyle.medium()),
        SizedBox(height: 1.h),

        _buildFilePicker(fileName: _imageFileName, onTap: _pickImage),

        SizedBox(height: 1.5.h),

        // ── Image Preview (web-safe) ───────────────────────────────
        Container(
          height: 22.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildImagePreview(),
        ),

        SizedBox(height: 2.h),
      ],
    );
  }

 Widget _buildImagePreview() {
  // 1. Newly picked image
  if (_selectedImageBytes != null) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 6, right: 6,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Existing network image — only show if NOT removed
  if (widget.staff?.imageUrl != null && !_existingImageRemoved) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.staff!.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator()));
            },
            errorBuilder: (_, __, ___) => const Center(child: Text('Failed to load image')),
          ),
        ),
        Positioned(
          top: 6, right: 6,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Placeholder
  return Center(
    child: Text('No Image Selected', style: TextStyle(color: Colors.grey.shade500)),
  );
}
  // ─── Upload Section ───────────────────────────────────────────────────────

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              'Upload Files',
              style: AppTextStyle.medium(
                size: 11.sp,
                color: AppColors.black.withOpacity(0.77),
                weight: FontWeight.w600,
              ),
            ),
          ),
          Divider(color: AppColors.divider),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Dropdown(
                    hint: 'Select document',
                    items: const ['Aadhaar', 'PAN', 'Passport', 'Other'],
                    selectedValue: _selectedDocuments,
                    onChanged: (v) => setState(() => _selectedDocuments = v),
                    label: 'Select Document Name',
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Document',
                        style: AppTextStyle.medium(
                          size: 11.sp,
                          weight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      _buildFilePicker(
                        fileName: _docFileName,
                        onTap: _pickDocument,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return BlocBuilder<StaffCubit, StaffState>(
      builder: (context, state) {
        final isSaving = state is StaffSaving;
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 10.w,
            height: 5.h,
            child: ElevatedButton(
              onPressed: isSaving ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaving ? AppColors.grey : AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Update' : 'Submit',
                      style: AppTextStyle.medium(
                        size: 10.sp,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ─── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildFilePicker({
    required String fileName,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 5.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(right: BorderSide(color: Colors.grey.shade400)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Choose file',
                style: AppTextStyle.medium(size: 10.sp),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                fileName,
                style: TextStyle(color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final bool showStar;
  final bool isPhone;

  const InputField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.showStar = false,
    this.isPhone=false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyle.medium()),
              if (showStar)
                Text('*', style: AppTextStyle.medium(color: Colors.red)),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            height: 5.3.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
              color: AppColors.greyCard,
            ),
            child: TextField(
              controller: controller,
              style: AppTextStyle.body(size: 11.sp),
              obscureText: isPassword,
              inputFormatters: [
  if (isPhone) FilteringTextInputFormatter.digitsOnly,
  if (isPhone) LengthLimitingTextInputFormatter(10),
],
keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(1.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckboxTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) onChanged;

  const CheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(title, style: AppTextStyle.medium()),
      ],
    );
  }
}
