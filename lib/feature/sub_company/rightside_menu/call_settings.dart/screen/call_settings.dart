import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/model/bonvoice_model.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/model/voxbay_model.dart';
import 'package:sizer/sizer.dart';

import '../cubit/call_settings_cubit.dart';

class CloudCallSettingsPage extends StatelessWidget {
  const CloudCallSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CallSettingsCubit(repository: CallSettingsRepository())..init(),
      child: const CloudCallSettingsScreen(),
    );
  }
}

class CloudCallSettingsScreen extends StatefulWidget {
  const CloudCallSettingsScreen({super.key});

  @override
  State<CloudCallSettingsScreen> createState() =>
      _CloudCallSettingsScreenState();
}

class _CloudCallSettingsScreenState extends State<CloudCallSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _accessibleUsers = ['User 1', 'User 2', 'User 3'];
  final List<String> _leadCategories = [
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

  List<TableColumn> get _cloudCallColumns => [
    TableColumn(title: '#'),
    TableColumn(title: 'Provider'),
    TableColumn(title: 'CallerID'),
    TableColumn(title: 'ChannelID'),
    TableColumn(title: 'User'),
    TableColumn(title: 'Lead Category'),
    TableColumn(title: 'Lead Sub category'),
    TableColumn(title: 'Action'),
  ];

  List<TableColumn> get _ivrColumns => [
    TableColumn(title: '#'),
    TableColumn(title: 'Provider'),
    TableColumn(title: 'Caller Id'),
    TableColumn(title: 'UID'),
    TableColumn(title: 'PIN'),
    TableColumn(title: 'Ext No'),
    TableColumn(title: 'Staff'),
    TableColumn(title: 'Type'),
    TableColumn(title: 'Action'),
  ];

  List<List<Widget>> _buildBonvoiceRows(
    List<BonvoiceSettingsModel> list,
    CallSettingsCubit cubit,
  ) {
    return list.asMap().entries.map((entry) {
      final m = entry.value;
      return <Widget>[
        Text('${entry.key + 1}', style: AppTextStyle.medium(size: 10.sp)),
        Text(m.providerName, style: AppTextStyle.medium(size: 10.sp)),
        Text(m.callerId, style: AppTextStyle.medium(size: 10.sp)),
        Text(m.channelId, style: AppTextStyle.medium(size: 10.sp)),
        Text(m.accessibleUser, style: AppTextStyle.medium(size: 10.sp)),
        Text(m.leadCategory, style: AppTextStyle.medium(size: 10.sp)),
        Text('—', style: AppTextStyle.medium(size: 10.sp)),
        _actionButtons(
          onEdit: () => _showDialogforBonVoice(existing: m),
          onDelete: () => cubit.deleteBonvoice(m.id),
        ),
      ];
    }).toList();
  }

  List<List<Widget>> _buildVoxbayRows(
    List<VoxbaySettingsModel> list,
    CallSettingsCubit cubit,
  ) {
    return list.asMap().entries.map((entry) {
      final m = entry.value;
      return <Widget>[
        Text('${entry.key + 1}', style: AppTextStyle.small(size: 10.sp)),
        Text(m.providerName, style: AppTextStyle.small(size: 10.sp)),
        Text(m.callerId, style: AppTextStyle.small(size: 10.sp)),
        Text(m.uid, style: AppTextStyle.small(size: 10.sp)),
        Text(m.pin, style: AppTextStyle.small(size: 10.sp)),
        Text(m.extNo, style: AppTextStyle.small(size: 10.sp)),
        Text(m.accessibleUser, style: AppTextStyle.small(size: 10.sp)),
        Text(m.type, style: AppTextStyle.small(size: 10.sp)),
        _actionButtons(
          onEdit: () => _showDialogforVoxbay(existing: m),
          onDelete: () => cubit.deleteVoxbay(m.id),
        ),
      ];
    }).toList();
  }

  Widget _actionButtons({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.edit_outlined,
              size: 2.5.h,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 0.3.w),
        InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.delete_outline,
              size: 2.5.h,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  bool _isHovering = false;

  Widget _addNewButton(VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 6.h,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.green
                : AppColors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: _isHovering ? Colors.white : AppColors.green,
                size: 2.5.h,
              ),
              const SizedBox(width: 5),
              Text(
                'Add New',
                style: AppTextStyle.small(
                  color: _isHovering ? Colors.white : AppColors.green,
                  size: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required VoidCallback onAddNew,
    required List<TableColumn> columns,
    required List<List<Widget>> rows,
    required bool isLoading,
  }) {
    return Container(
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
          Divider(color: AppColors.divider, height: 1, thickness: 1),
          SizedBox(height: 1.5.h),
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else
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
      body: BlocConsumer<CallSettingsCubit, CallSettingsState>(
        listenWhen: (_, curr) =>
            curr.status == CallSettingsStatus.failure &&
            curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
              backgroundColor: Colors.red,
            ),
          );
        },
        builder: (context, state) {
          final cubit = context.read<CallSettingsCubit>();
          return Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0.8.w),
                  child: _tabs(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: _sectionCard(
                          title: 'Cloud Call Settings',
                          onAddNew: () => _showDialogforBonVoice(),
                          columns: _cloudCallColumns,
                          rows: _buildBonvoiceRows(state.bonvoiceList, cubit),
                          isLoading: state.isLoading,
                        ),
                      ),
                      SingleChildScrollView(
                        child: _sectionCard(
                          title: 'IVR Settings',
                          onAddNew: () => _showDialogforVoxbay(),
                          columns: _ivrColumns,
                          rows: _buildVoxbayRows(state.voxbayList, cubit),
                          isLoading: state.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        _tabItem('Bonvoice', 0),
        SizedBox(width: 1.w),
        _tabItem('Voxbay', 1),
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

  Widget _dialogFooter({
    required BuildContext ctx,
    required bool isSubmitting,
    required VoidCallback onSubmit,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 2.w, bottom: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 240, 217, 217),
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.w),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: AppTextStyle.small(size: 10.sp, color: Colors.black),
            ),
          ),
          SizedBox(width: 1.w),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            ),
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit',
                    style: AppTextStyle.small(
                      size: 10.sp,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dialogHeader(BuildContext ctx, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          Text(title, style: AppTextStyle.medium(size: 13.sp)),
          InkWell(
            onTap: () => Navigator.pop(ctx),
            child: Icon(Icons.close, color: AppColors.black),
          ),
        ],
      ),
    );
  }

  // ── Dialog: Bonvoice ──────────────────────────────────────────────────────

  void _showDialogforBonVoice({BonvoiceSettingsModel? existing}) {
    // ✅ Capture cubit before dialog opens, while context still has access
    final cubit = context.read<CallSettingsCubit>();

    final providerCtrl = TextEditingController(
      text: existing?.providerName ?? 'Bonvoice',
    );
    final callerCtrl = TextEditingController(text: existing?.callerId ?? '');
    final channelCtrl = TextEditingController(text: existing?.channelId ?? '');
    final tokenCtrl = TextEditingController(text: existing?.token ?? '');
    final urlCtrl = TextEditingController(text: existing?.url ?? '');

    bool zipCall = existing?.isUsingZipCall ?? false;
    String? selectedUser = (existing?.accessibleUser.isNotEmpty == true)
        ? existing!.accessibleUser
        : null;
    String? selectedCategory = (existing?.leadCategory.isNotEmpty == true)
        ? existing!.leadCategory
        : null;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        // ✅ Inject the existing cubit into the dialog's widget tree
        value: cubit,
        child: StatefulBuilder(
          builder: (ctx, setLocal) =>
              BlocBuilder<CallSettingsCubit, CallSettingsState>(
                builder: (context, state) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: 500,
                      color: AppColors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _dialogHeader(
                              ctx,
                              existing == null
                                  ? 'Add Settings'
                                  : 'Edit Settings',
                            ),

                            // Body
                            Padding(
                              padding: EdgeInsets.all(1.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Provider Name'),
                                  _buildTextField(
                                    controller: providerCtrl,
                                    hint: 'Provider Name',
                                  ),
                                  SizedBox(height: 2.h),

                                  Row(
                                    children: [
                                      Checkbox(
                                        value: zipCall,
                                        onChanged: (val) => setLocal(
                                          () => zipCall = val ?? false,
                                        ),
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
                                          color: AppColors.black.withOpacity(
                                            0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Caller ID'),
                                  _buildTextField(
                                    controller: callerCtrl,
                                    hint: 'Caller ID',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Channel ID'),
                                  _buildTextField(
                                    controller: channelCtrl,
                                    hint: 'Channel ID',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Token'),
                                  _buildTextField(
                                    controller: tokenCtrl,
                                    hint: 'Token',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Url'),
                                  _buildTextField(
                                    controller: urlCtrl,
                                    hint: 'Url',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Accessible users'),
                                  _buildDropdown(
                                    hint: 'Select',
                                    value: selectedUser,
                                    items: _accessibleUsers,
                                    onChanged: (val) =>
                                        setLocal(() => selectedUser = val),
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Lead Category'),
                                  _buildDropdown(
                                    hint: 'Select Lead Category',
                                    value: selectedCategory,
                                    items: _leadCategories,
                                    onChanged: (val) =>
                                        setLocal(() => selectedCategory = val),
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),

                            // Footer
                            _dialogFooter(
                              ctx: ctx,
                              isSubmitting: state.isBonvoiceSubmitting,
                              onSubmit: () async {
                                if (existing == null) {
                                  await cubit.addBonvoice(
                                    providerName: providerCtrl.text.trim(),
                                    isUsingZipCall: zipCall,
                                    callerId: callerCtrl.text.trim(),
                                    channelId: channelCtrl.text.trim(),
                                    token: tokenCtrl.text.trim(),
                                    url: urlCtrl.text.trim(),
                                    accessibleUser: selectedUser ?? '',
                                    leadCategory: selectedCategory ?? '',
                                  );
                                } else {
                                  await cubit.updateBonvoice(
                                    existing.copyWith(
                                      providerName: providerCtrl.text.trim(),
                                      isUsingZipCall: zipCall,
                                      callerId: callerCtrl.text.trim(),
                                      channelId: channelCtrl.text.trim(),
                                      token: tokenCtrl.text.trim(),
                                      url: urlCtrl.text.trim(),
                                      accessibleUser: selectedUser ?? '',
                                      leadCategory: selectedCategory ?? '',
                                    ),
                                  );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  // ── Dialog: Voxbay ────────────────────────────────────────────────────────

  void _showDialogforVoxbay({VoxbaySettingsModel? existing}) {
    // ✅ Capture cubit before dialog opens, while context still has access
    final cubit = context.read<CallSettingsCubit>();

    final providerCtrl = TextEditingController(
      text: existing?.providerName ?? 'Voxbay',
    );
    final typeCtrl = TextEditingController(text: existing?.type ?? '');
    final customerCtrl = TextEditingController(text: existing?.customer ?? '');
    final callerCtrl = TextEditingController(text: existing?.callerId ?? '');
    final uidCtrl = TextEditingController(text: existing?.uid ?? '');
    final pinCtrl = TextEditingController(text: existing?.pin ?? '');
    final extCtrl = TextEditingController(text: existing?.extNo ?? '');
    final urlCtrl = TextEditingController(text: existing?.url ?? '');

    String? selectedUser = (existing?.accessibleUser.isNotEmpty == true)
        ? existing!.accessibleUser
        : null;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        // ✅ Inject the existing cubit into the dialog's widget tree
        value: cubit,
        child: StatefulBuilder(
          builder: (ctx, setLocal) =>
              BlocBuilder<CallSettingsCubit, CallSettingsState>(
                builder: (context, state) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: 500,
                      color: AppColors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _dialogHeader(
                              ctx,
                              existing == null
                                  ? 'Add Voxbay Settings'
                                  : 'Edit Voxbay Settings',
                            ),

                            // Body
                            Padding(
                              padding: EdgeInsets.all(1.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Provider Name'),
                                  _buildTextField(
                                    controller: providerCtrl,
                                    hint: 'Voxbay',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Type'),
                                  _buildTextField(
                                    controller: typeCtrl,
                                    hint: 'Incoming',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Customer'),
                                  _buildTextField(
                                    controller: customerCtrl,
                                    hint: 'Customer',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Caller Id'),
                                  _buildTextField(
                                    controller: callerCtrl,
                                    hint: 'Caller Id',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('UID'),
                                  _buildTextField(
                                    controller: uidCtrl,
                                    hint: 'UID',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('PIN'),
                                  _buildTextField(
                                    controller: pinCtrl,
                                    hint: 'PIN',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('EXT no'),
                                  _buildTextField(
                                    controller: extCtrl,
                                    hint: 'EXT no',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Url'),
                                  _buildTextField(
                                    controller: urlCtrl,
                                    hint: 'url',
                                  ),
                                  SizedBox(height: 2.h),

                                  _buildLabel('Accessible users'),
                                  _buildDropdown(
                                    hint: 'Select',
                                    value: selectedUser,
                                    items: _accessibleUsers,
                                    onChanged: (val) =>
                                        setLocal(() => selectedUser = val),
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),

                            // Footer
                            _dialogFooter(
                              ctx: ctx,
                              isSubmitting: state.isVoxbaySubmitting,
                              onSubmit: () async {
                                if (existing == null) {
                                  await cubit.addVoxbay(
                                    providerName: providerCtrl.text.trim(),
                                    type: typeCtrl.text.trim(),
                                    customer: customerCtrl.text.trim(),
                                    callerId: callerCtrl.text.trim(),
                                    uid: uidCtrl.text.trim(),
                                    pin: pinCtrl.text.trim(),
                                    extNo: extCtrl.text.trim(),
                                    url: urlCtrl.text.trim(),
                                    accessibleUser: selectedUser ?? '',
                                  );
                                } else {
                                  await cubit.updateVoxbay(
                                    existing.copyWith(
                                      providerName: providerCtrl.text.trim(),
                                      type: typeCtrl.text.trim(),
                                      customer: customerCtrl.text.trim(),
                                      callerId: callerCtrl.text.trim(),
                                      uid: uidCtrl.text.trim(),
                                      pin: pinCtrl.text.trim(),
                                      extNo: extCtrl.text.trim(),
                                      url: urlCtrl.text.trim(),
                                      accessibleUser: selectedUser ?? '',
                                    ),
                                  );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}
