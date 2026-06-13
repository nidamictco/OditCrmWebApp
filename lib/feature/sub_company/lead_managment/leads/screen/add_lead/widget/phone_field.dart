import 'package:flutter/material.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/screen/add_lead/widget/costum_text_field.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("+91"),
        ),
        const SizedBox(width: 10),
        const Expanded(child: CustomTextField(hint: "Enter number")),
      ],
    );
  }
}