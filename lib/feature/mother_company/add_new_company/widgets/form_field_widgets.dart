import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class NewCompanyTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const NewCompanyTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppThemeColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppThemeColors.textMuted,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 16,
                    color: AppThemeColors.textSecondary,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppThemeColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppThemeColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppThemeColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class NewCompanyDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const NewCompanyDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<T>(
              key: ValueKey(value),
              initialSelection: value,
              errorText: state.errorText,
              onSelected: (val) {
                state.didChange(val);
                onChanged(val);
              },
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              enableSearch: false,
              trailingIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppThemeColors.textSecondary,
                size: 18,
              ),
              selectedTrailingIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppThemeColors.textSecondary,
                size: 18,
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppThemeColors.textPrimary,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppThemeColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppThemeColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppThemeColors.primary,
                    width: 1.5,
                  ),
                ),
                // errorText: state.errorText,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                elevation: WidgetStateProperty.all(4),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppThemeColors.borderLight),
                  ),
                ),
              ),
              dropdownMenuEntries: items.map((DropdownMenuItem<T> item) {
                String labelText = '';
                final child = item.child;
                if (child is Text) {
                  labelText = child.data ?? '';
                } else {
                  labelText = item.value?.toString() ?? '';
                }
                return DropdownMenuEntry<T>(
                  value: item.value as T,
                  label: labelText,
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppThemeColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class NewCompanyDatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const NewCompanyDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppThemeColors.primary,
                      onPrimary: Colors.white,
                      onSurface: AppThemeColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppThemeColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppThemeColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  isToday
                      ? DateFormat('dd MMM yyyy').format(DateTime.now())
                      : formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppThemeColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
