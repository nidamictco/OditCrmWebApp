import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_manage_models.dart';
import '../../add_company/utils/add_company_validator.dart';

class EditCompanyDialog extends StatefulWidget {
  final CompanyActivity company;
  final dynamic cubit;

  const EditCompanyDialog({
    super.key,
    required this.company,
    required this.cubit,
  });

  @override
  State<EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _adminNameController;
  late TextEditingController _adminEmailController;
  late TextEditingController _adminMobileController;

  String? _selectedIndustry;
  late PlanType _selectedPlan;
  late bool _yearlyBilling;

  final List<String> industries = const [
    "Technology & SaaS",
    "Healthcare",
    "Finance",
    "Retail",
    "Education",
    "Manufacturing",
    "Construction",
    "Logistics",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.companyName);
    _locationController = TextEditingController(text: widget.company.location);
    _adminNameController = TextEditingController(
      text: widget.company.adminName,
    );
    _adminEmailController = TextEditingController(
      text: widget.company.adminEmail,
    );
    _adminMobileController = TextEditingController(
      text: widget.company.adminMobile,
    );

    _selectedIndustry = widget.company.industry.isEmpty
        ? null
        : widget.company.industry;
    _selectedPlan = widget.company.planType;
    _yearlyBilling = widget.company.yearlyBilling;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminMobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 850),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
              child: Row(
                children: [
                  Text(
                    "Edit Organization",
                    style: AppTextStyle.body(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff0F2E8A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.company.companyId,
                    style: AppTextStyle.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Company Details
                      Text(
                        "Company Details",
                        style: AppTextStyle.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Company Official Name",
                        controller: _nameController,
                        hint: "e.g. Acme Corporation",
                        validator: AddCompanyValidator.validateCompanyName,
                      ),
                      const SizedBox(height: 20),
                      // _buildDomainField(),
                      _buildTextField(
                        label: "Company Location",
                        controller: _locationController,
                        hint: "e.g. Kochi",
                        // validator: AddCompanyValidator.validateCompanyName,
                      ),
                      // const SizedBox(height: 20),
                      // _buildIndustryDropdown(),
                      const SizedBox(height: 32),

                      // Section 2: Admin Account
                      Text(
                        "Administrator Profile",
                        style: AppTextStyle.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Administrator Name",
                        controller: _adminNameController,
                        hint: "Enter full name",
                        validator: AddCompanyValidator.validateAdminName,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: "Administrator Email",
                        controller: _adminEmailController,
                        hint: "admin@company.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: AddCompanyValidator.validateAdminEmail,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: "Administrator Mobile Number",
                        controller: _adminMobileController,
                        hint: "+91 9876543210",
                        isphone: true,
                        keyboardType: TextInputType.phone,
                        validator: AddCompanyValidator.validateMobile,
                      ),
                      const SizedBox(height: 32),

                      // Section 3: Subscription details
                      Text(
                        "Subscription & Billing Plan",
                        style: AppTextStyle.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPlanDropdown(),
                      // const SizedBox(height: 20),
                      // _buildBillingCycleSwitch(),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer / Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTextStyle.body(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    width: 160,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0F2E8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: AppTextStyle.body(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    bool isphone=false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.body(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xff334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: isphone? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]:[],
          style: AppTextStyle.body(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyle.body(color: const Color(0xff94A3B8)),
            filled: true,
            fillColor: const Color(0xffF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff0F2E8A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildDomainField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Corporate Domain",
  //         style: AppTextStyle.body(
  //           fontSize: 13,
  //           fontWeight: FontWeight.w600,
  //           color: const Color(0xff334155),
  //         ),
  //       ),
  //       const SizedBox(height: 6),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             height: 48,
  //             padding: const EdgeInsets.symmetric(horizontal: 12),
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: const Color(0xffF1F5F9),
  //               border: Border.all(color: const Color(0xffCBD5E1)),
  //               borderRadius: const BorderRadius.only(
  //                 topLeft: Radius.circular(12),
  //                 bottomLeft: Radius.circular(12),
  //               ),
  //             ),
  //             child: Text(
  //               "https://",
  //               style: AppTextStyle.body(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: TextFormField(
  //               controller: _domainController,
  //               validator: AddCompanyValidator.validateDomain,
  //               style: AppTextStyle.body(fontSize: 14),
  //               decoration: InputDecoration(
  //                 hintText: "acme.com",
  //                 hintStyle: AppTextStyle.body(
  //                   color: const Color(0xff94A3B8),
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 16,
  //                   vertical: 14,
  //                 ),
  //                 border: const OutlineInputBorder(
  //                   borderRadius: BorderRadius.only(
  //                     topRight: Radius.circular(12),
  //                     bottomRight: Radius.circular(12),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildIndustryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Industry Sector",
          style: AppTextStyle.body(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xff334155),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return FormField<String>(
              initialValue: _selectedIndustry,
              validator: AddCompanyValidator.validateIndustry,
              builder: (FormFieldState<String> fieldState) {
                return DropdownMenu<String>(
                  initialSelection: _selectedIndustry,
                  width: constraints.maxWidth,
                  textStyle: AppTextStyle.body(fontSize: 14),
                  hintText: "Select industry",
                  dropdownMenuEntries: industries.map((String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                      style: MenuItemButton.styleFrom(
                        textStyle: AppTextStyle.body(),
                      ),
                    );
                  }).toList(),
                  inputDecorationTheme: InputDecorationTheme(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xffF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: fieldState.hasError
                            ? Colors.red
                            : const Color(0xffCBD5E1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: fieldState.hasError
                            ? Colors.red
                            : const Color(0xffCBD5E1),
                      ),
                    ),
                  ),
                  onSelected: (String? value) {
                    fieldState.didChange(value);
                    setState(() {
                      _selectedIndustry = value;
                    });
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subscription Plan",
          style: AppTextStyle.body(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xff334155),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<PlanType>(
              initialSelection: _selectedPlan,
              width: constraints.maxWidth,
              textStyle: AppTextStyle.body(fontSize: 14),
              hintText: "Select plan",
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: PlanType.basic, label: "BASIC"),
                DropdownMenuEntry(value: PlanType.standard, label: "STANDARD"),
                DropdownMenuEntry(
                  value: PlanType.enterprise,
                  label: "ENTERPRISE",
                ),
              ],
              inputDecorationTheme: InputDecorationTheme(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: const Color(0xffF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                ),
              ),
              onSelected: (PlanType? value) {
                if (value != null) {
                  setState(() {
                    _selectedPlan = value;
                  });
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBillingCycleSwitch() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yearly Billing Cycle",
              style: AppTextStyle.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xff334155),
              ),
            ),
            Text(
              "Enable yearly pricing (15% discount)",
              style: AppTextStyle.body(
                fontSize: 11,
                color: const Color(0xff64748B),
              ),
            ),
          ],
        ),
        const Spacer(),
        Switch(
          value: _yearlyBilling,
          activeThumbColor: const Color(0xff0F2E8A),
          onChanged: (bool value) {
            setState(() {
              _yearlyBilling = value;
            });
          },
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      widget.cubit.updateCompany(
        companyId: widget.company.companyId,
        companyName: _nameController.text.trim(),
        domain: widget.company.domain,
        location: _locationController.text.trim(),
        industry: _selectedIndustry ?? '',
        adminName: _adminNameController.text.trim(),
        adminEmail: _adminEmailController.text.trim(),
        adminMobile: _adminMobileController.text.trim(),
        planType: _selectedPlan,
        yearlyBilling: _yearlyBilling,
      );
      Navigator.pop(context);
    }
  }
}
