import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:sizer/sizer.dart';

class CloudCallSettingsScreen extends StatefulWidget {
  const CloudCallSettingsScreen({super.key});

  @override
  State<CloudCallSettingsScreen> createState() =>
      _CloudCallSettingsScreenState();
}

class _CloudCallSettingsScreenState extends State<CloudCallSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Replace with real data from your BLoC / Provider / API ───────────────
  final List<List<Widget>> _cloudCallRows = [];
  final List<List<Widget>> _ivrRows = [];

  bool isUsingZipCall = false;
  final TextEditingController providerNameController = TextEditingController(
    text: 'Bonvoice',
  );
  final TextEditingController callerIdController = TextEditingController();
  final TextEditingController channelIdController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  String? selectedUser;
  String? selectedLeadCategory;

  final List<String> accessibleUsers = ['User 1', 'User 2', 'User 3'];
  final List<String> leadCategories = [
    'Need Further Followup',
    'Not Contacted',
    'Fake',
    'Visited',
    'Converted',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Column definitions — flex values match the web screenshot proportions ──

  List<TableColumn> get _cloudCallColumns => [
    TableColumn(title: '#', flex: 1),
    TableColumn(title: 'Provider', flex: 2),
    TableColumn(title: 'CallerID', flex: 2),
    TableColumn(title: 'ChannelID', flex: 2),
    TableColumn(title: 'User', flex: 2),
    TableColumn(title: 'Lead Category', flex: 3),
    TableColumn(title: 'Lead Sub category', flex: 3),
    TableColumn(title: 'Action', flex: 2),
  ];

  List<TableColumn> get _ivrColumns => [
    TableColumn(title: '#', flex: 1),
    TableColumn(title: 'Provider', flex: 3),
    TableColumn(title: 'Caller Id', flex: 3),
    TableColumn(title: 'UID', flex: 2),
    TableColumn(title: 'PIN', flex: 2),
    TableColumn(title: 'Ext No', flex: 2),
    TableColumn(title: 'Staff', flex: 2),
    TableColumn(title: 'Type', flex: 2),
    TableColumn(title: 'Action', flex: 2),
  ];

  // ── "⊕ Add New" — teal outlined, very light teal bg ─────────────────────
  bool isHovering = false;
  Widget _addNewButton(VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),

      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => MainScreen(selectedIndex: 1),
          //   ),
          // );
        },

        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,

            height: 6.h,
            padding: const EdgeInsets.symmetric(horizontal: 12),

            decoration: BoxDecoration(
              color: isHovering
                  ? AppColors.green
                  : AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: isHovering ? Colors.white : AppColors.green,
                  size: 2.5.h,
                ),
                const SizedBox(width: 5),
                Text(
                  "Add New",
                  style: AppTextStyle.small(
                    color: isHovering ? Colors.white : AppColors.green,
                    size: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── White section card: title row + divider + CustomTable ─────────────────
  Widget _sectionCard({
    required String title,
    required VoidCallback onAddNew,
    required List<TableColumn> columns,
    required List<List<Widget>> rows,
  }) {
    return Container(
      // margin: EdgeInsets.fromLTRB(3.w, 2.h, 3.w, 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyle.medium(
                    size: 13.6.sp,
                    color: AppColors.black.withOpacity(0.77),
                    weight: FontWeight.w600,
                  ),
                ),
                _addNewButton(onAddNew),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────────
          Divider(color: AppColors.divider, height: 1, thickness: 1),

          SizedBox(height: 1.5.h),

          // ── Table — uses your existing CustomTable, fills full width ──────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: CustomTable(
              columns: columns,
              rows: rows,
              emptyMessage: 'No Data Found',
            ),
          ),

          SizedBox(height: 1.5.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0.8.w),
              child: _tabs(),
            ),
            // ── Tab content ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Bonvoice → Cloud Call Settings ────────────────────────
                  SingleChildScrollView(
                    child: _sectionCard(
                      title: 'Cloud Call Settings',
                      onAddNew: () {
                        _showDialogforBonVoice();
                      },
                      columns: _cloudCallColumns,
                      rows: _cloudCallRows,
                    ),
                  ),

                  // ── Voxbay → IVR Settings ─────────────────────────────────
                  SingleChildScrollView(
                    child: _sectionCard(
                      title: 'IVR Settings',
                      onAddNew: () {
                        _showDialogforVoxbay();
                      },
                      columns: _ivrColumns,
                      rows: _ivrRows,
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

  int selectedTab = 0;
  Widget _tabs() {
    return Column(
      children: [
        Row(
          children: [
            _tabItem("Bonvoice", 0),
            SizedBox(width: 1.w),
            _tabItem("Voxbay", 1),
          ],
        ),
      ],
    );
  }

  Widget _tabItem(String title, int index) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.medium(
              color: isSelected ? AppColors.primary : AppColors.grey,
              weight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.7.h),
          Container(
            height: 2,
            width: 10.w,
            // ✅ active tab line drawn ON TOP of the divider
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h, left: 0.5.w),
      child: Text(
        text,
        style: AppTextStyle.medium(
          size: 11.sp,
          color: AppColors.black.withOpacity(0.65),
          weight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return SizedBox(
      height: 5.h,
      child: TextField(
        controller: controller,
        style: AppTextStyle.medium(size: 11.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 0.5.w),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 5.5.h,
      padding: EdgeInsets.symmetric(horizontal: 0.5.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          style: AppTextStyle.medium(size: 11.sp, color: AppColors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showDialogforBonVoice() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 500,
            color: AppColors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔹 HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD3E3EC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Settings',
                          style: AppTextStyle.medium(size: 13.sp),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: AppColors.black),
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 BODY (Reusable)
                  Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// Provider Name
                        _buildLabel('Provider Name'),
                        _buildTextField(
                          controller: providerNameController,
                          hint: 'Provider Name',
                        ),
                        SizedBox(height: 2.h),

                        /// Zip Call Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: isUsingZipCall,
                              onChanged: (val) =>
                                  setState(() => isUsingZipCall = val ?? false),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Are you using zip call',
                              style: AppTextStyle.medium(
                                size: 11.sp,
                                color: AppColors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        /// Caller ID
                        _buildLabel('Caller ID'),
                        _buildTextField(
                          controller: callerIdController,
                          hint: 'Caller ID',
                        ),
                        SizedBox(height: 2.h),

                        /// Channel ID
                        _buildLabel('Channel ID'),
                        _buildTextField(
                          controller: channelIdController,
                          hint: 'Channel ID',
                        ),
                        SizedBox(height: 2.h),

                        /// Token
                        _buildLabel('Token'),
                        _buildTextField(
                          controller: tokenController,
                          hint: 'Token',
                        ),
                        SizedBox(height: 2.h),

                        /// URL
                        _buildLabel('Url'),
                        _buildTextField(controller: urlController, hint: 'Url'),
                        SizedBox(height: 2.h),

                        /// Accessible Users
                        _buildLabel('Accessible users'),
                        _buildDropdown(
                          hint: 'Select',
                          value: selectedUser,
                          items: accessibleUsers,
                          onChanged: (val) =>
                              setState(() => selectedUser = val),
                        ),
                        SizedBox(height: 2.h),

                        /// Lead Category
                        _buildLabel('Lead Category'),
                        _buildDropdown(
                          hint: 'Select Lead Category',
                          value: selectedLeadCategory,
                          items: leadCategories,
                          onChanged: (val) =>
                              setState(() => selectedLeadCategory = val),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),

                  /// 🔹 FOOTER
                  Padding(
                    padding: EdgeInsets.only(right: 2.w, bottom: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /// Close
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              240,
                              217,
                              217,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.w,
                              vertical: 1.w,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Close",
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(width: 1.w),

                        /// Submit
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.w,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Submit',
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: AppColors.white,
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
      },
    );
  }


  void _showDialogforVoxbay() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 500,
            color: AppColors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔹 HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD3E3EC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Voxbay Settings',
                          style: AppTextStyle.medium(size: 13.sp),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: AppColors.black),
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 BODY (Reusable)
                  Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// Provider Name
                        _buildLabel('Provider Name'),
                        _buildTextField(
                          controller: providerNameController,
                          hint: 'Voxbay',
                        ), 
                        SizedBox(height: 2.h),

                        /// Caller ID
                        _buildLabel('Type'),
                        _buildTextField(
                          controller: callerIdController,
                          hint: 'Incoming',
                        ),
                        SizedBox(height: 2.h),

                        /// Channel ID
                        _buildLabel('Customer'),
                        _buildTextField(
                          controller: channelIdController,
                          hint: 'Customer',
                        ),
                        SizedBox(height: 2.h),

                        /// Token
                        _buildLabel('Caller Id'),
                        _buildTextField(
                          controller: tokenController,
                          hint: 'Caller Id',
                        ),
                        SizedBox(height: 2.h),

                        /// URL
                        _buildLabel('UID'),
                        _buildTextField(controller: urlController, hint: 'UID'),
                        SizedBox(height: 2.h),

                        /// Accessible Users
                        _buildLabel('PIN'),
                        _buildTextField(controller: urlController, hint: 'PIN'),
                        SizedBox(height: 2.h),

                        /// ext
                         _buildLabel('EXT no'),
                        _buildTextField(controller: urlController, hint: 'EXT no'),
                        SizedBox(height: 2.h),

                        _buildLabel('Url'),
                        _buildTextField(controller: urlController, hint: 'url'),
                        SizedBox(height: 2.h),

                        /// Accessible Users
                        _buildLabel('Accessible users'),
                        _buildDropdown(
                          hint: 'Select',
                          value: selectedUser,
                          items: accessibleUsers,
                          onChanged: (val) =>
                              setState(() => selectedUser = val),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),

                  /// 🔹 FOOTER
                  Padding(
                    padding: EdgeInsets.only(right: 2.w, bottom: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /// Close
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              240,
                              217,
                              217,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.w,
                              vertical: 1.w,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Close",
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(width: 1.w),

                        /// Submit
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.w,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Submit',
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: AppColors.white,
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
      },
    );
  }
}
