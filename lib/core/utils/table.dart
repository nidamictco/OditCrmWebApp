import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class TableColumn {
  final String title;
  final int flex;

  TableColumn({required this.title, this.flex = 1});
}

class CustomTable extends StatelessWidget {
  final List<TableColumn> columns;
  final List<List<Widget>> rows;
  final String emptyMessage;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = "No data available in table",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildHeader(),

          /// 🔹 EMPTY STATE
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: AppTextStyle.medium(color: Colors.grey),
                ),
              ),
            )
          else
            ..._buildRows(),
        ],
      ),
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final col = columns[index];

          return Expanded(
            flex: col.flex,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                border: Border(
                  right: index == columns.length - 1
                      ? BorderSide.none
                      : BorderSide(color: AppColors.divider),
                ),
              ),
              child: Text(
                col.title,
                style: AppTextStyle.medium(weight: FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 🔹 ROWS
  List<Widget> _buildRows() {
    return List.generate(rows.length, (rowIndex) {
      return Container(
        decoration: BoxDecoration(
          color: rowIndex.isEven ? AppColors.greyCard : Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: List.generate(rows[rowIndex].length, (colIndex) {
            return Expanded(
              flex: columns[colIndex].flex,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: colIndex == columns.length - 1
                        ? BorderSide.none
                        : BorderSide(color: AppColors.divider),
                  ),
                ),
                child: rows[rowIndex][colIndex],
              ),
            );
          }),
        ),
      );
    });
  }
}
