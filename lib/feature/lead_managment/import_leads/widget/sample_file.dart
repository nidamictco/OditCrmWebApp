import 'dart:html' as html;
import 'package:excel/excel.dart';

void downloadSampleLeadExcel() {
  final excel = Excel.createExcel();

  // ── Remove default Sheet1 by renaming it directly ─────────────────────
  // Using rename() instead of delete() to avoid the package bug
  // where delete() silently fails on the default sheet.
  excel.rename('Sheet1', 'Report');
  final sheet = excel['Report'];

  // ── Header definitions ─────────────────────────────────────────────────
  final headers = ['Client Name', 'Contact Number', 'Address'];

  // ── Header style ───────────────────────────────────────────────────────
  final headerStyle = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('#1BAA90'),
    fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    horizontalAlign: HorizontalAlign.Center,
  );

  // ── Write header row ───────────────────────────────────────────────────
  for (var i = 0; i < headers.length; i++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
    );
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = headerStyle;
  }

  // ── Add 5 empty sample rows so user sees the format clearly ───────────
  for (var row = 1; row <= 5; row++) {
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      );
      cell.value = TextCellValue('');
      cell.cellStyle = CellStyle(
        textWrapping: TextWrapping.WrapText,
      );
    }
    // Give each empty row a standard height
    sheet.setRowHeight(row, 20.0);
  }

  // ── Column widths ──────────────────────────────────────────────────────
  sheet.setColumnWidth(0, 25); // Client Name
  sheet.setColumnWidth(1, 20); // Contact Number
  sheet.setColumnWidth(2, 35); // Address (wider for long text)

  // ── Encode and trigger browser download ───────────────────────────────
  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'Sample_Lead_Import.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}