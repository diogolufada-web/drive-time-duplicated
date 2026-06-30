import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart';
import '/index.dart';
import '/utils/error_messages.dart';
import '/utils/shift_time.dart';
import '/services/notifications_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage_model.dart';
export 'homepage_model.dart';

class HomepageWidget extends StatefulWidget {
  const HomepageWidget({
    super.key,
    bool? pause,
    this.start,
  }) : this.pause = pause ?? true;

  /// Pause
  final bool pause;

  /// Start
  final String? start;

  static String routeName = 'Homepage';
  static String routePath = '/homepage';

  @override
  State<HomepageWidget> createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<HomepageWidget> {
  late HomepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _shiftBusy = false;
  bool _autoStopInProgress = false;
  String? _autoStopTurnoId;
  Timer? _clockTimer;

  bool _isShiftPausa(TurnosRecord turno) {
    final e = turno.estado.trim().toLowerCase();
    return e == 'pausa' || e == 'em_pausa' || e == 'empausa';
  }

  /// RETOMAR se `estado` for pausa ou existir pausa activa ligada ao turno.
  bool _showRetomarLabel(
    TurnosRecord turno,
    List<PausasRecord> activePausasForTurno,
  ) =>
      _isShiftPausa(turno) || activePausasForTurno.isNotEmpty;

  void _showShiftSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  Future<TurnosRecord?> _loadFreshActiveTurno(TurnosRecord turno) async {
    try {
      final fresh = await TurnosRecord.getDocumentOnce(turno.reference);
      if (!fresh.ativo) {
        _showShiftSnack(tr('home.shiftInactive'));
        return null;
      }
      return fresh;
    } catch (e) {
      _showShiftSnack(firestoreErrorMessage(e));
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _model.veiculodoc = await queryVeiculosRecordOnce(
        queryBuilder: (veiculosRecord) => veiculosRecord
            .where('email', isEqualTo: currentUserEmail)
            .where('ativo', isEqualTo: true),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      final motorista = await queryMotoristasRecordOnce(
        queryBuilder: (q) => q.where('email', isEqualTo: currentUserEmail),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      if (!mounted) return;
      final profileIncomplete = motorista == null ||
          motorista.nif.trim().isEmpty ||
          _model.veiculodoc == null ||
          _model.veiculodoc!.matricula.trim().isEmpty;
      if (profileIncomplete) {
        _showShiftSnack(tr('onboarding.completeProfile'));
      }
      safeSetState(() {});
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _model.dispose();

    super.dispose();
  }

  String _formatTodayHours(
    List<TurnosRecord> turnos,
    List<PausasRecord> pausas,
    TurnosRecord? activeTurno,
  ) {
    final turnosByPath = <String, TurnosRecord>{
      for (final turno in turnos) turno.reference.path: turno,
    };
    if (activeTurno != null) {
      turnosByPath[activeTurno.reference.path] = activeTurno;
    }

    var totalSeconds = 0;
    for (final turno in turnosByPath.values) {
      totalSeconds += effectiveShiftSeconds(turno, pausas);
    }
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _scheduleAutoStopIfNeeded(TurnosRecord? turno) {
    if (turno == null || !turno.ativo || _shiftBusy || _autoStopInProgress) {
      return;
    }
    if (!isShiftExpired(turno)) {
      return;
    }
    if (_autoStopTurnoId == turno.reference.id) {
      return;
    }
    _autoStopTurnoId = turno.reference.id;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _autoStopInProgress) {
        return;
      }
      _autoStopInProgress = true;
      _shiftBusy = true;
      try {
        final stopped = await autoStopTurnoIfExpired(turno);
        if (!stopped) {
          _autoStopTurnoId = null;
        }
      } finally {
        _autoStopInProgress = false;
        _shiftBusy = false;
        if (mounted) {
          safeSetState(() {});
        }
      }
    });
  }

  Future<void> _onPauseResumePressed(TurnosRecord turno) async {
    if (_shiftBusy) {
      return;
    }
    _shiftBusy = true;
    try {
      final fresh = await _loadFreshActiveTurno(turno);
      if (fresh == null) {
        return;
      }
      await pauseResumeTurno(fresh);
    } catch (e) {
      _showShiftSnack(firestoreErrorMessage(e));
    } finally {
      _shiftBusy = false;
      if (mounted) {
        safeSetState(() {});
      }
    }
  }

  Widget _buildDriverHeader(
    BuildContext context, {
    required String driverName,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final hasName = driverName.trim().isNotEmpty;
    final matricula = (_model.veiculodoc?.matricula ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 14.0, 12.0, 12.0),
          child: dtHomeHeaderLogo(context),
        ),
        _buildDriverHeaderCard(context, theme, hasName, driverName, matricula),
      ],
    );
  }

  Widget _buildDriverHeaderCard(
    BuildContext context,
    FlutterFlowTheme theme,
    bool hasName,
    String driverName,
    String matricula,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 0.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: dtCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: theme.titleSmall.override(
                        font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w800),
                        color: theme.primaryText,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(text: '${tr('home.welcome')}, '),
                        TextSpan(
                          text: hasName ? driverName : '—',
                          style: const TextStyle(
                            color: kDtGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    matricula.isNotEmpty
                        ? matricula.toUpperCase()
                        : '__-__-__',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w800),
                      color: kDtGold,
                      fontSize: 18.0,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingDriverProfile(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: dtHomeHeaderLogo(context)),
              const SizedBox(height: 24.0),
              Text(
                tr('onboarding.missingDriverTitle'),
                textAlign: TextAlign.center,
                style: theme.headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                tr('onboarding.missingDriverBody'),
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 28.0),
              FFButtonWidget(
                onPressed: () =>
                    context.pushNamed(DadosmotoristaWidget.routeName),
                text: tr('onboarding.setupProfile'),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 48.0,
                  color: kDtGold,
                  textStyle: theme.titleSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStopPressed(TurnosRecord turno) async {
    if (_shiftBusy) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('shift.stopConfirmTitle')),
        content: Text(tr('shift.stopConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('common.confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    _shiftBusy = true;
    try {
      final fresh = await _loadFreshActiveTurno(turno);
      if (fresh == null) {
        return;
      }
      await stopTurno(fresh);
    } catch (e) {
      _showShiftSnack(firestoreErrorMessage(e));
    } finally {
      _shiftBusy = false;
      if (mounted) {
        safeSetState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MotoristasRecord>>(
      stream: queryMotoristasRecord(
        queryBuilder: (motoristasRecord) => motoristasRecord.where(
          'email',
          isEqualTo: currentUserEmail,
        ),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<MotoristasRecord> homepageMotoristasRecordList = snapshot.data!;
        if (snapshot.data!.isEmpty) {
          return _buildMissingDriverProfile(context);
        }
        final homepageMotoristasRecord = homepageMotoristasRecordList.first;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDriverHeader(
                            context,
                            driverName: homepageMotoristasRecord.nome,
                          ),
                          const SizedBox(height: 12.0),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              height: 100.0,
                              decoration: dtCardDecoration(context),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                    alignment:
                                        AlignmentDirectional(-0.03, -0.75),
                                    child: Text(
                                      dateTimeFormat(
                                          "Hm", getCurrentTimestamp),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 38.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        AlignmentDirectional(-0.04, -0.63),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text(
                                        dateTimeFormat(
                                            "MMMMEEEEd", getCurrentTimestamp),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: Color(0xFFD4AF37),
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: StreamBuilder<List<TurnosRecord>>(
                              stream: queryTurnosRecord(
                                queryBuilder: (turnosRecord) => turnosRecord
                                    .where(
                                      'email',
                                      isEqualTo: currentUserEmail,
                                    )
                                    .where(
                                      'data_dia',
                                      isEqualTo: dateTimeFormat(
                                        'yyyy-MM-dd',
                                        getCurrentTimestamp,
                                      ),
                                    ),
                              ),
                              builder: (context, todayTurnosSnap) {
                                final todayTurnos =
                                    todayTurnosSnap.data ?? <TurnosRecord>[];
                                return StreamBuilder<List<PausasRecord>>(
                                  stream: queryPausasRecord(
                                    queryBuilder: (pausasRecord) =>
                                        pausasRecord.where(
                                          'email',
                                          isEqualTo: currentUserEmail,
                                        ),
                                  ),
                                  builder: (context, pausasSnap) {
                                    final allPausas =
                                        pausasSnap.data ?? <PausasRecord>[];
                                    return StreamBuilder<List<TurnosRecord>>(
                                      stream: queryTurnosRecord(
                                        queryBuilder: (turnosRecord) =>
                                            turnosRecord
                                                .where(
                                                  'email',
                                                  isEqualTo: currentUserEmail,
                                                )
                                                .where(
                                                  'ativo',
                                                  isEqualTo: true,
                                                ),
                                        singleRecord: true,
                                      ),
                                      builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                List<TurnosRecord> containerTurnosRecordList =
                                    snapshot.data!;
                                final containerTurnosRecord =
                                    containerTurnosRecordList.isNotEmpty
                                        ? containerTurnosRecordList.first
                                        : null;

                                final todayStr = dateTimeFormat(
                                  'yyyy-MM-dd',
                                  getCurrentTimestamp,
                                );
                                final activePath =
                                    containerTurnosRecord?.reference.path;
                                final pausasList = allPausas.where((p) {
                                  if (p.dataDia == todayStr) {
                                    return true;
                                  }
                                  if (activePath != null &&
                                      p.turnoRef?.path == activePath) {
                                    return true;
                                  }
                                  return false;
                                }).toList();

                                _scheduleAutoStopIfNeeded(
                                  containerTurnosRecord,
                                );

                                return Container(
                                  width: double.infinity,
                                  decoration: dtCardDecoration(context),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12.0,
                                            10.0,
                                            12.0,
                                            10.0,
                                          ),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    tr('home.hoursToday'),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      fontSize: 18.0,
                                                      letterSpacing: 1.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    _formatTodayHours(
                                                      todayTurnos,
                                                      pausasList,
                                                      containerTurnosRecord,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      fontSize: 20.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (containerTurnosRecord ==
                                                    null)
                                                  StreamBuilder<
                                                      List<VeiculosRecord>>(
                                                    stream: queryVeiculosRecord(
                                                      queryBuilder: (q) => q
                                                          .where(
                                                            'email',
                                                            isEqualTo:
                                                                currentUserEmail,
                                                          )
                                                          .where(
                                                            'ativo',
                                                            isEqualTo: true,
                                                          ),
                                                      singleRecord: true,
                                                    ),
                                                    builder: (context,
                                                        veicSnap) {
                                                      final activeVeiculo =
                                                          veicSnap.hasData &&
                                                                  veicSnap
                                                                      .data!
                                                                      .isNotEmpty
                                                              ? veicSnap
                                                                  .data!.first
                                                              : null;
                                                      final hasVeiculo =
                                                          activeVeiculo !=
                                                              null;

                                                      if (!hasVeiculo) {
                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                              ),
                                                              child: Text(
                                                                tr('home.registerVehicleFirst'),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                  font: GoogleFonts
                                                                      .inter(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      10.0),
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  await context
                                                                      .pushNamed(
                                                                    DadosveiculosWidget
                                                                        .routeName,
                                                                  );
                                                                  _model.veiculodoc =
                                                                      await queryVeiculosRecordOnce(
                                                                    queryBuilder: (q) => q
                                                                        .where(
                                                                          'email',
                                                                          isEqualTo:
                                                                              currentUserEmail,
                                                                        )
                                                                        .where(
                                                                          'ativo',
                                                                          isEqualTo:
                                                                              true,
                                                                        ),
                                                                    singleRecord:
                                                                        true,
                                                                  ).then((s) =>
                                                                          s.firstOrNull);
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                text:
                                                                    tr('home.addVehicle'),
                                                                icon: Icon(
                                                                  Icons
                                                                      .directions_car_outlined,
                                                                  size: 20.0,
                                                                ),
                                                                options:
                                                                    FFButtonOptions(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 40.0,
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0,
                                                                  ),
                                                                  color: Color(
                                                                      0xFFD4AF37),
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                    font: GoogleFonts
                                                                        .interTight(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  elevation:
                                                                      0.0,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    8.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }

                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 4.0,
                                                            ),
                                                            child: Text(
                                                              tr('home.noActiveShift'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                font: GoogleFonts
                                                                    .inter(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                color: FlutterFlowTheme
                                                                        .of(context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                        padding:
                                                            EdgeInsets.all(
                                                                10.0),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            _model.motoristadoc =
                                                                await queryMotoristasRecordOnce(
                                                              queryBuilder: (motoristasRecord) =>
                                                                  motoristasRecord
                                                                      .where(
                                                                'email',
                                                                isEqualTo:
                                                                    currentUserEmail,
                                                              ),
                                                              singleRecord:
                                                                  true,
                                                            ).then((s) => s
                                                                    .firstOrNull);
                                                            _model.veiculodoc =
                                                                activeVeiculo;

                                                            final inicioTurno =
                                                                getCurrentTimestamp;
                                                            await TurnosRecord
                                                                .collection
                                                                .doc()
                                                                .set(
                                                                    createTurnosRecordData(
                                                                  email:
                                                                      currentUserEmail,
                                                                  estado:
                                                                      'ativo',
                                                                  inicioTurno:
                                                                      inicioTurno,
                                                                  ativo: true,
                                                                  data:
                                                                      inicioTurno,
                                                                  dataDia:
                                                                      dateTimeFormat(
                                                                    'yyyy-MM-dd',
                                                                    inicioTurno,
                                                                  ),
                                                                  nomeMotorista:
                                                                      _model
                                                                          .motoristadoc
                                                                          ?.nome,
                                                                  certificadoCmtvde: _model
                                                                      .motoristadoc
                                                                      ?.certeficadocmtvde,
                                                                  matricula:
                                                                      activeVeiculo
                                                                          .matricula,
                                                                  licencaOperador:
                                                                      activeVeiculo
                                                                          .licencaoperador,
                                                                ));

                                                            unawaited(
                                                              NotificationsService
                                                                  .instance
                                                                  .scheduleShiftAlerts(
                                                                inicioTurno:
                                                                    inicioTurno,
                                                              ),
                                                            );

                                                            safeSetState(
                                                                () {});
                                                          },
                                                          text:
                                                              tr('home.startShift'),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height: 40.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                              16.0,
                                                              0.0,
                                                              16.0,
                                                              0.0,
                                                            ),
                                                            iconAlignment:
                                                                IconAlignment
                                                                    .start,
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                              0.0,
                                                              0.0,
                                                              0.0,
                                                              0.0,
                                                            ),
                                                            color: Color(
                                                                0xFFD4AF37),
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                              font: GoogleFonts
                                                                  .interTight(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                            elevation: 0.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              8.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                if (containerTurnosRecord !=
                                                    null)
                                                  Builder(
                                                    builder: (context) {
                                                      final activePausas =
                                                          pausasList
                                                              .where(
                                                                (p) =>
                                                                    p.ativo &&
                                                                    p.turnoRef
                                                                            ?.path ==
                                                                        containerTurnosRecord
                                                                            .reference
                                                                            .path,
                                                              )
                                                              .toList();
                                                      final showRetomar =
                                                          _showRetomarLabel(
                                                        containerTurnosRecord,
                                                        activePausas,
                                                      );
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.all(
                                                                10.0),
                                                        child: FFButtonWidget(
                                                          key: ValueKey(
                                                            'pause-${containerTurnosRecord.reference.id}-$showRetomar',
                                                          ),
                                                          onPressed: () async {
                                                            await _onPauseResumePressed(
                                                              containerTurnosRecord,
                                                            );
                                                          },
                                                          text: showRetomar
                                                              ? tr('home.resume')
                                                              : tr('home.pause'),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height: 40.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                              16.0,
                                                              0.0,
                                                              16.0,
                                                              0.0,
                                                            ),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                              0.0,
                                                              0.0,
                                                              0.0,
                                                              0.0,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                              font: GoogleFonts
                                                                  .interTight(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: Color(
                                                                  0xFFD4AF37),
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                            elevation: 0.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              8.0,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (containerTurnosRecord !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        await _onStopPressed(
                                                          containerTurnosRecord,
                                                        );
                                                      },
                                                      text: tr('home.stop'),
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 40.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                          16.0,
                                                          0.0,
                                                          16.0,
                                                          0.0,
                                                        ),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                          0.0,
                                                          0.0,
                                                          0.0,
                                                          0.0,
                                                        ),
                                                        color:
                                                            Color(0xFFD4AF37),
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                          font: GoogleFonts
                                                              .interTight(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          color:
                                                              Color(0xFF7E1F25),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 96.0),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          height: 70.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD4AF37),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home,
                                    color: FlutterFlowTheme.of(context)
                                        .alternate,
                                    size: 30.0,
                                  ),
                                  Text(
                                    tr('nav.home'),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context
                                      .goNamed(HistoricopageWidget.routeName);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                    Text(
                                      tr('nav.history'),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context
                                      .goNamed(RelatoriospageWidget.routeName);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                    Text(
                                      tr('nav.reports'),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.goNamed(
                                        DefenioespageWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.settings_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 30.0,
                                      ),
                                      Text(
                                        tr('nav.settings'),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
      },
    );
  }
}
