import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/staff_top_bar.dart';
import 'package:sizer/sizer.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

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

// ─── Screen ─────────────────────────────────────────────────────────────────

class DesignationPermissionsScreen extends StatefulWidget {
  const DesignationPermissionsScreen({super.key});

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
        MenuPermission(
          name: 'Transfer Lead Report',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Total Lead Report',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Staff Report',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Scheduled Lead Report',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
        MenuPermission(
          name: 'Rejected Lead Report',
          createEnabled: false,
          viewEnabled: false,
          editEnabled: false,
          deleteEnabled: false,
          otherEnabled: false,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showScrollTop) {
        setState(() => _showScrollTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _designationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Logic ───────────────────────────────────────────────────────────────

  void _toggleGroupHeader(int groupIndex) {
    setState(() {
      final group = _groups[groupIndex];
      group.selected = !group.selected;
      for (final item in group.items) {
        item.selected = group.selected;
      }
    });
  }

  void _toggleItemRow(int groupIndex, int itemIndex) {
    setState(() {
      final item = _groups[groupIndex].items[itemIndex];
      item.selected = !item.selected;
      final group = _groups[groupIndex];
      group.selected = group.items.every((i) => i.selected);
    });
  }

  void _togglePermission(int groupIndex, int itemIndex, String permType) {
    setState(() {
      final item = _groups[groupIndex].items[itemIndex];
      switch (permType) {
        case 'create':
          item.canCreate = !item.canCreate;
          break;
        case 'view':
          item.canView = !item.canView;
          break;
        case 'edit':
          item.canEdit = !item.canEdit;
          break;
        case 'delete':
          item.canDelete = !item.canDelete;
          break;
        case 'other':
          item.canOther = !item.canOther;
          break;
      }
    });
  }

  void _handleSubmit() {
    if (_designationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a designation name',
            style: AppTextStyle.body(color: AppColors.white),
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Designation "${_designationController.text}" saved!',
          style: AppTextStyle.body(color: AppColors.white),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   elevation: 0,
      //   shadowColor: AppColors.black.withOpacity(0.06),
      //   surfaceTintColor: AppColors.white,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios_new, size: 13.sp),
      //     color: AppColors.black,
      //     onPressed: () => Navigator.maybePop(context),
      //   ),
      //   title: Text(
      //     'Add Designation',
      //     style: AppTextStyle.medium(
      //       color: AppColors.black,
      //       weight: FontWeight.w600,
      //     ),
      //   ),
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Divider(height: 1, color: AppColors.divider),
      //   ),
      // ),
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
            title: 'Add Designation',
            parent: 'Staff Management',
            current: 'Add Designation',
          ),
          Expanded(
            child: SingleChildScrollView(
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
                    // ✅ plain Column, no Expanded child
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
          _buildSubmitBar(), // ✅ outside scroll, always visible at bottom
        ],
      ),
    );
  }

  // ── Designation Field ─────────────────────────────────────────────────────

  Widget _buildDesignationField() {
    return Container(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
                  // contentPadding: EdgeInsets.symmetric(
                  //   horizontal: 3.w,
                  //   vertical: 1.4.h,
                  // ),
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  //   borderSide: BorderSide(color: AppColors.divider),
                  // ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  //   borderSide: BorderSide(color: AppColors.divider),
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  //   borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  // ),
                  // filled: true,
                  // fillColor: AppColors.white,
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

  // ── Permission Group Card ─────────────────────────────────────────────────

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
          // Header row
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
                  // Icon(
                  //   group.expanded
                  //       ? Icons.keyboard_arrow_up_rounded
                  //       : Icons.keyboard_arrow_down_rounded,
                  //   color: AppColors.grey,
                  //   size: 14.sp,
                  // ),
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

  // ── Permissions Table ─────────────────────────────────────────────────────

  Widget _buildTable(int groupIndex, PermissionGroup group) {
    final menuColW = 20.w;
    final permColW = 11.w;
    const cols = ['Menu', 'Create', 'View', 'Edit', 'Delete', 'Other'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header row
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
                bottom: BorderSide(color: AppColors.divider),
                left: BorderSide(color: AppColors.divider),
                right: BorderSide(color: AppColors.divider),
              ),
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
          // Data rows
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
    final isLast = itemIndex == _groups[groupIndex].items.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: itemIndex.isEven ? AppColors.white : AppColors.container,
        border: Border(
          // bottom: isLast
          //     ? BorderSide.none
          //     : BorderSide(color: AppColors.divider),
          bottom: BorderSide(color: AppColors.divider),
          left: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Menu name cell
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
          // Permission cells
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
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 7.5.w,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: Text(
              'Submit',
              style: AppTextStyle.body(
                color: AppColors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
