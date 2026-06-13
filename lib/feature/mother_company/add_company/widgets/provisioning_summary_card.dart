import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProvisioningSummaryCard extends StatelessWidget {
  final String companyName;
  final String domain;
  final String industry;

  final String plan;
  final String billingCycle;

  final List<String> addons;

  final String adminEmail;
  final String adminMobile;
  final String generatedCompanyId;

  const ProvisioningSummaryCard({
    super.key,
    required this.companyName,
    required this.domain,
    required this.industry,
    required this.plan,
    required this.billingCycle,
    required this.addons,
    required this.adminEmail,
    required this.adminMobile,
    required this.generatedCompanyId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xff0F172A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            "Provisioning Summary",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 30),

          _sectionTitle(
            "Company Information",
          ),

          _item(
            "Company",
            companyName,
          ),

          _item(
            "Domain",
            domain,
          ),

          _item(
            "Industry",
            industry,
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Subscription",
          ),

          _item(
            "Plan",
            plan,
          ),

          _item(
            "Billing",
            billingCycle,
          ),

          _item(
            "Add-ons",
            addons.isEmpty
                ? "None"
                : addons.join(", "),
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Administrator",
          ),

          _item(
            "Email",
            adminEmail,
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "System",
          ),

          _item(
            "Company ID",
            generatedCompanyId,
          ),

          _item(
            "Provision Date",
            DateTime.now()
                .toString()
                .split(" ")
                .first,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white54,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _item(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
