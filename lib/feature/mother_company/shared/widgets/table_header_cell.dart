import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import '../../../../core/theme/app_theme.dart';

class TableHeaderCell extends StatelessWidget {
  const TableHeaderCell(
      this.label, {
        super.key,
        this.centered = false,
      });

  final String label;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign:
      centered ? TextAlign.center : TextAlign.start,
      style: AppTextStyle.tableHeader(),
    );
  }
}