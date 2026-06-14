import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/alert_dialog.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/note_model.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────
// NOTES DIALOG  — add-only, no list
// ─────────────────────────────────────────────

class NotesDialog extends StatefulWidget {
  final String id;
  const NotesDialog({super.key, required this.id});

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      showAlertDialog(
        context,
        message: 'Please fill at least one note.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    setState(() => _isSaving = true);

    context.read<StaffCubit>().addNotes(widget.id, [
      NoteModel(title: title, content: content, createdAt: DateTime.now()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is NoteSaved) {
          // 1. Close THIS dialog first, signalling the drawer to refresh
          Navigator.pop(context, true);

          // 2. Show success alert on top of the drawer (via root context)
          showAlertDialog(
            context,
            message: 'Note saved successfully.',
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
          );
        }

        if (state is StaffError) {
          setState(() => _isSaving = false);
          showAlertDialog(
            context,
            message: state.message,
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        }
      },
      child: Dialog(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Note',
                    style: AppTextStyle.heading(
                      size: 14.sp,
                      color: AppColors.black.withOpacity(0.8),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ── Body ──────────────────────────────────
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title field
                    Text(
                      'Title',
                      style: AppTextStyle.medium(
                        size: 11.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    _inputField(
                      controller: _titleController,
                      hint: 'Enter title...',
                      maxLines: 1,
                    ),

                    SizedBox(height: 1.5.h),

                    // Content field
                    Text(
                      'Content',
                      style: AppTextStyle.medium(
                        size: 10.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    _inputField(
                      controller: _contentController,
                      hint: 'Write your note here...',
                      maxLines: 4,
                    ),

                    SizedBox(height: 2.h),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save',
                                style: AppTextStyle.medium(
                                  color: Colors.white,
                                  size: 12.sp,
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      color: AppColors.background,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.grey.withOpacity(0.6),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F6BED)),
          ),
        ),
      ),
    );
  }
}