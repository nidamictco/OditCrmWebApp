import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddonCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final bool selected;
  final VoidCallback onTap;

  const AddonCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 320,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffF8FAFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xff0F2E8A)
                : const Color(0xffE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              activeColor: const Color(0xff0F2E8A),
              onChanged: (_) => onTap(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                "+\$${price.toInt()}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0F2E8A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
