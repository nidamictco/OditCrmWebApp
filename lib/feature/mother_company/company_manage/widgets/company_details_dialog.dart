import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/company_manage_models.dart';
import 'edit_company_dialog.dart';

class CompanyDetailsDialog extends StatelessWidget {
  final CompanyActivity company;
  final dynamic cubit;

  const CompanyDetailsDialog({
    super.key,
    required this.company,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final registrationDate = DateFormat(
      'MMM dd, yyyy',
    ).format(company.subscriptionStartDate);
    final domain = company.domain.isNotEmpty ? company.domain : '-';

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Company Details',
                    style: AppTextStyle.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppThemeColors.borderLight),
              const SizedBox(height: 24),

              // Details Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          label: 'COMPANY NAME',
                          value: company.companyName,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                          label: 'ADMIN NAME',
                          value: company.adminName,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                          label: 'CONTACT EMAIL',
                          value: company.adminEmail,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                          label: 'PHONE NUMBER',
                          value: company.adminMobile,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Right Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlanItem(company.planType),
                        const SizedBox(height: 20),
                        _buildStatusItem(company.status),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                          label: 'REGISTRATION DATE',
                          value: registrationDate,
                        ),
                        // const SizedBox(height: 20),
                        // _buildDetailItem(label: 'DOMAIN', value: domain),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                          label: 'LOCATION',
                          value: company.location,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Close Button
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: AppTextStyle.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Edit Details Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close details dialog first
                      showDialog(
                        context: context,
                        builder: (_) =>
                            EditCompanyDialog(company: company, cubit: cubit),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B388),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Edit Details',
                      style: AppTextStyle.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.body(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : '—',
          style: AppTextStyle.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanItem(PlanType planType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLANE TYPE',
          style: AppTextStyle.body(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1E3A8A), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            planType.label,
            style: AppTextStyle.body(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(CompanyStatus status) {
    Color statusColor;
    switch (status) {
      case CompanyStatus.active:
        statusColor = AppThemeColors.statusActive;
        break;
      case CompanyStatus.pending:
        statusColor = AppThemeColors.statusPending;
        break;
      case CompanyStatus.suspended:
        statusColor = AppThemeColors.statusSuspended;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS',
          style: AppTextStyle.body(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status.label,
          style: AppTextStyle.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
