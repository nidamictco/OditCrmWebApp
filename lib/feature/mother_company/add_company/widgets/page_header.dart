import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageHeader extends StatelessWidget {
  final String breadcrumb;
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.breadcrumb,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breadcrumb,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Color(0xff64748B),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 35,
            fontWeight: FontWeight.w600,
            color: Color(0xff0F2E8A),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Color(0xff64748B),
          ),
        ),
      ],
    );
  }
}