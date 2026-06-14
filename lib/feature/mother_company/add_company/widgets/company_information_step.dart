import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_text_field.dart';
import 'logo_upload_widget.dart';
import 'section_card.dart';

class CompanyInformationStep extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController domainController;

  final String? selectedIndustry;
  final List<String> industries;

  final Uint8List? logoBytes;

  final ValueChanged<String?> onIndustryChanged;
  final VoidCallback onUploadLogo;

  final VoidCallback onCancel;
  final VoidCallback onNext;

  final FormFieldValidator<String>? companyNameValidator;
  final FormFieldValidator<String>? domainValidator;
  final FormFieldValidator<String>? industryValidator;

  const CompanyInformationStep({
    super.key,
    required this.companyNameController,
    required this.domainController,
    required this.selectedIndustry,
    required this.industries,
    required this.logoBytes,
    required this.onIndustryChanged,
    required this.onUploadLogo,
    required this.onCancel,
    required this.onNext,
    this.companyNameValidator,
    this.domainValidator,
    this.industryValidator,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    AppTextField(
                      controller: companyNameController,
                      label: "Company Official Name",
                      hint: "e.g. Acme Corporation",
                      validator: companyNameValidator,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DomainField(
                            controller: domainController,
                            validator: domainValidator,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _IndustryDropdown(
                            industries: industries,
                            selectedIndustry: selectedIndustry,
                            onChanged: onIndustryChanged,
                            validator: industryValidator,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // const SizedBox(width: 40),

              // LogoUploadWidget(imageBytes: logoBytes, onTap: onUploadLogo),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 24),

          Row(
            children: [
              // TextButton(
              //   onPressed: onCancel,
              //   child: Text(
              //     "Cancel Request",
              //     style: GoogleFonts.poppins(
              //       fontSize: 15,
              //       color: Color(0xff334155),
              //     ),
              //   ),
              // ),
              const Spacer(),

              SizedBox(
                width: 180,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    "Next Step",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0F2E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DomainField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const _DomainField({required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Corporate Domain",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 49,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  border: Border.all(color: const Color(0xffCBD5E1)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "https://",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),

              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: "acme.com",
                    hintStyle: GoogleFonts.poppins(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndustryDropdown extends StatelessWidget {
  final List<String> industries;
  final String? selectedIndustry;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const _IndustryDropdown({
    required this.industries,
    required this.selectedIndustry,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(
          "Industry Sector",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            return FormField<String>(
              initialValue: selectedIndustry,
              validator: validator,
              builder: (FormFieldState<String> fieldState) {
                return DropdownMenu<String>(
                  initialSelection: selectedIndustry,
                  width: constraints.maxWidth,
                  textStyle: GoogleFonts.poppins(),
                  hintText: "Select industry",
                  dropdownMenuEntries: industries.map((String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                      style: MenuItemButton.styleFrom(
                        textStyle: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  inputDecorationTheme: InputDecorationTheme(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: fieldState.hasError
                            ? Colors.red
                            : const Color(0xff0F2E8A),
                        width: 2,
                      ),
                    ),
                    // errorText: fieldState.errorText,
                    errorStyle: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onSelected: (String? value) {
                    fieldState.didChange(value);
                    onChanged(value);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
