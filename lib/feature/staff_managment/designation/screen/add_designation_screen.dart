import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/model/designation_model.dart';
import 'package:sizer/sizer.dart';

// ─── Local UI Models ─────────────────────────────────────────────────────────

class MenuPermission {
  final String name;
  bool selected;
  bool canCreate;
  bool canView;
  bool canEdit;
  bool canDelete;
  bool canOther;
  final bool createEnabled;
  final bool viewEnabled;
  final bool editEnabled;
  final bool deleteEnabled;
  final bool otherEnabled;

  MenuPermission({
    required this.name,
    this.selected = false,
    this.canCreate = false,
    this.canView = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canOther = false,
    this.createEnabled = true,
    this.viewEnabled = true,
    this.editEnabled = true,
    this.deleteEnabled = true,
    this.otherEnabled = true,
  });
}

class PermissionGroup {
  final String title;
  bool selected;
  bool expanded;
  List<MenuPermission> items;

  PermissionGroup({
    required this.title,
    this.selected = false,
    this.expanded = true,
    required this.items,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class DesignationPermissionsScreen extends StatefulWidget {
  final DesignationModel? designation;
  const DesignationPermissionsScreen({super.key, this.designation});

  @override
  State<DesignationPermissionsScreen> createState() =>
      _DesignationPermissionsScreenState();
}

class _DesignationPermissionsScreenState
    extends State<DesignationPermissionsScreen> {
  final TextEditingController _designationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollTop = false;

  final List<PermissionGroup> _groups = [
    PermissionGroup(
      title: 'Staff management',
      items: [
        MenuPermission(
          name: 'Add Staff',
          createEnabled: true,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'View Staff',
          createEnabled: false,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Designation',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Deleted Staff',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Lead Management',
      items: [
        MenuPermission(
          name: 'Dashboard',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Add Lead',
          createEnabled: true,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Lead Category',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Import Leads',
          createEnabled: true,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: true,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Call Settings',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Call History',
          createEnabled: false,
          viewEnabled: true,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Deleted Leads',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Unassigned Leads',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Transfer Leads',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Custom Field Settings',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Leads Report',
          createEnabled: false,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'File Manager',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Phone Call Log',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'Lead Source',
          createEnabled: true,
          viewEnabled: false,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Lead Stages',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Settings',
      items: [
        MenuPermission(
          name: 'Facebook Settings',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: false,
          deleteEnabled: true,
          otherEnabled: true,
        ),
        MenuPermission(
          name: 'General Settings',
          createEnabled: true,
          viewEnabled: true,
          editEnabled: true,
          deleteEnabled: true,
          otherEnabled: false,
        ),
      ],
    ),
    PermissionGroup(
      title: 'File Manager',
      items: [
        MenuPermission(
          name: 'View',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: true,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Reports',
      items: [
        MenuPermission(name: 'Transfer Lead Report'),
        MenuPermission(name: 'Total Lead Report'),
        MenuPermission(name: 'Staff Report'),
        MenuPermission(name: 'Scheduled Lead Report'),
        MenuPermission(name: 'Rejected Lead Report'),
      ],
    ),
  ];

  bool get isEditMode => widget.designation != null;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showScrollTop) {
        setState(() => _showScrollTop = shouldShow);
      }
    });

    /// ✅ PREFILL DATA
    if (isEditMode) {
      final data = widget.designation!;

      _designationController.text = data.designationName;

      /// Map permissions → UI
      _applyPermissions(data);
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Helpers: UI → Domain model ──────────────────────────────────────────

  MenuPermission _groupItem(String groupTitle, String itemName) {
    return _groups
        .firstWhere((g) => g.title == groupTitle)
        .items
        .firstWhere((i) => i.name == itemName);
  }

  Permission _perm(String groupTitle, String itemName) {
    final item = _groupItem(groupTitle, itemName);
    return Permission(
      create: item.canCreate,
      view: item.canView,
      edit: item.canEdit,
      delete: item.canDelete,
      other: item.canOther,
    );
  }

  DesignationModel _buildModel() {
    return DesignationModel(
      id: isEditMode ? widget.designation!.id : null,
      designationName: _designationController.text.trim(),
      staffManagement: StaffManagementPermissions(
        addStaff: _perm('Staff management', 'Add Staff'),
        viewStaff: _perm('Staff management', 'View Staff'),
        designation: _perm('Staff management', 'Designation'),
        deletedStaff: _perm('Staff management', 'Deleted Staff'),
      ),
      leadManagement: LeadManagementPermissions(
        dashboard: _perm('Lead Management', 'Dashboard'),
        addLead: _perm('Lead Management', 'Add Lead'),
        leadCategory: _perm('Lead Management', 'Lead Category'),
        importLeads: _perm('Lead Management', 'Import Leads'),
        callSettings: _perm('Lead Management', 'Call Settings'),
        callHistory: _perm('Lead Management', 'Call History'),
        deletedLeads: _perm('Lead Management', 'Deleted Leads'),
        unassignedLeads: _perm('Lead Management', 'Unassigned Leads'),
        transferLeads: _perm('Lead Management', 'Transfer Leads'),
        customFieldSettings: _perm('Lead Management', 'Custom Field Settings'),
        leadsReport: _perm('Lead Management', 'Leads Report'),
        fileManager: _perm('Lead Management', 'File Manager'),
        phoneCallLog: _perm('Lead Management', 'Phone Call Log'),
        leadSource: _perm('Lead Management', 'Lead Source'),
        leadStages: _perm('Lead Management', 'Lead Stages'),
      ),
      settings: SettingsPermissions(
        facebookSettings: _perm('Settings', 'Facebook Settings'),
        generalSettings: _perm('Settings', 'General Settings'),
      ),
      fileManager: FileManagerPermissions(view: _perm('File Manager', 'View')),
      reports: ReportsPermissions(
        transferLeadReport: _perm('Reports', 'Transfer Lead Report'),
        totalLeadReport: _perm('Reports', 'Total Lead Report'),
        staffReport: _perm('Reports', 'Staff Report'),
        scheduledLeadReport: _perm('Reports', 'Scheduled Lead Report'),
        rejectedLeadReport: _perm('Reports', 'Rejected Lead Report'),
      ),
    );
  }

  // ─── Toggle logic ─────────────────────────────────────────────────────────

  // void _toggleGroupHeader(int groupIndex) {
  //   setState(() {
  //     final group = _groups[groupIndex];
  //     group.selected = !group.selected;
  //     for (final item in group.items) {
  //       item.selected = group.selected;
  //     }
  //   });
  // }

  void _toggleGroupHeader(int groupIndex) {
    setState(() {
      final group = _groups[groupIndex];
      group.selected = !group.selected;

      for (final item in group.items) {
        item.selected = group.selected;

        // Set each permission only if it's enabled for this item
        if (item.createEnabled) item.canCreate = group.selected;
        if (item.viewEnabled) item.canView = group.selected;
        if (item.editEnabled) item.canEdit = group.selected;
        if (item.deleteEnabled) item.canDelete = group.selected;
        if (item.otherEnabled) item.canOther = group.selected;
      }
    });
  }

  // void _toggleItemRow(int groupIndex, int itemIndex) {
  //   setState(() {
  //     final item = _groups[groupIndex].items[itemIndex];
  //     item.selected = !item.selected;
  //     _groups[groupIndex].selected =
  //         _groups[groupIndex].items.every((i) => i.selected);
  //   });
  // }

  void _toggleItemRow(int groupIndex, int itemIndex) {
    setState(() {
      final item = _groups[groupIndex].items[itemIndex];
      item.selected = !item.selected;

      // Set each permission only if it's enabled for this item
      if (item.createEnabled) item.canCreate = item.selected;
      if (item.viewEnabled) item.canView = item.selected;
      if (item.editEnabled) item.canEdit = item.selected;
      if (item.deleteEnabled) item.canDelete = item.selected;
      if (item.otherEnabled) item.canOther = item.selected;

      _groups[groupIndex].selected = _groups[groupIndex].items.every(
        (i) => i.selected,
      );
    });
  }

  void _togglePermission(int groupIndex, int itemIndex, String permType) {
    setState(() {
      final item = _groups[groupIndex].items[itemIndex];
      switch (permType) {
        case 'create':
          item.canCreate = !item.canCreate;
        case 'view':
          item.canView = !item.canView;
        case 'edit':
          item.canEdit = !item.canEdit;
        case 'delete':
          item.canDelete = !item.canDelete;
        case 'other':
          item.canOther = !item.canOther;
      }
    });
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  // void _handleSubmit() {
  //   if (_designationController.text.trim().isEmpty) {
  //     _showSnack('Please enter a designation name', isError: true);
  //     return;
  //   }

  //   final model = _buildModel();

  //   if (isEditMode) {
  //     context.read<DesignationCubit>().updateDesignation(model);
  //     //    Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(builder: (context) => const MainScreen(selectedIndex: 17,)),
  //     // );
  //     Navigator.pop(context);
  //   } else {
  //     context.read<DesignationCubit>().saveDesignation(model);
  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => const MainScreen(selectedIndex: 17),
  //     //   ),
  //     // );
  //      Navigator.pop(context);
  //   }
  // }
  void _handleSubmit() {
  if (_designationController.text.trim().isEmpty) {
    _showSnack('Please enter a designation name', isError: true);
    return;
  }
 
  final model = _buildModel();
 
  if (isEditMode) {
    context.read<DesignationCubit>().updateDesignation(model);
  } else {
    context.read<DesignationCubit>().saveDesignation(model);
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<DesignationCubit, DesignationState>(
      listener: (context, state) {
        if (state is DesignationSaved) {
          _showSnack('Designation "${_designationController.text}" saved!');
          context.read<DesignationCubit>().reset();
    Navigator.pop(context);
          // context.read<DesignationCubit>().reset();
        } else if (state is DesignationError) {
          _showSnack('Error: ${state.message}', isError: true);
          context.read<DesignationCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: _showScrollTop
            ? FloatingActionButton.small(
                onPressed: () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                elevation: 3,
                child: Icon(Icons.arrow_upward, size: 13.sp),
              )
            : null,
        body: Column(
          children: [
            StaffTopBar(
              title: isEditMode ? 'Edit Designation' : 'Add Designation',

              parent: 'Staff Management',
              parent2True: true,
              parent2: 'Designation',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(selectedIndex: 17),
                  ),
                );
              },
              current: isEditMode ? 'Edit Designation' : 'Add Designation',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        _buildDesignationField(),
                        SizedBox(height: 1.5.h),
                        ..._groups.asMap().entries.map(
                          (e) => Padding(
                            padding: EdgeInsets.only(bottom: 3.h),
                            child: _buildPermissionGroup(e.key, e.value),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSubmitBar(),
          ],
        ),
      ),
    );
  }

  // ── Designation Field ────────────────────────────────────────────────────

  Widget _buildDesignationField() {
    return Container(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Designation Name',
              style: AppTextStyle.body(
                color: AppColors.black,
                weight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: AppTextStyle.body(color: AppColors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 19.w,
              height: 5.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
                color: AppColors.greyCard,
              ),
              child: TextField(
                controller: _designationController,
                style: AppTextStyle.body(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Enter Designation',
                  hintStyle: AppTextStyle.body(color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(1.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Permission Group Card ────────────────────────────────────────────────

  Widget _buildPermissionGroup(int groupIndex, PermissionGroup group) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.primary.withOpacity(0.69)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(10),
              bottom: group.expanded ? Radius.zero : const Radius.circular(10),
            ),
            onTap: () => setState(() => group.expanded = !group.expanded),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blueCard,
                borderRadius: group.expanded
                    ? const BorderRadius.vertical(top: Radius.circular(10))
                    : BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
              child: Row(
                children: [
                  _buildCheckbox(
                    value: group.selected,
                    size: 2.2.h,
                    onChanged: (_) => _toggleGroupHeader(groupIndex),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      group.title,
                      style: AppTextStyle.body(
                        size: 11.3.sp,
                        color: AppColors.primary,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (group.expanded)
            Padding(
              padding: EdgeInsets.all(1.w),
              child: _buildTable(groupIndex, group),
            ),
        ],
      ),
    );
  }

  // ── Permissions Table ────────────────────────────────────────────────────

  Widget _buildTable(int groupIndex, PermissionGroup group) {
    final menuColW = 20.w;
    final permColW = 11.w;
    const cols = ['Menu', 'Create', 'View', 'Edit', 'Delete', 'Other'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: cols.asMap().entries.map((e) {
                final isMenu = e.key == 0;
                return Container(
                  width: isMenu ? menuColW : permColW,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMenu ? 3.w : 1.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    border: e.key > 0
                        ? Border(left: BorderSide(color: AppColors.divider))
                        : null,
                  ),
                  alignment: isMenu ? Alignment.centerLeft : Alignment.center,
                  child: Text(
                    e.value,
                    style: AppTextStyle.medium(weight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ),
          ...group.items.asMap().entries.map((e) {
            return _buildTableRow(
              groupIndex,
              e.key,
              e.value,
              menuColW,
              permColW,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    int groupIndex,
    int itemIndex,
    MenuPermission item,
    double menuColW,
    double permColW,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: itemIndex.isEven ? AppColors.white : AppColors.container,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          left: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: menuColW,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            child: Row(
              children: [
                _buildCheckbox(
                  value: item.selected,
                  size: 2.h,
                  onChanged: (_) => _toggleItemRow(groupIndex, itemIndex),
                ),
                SizedBox(width: 2.w),
                Flexible(child: Text(item.name, style: AppTextStyle.medium())),
              ],
            ),
          ),
          ..._permCells(groupIndex, itemIndex, item, permColW),
        ],
      ),
    );
  }

  List<Widget> _permCells(
    int groupIndex,
    int itemIndex,
    MenuPermission item,
    double colW,
  ) {
    final perms = [
      (item.canCreate, item.createEnabled, 'create'),
      (item.canView, item.viewEnabled, 'view'),
      (item.canEdit, item.editEnabled, 'edit'),
      (item.canDelete, item.deleteEnabled, 'delete'),
      (item.canOther, item.otherEnabled, 'other'),
    ];

    return perms.map((p) {
      final checked = p.$1;
      final enabled = p.$2;
      final type = p.$3;

      return Container(
        width: colW,
        height: 5.5.h,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.divider)),
        ),
        alignment: Alignment.center,
        child: enabled
            ? _buildCheckbox(
                value: checked,
                size: 2.w,
                onChanged: (_) =>
                    _togglePermission(groupIndex, itemIndex, type),
              )
            : Icon(Icons.check_box, size: 1.5.w, color: AppColors.lightGrey),
      );
    }).toList();
  }

  // ── Reusable Checkbox ─────────────────────────────────────────────────────

  Widget _buildCheckbox({
    required bool value,
    required double size,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        checkColor: AppColors.white,
        side: BorderSide(
          color: value ? AppColors.primary : AppColors.grey,
          width: 0.07.w,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ── Submit Bar ────────────────────────────────────────────────────────────

  Widget _buildSubmitBar() {
    return BlocBuilder<DesignationCubit, DesignationState>(
      builder: (context, state) {
        final isSaving = state is DesignationSaving;
        return Padding(
          padding: EdgeInsets.all(2.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 7.5.w,
              child: ElevatedButton(
                onPressed: isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaving ? AppColors.grey : AppColors.green,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.5.w,
                    vertical: 0.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: isSaving
                    ? SizedBox(
                        width: 1.5.w,
                        height: 1.5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        isEditMode ? 'Update' : 'Submit',
                        style: AppTextStyle.body(
                          color: AppColors.white,
                          weight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyPermissions(DesignationModel data) {
    void apply(MenuPermission item, Permission perm) {
      item.canCreate = perm.create;
      item.canView = perm.view;
      item.canEdit = perm.edit;
      item.canDelete = perm.delete;
      item.canOther = perm.other;
      item.selected =
          perm.create || perm.view || perm.edit || perm.delete || perm.other;
    }

    apply(
      _groupItem('Staff management', 'Add Staff'),
      data.staffManagement.addStaff,
    );
    apply(
      _groupItem('Staff management', 'View Staff'),
      data.staffManagement.viewStaff,
    );
    apply(
      _groupItem('Staff management', 'Designation'),
      data.staffManagement.designation,
    );
    apply(
      _groupItem('Staff management', 'Deleted Staff'),
      data.staffManagement.deletedStaff,
    );
    //  apply(_groupItem('Staff management', 'Deleted Staff'),
    //     data.staffManagement.);

    apply(
      _groupItem('Lead Management', 'Dashboard'),
      data.leadManagement.dashboard,
    );
    apply(
      _groupItem('Lead Management', 'Add Lead'),
      data.leadManagement.addLead,
    );
    apply(
      _groupItem('Lead Management', 'Lead Category'),
      data.leadManagement.leadCategory,
    );
    apply(
      _groupItem('Lead Management', 'Import Leads'),
      data.leadManagement.importLeads,
    );
    apply(
      _groupItem('Lead Management', 'Lead Source'),
      data.leadManagement.leadSource,
    );
    apply(
      _groupItem('Lead Management', 'Call History'),
      data.leadManagement.callHistory,
    );
    apply(
      _groupItem('Lead Management', 'Call Settings'),
      data.leadManagement.callSettings,
    );
    apply(
      _groupItem('Lead Management', 'Leads Report'),
      data.leadManagement.leadsReport,
    );
    apply(
      _groupItem('Lead Management', 'Phone Call Log'),
      data.leadManagement.phoneCallLog,
    );
    apply(
      _groupItem('Lead Management', 'Lead Stages'),
      data.leadManagement.leadStages,
    );
    apply(
      _groupItem('Lead Management', 'Transfer Leads'),
      data.leadManagement.transferLeads,
    );
    apply(
      _groupItem('Lead Management', 'Deleted Leads'),
      data.leadManagement.deletedLeads,
    );
    apply(
      _groupItem('Lead Management', 'Unassigned Leads'),
      data.leadManagement.unassignedLeads,
    );
    apply(
      _groupItem('Lead Management', 'Custom Field Settings'),
      data.leadManagement.customFieldSettings,
    );
    apply(
      _groupItem('Lead Management', 'File Manager'),
      data.leadManagement.fileManager,
    );

    apply(
      _groupItem('Settings', 'Facebook Settings'),
      data.settings.facebookSettings,
    );
    apply(
      _groupItem('Settings', 'General Settings'),
      data.settings.generalSettings,
    );

    apply(_groupItem('File Manager', 'View'), data.fileManager.view);

    apply(
      _groupItem('Reports', 'Rejected Lead Report'),
      data.reports.rejectedLeadReport,
    );
    apply(
      _groupItem('Reports', 'Scheduled Lead Report'),
      data.reports.scheduledLeadReport,
    );
    apply(_groupItem('Reports', 'Staff Report'), data.reports.staffReport);
    apply(
      _groupItem('Reports', 'Total Lead Report'),
      data.reports.totalLeadReport,
    );
    apply(
      _groupItem('Reports', 'Transfer Lead Report'),
      data.reports.transferLeadReport,
    );

    setState(() {});
  }
}
