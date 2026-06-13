import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySettingsCard extends StatelessWidget {
  final bool enableMfa;
  final bool enableAuditLogs;
  final bool enableIpRestriction;

  final int sessionTimeout;

  final ValueChanged<bool> onMfaChanged;
  final ValueChanged<bool> onAuditChanged;
  final ValueChanged<bool> onIpRestrictionChanged;

  final ValueChanged<int> onSessionTimeoutChanged;

  const SecuritySettingsCard({
    super.key,
    required this.enableMfa,
    required this.enableAuditLogs,
    required this.enableIpRestriction,
    required this.sessionTimeout,
    required this.onMfaChanged,
    required this.onAuditChanged,
    required this.onIpRestrictionChanged,
    required this.onSessionTimeoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            "Security Configuration",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Configure organization security and compliance requirements.",
            style: GoogleFonts.poppins(
              color: const Color(0xff64748B),
            ),
          ),

          const SizedBox(height: 30),

          _SettingTile(
            title: "Multi-Factor Authentication",
            subtitle:
            "Require additional verification during login.",
            value: enableMfa,
            onChanged: onMfaChanged,
          ),

          const SizedBox(height: 18),

          _SettingTile(
            title: "Compliance Audit Logging",
            subtitle:
            "Track all important user and system activities.",
            value: enableAuditLogs,
            onChanged: onAuditChanged,
          ),

          const SizedBox(height: 18),

          _SettingTile(
            title: "IP Address Restriction",
            subtitle:
            "Allow access only from approved IP addresses.",
            value: enableIpRestriction,
            onChanged: onIpRestrictionChanged,
          ),

          const SizedBox(height: 28),

          const Divider(),

          const SizedBox(height: 24),

          Text(
            "Session Timeout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Automatically sign out inactive users.",
            style: GoogleFonts.poppins(
              color: const Color(0xff64748B),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<int>(
            value: sessionTimeout,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 15,
                child: Text("15 Minutes", style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text("30 Minutes", style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 60,
                child: Text("1 Hour", style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 120,
                child: Text("2 Hours", style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 240,
                child: Text("4 Hours", style: GoogleFonts.poppins()),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onSessionTimeoutChanged(value);
              }
            },
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xff0F2E8A),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Recommended: Enable MFA and Audit Logging for organizations handling sensitive customer information.",
                    style: GoogleFonts.poppins(
                      color: const Color(0xff334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Switch(
            value: value,
            activeColor:
            const Color(0xff0F2E8A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
