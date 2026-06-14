import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/subscription_feature.dart';

class SubscriptionCard extends StatelessWidget {
  final String category;
  final String title;
  final double price;
  final bool selected;
  final bool mostPopular;

  final VoidCallback onTap;

  final List<SubscriptionFeature> features;

  const SubscriptionCard({
    super.key,
    required this.category,
    required this.title,
    required this.price,
    required this.selected,
    required this.features,
    required this.onTap,
    this.mostPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xff0F2E8A)
        : const Color(0xffE2E8F0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 320,
      height: 600,
      padding: const EdgeInsets.all(28),
      transform: Matrix4.identity()..scale(selected ? 1.03 : 1.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(selected ? .08 : .03),
            blurRadius: selected ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xff64748B),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${price.toInt()}",
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff0F2E8A),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      "/ month",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xff64748B),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        feature.available
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 20,
                        color: feature.available
                            ? const Color(0xff0E8F62)
                            : const Color(0xffCBD5E1),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          feature.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: feature.available
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: feature.available
                                ? const Color(0xff1E293B)
                                : const Color(0xff94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected
                        ? const Color(0xff0F2E8A)
                        : Colors.white,
                    foregroundColor: selected
                        ? Colors.white
                        : const Color(0xff0F2E8A),
                    side: const BorderSide(color: Color(0xff0F2E8A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Select $title",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),

          if (mostPopular)
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff0F2E8A),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "MOST POPULAR",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
