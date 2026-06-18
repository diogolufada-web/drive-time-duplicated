import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/error_messages.dart';
import '/utils/shift_time.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'historicopage_model.dart';
export 'historicopage_model.dart';

class HistoricopageWidget extends StatefulWidget {
  const HistoricopageWidget({super.key});

  static String routeName = 'historicopage';
  static String routePath = '/historicopage';

  @override
  State<HistoricopageWidget> createState() => _HistoricopageWidgetState();
}

class _HistoricopageWidgetState extends State<HistoricopageWidget> {
  late HistoricopageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _accent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoricopageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfWindow = startOfToday.subtract(const Duration(days: 6));

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
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<PausasRecord>>(
                  stream: queryPausasRecord(
                    queryBuilder: (q) =>
                        q.where('email', isEqualTo: currentUserEmail),
                  ),
                  builder: (context, pausasSnapshot) {
                    final pausas = (pausasSnapshot.data ?? <PausasRecord>[])
                        .where((p) =>
                            p.inicioPausa != null &&
                            !p.inicioPausa!.isBefore(startOfWindow))
                        .toList();
                    return StreamBuilder<List<TurnosRecord>>(
                      stream: queryTurnosRecord(
                        queryBuilder: (q) => q
                            .where('email', isEqualTo: currentUserEmail)
                            .where('inicio_turno',
                                isGreaterThanOrEqualTo: startOfWindow),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ListView(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              _buildHeader(theme),
                              const SizedBox(height: 40),
                              Text(
                                firestoreErrorMessage(snapshot.error),
                                textAlign: TextAlign.center,
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: theme.error,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(_accent),
                              ),
                            ),
                          );
                        }
                        final turnos = snapshot.data!;
                        if (turnos.isEmpty) {
                          return ListView(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              _buildHeader(theme),
                              const SizedBox(height: 40),
                              Text(
                                tr('history.emptyList'),
                                textAlign: TextAlign.center,
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: theme.secondaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }
                        final perDay =
                            _groupByDay(turnos, pausas, startOfToday);
                        final totalSeconds = perDay.values
                            .fold<int>(0, (sum, d) => sum + d.totalSeconds);
                        final totalShifts = perDay.values
                            .fold<int>(0, (sum, d) => sum + d.shifts);
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            _buildHeader(theme),
                            const SizedBox(height: 16),
                            _buildWeekTotalCard(
                              theme,
                              totalSeconds: totalSeconds,
                              totalShifts: totalShifts,
                            ),
                            const SizedBox(height: 20),
                            for (int i = 0; i < 7; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildDayCard(
                                  theme,
                                  day:
                                      startOfToday.subtract(Duration(days: i)),
                                  info: perDay[_dayKey(startOfToday
                                      .subtract(Duration(days: i)))],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _buildBottomNav(theme),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, _DaySummary> _groupByDay(
    List<TurnosRecord> turnos,
    List<PausasRecord> pausas,
    DateTime startOfToday,
  ) {
    final map = <String, _DaySummary>{};
    for (final t in turnos) {
      final start = t.inicioTurno;
      if (start == null) continue;
      final dayStart = DateTime(start.year, start.month, start.day);
      if (dayStart.isAfter(startOfToday)) continue;
      final diff = startOfToday.difference(dayStart).inDays;
      if (diff > 6) continue;
      final key = _dayKey(dayStart);
      final existing = map[key] ?? _DaySummary(date: dayStart);
      existing.shifts += 1;
      existing.totalSeconds += effectiveShiftSeconds(t, pausas);
      map[key] = existing;
    }
    return map;
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0${tr('common.hoursShort')} 0${tr('common.minutesShort')}';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '$hours${tr('common.hoursShort')} ${minutes.toString().padLeft(2, '0')}${tr('common.minutesShort')}';
  }

  String _dayLabel(DateTime day, DateTime startOfToday) {
    final diff = startOfToday.difference(day).inDays;
    if (diff == 0) return tr('history.today');
    return tr('weekday.${day.weekday}');
  }

  String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Column(
      children: [
        dtTextLogo(context),
        const SizedBox(height: 12),
        dtSectionTitle(context, tr('history.weekly'), fontSize: 32),
      ],
    );
  }

  Widget _buildWeekTotalCard(
    FlutterFlowTheme theme, {
    required int totalSeconds,
    required int totalShifts,
  }) {
    final shiftsLabel = totalShifts == 1
        ? tr('history.shiftCount')
        : tr('history.shiftsCount');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: dtGoldCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('history.weekTotal'),
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDuration(totalSeconds),
            style: theme.titleLarge.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalShifts $shiftsLabel',
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

  Widget _buildDayCard(
    FlutterFlowTheme theme, {
    required DateTime day,
    required _DaySummary? info,
  }) {
    final startOfToday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final hasData = info != null && info.totalSeconds > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: dtCardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: hasData ? _accent : theme.primaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  _dayLabel(day, startOfToday),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: hasData ? Colors.white : theme.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _shortDate(day),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    color: hasData
                        ? Colors.white.withOpacity(0.9)
                        : theme.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData
                      ? _formatDuration(info.totalSeconds)
                      : _formatDuration(0),
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: hasData ? theme.primaryText : theme.secondaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasData
                      ? '${info.shifts} ${info.shifts == 1 ? tr('history.shiftCount') : tr('history.shiftsCount')}'
                      : tr('history.noShifts'),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    color: theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasData ? Icons.check_circle : Icons.remove_circle_outline,
            color: hasData ? _accent : theme.alternate,
            size: 22,
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
            selected: true,
            onTap: () {},
          ),
          _navItem(
            theme: theme,
            icon: Icons.description_outlined,
            label: tr('nav.reports'),
            onTap: () => context.goNamed(RelatoriospageWidget.routeName),
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

class _DaySummary {
  _DaySummary({required this.date});
  final DateTime date;
  int totalSeconds = 0;
  int shifts = 0;
}
