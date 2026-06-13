import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoUploadWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const LogoUploadWidget({
    super.key,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Company Logo",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            dashPattern: const [6, 4],
            color: const Color(0xffCBD5E1),
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              child: imageBytes == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 42,
                    color: Color(0xff64748B),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "UPLOAD PNG",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Max size 2MB\nRecommended 400x400",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xff94A3B8),
          ),
        ),
      ],
    );
  }
}
