// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

Future<void> gerarRelatorioPDF(
  List<TurnosRecord>? turnos,
  List<PausasRecord>? pausas,
) async {
  final pdf = pw.Document();

  String formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Text(
            'Relatório de Horas - Drive Time',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
              'Documento gerado automaticamente pela aplicação Drive Time.'),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Turnos',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (turnos == null || turnos.isEmpty)
            pw.Text('Sem turnos encontrados.')
          else
            pw.Table.fromTextArray(
              headers: [
                'Data',
                'Motorista',
                'Início',
                'Fim',
                'Estado',
                'Matrícula'
              ],
              data: turnos.map((t) {
                return [
                  t.dataDia ?? '-',
                  t.nomeMotorista ?? '-',
                  formatDate(t.inicioTurno),
                  formatDate(t.fimTurno),
                  t.estado ?? '-',
                  t.matricula ?? '-',
                ];
              }).toList(),
            ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Pausas',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (pausas == null || pausas.isEmpty)
            pw.Text('Sem pausas encontradas.')
          else
            pw.Table.fromTextArray(
              headers: ['Data', 'Início Pausa', 'Fim Pausa'],
              data: pausas.map((p) {
                return [
                  p.dataDia ?? '-',
                  formatDate(p.inicioPausa),
                  formatDate(p.fimPausa),
                ];
              }).toList(),
            ),
        ];
      },
    ),
  );

  final Uint8List bytes = await pdf.save();

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'relatorio_drive_time.pdf')
    ..click();

  html.Url.revokeObjectUrl(url);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
