import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String hint;
  final List<String> items;

  const DropdownField({super.key, required this.hint, required this.items});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {},
    );
  }
}