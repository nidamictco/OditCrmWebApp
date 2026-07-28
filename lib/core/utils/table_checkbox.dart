import 'package:flutter/material.dart';

Widget buildRoundedCheckbox({
  required bool value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: value ? const Color(0xff10B981) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value ? const Color(0xff10B981) : const Color(0xffCBD5E1),
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    ),
  );
}
