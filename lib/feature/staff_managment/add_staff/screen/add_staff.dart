import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/staff_managment/add_staff/model/staff_model.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/add_designation_screen.dart';
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
  String? _designation;
  String? _accessibleUsers;

  File? _selectedImage;
  File? _selectedDocument;
  String _imageFileName = 'No file chosen';
  String _docFileName = 'No file chosen';

  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.staff != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final cubit = context.read<DesignationCubit>();
        print('✅ DesignationCubit found: $cubit');
        cubit.fetchAll();
      } catch (e) {
        print('❌ DesignationCubit NOT found: $e');
      }
    });

    if (_isEditMode) _prefill(widget.staff!);
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
      setState(() {
        _selectedImage = File(picked.path);
        _imageFileName = picked.name;
      });
    }
  }

  Future<void> _pickDocument() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedDocument = File(picked.path);
        _docFileName = picked.name;
      });
    }
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Name is required';
    if (_passwordCtrl.text.trim().isEmpty) return 'Password is required';
    if (_phoneCtrl.text.trim().isEmpty) return 'Phone number is required';
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
      imageUrl: widget.staff?.imageUrl,
      documentName: _selectedDocuments,
      documentUrl: widget.staff?.documentUrl,
      accessibleUsers: _accessibleUsers,
    );

    if (_isEditMode) {
      context.read<StaffCubit>().updateStaff(
        model,
        imageFile: _selectedImage,
        documentFile: _selectedDocument,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 16)),
      );
    } else {
      context.read<StaffCubit>().addStaff(
        model,
        imageFile: _selectedImage,
        documentFile: _selectedDocument,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 16)),
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
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

  /// ✅ FIX: Wrap the Dialog with BlocProvider.value so DesignationPermissionsScreen
  /// can access the SAME DesignationCubit instance that already exists in the tree.
  /// After dialog closes, re-fetch so the dropdown items are fresh.
  void _openDesignationDialog() async {
    final designationCubit = context.read<DesignationCubit>();

    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: designationCubit,
        child: const Dialog(child: DesignationPermissionsScreen()),
      ),
    );

    // Re-fetch after dialog closes so newly added designation appears in list
    if (mounted) {
      designationCubit.fetchAll();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: _isEditMode ? 'Edit Staff' : 'Add Staff',
              current: _isEditMode ? 'Edit Staff' : 'Add Staff',
              parent: 'Staff Management',
              parent2: _isEditMode? 'View Staff' : '',
              onPressed: _isEditMode? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(selectedIndex: 16),
                  ),
                );
              } : null,
              parent2True: _isEditMode?true:false,
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

                  // // ── Upload Files Card ────────────────────────────────
                  // _buildUploadSection(),

                  // SizedBox(height: 2.h),

                  // ── Submit Button ────────────────────────────────────
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
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
        InputField(
          label: 'Password',
          showStar: true,
          hint: 'Password',
          controller: _passwordCtrl,
          isPassword: true,
        ),
        Dropdown(
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
        ),
        BlocBuilder<DesignationCubit, DesignationState>(
          builder: (context, state) {
            // Build the items list from loaded designations
            List<String> designationItems = [];

            if (state is DesignationListLoaded) {
              designationItems = state.designations
                  .map((d) => d.designationName)
                  .toList();
            }

            // If the previously saved designation isn't in the list yet, keep it selectable
            if (_designation != null &&
                _designation!.isNotEmpty &&
                !designationItems.contains(_designation)) {
              designationItems.insert(0, _designation!);
            }
            log('designationItems = ${designationItems.toString()}');
            return DropdownWithAdd(
              label: 'Designation',
              // ✅ Live list from Firestore via cubit
              items: designationItems,
              selectedValue: _designation,
              showStar: true,
              // ✅ FIX: Pass the cubit into the dialog so it doesn't throw
              onTap: _openDesignationDialog,
              onChanged: (v) => setState(() => _designation = v),
            );
          },
        ),
        InputField(
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

        // File picker bar
        _buildFilePicker(fileName: _imageFileName, onTap: _pickImage),

        SizedBox(height: 1.5.h),

        // Image preview
        Container(
          height: 22.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage == null
              ? Center(
                  child: Text(
                    widget.staff?.imageUrl != null
                        ? 'Existing image (tap to replace)'
                        : 'No Image Selected',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
        ),

        SizedBox(height: 2.h),
      ],
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
                      width: 1.5.w,
                      height: 1.5.w,
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
  const InputField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.showStar = false,
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
                Text("*", style: AppTextStyle.medium(color: Colors.red)),
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
