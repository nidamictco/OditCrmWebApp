import 'dart:html' as html; // web only
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';

void exportLeadsToExcel(List<AddLeadModel> leads) {
  final excel = Excel.createExcel();
  final sheet = excel['Leads Report'];

  // ── Header row ────────────────────────────────────────────────────────────
  final headers = [
    '#', 'Client Name', 'Phone No', 'WhatsApp No', 'Email',
    'Address', 'Pin Code', 'Post Office', 'State', 'District',
    'Lead Category', 'Lead Source', 'Lead Stage', 'Priority',
    'Assigned Staff', 'Created By', 'Call Result', 'Remarks', 'Created Date',
  ];

  for (var i = 0; i < headers.length; i++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
    );
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1BAA90'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
  }

  // ── Data rows ─────────────────────────────────────────────────────────────
  for (var i = 0; i < leads.length; i++) {
    final lead = leads[i];
    final row = [
      '${i + 1}',
      lead.clientName,
      lead.contactNumber,
      lead.whatsappNumber,
      lead.email,
      lead.address,
      lead.pinCode,
      lead.postOffice,
      lead.state,
      lead.district,
      lead.leadCategory,
      lead.leadSource,
      lead.leadStage,
      lead.priority,
      lead.assignedStaff,
      lead.createdBy,
      lead.callResult,
      lead.remarks,
      lead.createdAt != null
          ? DateFormat('dd-MM-yyyy').format(lead.createdAt!)
          : '-',
    ];

    for (var j = 0; j < row.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
          .value = TextCellValue(row[j]?? '-');
    }
  }

  // ── Auto column width ─────────────────────────────────────────────────────
  for (var i = 0; i < headers.length; i++) {
    sheet.setColumnWidth(i, 20);
  }

  // ── Trigger browser download ──────────────────────────────────────────────
  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob([bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute(
        'download',
        'leads_report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}