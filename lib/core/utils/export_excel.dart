// import 'dart:html' as html; // web only
// import 'package:excel/excel.dart';
// import 'package:intl/intl.dart';
// import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';

// void exportLeadsToExcel(List<AddLeadModel> leads,String fileName) {
//   final excel = Excel.createExcel();
//   final sheet = excel['Leads Report'];

//   // ── Header row ────────────────────────────────────────────────────────────
//   final headers = [
//     '#', 'Client Name', 'Phone No', 'WhatsApp No', 'Email',
//     'Address', 'Pin Code', 'Post Office', 'State', 'District',
//     'Lead Category', 'Lead Source', 'Lead Stage', 'Priority',
//     'Assigned Staff', 'Created By', 'Call Result', 'Remarks', 'Created Date',
//   ];

//   for (var i = 0; i < headers.length; i++) {
//     final cell = sheet.cell(
//       CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
//     );
//     cell.value = TextCellValue(headers[i]);
//     cell.cellStyle = CellStyle(
//       bold: true,
//       backgroundColorHex: ExcelColor.fromHexString('#1BAA90'),
//       fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
//     );
//   }

//   // ── Data rows ─────────────────────────────────────────────────────────────
//   for (var i = 0; i < leads.length; i++) {
//     final lead = leads[i];
//     final row = [
//       '${i + 1}',
//       lead.clientName,
//       lead.contactNumber,
//       lead.whatsappNumber,
//       lead.email,
//       lead.address,
//       lead.pinCode,
//       lead.postOffice,
//       lead.state,
//       lead.district,
//       lead.leadCategory,
//       lead.leadSource,
//       lead.leadStage,
//       lead.priority,
//       lead.assignedStaff,
//       lead.createdBy,
//       lead.callResult,
//       lead.remarks,
//       lead.createdAt != null
//           ? DateFormat('dd-MM-yyyy').format(lead.createdAt!)
//           : '-',
//     ];

//     for (var j = 0; j < row.length; j++) {
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
//           .value = TextCellValue(row[j]?? '-');
//     }
//   }

//   // ── Auto column width ─────────────────────────────────────────────────────
//   for (var i = 0; i < headers.length; i++) {
//     sheet.setColumnWidth(i, 20);
//   }

//   // ── Trigger browser download ──────────────────────────────────────────────
//   final bytes = excel.encode();
//   if (bytes == null) return;

//   final blob = html.Blob([bytes],
//       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   final anchor = html.AnchorElement(href: url)
//     ..setAttribute(
//         'download',
//         '$fileName${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx')
//     ..click();
//   html.Url.revokeObjectUrl(url); 
// }

import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

/// A single column definition: header label + how to extract the cell value from a row item.
class ExcelColumn<T> {
  final String header;
  final String? Function(T item) value;

  const ExcelColumn({required this.header, required this.value});
}

/// Generic Excel exporter.
/// [T]        – your data model type
/// [columns]  – list of column definitions (header + value extractor)
/// [rows]     – the data
/// [fileName] – prefix for the downloaded file name
void exportToExcel<T>({
  required String fileName,
  required List<ExcelColumn<T>> columns,
  required List<T> rows,
}) {
  final excel = Excel.createExcel();
  final sheet = excel['Report'];

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
    );
  }

  // ── Data rows ─────────────────────────────────────────────────────────────
  for (var i = 0; i < rows.length; i++) {
    for (var j = 0; j < columns.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
          .value = TextCellValue(columns[j].value(rows[i]) ?? '-');
    }
  }

  // ── Auto column width ─────────────────────────────────────────────────────
  for (var i = 0; i < columns.length; i++) {
    sheet.setColumnWidth(i, 20);
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