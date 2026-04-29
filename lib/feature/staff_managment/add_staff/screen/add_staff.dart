import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/feature/lead_managment/add_lead/widget/dropdown_with_add.dart';
import 'package:sizer/sizer.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  bool salaryAccount = true;
  bool pettyCash = false;
  bool whatsapp = false;
  bool callLog = false;

  String? selectedDocuments;

   File? selectedImage;
  String fileName = "No file chosen";

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        fileName = picked.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Staff List',
              current: 'Add Staff',
              parent: 'Staff Management',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 2.h,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '4/4',
                              style: AppTextStyle.medium(
                                size: 12,
                                weight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                            SizedBox(width: 0.2.w),
                            Text(
                              'used',
                              style: AppTextStyle.medium(
                                size: 12,
                                weight: FontWeight.w400,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.close, color: AppColors.green),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.w),
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  Container(
                    //  padding: EdgeInsets.symmetric(
                    //           horizontal: 2.w,
                    //           vertical: 2.h,
                    //         ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          child: Text(
                            "Upload Files",
                            style: AppTextStyle.medium(
                              size: 11.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Divider(color: AppColors.divider),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                // width: 15.w,
                                child: Dropdown(
                                  hint: 'select document',
                                  items: [],
                                  selectedValue: selectedDocuments,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedDocuments = val;
                                    });
                                  },
                                  label: "Select Document Name",
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Container(
                                  // width: 10.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Upload Document',
                                        style: AppTextStyle.medium(
                                          size: 11.sp,
                                          // color: AppColors.black.withOpacity(0.77),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'No Files Uploaded',
                                        style: AppTextStyle.medium(
                                          size: 11.sp,
                                          color: AppColors.black.withOpacity(
                                            0.77,
                                          ),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                            width: 10.w,
                            height: 5.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "Submit",
                                style: AppTextStyle.medium(
                                  size: 10.sp,
                                  color: AppColors.white,
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
      ),
    );
  }

  Widget _leftSection() {
    return Column(
      children: [
        InputField(label: "Name*", hint: "Enter Full Name"),
        InputField(label: "Password*", hint: "Password", isPassword: true),
        Dropdown(label: "Staff Type",hint: 'select staff type',),
        InputField(label: "Joining Date", hint: "Joining Date"),

        SizedBox(height: 2.h),

        CheckboxTile(
          title: "Access Official Whatsapp",
          value: whatsapp,
          onChanged: (v) => setState(() => whatsapp = v!),
        ),
        CheckboxTile(
          title: "Access Phone Call Log",
          value: callLog,
          onChanged: (v) => setState(() => callLog = v!),
        ),
      ],
    );
  }

  /// MIDDLE SECTION
  Widget _middleSection() {
    return Column(
      children: [
        InputField(label: "Phone Number*", hint: "Enter Phone Number"),
        DropdownWithAdd(label: "Designation", items: ['Telecalling'], onTap: () {  }, selectedValue: '', onChanged: (String? p1) {  },showIcon: true,),
        InputField(label: "Email Id", hint: "Enter Your Email"),
        InputField(label: "Salary", hint: "Enter Salary"),
        Dropdown(label: "Accessible Users",hint: "select accessible users",),
      ],
    );
  }

  /// RIGHT SECTION
  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Staff Image"),

         SizedBox(height: 1.h),

        /// FILE PICKER BAR
        Container(
          height: 5.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              /// BUTTON
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text("Choose file"),
                ),
              ),

              /// FILE NAME
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Text(
                    fileName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.5.h),

        /// IMAGE PREVIEW BOX
        Container(
          height: 22.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selectedImage == null
              ? Center(
                  child: Text(
                    "No Image Selected",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(height: 2.h),

        Row(
          children: [
            Checkbox(
              value: salaryAccount,
              onChanged: (v) => setState(() => salaryAccount = v!),
            ),
            const Text("Salary A/C"),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: InputField(label: "Opening Balance", hint: ""),
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: InputField(label: "Date", hint: "25-04-2026"),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        Row(
          children: const [
            Icon(Icons.circle, size: 12),
            SizedBox(width: 5),
            Text("Advance Amount"),
            SizedBox(width: 20),
            Icon(Icons.circle_outlined, size: 12),
            SizedBox(width: 5),
            Text("Pending Amount"),
          ],
        ),

        SizedBox(height: 1.h),

        Row(
          children: [
            Checkbox(
              value: pettyCash,
              onChanged: (v) => setState(() => pettyCash = v!),
            ),
            const Text("Petty Cash A/C"),
          ],
        ),
      ],
    );
  }
}

/// INPUT FIELD
class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;

  const InputField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.medium()),
          SizedBox(height: 0.5.h),
          Container(
            height: 5.3.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
              color: AppColors.greyCard,
            ),
            child: TextField(
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

Widget _label(String text, bool required, IconData icons) {
  return Row(
    children: [
      Icon(icons, size: 12.sp, color: AppColors.green),
      SizedBox(width: 0.5.w),
      Text(text, style: AppTextStyle.medium()),
      if (required)
        Text(
          "*",
          style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
        ),
    ],
  );
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
        Text(title),
      ],
    );
  }
}
