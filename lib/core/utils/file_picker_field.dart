import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

// =============================================================================
//  FilePickerField
//
//  Looks exactly like the browser native <input type="file"> widget:
//
//  ┌──────────────┬─────────────────────────────┐
//  │  Choose file │  No file chosen              │
//  └──────────────┴─────────────────────────────┘
//
//  Usage:
//    FilePickerField(
//      onFilePicked: (file) => print(file.path),
//    )
// =============================================================================

class FilePickerField extends StatefulWidget {
  /// Called with the picked [File] (null if user cancels).
  final ValueChanged<File?>? onFilePicked;

  /// Allowed extensions, e.g. ['pdf', 'jpg', 'png'].
  /// Leave null to allow any file type.
  final List<String>? allowedExtensions;

  /// Placeholder shown before a file is chosen.
  final String placeholder;

  const FilePickerField({
    super.key,
    this.onFilePicked,
    this.allowedExtensions,
    this.placeholder = 'No file chosen',
  });

  @override
  State<FilePickerField> createState() => _FilePickerFieldState();
}

class _FilePickerFieldState extends State<FilePickerField> {
  String _fileName = '';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() => _fileName = result.files.single.name);
      widget.onFilePicked?.call(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffCBD5E1)), // slate-300
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            // ── "Choose file" button half ────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: const BoxDecoration(
                color: AppColors.greyCard,
                border: Border(right: BorderSide(color: AppColors.greyCard)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Choose file',
                style: AppTextStyle.body(color: AppColors.black, size: 9.5.sp),
              ),
            ),

            // ── File name / placeholder half ─────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Text(
                  _fileName.isEmpty ? widget.placeholder : _fileName,
                  style: AppTextStyle.body(
                    color: _fileName.isEmpty ? AppColors.grey : AppColors.black,
                    size: 9.5.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
