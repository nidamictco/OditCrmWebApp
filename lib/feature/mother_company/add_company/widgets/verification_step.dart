import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_account_form.dart';
import 'provisioning_summary_card.dart';
import 'security_settings_card.dart';

class VerificationStep extends StatelessWidget {
  final Widget adminAccountForm;

  final bool enableMfa;
  final bool enableAuditLogs;
  final bool enableIpRestriction;

  final int sessionTimeout;

  final ValueChanged<bool> onMfaChanged;
  final ValueChanged<bool> onAuditChanged;
  final ValueChanged<bool> onIpRestrictionChanged;

  final ValueChanged<int> onSessionTimeoutChanged;

  final String companyName;
  final String domain;
  final String industry;

  final String plan;
  final String billingCycle;

  final List<String> addons;

  final String adminEmail;
  final String adminMobile;
  final String generatedCompanyId;

  final bool isCreating;

  final VoidCallback onBack;
  final VoidCallback onCreateCompany;

  const VerificationStep({
    super.key,
    required this.adminAccountForm,
    required this.enableMfa,
    required this.enableAuditLogs,
    required this.enableIpRestriction,
    required this.sessionTimeout,
    required this.onMfaChanged,
    required this.onAuditChanged,
    required this.onIpRestrictionChanged,
    required this.onSessionTimeoutChanged,
    required this.companyName,
    required this.domain,
    required this.industry,
    required this.plan,
    required this.billingCycle,
    required this.addons,
    required this.adminEmail,
    required this.adminMobile,
    required this.generatedCompanyId,
    required this.isCreating,
    required this.onBack,
    required this.onCreateCompany,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: adminAccountForm),

            // const SizedBox(width: 24),

            // Expanded(
            //   flex: 4,
            //   child: SecuritySettingsCard(
            //     enableMfa: enableMfa,
            //     enableAuditLogs:
            //     enableAuditLogs,
            //     enableIpRestriction:
            //     enableIpRestriction,
            //     sessionTimeout:
            //     sessionTimeout,
            //     onMfaChanged:
            //     onMfaChanged,
            //     onAuditChanged:
            //     onAuditChanged,
            //     onIpRestrictionChanged:
            //     onIpRestrictionChanged,
            //     onSessionTimeoutChanged:
            //     onSessionTimeoutChanged,
            //   ),
            // ),
            const SizedBox(width: 24),

            ProvisioningSummaryCard(
              companyName: companyName,
              domain: domain,
              industry: industry,
              plan: plan,
              billingCycle: billingCycle,
              addons: addons,
              adminEmail: adminEmail,
              adminMobile: adminMobile,
              generatedCompanyId: generatedCompanyId,
            ),
          ],
        ),

        const SizedBox(height: 32),

        const Divider(),

        const SizedBox(height: 24),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: isCreating ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              label: Text("Back", style: GoogleFonts.poppins()),
            ),

            const Spacer(),

            SizedBox(
              width: 220,
              height: 54,
              child: ElevatedButton(
                onPressed: isCreating ? null : onCreateCompany,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F2E8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isCreating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Text(
                            "Creating...",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.business, color: Colors.white),

                          const SizedBox(width: 10),

                          Text(
                            "Create Company",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
