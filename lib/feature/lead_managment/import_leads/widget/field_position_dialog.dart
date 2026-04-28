import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class FieldPositionDialog extends StatelessWidget {
  const FieldPositionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔵 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFC6D6E2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Field Position",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            /// 🔽 BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// NOTE BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E6F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF9EC3DC)),
                    ),
                    child: const Text(
                      "Note: Field Position start from 0",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// INPUT FIELDS
                  _buildField("Client Name", "0"),
                  const SizedBox(height: 12),

                  _buildField("Phone", "1"),
                  const SizedBox(height: 12),

                  _buildField("Address", "2"),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Close",
                          style: AppTextStyle.medium(weight: FontWeight.w400),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        height: 4.h,
                        width: 7.w,
                        decoration: BoxDecoration(
                          color: Color(0xFF4C5B8F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            "Submit",
                            style: AppTextStyle.medium(
                              color: Colors.white,
                              size: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 Reusable Field Widget
  Widget _buildField(String label, String hint) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.small(size: 10.sp),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}
