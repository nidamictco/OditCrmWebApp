import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';

Future<void> exportLeadsToPdf(List<AddLeadModel> leads) async {
  final pdf = pw.Document();
  final fmt = DateFormat('dd-MM-yyyy');
  final now = fmt.format(DateTime.now());

  // ── Column definitions: [header label, flex weight] ───────────────────────
  const columns = [
    ('#', 1),
    ('Name', 3),
    ('Phone', 2),
    ('Category', 3),
    ('Stage', 2),
    ('Priority', 2),
    ('Staff', 3),
    ('Created', 2),
  ];

  // ── Brand colors ──────────────────────────────────────────────────────────
  const headerBg   = PdfColor.fromInt(0xFF1BAA90);
  const headerText = PdfColors.white;
  const rowEven    = PdfColor.fromInt(0xFFF6FFFE);
  const rowOdd     = PdfColors.white;
  const borderCol  = PdfColor.fromInt(0xFFE0E0E0);
  const textCol    = PdfColor.fromInt(0xFF333333);

  // ── Split leads into pages of 25 rows each ────────────────────────────────
  const rowsPerPage = 25;
  final totalPages  = (leads.isEmpty ? 1 : (leads.length / rowsPerPage).ceil());

  for (var pageIdx = 0; pageIdx < totalPages; pageIdx++) {
    final start   = pageIdx * rowsPerPage;
    final end     = (start + rowsPerPage).clamp(0, leads.length);
    final chunk   = leads.isEmpty ? <AddLeadModel>[] : leads.sublist(start, end);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // ── Title bar ─────────────────────────────────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8,
                ),
                decoration: const pw.BoxDecoration(color: headerBg),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Leads Report',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: headerText,
                      ),
                    ),
                    pw.Text(
                      'Generated: $now   |   Total: ${leads.length} leads   |   Page ${pageIdx + 1}/$totalPages',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: headerText,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // ── Table ─────────────────────────────────────────────────────
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: borderCol, width: 0.5),
                  columnWidths: {
                    for (var i = 0; i < columns.length; i++)
                      i: pw.FlexColumnWidth(columns[i].$2.toDouble()),
                  },
                  children: [

                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: headerBg),
                      children: columns.map((col) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 5,
                          ),
                          child: pw.Text(
                            col.$1,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: headerText,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Data rows
                    ...chunk.asMap().entries.map((entry) {
                      final idx  = entry.key;
                      final lead = entry.value;
                      final globalIdx = start + idx + 1;
                      final bg = idx.isEven ? rowEven : rowOdd;

                      final cells = [
                        '$globalIdx',
                        lead.clientName,
                        lead.contactNumber,
                        lead.leadCategory,
                        lead.leadStage,
                        lead.priority,
                        lead.assignedStaff,
                        lead.createdAt != null
                            ? fmt.format(lead.createdAt!)
                            : '-',
                      ];

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: bg),
                        children: cells.map((cell) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4,
                            ),
                            child: pw.Text(
                              cell.isEmpty ? '-' : cell,
                              style: pw.TextStyle(
                                fontSize: 7.5,
                                color: textCol,
                              ),
                              overflow: pw.TextOverflow.clip,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // ── Footer ────────────────────────────────────────────────────
              pw.Text(
                'Exported on $now',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColor.fromInt(0xFF999999),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Trigger browser download ───────────────────────────────────────────────
  final bytes = await pdf.save();
  final blob  = html.Blob(
    [bytes],
    'application/pdf',
  );
  final url    = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'leads_report_$now.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}