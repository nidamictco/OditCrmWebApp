import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:sizer/sizer.dart';

/// Dialog that lets the user configure which CSV column index maps to which
/// lead field.  Changes are persisted to [ImportLeadsCubit] on submit.
class FieldPositionDialog extends StatefulWidget {
  const FieldPositionDialog({super.key});

  @override
  State<FieldPositionDialog> createState() => _FieldPositionDialogState();
}

class _FieldPositionDialogState extends State<FieldPositionDialog> {
  // One controller per configurable field
  late final TextEditingController _clientNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;

  // Add more controllers here as you expand the mappable fields
  static const List<_FieldMeta> _fields = [
    _FieldMeta(key: 'clientName', label: 'Client Name'),
    _FieldMeta(key: 'phone',      label: 'Phone'),
    _FieldMeta(key: 'address',    label: 'Address'),
  ];

  @override
  void initState() {
    super.initState();
    final positions = context.read<ImportLeadsCubit>().state.fieldPositions;
    _clientNameCtrl = TextEditingController(
      text: '${positions['clientName'] ?? 0}',
    );
    _phoneCtrl = TextEditingController(
      text: '${positions['phone'] ?? 1}',
    );
    _addressCtrl = TextEditingController(
      text: '${positions['address'] ?? 2}',
    );
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(String key) {
    switch (key) {
      case 'clientName': return _clientNameCtrl;
      case 'phone':      return _phoneCtrl;
      case 'address':    return _addressCtrl;
      default:           return TextEditingController();
    }
  }

  void _onSubmit() {
    final cubit = context.read<ImportLeadsCubit>();
    for (final field in _fields) {
      final raw = _controllerFor(field.key).text.trim();
      final pos = int.tryParse(raw);
      if (pos != null && pos >= 0) {
        cubit.updateFieldPosition(field.key, pos);
      }
      log(cubit.state.fieldPositions.toString());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width:   30.w,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFC6D6E2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Field Position',
                    style: AppTextStyle.medium(
                      size:   13.sp,
                      weight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:  const Color(0xFFD6E6F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF9EC3DC)),
                    ),
                    child: Text(
                      'Note: Field Position starts from 0',
                      style: AppTextStyle.medium(
                        color: Colors.black87,
                        size:  11.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Input fields
                  ...List.generate(_fields.length, (i) {
                    final field = _fields[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < _fields.length - 1 ? 1.h : 0,
                      ),
                      child: _buildField(
                        label:      field.label,
                        controller: _controllerFor(field.key),
                      ),
                    );
                  }),

                  SizedBox(height: 2.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: AppTextStyle.medium(weight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _onSubmit,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height:     4.h,
                          width:      7.w,
                          decoration: BoxDecoration(
                            color:        const Color(0xFF4C5B8F),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: AppTextStyle.medium(
                                color: Colors.white,
                                size:  11.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyle.medium(size: 11.sp)),
        ),
        Expanded(
          child: TextField(
            controller:  controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintStyle: AppTextStyle.small(size: 10.sp),
              filled:    true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small data class for field metadata ───────────────────────────────────────
class _FieldMeta {
  final String key;
  final String label;
  const _FieldMeta({required this.key, required this.label});
}