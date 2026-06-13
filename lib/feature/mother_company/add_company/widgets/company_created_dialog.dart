import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class CompanyCreatedDialog
    extends StatelessWidget {
  final String companyId;
  final String adminMobile;

  const CompanyCreatedDialog({
    super.key,
    required this.companyId,
    required this.adminMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Container(
        width: 520,
        padding:
        const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
              const BoxDecoration(
                color:
                Color(0xffECFDF5),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color:
                Colors.green,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Company Created Successfully",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Organization has been provisioned successfully.",
              textAlign:
              TextAlign.center,
              style: GoogleFonts.poppins(),
            ),

            const SizedBox(height: 30),

            _item(
              "Company ID",
              companyId,
            ),

            _item(
              "Admin Mobile",
              adminMobile,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppThemeColors
                      .primary,
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Text(
            "$title : ",
            style: GoogleFonts.poppins(
              fontWeight:
              FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
