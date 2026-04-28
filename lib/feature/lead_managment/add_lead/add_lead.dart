import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/menu_hover_bottun.dart';
import 'package:login_2_it_solution/feature/lead_managment/add_lead/widget/dropdown_with_add.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sizer/sizer.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  bool isHovering = false;

  final List<String> leadCategory = [
    "Select lead Type ",
    "Need Further Followup",
    "Not Contacted",
    "Fake",
    "Visited",
    "May vist",
    "Not Interested",
    "Converted",
    "Lost",
  ];

  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];
  final List<String> priority = ["High", "Low", "Negative", "Normal"];
  final List<String> leadStage = ["New", "Follow Up", "Closed", 'Rejected'];

  String? selectedCategory;
  String? selectedSource;
  String? selectedPriority;
  String? selectedLeadStage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔥 HEADER
                  SizedBox(height: 2.h),

                  /// TOP SECTION
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEFT
                        Expanded(
                          flex: 3,
                          child: _sectionCard(
                            "Customer Details",
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _field(
                                        "Client Name",
                                        true,
                                        Icons.person_outline,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: _phoneField(
                                        "Contact Number",
                                        true,
                                        Icons.call_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _phoneField(
                                        "Whatsapp Number",
                                        false,
                                        Icons.call_outlined,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: _field(
                                        "Email",
                                        false,
                                        Icons.email_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                _multilineField(
                                  "Address",
                                  Icons.location_on_outlined,
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _field(
                                        "Pin Code",
                                        false,
                                        Icons.pin_drop_outlined,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Expanded(
                                      child: _field(
                                        "Post Office",
                                        false,
                                        Icons.location_city,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Expanded(
                                      child: _dropdown(
                                        "State",
                                        Icons.flag_outlined,
                                        items: stateDistrictMap.keys.toList(),
                                        selectedValue: selectedState,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedState = value;

                                            /// reset district when state changes
                                            selectedDistrict = null;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Expanded(
                                      child: _dropdown(
                                        "District",
                                        Icons.location_on_outlined,
                                        items: selectedState == null
                                            ? []
                                            : stateDistrictMap[selectedState] ??
                                                  [],
                                        selectedValue: selectedDistrict,
                                        enabled:
                                            selectedState !=
                                            null, // 🔥 disable until state selected
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDistrict = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 2.w),

                        /// RIGHT
                        Expanded(
                          flex: 1,
                          child: _sectionCard(
                            "Product Info",
                            Column(
                              children: [
                                _dropdown(
                                  "Product",
                                  Icons.production_quantity_limits_outlined,
                                ),
                                SizedBox(height: 1.5.h),
                                _field("Cost", false, Icons.money),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  /// BOTTOM SECTION
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _sectionCard(
                            "Lead Information",
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _dropdown(
                                        "Assign Staff",
                                        Icons.person_outline,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: DropdownWithAdd(
                                        label: 'Lead Category',
                                        icon: Icons.layers_outlined,
                                        items: leadCategory,
                                        selectedValue: selectedCategory,
                                        onChanged: (String? p1) {},
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownWithAdd(
                                        label: 'Lead Source',
                                        icon: Icons.layers_rounded,
                                        items: leadSource,
                                        selectedValue: selectedSource,
                                        onChanged: (String? p1) {
                                          setState(() {
                                            selectedSource = p1?.trim();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: _dropdown(
                                        "Priority",
                                        Icons.flag_outlined,
                                        items: priority,
                                        selectedValue: selectedPriority,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPriority = value?.trim();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: _dropdown(
                                        "Lead Stage",
                                        Icons.task_outlined,
                                        items: leadStage,
                                        selectedValue: selectedLeadStage,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedLeadStage = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                _multilineField(
                                  "Remarks",
                                  Icons.note_alt_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        const Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                  ),

                  // submit button
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Container(
                      margin: EdgeInsets.all(2.w),
                      width: double.infinity,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 2.w,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 6.5.w,
                          height: 5.h,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "Submit",
                              style: AppTextStyle.medium(
                                size: 11.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= COMPONENTS =================

  Widget _sectionCard(String title, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  // Icons.person_2_outlined,
                  Symbols.person,
                  size: 13.sp,
                  weight: 600,
                  color: AppColors.green,
                ),
                SizedBox(width: 1.w),
                Text(
                  title,
                  style: AppTextStyle.medium(
                    size: 11.sp,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(2.w), child: child),
        ],
      ),
    );
  }

  Widget _field(String label, bool required, IconData icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: _box(),
          child: TextField(
            style: AppTextStyle.body(size: 11.sp),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(1.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _phoneField(String label, bool required, IconData icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),

        Row(
          children: [
            /// ✅ Country Picker Container
            SizedBox(
              height: 5.h,
              width: 7.5.w, // ✅ IMPORTANT FIX
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: CountryCodePicker(
                  onChanged: (country) {
                    print(country.dialCode);
                  },
                  initialSelection: 'IN',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: true,
                  padding: EdgeInsets.zero,
                  textStyle: AppTextStyle.body(size: 11.sp),
                  flagWidth: 16,
                  dialogBackgroundColor: AppColors.white,
                  dialogSize: Size(30.w, 80.h),
                  dialogTextStyle: AppTextStyle.body(size: 11.sp),
                  searchStyle: AppTextStyle.body(size: 11.sp),
                  searchDecoration: InputDecoration(
                    hintText: "Search country",
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),

            SizedBox(width: 0.25.w),

            /// 📱 Phone Input
            Expanded(
              child: Container(
                height: 5.h,
                decoration: _box(),
                child: TextField(
                  style: AppTextStyle.body(size: 11.sp),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter number",
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _multilineField(String label, IconData icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 10.h,
          decoration: _box(),
          child: TextField(
            maxLines: null,
            style: AppTextStyle.body(size: 11.sp),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(1.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    IconData icons, {
    List<String> items = const [],
    String? selectedValue,
    Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false, icons),
        SizedBox(height: 0.5.h),

        Container(
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: _box(),

          child: DropdownSearch<String>(
            items: items,
            asyncItems: null,
            selectedItem: selectedValue,
            enabled: enabled && items.isNotEmpty,

            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              constraints: BoxConstraints(maxHeight: 300),
            ),

            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Select $label",
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                floatingLabelAlignment: FloatingLabelAlignment.center,
              ),
            ),

            /// 🔥 THIS IS THE MAIN FIX
            dropdownBuilder: (context, selectedItem) {
              final isHint = selectedItem == null;

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      isHint ? "Select $label" : selectedItem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isHint
                          ? AppTextStyle.small(
                              size: 11.sp,
                              color: AppColors.grey,
                            )
                          : AppTextStyle.body(size: 11.sp),
                    ),
                  ),
                ],
              );
            },

            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _label(String text, bool required, IconData icons) {
    return Row(
      children: [
        Icon(icons, size: 12.sp, color: AppColors.green),
        SizedBox(width: 0.5.w),
        Text(text, style: AppTextStyle.medium()),
        if (required)
          Text(
            "*",
            style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
          ),
      ],
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.greyCard,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT
          Text(
            "ADD NEW LEAD",
            style: AppTextStyle.medium(
              size: 13.sp,
              color: AppColors.black.withOpacity(0.77),
              weight: FontWeight.w700,
            ),
          ),

          /// RIGHT
          Row(
            children: [
              /// Breadcrumb
              Row(
                children: [
                  Text('Lead Management', style: AppTextStyle.medium()),
                  Icon(Icons.chevron_right, size: 16.sp),
                  Text(
                    'Add Lead',
                    style: AppTextStyle.medium(color: AppColors.grey),
                  ),
                ],
              ),

              SizedBox(width: 1.w),

              /// MENU BUTTON
              MenuHoverButton(),
            ],
          ),
        ],
      ),
    );
  }

  String? selectedState;
  String? selectedDistrict;

  /// State → District Map
  final Map<String, List<String>> stateDistrictMap = {
    "Kerala": ["Ernakulam", "Kottayam", "Kozhikode"],
    "Tamil Nadu": ["Chennai", "Madurai"],
    "Arunachal Pradesh": ["Tawang", "Papum Pare", "West Kameng"],
  };
}
