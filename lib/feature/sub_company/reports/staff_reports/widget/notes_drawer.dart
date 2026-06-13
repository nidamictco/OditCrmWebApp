// ─────────────────────────────────────────────
// NOTES DRAWER — fetch, search, and display only
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/sub_company/reports/staff_reports/widget/note_dialog.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/note_model.dart';

class NotesDrawer extends StatefulWidget {
  final String staffId;
  const NotesDrawer({super.key, required this.staffId});

  @override
  State<NotesDrawer> createState() => _NotesDrawerState();
}

class _NotesDrawerState extends State<NotesDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch notes when drawer first opens
    context.read<StaffCubit>().fetchNotes(widget.staffId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Opens the add-only NotesDialog and refreshes the list when a note is saved.
  void _openAddNoteDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffCubit>(),
        child: NotesDialog(id: widget.staffId),
      ),
    );

    // Refresh only if the dialog reported a successful save
    if (saved == true && mounted) {
      context.read<StaffCubit>().fetchNotes(widget.staffId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth =
        (MediaQuery.of(context).size.width * 0.28).clamp(280.0, 420.0);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 8,
        child: SizedBox(
          width: drawerWidth,
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFF1E3A5F),
              onPressed: _openAddNoteDialog,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: Column(
              children: [
                _DrawerHeader(onClose: () => Navigator.pop(context)),
                _SearchField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
                const Divider(height: 1),
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
                              style: const TextStyle(color: Colors.red),
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
                                      (n.title ?? '')
                                          .toLowerCase()
                                          .contains(_searchQuery) ||
                                      (n.content ?? '')
                                          .toLowerCase()
                                          .contains(_searchQuery),
                                )
                                .toList();

                        if (notes.isEmpty) return const _EmptyNotes();

                        return ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(12, 12, 12, 80),
                          itemCount: notes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) => _NoteCard(
                            note: notes[i],
                            staffId: widget.staffId,
                          ),
                        );
                      }

                      // Initial state — show empty until first load completes
                      return const _EmptyNotes();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Drawer header ────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _DrawerHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        8,
        12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2442), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_alt_outlined,
              color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ── Search field ─────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search notes…',
          hintStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF718096)),
          prefixIcon: const Icon(Icons.search,
              size: 18, color: Color(0xFF718096)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          filled: true,
          fillColor: const Color(0xFFF7FAFC),
        ),
      ),
    );
  }
}

// ── Note card ────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final String staffId;
  const _NoteCard({required this.note, required this.staffId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row + actions ──────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title.isNotEmpty ? note.title : 'Untitled',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ),
              _NoteActions(note: note, staffId: staffId),
            ],
          ),

          // ── Content ─────────────────────────
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.content,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF4A5568)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 8),

          // ── Meta row ────────────────────────
          Text(
            note.createdAt != null
                ? _formatDate(note.createdAt!)
                : '—',
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.year}';

// ── Note action buttons ──────────────────────

class _NoteActions extends StatelessWidget {
  final NoteModel note;
  final String staffId;
  const _NoteActions({required this.note, required this.staffId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       
        _iconBtn(Icons.delete_outline,Colors.red.shade300, () {
          if (note.id == null) return;
          context.read<StaffCubit>().deleteNote(staffId, note.id!);
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No notes available',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}