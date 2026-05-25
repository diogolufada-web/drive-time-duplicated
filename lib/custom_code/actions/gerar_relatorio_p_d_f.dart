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

const PdfColor _gold = PdfColor.fromInt(0xFFD4AF37);
const PdfColor _goldSoft = PdfColor.fromInt(0xFFFFF6D6);
const PdfColor _darkGrey = PdfColor.fromInt(0xFF1A1A1A);
const PdfColor _midGrey = PdfColor.fromInt(0xFF666666);
const PdfColor _lineGrey = PdfColor.fromInt(0xFFE5E5E5);

Future<void> gerarRelatorioPDF(
  List<TurnosRecord>? turnos,
  List<PausasRecord>? pausas,
) async {
  final pdf = pw.Document();
  final safeTurnos = (turnos ?? []).where((t) => t.inicioTurno != null).toList()
    ..sort((a, b) => b.inicioTurno!.compareTo(a.inicioTurno!));
  final safePausas = pausas ?? [];

  final totalSeconds = safeTurnos.fold<int>(
    0,
    (sum, t) => sum + _shiftSeconds(t),
  );
  final completedShifts = safeTurnos.where((t) => t.fimTurno != null).length;
  final periodLabel = _periodLabel(safeTurnos);
  final motorista =
      safeTurnos.isNotEmpty ? (safeTurnos.first.nomeMotorista) : '';
  final matriculaSet = <String>{
    for (final t in safeTurnos)
      if (t.matricula.isNotEmpty) t.matricula,
  };
  final matriculaLabel =
      matriculaSet.isEmpty ? '-' : matriculaSet.join(', ');

  final pausasByShiftKey = <String, List<PausasRecord>>{};
  for (final p in safePausas) {
    final key = p.dataDia.isNotEmpty
        ? p.dataDia
        : (p.inicioPausa != null ? _dayKey(p.inicioPausa!) : '');
    if (key.isEmpty) continue;
    pausasByShiftKey.putIfAbsent(key, () => []).add(p);
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 36, 32, 40),
      header: (ctx) => _header(motorista: motorista, matricula: matriculaLabel),
      footer: (ctx) => _footer(ctx),
      build: (pw.Context context) {
        return [
          _summaryCard(
            periodLabel: periodLabel,
            totalSeconds: totalSeconds,
            shiftsCount: safeTurnos.length,
            completedShifts: completedShifts,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Resumo diário'),
          pw.SizedBox(height: 6),
          _dailyBreakdownTable(safeTurnos),
          pw.SizedBox(height: 18),
          _sectionTitle('Detalhe de turnos'),
          pw.SizedBox(height: 6),
          _shiftsTable(safeTurnos, pausasByShiftKey),
          if (safePausas.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle('Pausas registadas'),
            pw.SizedBox(height: 6),
            _pausasTable(safePausas),
          ],
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _goldSoft,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Documento gerado pela aplicação Drive Time em ${_formatDateTime(DateTime.now())}.',
              style: pw.TextStyle(fontSize: 9, color: _darkGrey),
            ),
          ),
        ];
      },
    ),
  );

  final Uint8List bytes = await pdf.save();
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'relatorio_drive_time.pdf',
  );
}

int _shiftSeconds(TurnosRecord t) {
  if (t.duracaoSegundos > 0) return t.duracaoSegundos;
  final start = t.inicioTurno;
  final end = t.fimTurno;
  if (start != null && end != null && end.isAfter(start)) {
    return end.difference(start).inSeconds;
  }
  return 0;
}

String _dayKey(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

String _formatDate(DateTime? dt) {
  if (dt == null) return '-';
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d/$m/$y';
}

String _formatTime(DateTime? dt) {
  if (dt == null) return '-';
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$h:$min';
}

String _formatDateTime(DateTime dt) {
  return '${_formatDate(dt)} ${_formatTime(dt)}';
}

String _formatDuration(int seconds) {
  if (seconds <= 0) return '0h 00m';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}

String _periodLabel(List<TurnosRecord> turnos) {
  if (turnos.isEmpty) return 'Sem dados';
  final dates = turnos
      .map((t) => t.inicioTurno!)
      .toList()
    ..sort();
  return '${_formatDate(dates.first)} – ${_formatDate(dates.last)}';
}

pw.Widget _header({required String motorista, required String matricula}) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _gold, width: 1.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'DRIVE TIME',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _gold,
                letterSpacing: 1.4,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Relatório de horas trabalhadas',
              style: pw.TextStyle(
                fontSize: 10,
                color: _midGrey,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (motorista.isNotEmpty)
              pw.Text(
                motorista,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkGrey,
                ),
              ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Matrícula: $matricula',
              style: pw.TextStyle(fontSize: 9, color: _midGrey),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _footer(pw.Context ctx) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _lineGrey, width: 0.7)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Drive Time © ${DateTime.now().year}',
          style: pw.TextStyle(fontSize: 8, color: _midGrey),
        ),
        pw.Text(
          'Página ${ctx.pageNumber} / ${ctx.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: _midGrey),
        ),
      ],
    ),
  );
}

pw.Widget _sectionTitle(String title) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: _gold,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        letterSpacing: 1.0,
      ),
    ),
  );
}

pw.Widget _summaryCard({
  required String periodLabel,
  required int totalSeconds,
  required int shiftsCount,
  required int completedShifts,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: _goldSoft,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: _gold, width: 1.0),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _summaryItem('Período', periodLabel),
        _vDivider(),
        _summaryItem('Total horas', _formatDuration(totalSeconds), bold: true),
        _vDivider(),
        _summaryItem('Turnos', shiftsCount.toString()),
        _vDivider(),
        _summaryItem('Concluídos', completedShifts.toString()),
      ],
    ),
  );
}

pw.Widget _summaryItem(String label, String value, {bool bold = false}) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            color: _midGrey,
            letterSpacing: 0.6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: bold ? 14 : 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: bold ? _gold : _darkGrey,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _vDivider() => pw.Container(
      width: 1,
      height: 32,
      color: _gold,
      margin: const pw.EdgeInsets.symmetric(horizontal: 12),
    );

pw.Widget _dailyBreakdownTable(List<TurnosRecord> turnos) {
  final byDay = <String, _DayAgg>{};
  for (final t in turnos) {
    final dt = t.inicioTurno;
    if (dt == null) continue;
    final key = _dayKey(dt);
    final agg = byDay[key] ?? _DayAgg(date: dt);
    agg.shifts += 1;
    agg.seconds += _shiftSeconds(t);
    byDay[key] = agg;
  }
  final sorted = byDay.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  if (sorted.isEmpty) {
    return pw.Text('Sem turnos no período.',
        style: pw.TextStyle(fontSize: 10, color: _midGrey));
  }
  return pw.Table.fromTextArray(
    headers: ['Data', 'Turnos', 'Total'],
    data: sorted
        .map((d) => [
              _formatDate(d.date),
              d.shifts.toString(),
              _formatDuration(d.seconds),
            ])
        .toList(),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    ),
    headerDecoration: const pw.BoxDecoration(color: _darkGrey),
    cellStyle: pw.TextStyle(fontSize: 9, color: _darkGrey),
    rowDecoration:
        const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _lineGrey, width: 0.4))),
    cellAlignments: const {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.center,
      2: pw.Alignment.centerRight,
    },
    columnWidths: const {
      0: pw.FlexColumnWidth(2),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(1.5),
    },
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  );
}

pw.Widget _shiftsTable(
  List<TurnosRecord> turnos,
  Map<String, List<PausasRecord>> pausasByDay,
) {
  if (turnos.isEmpty) {
    return pw.Text('Sem turnos no período.',
        style: pw.TextStyle(fontSize: 10, color: _midGrey));
  }
  return pw.Table.fromTextArray(
    headers: ['Data', 'Início', 'Fim', 'Estado', 'Matrícula', 'Duração'],
    data: turnos.map((t) {
      final estado = (t.estado.isNotEmpty)
          ? t.estado
          : (t.fimTurno == null ? 'Em curso' : 'Concluído');
      final matricula = t.matricula.isNotEmpty ? t.matricula : '-';
      return [
        _formatDate(t.inicioTurno),
        _formatTime(t.inicioTurno),
        _formatTime(t.fimTurno),
        estado,
        matricula,
        _formatDuration(_shiftSeconds(t)),
      ];
    }).toList(),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    ),
    headerDecoration: const pw.BoxDecoration(color: _darkGrey),
    cellStyle: pw.TextStyle(fontSize: 9, color: _darkGrey),
    rowDecoration:
        const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _lineGrey, width: 0.4))),
    cellAlignments: const {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
      3: pw.Alignment.center,
      4: pw.Alignment.center,
      5: pw.Alignment.centerRight,
    },
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  );
}

pw.Widget _pausasTable(List<PausasRecord> pausas) {
  return pw.Table.fromTextArray(
    headers: ['Data', 'Início pausa', 'Fim pausa'],
    data: pausas
        .map((p) => [
              p.dataDia.isNotEmpty ? p.dataDia : _formatDate(p.inicioPausa),
              _formatDateTime(p.inicioPausa ?? DateTime(2000)),
              p.fimPausa != null ? _formatDateTime(p.fimPausa!) : 'Em curso',
            ])
        .toList(),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      fontSize: 9,
    ),
    headerDecoration: const pw.BoxDecoration(color: _darkGrey),
    cellStyle: pw.TextStyle(fontSize: 9, color: _darkGrey),
    rowDecoration:
        const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _lineGrey, width: 0.4))),
    cellAlignments: const {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
    },
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  );
}

class _DayAgg {
  _DayAgg({required this.date, this.seconds = 0, this.shifts = 0});
  final DateTime date;
  int seconds;
  int shifts;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
