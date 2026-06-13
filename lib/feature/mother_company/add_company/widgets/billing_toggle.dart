import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillingToggle extends StatelessWidget {
  final bool yearly;
  final ValueChanged<bool> onChanged;

  const BillingToggle({
    super.key,
    required this.yearly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Item(
              title: "Monthly",
              selected: !yearly,
              onTap: () => onChanged(false),
            ),
          ),

          Expanded(
            child: _Item(
              title: "Yearly",
              selected: yearly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
            BoxShadow(
              color:
              Colors.black.withOpacity(.05),
              blurRadius: 8,
            ),
          ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: selected
                ? const Color(0xff0F2E8A)
                : const Color(0xff64748B),
          ),
        ),
      ),
    );
  }
}
