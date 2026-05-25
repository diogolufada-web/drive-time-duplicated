import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'relatoriospage_model.dart';
export 'relatoriospage_model.dart';

enum ReportFilter { today, week, month, custom }

class RelatoriospageWidget extends StatefulWidget {
  const RelatoriospageWidget({super.key});

  static String routeName = 'relatoriospage';
  static String routePath = '/relatoriospage';

  @override
  State<RelatoriospageWidget> createState() => _RelatoriospageWidgetState();
}

class _RelatoriospageWidgetState extends State<RelatoriospageWidget> {
  late RelatoriospageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _accent = Color(0xFFD4AF37);

  ReportFilter _filter = ReportFilter.week;
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RelatoriospageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  ({DateTime start, DateTime end}) _resolveRange() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    switch (_filter) {
      case ReportFilter.today:
        return (start: startOfToday, end: endOfToday);
      case ReportFilter.week:
        final monday =
            startOfToday.subtract(Duration(days: startOfToday.weekday - 1));
        return (start: monday, end: endOfToday);
      case ReportFilter.month:
        final firstOfMonth = DateTime(now.year, now.month, 1);
        return (start: firstOfMonth, end: endOfToday);
      case ReportFilter.custom:
        final s = _customStart ?? startOfToday;
        final e = _customEnd != null
            ? DateTime(_customEnd!.year, _customEnd!.month, _customEnd!.day + 1)
            : endOfToday;
        return (
          start: DateTime(s.year, s.month, s.day),
          end: e.isAfter(s) ? e : e.add(const Duration(days: 1)),
        );
    }
  }

  String _periodLabel() {
    final r = _resolveRange();
    final endDisplay = r.end.subtract(const Duration(seconds: 1));
    return '${_shortDate(r.start)} – ${_shortDate(endDisplay)}';
  }

  String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _hm(DateTime? d) => d == null
      ? '--:--'
      : '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0h 00m';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  int _shiftSeconds(TurnosRecord t) {
    if (t.duracaoSegundos > 0) return t.duracaoSegundos;
    final s = t.inicioTurno;
    final e = t.fimTurno;
    if (s != null && e != null && e.isAfter(s)) {
      return e.difference(s).inSeconds;
    }
    return 0;
  }

  List<TurnosRecord> _applyRange(List<TurnosRecord> all) {
    final r = _resolveRange();
    return all
        .where((t) =>
            t.inicioTurno != null &&
            !t.inicioTurno!.isBefore(r.start) &&
            t.inicioTurno!.isBefore(r.end))
        .toList()
      ..sort((a, b) => b.inicioTurno!.compareTo(a.inicioTurno!));
  }

  List<PausasRecord> _applyRangePausas(List<PausasRecord> all) {
    final r = _resolveRange();
    return all
        .where((p) =>
            p.inicioPausa != null &&
            !p.inicioPausa!.isBefore(r.start) &&
            p.inicioPausa!.isBefore(r.end))
        .toList();
  }

  Future<void> _pickCustomDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_customStart ?? now)
        : (_customEnd ?? _customStart ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    safeSetState(() {
      if (isStart) {
        _customStart = picked;
        if (_customEnd != null && _customEnd!.isBefore(picked)) {
          _customEnd = picked;
        }
      } else {
        _customEnd = picked;
        if (_customStart != null && picked.isBefore(_customStart!)) {
          _customStart = picked;
        }
      }
      _filter = ReportFilter.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: StreamBuilder<List<TurnosRecord>>(
            stream: queryTurnosRecord(
              queryBuilder: (q) => q.where('email', isEqualTo: currentUserEmail),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                );
              }
              final allTurnos = snapshot.data!;
              return StreamBuilder<List<PausasRecord>>(
                stream: queryPausasRecord(
                  queryBuilder: (q) =>
                      q.where('email', isEqualTo: currentUserEmail),
                ),
                builder: (context, snapshotPausas) {
                  final allPausas = snapshotPausas.data ?? [];
                  final filtered = _applyRange(allTurnos);
                  final filteredPausas = _applyRangePausas(allPausas);
                  final totalSeconds = filtered.fold<int>(
                      0, (s, t) => s + _shiftSeconds(t));
                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            _buildTitle(theme),
                            const SizedBox(height: 16),
                            _buildFilterChips(theme),
                            const SizedBox(height: 12),
                            if (_filter == ReportFilter.custom)
                              _buildCustomDates(theme),
                            const SizedBox(height: 14),
                            _buildSummaryCard(
                              theme,
                              totalSeconds: totalSeconds,
                              shifts: filtered.length,
                            ),
                            const SizedBox(height: 14),
                            _buildExportButton(
                              theme,
                              filtered: filtered,
                              pausas: filteredPausas,
                            ),
                            const SizedBox(height: 18),
                            _sectionLabel(theme, tr('reports.shiftsList')),
                            const SizedBox(height: 8),
                            if (filtered.isEmpty)
                              _emptyState(theme)
                            else
                              ...filtered.map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _shiftCard(theme, t),
                                  )),
                          ],
                        ),
                      ),
                      _buildBottomNav(theme),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(FlutterFlowTheme theme) {
    return Center(
      child: Text(
        tr('reports.title'),
        style: theme.titleLarge.override(
          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
          color: _accent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFilterChips(FlutterFlowTheme theme) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(theme, tr('reports.filterToday'), ReportFilter.today),
          const SizedBox(width: 8),
          _chip(theme, tr('reports.filterWeek'), ReportFilter.week),
          const SizedBox(width: 8),
          _chip(theme, tr('reports.filterMonth'), ReportFilter.month),
          const SizedBox(width: 8),
          _chip(theme, tr('reports.filterCustom'), ReportFilter.custom),
        ],
      ),
    );
  }

  Widget _chip(FlutterFlowTheme theme, String label, ReportFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () {
        safeSetState(() {
          _filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _accent : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent, width: 1.2),
        ),
        child: Text(
          label,
          style: theme.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            color: selected ? Colors.white : theme.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDates(FlutterFlowTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _dateButton(
            theme,
            label: tr('reports.startDate'),
            value: _customStart,
            onTap: () => _pickCustomDate(isStart: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dateButton(
            theme,
            label: tr('reports.endDate'),
            value: _customEnd,
            onTap: () => _pickCustomDate(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _dateButton(
    FlutterFlowTheme theme, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: _accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null ? _shortDate(value) : label,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  color: value != null ? theme.primaryText : theme.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    FlutterFlowTheme theme, {
    required int totalSeconds,
    required int shifts,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x55000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _periodLabel(),
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDuration(totalSeconds),
            style: theme.titleLarge.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$shifts ${tr('reports.shifts').toLowerCase()}',
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w500),
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    FlutterFlowTheme theme, {
    required List<TurnosRecord> filtered,
    required List<PausasRecord> pausas,
  }) {
    return FFButtonWidget(
      onPressed: filtered.isEmpty || _exporting
          ? null
          : () async {
              safeSetState(() => _exporting = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('reports.generatingPdf')),
                  duration: const Duration(seconds: 2),
                ),
              );
              try {
                await actions.gerarRelatorioPDF(filtered, pausas);
              } finally {
                if (mounted) safeSetState(() => _exporting = false);
              }
            },
      text: _exporting ? '…' : tr('reports.exportPdf'),
      icon: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.white),
      options: FFButtonOptions(
        width: double.infinity,
        height: 46,
        color: _accent,
        textStyle: theme.titleSmall.override(
          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
          color: Colors.white,
          letterSpacing: 0.6,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        disabledColor: theme.alternate,
        disabledTextColor: theme.secondaryText,
      ),
    );
  }

  Widget _sectionLabel(FlutterFlowTheme theme, String label) {
    return Text(
      label,
      style: theme.bodyMedium.override(
        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
        color: theme.secondaryText,
        fontSize: 13,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _emptyState(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.alternate.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              color: theme.secondaryText, size: 40),
          const SizedBox(height: 8),
          Text(
            tr('reports.empty'),
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w500),
              color: theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shiftCard(FlutterFlowTheme theme, TurnosRecord t) {
    final inProgress = t.fimTurno == null;
    final estado = inProgress
        ? tr('reports.inProgress')
        : (t.estado.isNotEmpty ? t.estado : tr('reports.completed'));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inProgress ? _accent : _accent.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: inProgress ? _accent : theme.primaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              inProgress ? Icons.play_arrow : Icons.check,
              color: inProgress ? Colors.white : _accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _shortDate(t.inicioTurno!),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_hm(t.inicioTurno)} – ${_hm(t.fimTurno)}  •  $estado',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    color: theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (t.matricula.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    t.matricula,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: _accent,
                      fontSize: 12,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            _formatDuration(_shiftSeconds(t)),
            style: theme.titleSmall.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: _accent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: const BoxDecoration(color: _accent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            theme: theme,
            icon: Icons.home,
            label: tr('nav.home'),
            onTap: () => context.goNamed(HomepageWidget.routeName),
          ),
          _navItem(
            theme: theme,
            icon: Icons.history,
            label: tr('nav.history'),
            onTap: () => context.goNamed(HistoricopageWidget.routeName),
          ),
          _navItem(
            theme: theme,
            icon: Icons.description_outlined,
            label: tr('nav.reports'),
            selected: true,
            onTap: () {},
          ),
          _navItem(
            theme: theme,
            icon: Icons.settings_outlined,
            label: tr('nav.settings'),
            onTap: () => context.goNamed(DefenioespageWidget.routeName),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required FlutterFlowTheme theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final color = selected ? theme.alternate : theme.primaryText;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
