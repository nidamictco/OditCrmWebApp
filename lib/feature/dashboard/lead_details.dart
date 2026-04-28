import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:login_2_it_solution/feature/dashboard/widget/add_leads_button.dart';
import 'package:sizer/sizer.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';

class NewLeadsPage extends StatefulWidget {
  const NewLeadsPage({super.key});

  @override
  State<NewLeadsPage> createState() => _NewLeadsPageState();
}

class _NewLeadsPageState extends State<NewLeadsPage> {
  bool isHovering = false;
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '50', '100', '500', '1000'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(title: 'Dashboard', subTitle: 'New Leads'),

            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: _cardBox(),
                child: Column(
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "New Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              AddLeadsButton(),
                              SizedBox(width: 1.w),
                              // Container(
                              //   height: 4.5.h,
                              //   width: 4.5.h,
                              //   decoration: BoxDecoration(
                              //     // border: Border.all(color: Colors.indigo.shade00),
                              //     borderRadius: BorderRadius.circular(4),
                              //     color: Colors.indigo.shade100,
                              //   ),
                              //   child: Icon(
                              //     Icons.print,
                              //     size: 18,
                              //     color: Colors.indigo.shade900,
                              //   ),
                              // ),
                              HoverExportButton(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 FILTER SECTION
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          /// FIRST ROW
                          Row(
                            children: [
                              Expanded(
                                child: _input("From Date", '20-04-2026'),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(child: _input("To Date", '20-04-2026')),
                              SizedBox(width: 2.w),
                              Expanded(child: _dropdown("Lead Category")),
                              SizedBox(width: 2.w),
                              Expanded(child: _dropdown("Lead Stage")),
                            ],
                          ),

                          SizedBox(height: 2.h),

                          /// SECOND ROW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 17.6.w,
                                child: _dropdown("Priority"),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.6.w,
                                child: _dropdown("Staff"),
                              ),
                              SizedBox(width: 2.w),
                              _viewButton(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 TABLE CONTROLS
                    Padding(
                      padding: EdgeInsets.only(
                        top: 1.h,
                        left: 2.w,
                        right: 2.w,
                        bottom: 1.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Show ",
                                style: AppTextStyle.medium(size: 11.sp),
                              ),
                              _smallDropdown(),
                              Text(
                                " entries",
                                style: AppTextStyle.medium(size: 11.sp),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Search:",
                                style: AppTextStyle.medium(size: 11.sp),
                              ),
                              SizedBox(width: 1.w),
                              Container(
                                width: 12.w,
                                height: 4.h,
                                decoration: _box(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 TABLE HEADER
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      padding: EdgeInsets.all(0.2.w),
                      color: AppColors.greyCard,
                      child: Row(
                        children: [
                          _checkbox(),
                          _th("#"),
                          _th("Name"),
                          _th("Contact Number"),
                          _th("Lead Category"),
                          _th("Staff"),
                          _th("Status"),
                          _th("Action"),
                        ],
                      ),
                    ),

                    /// 🔹 EMPTY
                    _empty(),

                    Divider(color: AppColors.divider),

                    /// 🔹 FOOTER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 0 to 0 of 0 entries",
                            style: AppTextStyle.medium(
                              size: 11.sp,
                              weight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.lightGrey),
                                    bottom: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Previous',
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Next',
                                  style: AppTextStyle.small(
                                    size: 11.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 BOTTOM TRANSFER BUTTON
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 3.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: AppColors.red,
                                  size: 1.5.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 0.5.w),
                            Center(child: _bottomButton("Transfer")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================

  BoxDecoration _cardBox() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: AppColors.divider),
  );

  Widget _input(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Container(
          height: 4.5.h,
          decoration: _box(),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            value,
            style: AppTextStyle.small(
              size: 11.sp,
              color: AppColors.black,
              weight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Container(
          height: 4.8.h,
          decoration: _box(),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text("All", style: AppTextStyle.small(size: 10.sp)),
        ),
      ],
    );
  }

  Widget _viewButton() {
    return Container(
      width: 8.w,
      height: 4.5.h,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          "View",
          style: AppTextStyle.small(size: 10.sp, color: Colors.white),
        ),
      ),
    );
  }

  Widget _topButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: AppTextStyle.small(color: AppColors.green)),
    );
  }

  Widget _checkbox() {
    return SizedBox(
      width: 4.w,
      child: Checkbox(value: false, onChanged: (_) {}),
    );
  }

  Widget _th(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.medium(size: 11.sp),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        "No data available in table",
        style: AppTextStyle.medium(size: 10.sp),
      ),
    );
  }

  Widget _smallDropdown() {
    return Container(
      width: 4.2.w,
      height: 4.h,
      decoration: _box(),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 16),
          onChanged: (v) {
            setState(() => selectedValue = v!);
          },
          items: dropdownItems
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _pagination(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      margin: EdgeInsets.only(left: 1.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: AppTextStyle.small(color: AppColors.grey)),
    );
  }

  Widget _bottomButton(String text) {
    return Container(
      width: 5.w,
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(size: 11.sp, color: Colors.white),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    border: Border.all(color: AppColors.lightGrey),
    borderRadius: BorderRadius.circular(4),
    color: AppColors.white,
  );
}

class HoverExportButton extends StatefulWidget {
  const HoverExportButton({super.key});

  @override
  State<HoverExportButton> createState() => _HoverExportButtonState();
}

class _HoverExportButtonState extends State<HoverExportButton> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 10.w,
        top: position.dy + renderBox.size.height + 5,
        child: MouseRegion(
          onEnter: (_) => _isHovering = true,
          onExit: (_) => _hideOverlay(),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _item(Icons.table_chart, "Export Excel"),
                  _item(Icons.picture_as_pdf, "Export PDF"),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_isHovering) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Widget _item(IconData icon, String text) {
    return InkWell(
      onTap: () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isHovering = true;
        _showOverlay();
      },
      onExit: (_) {
        _isHovering = false;
        _hideOverlay();
      },
      child: Container(
        height: 4.5.h,
        width: 4.5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.indigo.shade100,
        ),
        child: Icon(Icons.print, size: 18, color: Colors.indigo.shade900),
      ),
    );
  }




}
