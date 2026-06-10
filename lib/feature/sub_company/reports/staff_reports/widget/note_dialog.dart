import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/note_model.dart';
import 'package:sizer/sizer.dart';

class _NoteEntry {
  final TextEditingController titleController;
  final TextEditingController contentController;

  _NoteEntry({String title = '', String content = ''})
    : titleController = TextEditingController(text: title),
      contentController = TextEditingController(text: content);

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}

class NotesDialog extends StatefulWidget {
  final String id;
  const NotesDialog({super.key, required this.id});

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  // ── existing notes loaded from Firestore ──
  List<NoteModel> _savedNotes = [];

  // ── new entries being typed ───────────────
  final List<_NoteEntry> _newEntries = [_NoteEntry()];

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetch existing notes on open
    context.read<StaffCubit>().fetchNotes(widget.id);
  }

  @override
  void dispose() {
    for (final e in _newEntries) {
      e.dispose();
    }
    super.dispose();
  }

 
  void _removeNewEntry(int index) {
    setState(() {
      _newEntries[index].dispose();
      _newEntries.removeAt(index);
    });
  }

  Future<void> _save() async {
    final validEntries = _newEntries
        .where(
          (e) =>
              e.titleController.text.trim().isNotEmpty ||
              e.contentController.text.trim().isNotEmpty,
        )
        .toList();

    if (validEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one note.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final notes = validEntries
        .map(
          (e) => NoteModel(
            title: e.titleController.text.trim(),
            content: e.contentController.text.trim(),
            createdAt: DateTime.now(),
          ),
        )
        .toList();

    context.read<StaffCubit>().addNotes(widget.id, notes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is NotesLoading) {
          setState(() => _isLoading = true);
        }

        if (state is NotesLoaded) {
          setState(() {
            _savedNotes = state.notes;
            _isLoading = false;
          });
        }

        if (state is NoteSaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notes saved successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          // clear new entries and reset to one blank
          for (final e in _newEntries) {
            e.dispose();
          }
          _newEntries.clear();
          _newEntries.add(_NoteEntry());
          // reload saved notes to show newly added ones
          context.read<StaffCubit>().fetchNotes(widget.id);
        }

        if (state is StaffError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 55.w,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                SizedBox(height: 2.h),
                _body(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notes',
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Saved notes (read-only) ──────────────
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_savedNotes.isNotEmpty) ...[
            Text(
              'Saved Notes',
              style: AppTextStyle.medium(
                size: 11.sp,
                color: AppColors.grey,
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...List.generate(
              _savedNotes.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: _savedNoteCard(_savedNotes[index], index),
              ),
            ),
            Divider(color: const Color(0xFFE5E7EB), height: 3.h),
          ],

          // ─── New entries ──────────────────────────
          Text(
            'Add New Note',
            style: AppTextStyle.medium(
              size: 11.sp,
              color: AppColors.grey,
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          ...List.generate(
            _newEntries.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < _newEntries.length - 1 ? 2.h : 0,
              ),
              child: _newNoteCard(index),
            ),
          ),

          SizedBox(height: 2.h),

          // ─── Action buttons ───────────────────────
          TextButton(
            onPressed: _isSaving ? null : _save,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
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
                      size: 11.sp,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Read-only saved note card ────────────────────────────────────────────

  Widget _savedNoteCard(NoteModel note, int index) {
    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── header row ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Note ${index + 1}',
                style: AppTextStyle.medium(
                  size: 11.sp,
                  color: const Color(0xFF4F6BED),
                  weight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  // date
                  if (note.createdAt != null)
                    Text(
                      '${note.createdAt!.day.toString().padLeft(2, '0')}-'
                      '${note.createdAt!.month.toString().padLeft(2, '0')}-'
                      '${note.createdAt!.year}',
                      style: AppTextStyle.small(
                        size: 9.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  SizedBox(width: 1.w),
                  // delete button
                  GestureDetector(
                    onTap: () {
                      if (note.id == null) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(
                            'Delete Note',
                            style: AppTextStyle.medium(size: 13.sp),
                          ),
                          content: Text(
                            'Are you sure you want to delete this note?',
                            style: AppTextStyle.medium(size: 11.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: AppTextStyle.medium(
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<StaffCubit>().deleteNote(
                                  widget.id,
                                  note.id!,
                                );
                              },
                              child: Text(
                                'Delete',
                                style: AppTextStyle.medium(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.close, size: 12.sp, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 0.8.h),

          // ─── title ───────────────────────────────
          if (note.title.isNotEmpty) ...[
            Text(
              note.title,
              style: AppTextStyle.medium(
                size: 11.sp,
                weight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 0.4.h),
          ],

          // ─── content ─────────────────────────────
          if (note.content.isNotEmpty)
            Text(
              note.content,
              style: AppTextStyle.small(size: 10.sp, color: AppColors.grey),
            ),
        ],
      ),
    );
  }
  // ─── Editable new note card ───────────────────────────────────────────────

  Widget _newNoteCard(int index) {
    final entry = _newEntries[index];
    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Note ${index + 1}',
                style: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
              ),
              if (_newEntries.length > 1)
                GestureDetector(
                  onTap: () => _removeNewEntry(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B4A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Section Title',
            style: AppTextStyle.medium(size: 10.sp, color: AppColors.grey),
          ),
          SizedBox(height: 0.5.h),
          _inputField(
            controller: entry.titleController,
            hint: 'Enter title...',
            maxLines: 1,
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Content',
            style: AppTextStyle.medium(size: 10.sp, color: AppColors.grey),
          ),
          SizedBox(height: 0.5.h),
          _inputField(
            controller: entry.contentController,
            hint: 'Write your note here...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
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
    );
  }
}
