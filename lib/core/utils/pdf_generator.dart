import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/providers.dart';
import 'formatters.dart';

class PdfGenerator {
  static Future<void> exportProjectSummary(ProjectDetailsData data) async {
    final pdf = pw.Document();

    final project = data.project;
    final stages = data.stages;
    final materials = data.materials;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Board
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.blueGrey, width: 2),
                  ),
                ),
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GOVERNMENT OF JHARKHAND',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.Text(
                          'ROAD CONSTRUCTION MONITORING SYSTEM',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'STATUS REPORT',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          Formatters.formatDate(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // 2. Project Title
              pw.Text(
                project.name,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'District: ${project.district} | Status: ${project.status.toUpperCase()}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 16),

              // 3. Metadata Table
              pw.Text('I. Project Metadata', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      _cell('Supervising Authority', isHeader: true),
                      _cell(project.authority?.name ?? 'N/A'),
                      _cell('Assigned Contractor', isHeader: true),
                      _cell(project.contractor?.name ?? 'N/A'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('Financial Budget', isHeader: true),
                      _cell(Formatters.formatFullCurrency(project.budget)),
                      _cell('Structural Length', isHeader: true),
                      _cell('${project.lengthKm} KM'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('Commencement Date', isHeader: true),
                      _cell(Formatters.formatDate(project.startDate)),
                      _cell('Estimated Completion', isHeader: true),
                      _cell(Formatters.formatDate(project.endDate)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('Recorded Delay', isHeader: true),
                      _cell('${project.delayDays} Days'),
                      _cell('Current Completion', isHeader: true),
                      _cell('${project.completionPercent.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // 4. Construction Stages Timeline
              pw.Text('II. Construction Stages Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(40),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(80),
                  3: pw.FixedColumnWidth(100),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('#', isHeader: true),
                      _cell('Stage Details', isHeader: true),
                      _cell('Progress', isHeader: true),
                      _cell('Start Date', isHeader: true),
                    ],
                  ),
                  ...stages.map((stage) => pw.TableRow(
                        children: [
                          _cell('${stage.sequenceOrder}'),
                          _cell(stage.stageName),
                          _cell('${stage.completionPercent.toStringAsFixed(0)}%'),
                          _cell(Formatters.formatDate(stage.startDate)),
                        ],
                      )),
                ],
              ),
              pw.SizedBox(height: 24),

              // 5. Materials Utilized
              pw.Text('III. Utilized Structural Materials', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 6),
              if (materials.isEmpty)
                pw.Text('No material logs recorded.', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700))
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(),
                    1: pw.FixedColumnWidth(150),
                    2: pw.FixedColumnWidth(100),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _cell('Material Name', isHeader: true),
                        _cell('Quantity Utilized', isHeader: true),
                        _cell('Measurement Unit', isHeader: true),
                      ],
                    ),
                    ...materials.map((mat) => pw.TableRow(
                          children: [
                            _cell(mat.materialName),
                            _cell(mat.quantity.toStringAsFixed(1)),
                            _cell(mat.unit),
                          ],
                        )),
                  ],
                ),
              pw.Spacer(),

              // 6. Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5)),
                        ),
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          'Prepared By (Contractor)',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5)),
                        ),
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          'Verified By (Authority)',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Show Print/Share sheet
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Project_Summary_${project.id}.pdf',
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
