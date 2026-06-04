
// import 'dart:html' as html;
// import 'package:excel/excel.dart';
// import 'package:intl/intl.dart';

// /// A single column definition: header label + how to extract the cell value from a row item.
// class ExcelColumn<T> {
//   final String header;
//   final String? Function(T item) value;

//   const ExcelColumn({required this.header, required this.value});
// }

// /// Generic Excel exporter.
// /// [T]        – your data model type
// /// [columns]  – list of column definitions (header + value extractor)
// /// [rows]     – the data
// /// [fileName] – prefix for the downloaded file name
// void exportToExcel<T>({
//   required String fileName,
//   required List<ExcelColumn<T>> columns,
//   required List<T> rows,
// }) {
//   final excel = Excel.createExcel();
//   final sheet = excel['Report'];

//   // ── Header row ────────────────────────────────────────────────────────────
//   for (var i = 0; i < columns.length; i++) {
//     final cell = sheet.cell(
//       CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
//     );
//     cell.value = TextCellValue(columns[i].header);
//     cell.cellStyle = CellStyle(
//       bold: true,
//       backgroundColorHex: ExcelColor.fromHexString('#1BAA90'),
//       fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
//     );
//   }

//   // ── Data rows ─────────────────────────────────────────────────────────────
//   for (var i = 0; i < rows.length; i++) {
//     for (var j = 0; j < columns.length; j++) {
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
//           .value = TextCellValue(columns[j].value(rows[i]) ?? '-');
//     }
//   }

//   // ── Auto column width ─────────────────────────────────────────────────────
//   for (var i = 0; i < columns.length; i++) {
//     sheet.setColumnWidth(i, 20);
//   }

//   // ── Trigger browser download ──────────────────────────────────────────────
//   final bytes = excel.encode();
//   if (bytes == null) return;

//   final blob = html.Blob(
//     [bytes],
//     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
//   );
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   html.AnchorElement(href: url)
//     ..setAttribute(
//       'download',
//       '$fileName${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx',
//     )
//     ..click();
//   html.Url.revokeObjectUrl(url);
// }

import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class ExcelColumn<T> {
  final String header;
  final String? Function(T item) value;
  const ExcelColumn({required this.header, required this.value});
}

void exportToExcel<T>({
  required String fileName,
  required List<ExcelColumn<T>> columns,
  required List<T> rows,
  // Optional: pass column indices that contain long text (e.g. address)
  // so we can give them a wider fixed width.
  List<int> wrapColumnIndices = const [],
}) {
 final excel = Excel.createExcel();

// Rename Sheet1 → Report directly (no delete needed)
excel.rename('Sheet1', 'Report');

// Now get the reference AFTER renaming
final sheet = excel['Report'];

print('Sheets: ${excel.sheets.keys.toList()}'); // should print: [Report]
  // ── Header row ────────────────────────────────────────────────────────────
  for (var i = 0; i < columns.length; i++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
    );
    cell.value = TextCellValue(columns[i].header);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1BAA90'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      // NOTE: We do NOT enable textWrapping on the header row
      // so header styling stays unchanged as required.
    );
  }

  // ── Data rows ─────────────────────────────────────────────────────────────
  for (var rowIdx = 0; rowIdx < rows.length; rowIdx++) {
    // FIX 2a: Track the max number of lines needed in this row.
    // The excel package does NOT auto-calculate row height, so we must
    // estimate it ourselves based on text length and column width.
    int maxLines = 1;

    for (var colIdx = 0; colIdx < columns.length; colIdx++) {
      final cellVal = columns[colIdx].value(rows[rowIdx]) ?? '-';
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 1),
      );
      cell.value = TextCellValue(cellVal);

      // FIX 2b: Apply wrap text style to every data cell.
      // TextWrapping.WrapText is the equivalent of Excel's
      // "Format Cells → Alignment → Wrap Text".
      cell.cellStyle = CellStyle(
        textWrapping: TextWrapping.WrapText,
      );

      // FIX 2c: Estimate how many lines this cell will need.
      // We use a column width of 30 chars for wrap columns, 20 for others.
      // This is an approximation — Excel renders fonts differently,
      // but this gets us close enough for most content.
      final colWidth = wrapColumnIndices.contains(colIdx) ? 30 : 20;
      final estimatedLines = (cellVal.length / colWidth).ceil().clamp(1, 20);
      if (estimatedLines > maxLines) maxLines = estimatedLines;
    }

    // FIX 2d: Set the row height manually.
    // LIMITATION: The flutter `excel` package has NO automatic row-height
    // feature. You MUST set it yourself via sheet.setRowHeight().
    // Standard Excel row height is ~15pt. We multiply by lines + a small
    // padding factor (1.2) so the last line of text isn't clipped.
    // Minimum height: 20.0 (single-line rows still look clean).
    final estimatedHeight = (maxLines * 15.0 * 1.2).clamp(20.0, 300.0);
    sheet.setRowHeight(rowIdx + 1, estimatedHeight);
  }

  // ── Column widths ─────────────────────────────────────────────────────────
  for (var i = 0; i < columns.length; i++) {
    // Give wrap-text columns extra width so fewer lines are needed per cell.
    if (wrapColumnIndices.contains(i)) {
      sheet.setColumnWidth(i, 35); // wider for long-text columns like Address
    } else {
      sheet.setColumnWidth(i, 20); // standard width for other columns
    }
  }

  // ── Trigger browser download ──────────────────────────────────────────────
  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute(
      'download',
      '$fileName${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx',
    )
    ..click();
  html.Url.revokeObjectUrl(url);
}