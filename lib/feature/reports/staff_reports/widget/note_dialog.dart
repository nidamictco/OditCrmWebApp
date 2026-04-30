import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class NotesDialog extends StatefulWidget {
  const NotesDialog({super.key});

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 50.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            SizedBox(height: 2.h),
            _body(),
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Notes",
          style: AppTextStyle.heading(
            size: 14.sp,
            color: AppColors.black.withOpacity(0.8),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// BODY CONTAINER
  Widget _body() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Section title",
            style: AppTextStyle.medium(size: 12.sp, color: AppColors.grey),
          ),
          SizedBox(height: 1.h),

          /// INPUT LIST
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controllers.length,
            separatorBuilder: (_, __) => Divider(height: 5.h),
            itemBuilder: (_, index) {
              return _entryField(index);
            },
          ),

          SizedBox(height: 1.h),

          /// ADD BUTTON
          TextButton(
            onPressed: _addEntry,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4F6BED),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "+ Add Entry",
              style: AppTextStyle.medium(color: Colors.white, size: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// SINGLE FIELD
  Widget _entryField(int index) {
    return Row(
      children: [
        /// TEXT FIELD
        Expanded(
          child: TextField(
            controller: _controllers[index],
            decoration: InputDecoration(
              hintText: "Type here...",
              hintStyle: AppTextStyle.small(
                size: 11.sp,
                color: AppColors.grey.withOpacity(0.8),
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// DELETE BUTTON
        Container(
          height: 4.h,
          width: 3.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B4A),
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => _removeEntry(index),
          ),
        ),
      ],
    );
  }
}
