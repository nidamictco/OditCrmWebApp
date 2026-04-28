import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/dropdown.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:login_2_it_solution/feature/lead_managment/add_lead/widget/dropdown_with_add.dart';
import 'package:login_2_it_solution/feature/lead_managment/import_leads/widget/field_position_dialog.dart';
import 'package:sizer/sizer.dart';

class ImportLeads extends StatefulWidget {
  const ImportLeads({super.key});

  @override
  State<ImportLeads> createState() => _ImportLeadsState();
}

class _ImportLeadsState extends State<ImportLeads> {
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
  final List<String> staff = ["Staff 1", "Staff 2", "Staff 3", "Staff 4"];
  final List<String> priority = ["High", "Low", "Negative", "Normal"];
  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];
  final List<String> leadStage = ["New", "Follow Up", "Closed", 'Rejected'];

  String? selectedCategory;
  String? selectedSource;
  String? selectedLeadStages;
  String? selectedPriority;
  String? selectedStaff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              subTitle: 'Import Leads',
              title: 'Leads Management',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    /// TITLE BAR
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Import Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              _topButton(
                                "Sample File",
                                Colors.orange.shade50,
                                Colors.orange,
                              ),
                              SizedBox(width: 1.w),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        const FieldPositionDialog(),
                                  );
                                },
                                child: _topButton(
                                  "Field Settings",
                                  Colors.blue,
                                  Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 2.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        "There are two methods available for importing leads. The first option is to refer to the provided sample CSV format and use it directly. Alternatively, you can modify the field settings according to the recommended format before importing the leads.",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.only(left: 2.w, right: 40.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// COUNTRY CODE
                          _inputContainer(
                            child: Row(
                              children: [
                                const Icon(Icons.flag_outlined),
                                SizedBox(width: 1.w),
                                const Text("+91"),
                              ],
                            ),
                          ),

                          SizedBox(height: 2.h),

                          /// LEAD STAGE
                          Dropdown(
                            items: leadStage,
                            selectedValue: selectedLeadStages,
                            onChanged: (val) =>
                                setState(() => selectedLeadStages = val),
                            label: 'Lead Stage',
                            hint: 'Select Lead Stage',
                          ),

                          SizedBox(height: 2.h),

                          /// CATEGORY
                          DropdownWithAdd(
                            label: 'Lead Category',
                            icon: Icons.layers_outlined,
                            items: leadCategory,
                            selectedValue: selectedCategory,
                            onChanged: (String? p1) {},
                          ),

                          SizedBox(height: 2.h),

                          /// STAFF
                          Dropdown(
                            label: 'Staff',
                            hint: 'Select Staff',
                            items: staff,
                            selectedValue: selectedStaff,
                            onChanged: (val) =>
                                setState(() => selectedStaff = val),
                          ),

                          SizedBox(height: 2.h),

                          /// SOURCE
                          DropdownWithAdd(
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

                          SizedBox(height: 2.h),

                          /// PRIORITY
                          Dropdown(
                            items: priority,
                            onChanged: (val) =>
                                setState(() => selectedPriority = val),
                            label: 'Priority',
                            hint: 'Select Priority',
                          ),

                          SizedBox(height: 2.h),

                          /// STATE
                          Dropdown(
                            label: "State",
                            hint: 'Select State',
                            showHelp: true,
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

                          SizedBox(height: 2.h),

                          /// DISTRICT
                          Dropdown(
                            label: 'District',
                            hint: 'Select District',
                            items: selectedState == null
                                ? []
                                : stateDistrictMap[selectedState] ?? [],
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

                          SizedBox(height: 2.h),

                          /// FILE PICKER
                          _label("CSV file *"),
                          _filePicker(),

                          SizedBox(height: 3.h),

                          /// SUBMIT
                          SizedBox(
                            width: 10.w,
                            height: 5.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "Submit",
                                style: AppTextStyle.medium(
                                  size: 10.sp,
                                  color: AppColors.white,
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
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _inputContainer({required Widget child}) {
    return SizedBox(
      height: 5.h,
      width: 45.w, // ✅ IMPORTANT FIX
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(3),
          color: AppColors.greyCard,
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
            hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            contentPadding: EdgeInsets.all(1.w),
          ),
        ),
      ),
    );
  }

  Widget _topButton(String text, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  Widget _filePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      height: 6.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Text("Choose file"),
          SizedBox(width: 10),
          Expanded(child: Text("No file chosen")),
        ],
      ),
    );
  }

  String? selectedState;
  String? selectedDistrict;

  final Map<String, List<String>> stateDistrictMap = {
    "Kerala": ["Ernakulam", "Kottayam", "Kozhikode"],
    "Tamil Nadu": ["Chennai", "Madurai"],
    "Arunachal Pradesh": ["Tawang", "Papum Pare", "West Kameng"],
  };
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final bool showAdd;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.showAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      height: 6.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (showAdd)
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
