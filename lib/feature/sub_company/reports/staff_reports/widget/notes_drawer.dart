// // ─────────────────────────────────────────────
// // NOTES DRAWER — fetch, search, and display only
// // ─────────────────────────────────────────────

import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/note_dialog.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/note_model.dart';

// ─────────────────────────────────────────────
// RECENT NOTES PANEL — fixed right-side panel
// Replaces the old NotesDrawer. Same fetch/search/
// add/delete logic — UI + layout only.
// ─────────────────────────────────────────────
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

/// Panel breakpoints — reuse these from wherever you lay out the
/// Profile Details screen so panel width + mobile fallback stay in sync.
class NotesPanelBreakpoints {
  static const double mobile = 700;
  static const double tablet = 1100;
}

/// Fixed, always-visible Notes panel for desktop/tablet layouts.
/// For mobile, don't place this in the layout — instead call
/// [showNotesAsSheet] (bottom sheet) or open it in a [Drawer] from
/// the Scaffold's `endDrawer`, keeping the same [RecentNotesPanel]
/// as the drawer's child.
class RecentNotesPanel extends StatefulWidget {
  final String staffId;

  /// Panel width for desktop. Ignored when used inside a Drawer/BottomSheet.
  final double width;
  final double? height;

  const RecentNotesPanel({
    super.key,
    required this.staffId,
    this.width = 440,
    this.height,
  });

  @override
  State<RecentNotesPanel> createState() => _RecentNotesPanelState();
}

class _RecentNotesPanelState extends State<RecentNotesPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StaffCubit>().fetchNotes(widget.staffId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddNoteDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffCubit>(),
        child: NotesDialog(id: widget.staffId),
      ),
    );

    if (saved == true && mounted) {
      context.read<StaffCubit>().fetchNotes(widget.staffId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          RecentNotesHeader(onAddNote: _openAddNoteDialog),
          NotesSearchField(
            controller: _searchController,
            onChanged: (v) =>
                setState(() => _searchQuery = v.trim().toLowerCase()),
          ),
          Expanded(
            child: BlocBuilder<StaffCubit, StaffState>(
              buildWhen: (prev, curr) =>
                  curr is NotesLoading ||
                  curr is NotesLoaded ||
                  curr is StaffError,
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StaffError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.message,
                        style: AppTextStyle.medium(
                          size: 11.5,
                          color: AppColors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (state is NotesLoaded) {
                  final notes = _searchQuery.isEmpty
                      ? state.notes
                      : state.notes
                            .where(
                              (n) =>
                                  (n.title).toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  (n.content).toLowerCase().contains(
                                    _searchQuery,
                                  ),
                            )
                            .toList();

                  if (notes.isEmpty) return const EmptyNotesView();

                  return NoteList(notes: notes, staffId: widget.staffId);
                }

                return const EmptyNotesView();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the same panel content as a modal bottom sheet — for mobile.
Future<void> showNotesAsSheet(BuildContext context, String staffId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: 0.9,
      child: BlocProvider.value(
        value: context.read<StaffCubit>(),
        child: SizedBox(
          width: double.infinity,
          child: RecentNotesPanel(
            staffId: staffId,
            width: 340,
            height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class RecentNotesHeader extends StatelessWidget {
  final VoidCallback onAddNote;
  const RecentNotesHeader({super.key, required this.onAddNote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recent Note',
                  style: AppTextStyle.heading(
                    size: 16,
                    color: AppThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      height: 2,
                      width: 110,
                      decoration: BoxDecoration(
                        color: AppThemeColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onAddNote,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Add New Note?',
                style: AppTextStyle.medium(
                  size: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.growthGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────

class NotesSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const NotesSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppThemeColors.borderClr),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTextStyle.medium(
            size: 11.5,
            color: AppThemeColors.textPrimary,
          ),
          cursorColor: AppThemeColors.primary,
          decoration: InputDecoration(
            hintText: 'Search Notes',
            hintStyle: AppTextStyle.medium(
              size: 11.5,
              color: AppThemeColors.textSecondary,
            ),
            suffixIcon: Icon(
              Icons.search,
              size: 13,
              color: AppThemeColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            // filled: true,
            // fillColor: Colors.white,
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(24),
            //   borderSide: BorderSide(color: AppThemeColors.borderClr),
            // ),
            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(24),
            //   borderSide: BorderSide(color: AppThemeColors.borderClr),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(24),
            //   borderSide: BorderSide(color: AppThemeColors.primary),
            // ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Notes list — only this part scrolls
// ─────────────────────────────────────────────

class NoteList extends StatefulWidget {
  final List<NoteModel> notes;
  final String staffId;
  const NoteList({super.key, required this.notes, required this.staffId});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(8),
      thickness: 4,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        itemCount: widget.notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) =>
            NoteCard(note: widget.notes[i], staffId: widget.staffId),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Note card
// ─────────────────────────────────────────────

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final String staffId;
  const NoteCard({super.key, required this.note, required this.staffId});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _hovering = false;

  String get _initial {
    final title = widget.note.title;
    return title.isNotEmpty ? title[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.year}';

  void _delete() {
    if (widget.note.id == null) return;
    context.read<StaffCubit>().deleteNote(widget.staffId, widget.note.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppThemeColors.primary,
            child: Text(
              _initial,
              style: AppTextStyle.body(size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.note.title.isNotEmpty
                            ? widget.note.title
                            : 'Untitled',
                        style: AppTextStyle.medium(
                          size: 13.5,
                          color: AppThemeColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _delete,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.red, width: 1),
                        ),
                        child: Image.asset(
                          AssetResources.deleteIcon,
                          scale: 2.3,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.note.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Tooltip(
                    message: widget.note.content,
                    textAlign: TextAlign.left,
                    textStyle: AppTextStyle.medium(
                      size: 11.5,
                      color: AppThemeColors.chartFill,
                    ),
                    constraints: BoxConstraints(maxWidth: 425),
                    padding: EdgeInsets.all(8),
                    triggerMode: TooltipTriggerMode.tap,
                    decoration: BoxDecoration(
                      color: AppThemeColors.textPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.note.content,
                      style: AppTextStyle.medium(
                        size: 11.5,
                        color: AppThemeColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  widget.note.createdAt != null
                      ? _formatDate(widget.note.createdAt!)
                      : '—',
                  style: AppTextStyle.medium(
                    size: 11,
                    color: AppThemeColors.textSecondary,
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

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_outlined, size: 28, color: AppThemeColors.borderClr),
          const SizedBox(height: 12),
          Text(
            'No notes available',
            style: AppTextStyle.medium(
              size: 11.5,
              color: AppThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
