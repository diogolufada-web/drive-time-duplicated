import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
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
      _showShiftSnack(tr('home.shiftUpdateError'));
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
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
      _showShiftSnack(tr('home.pauseResumeError'));
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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 0.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 8.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              driveTimeMarkAsset,
              width: 56.0,
              height: 56.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: theme.titleSmall.override(
                        font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600),
                        color: theme.primaryText,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(text: 'Bem-vindo, '),
                        TextSpan(
                          text: hasName ? driverName : '—',
                          style: TextStyle(
                            color: const Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    matricula.isNotEmpty ? matricula : '__-__-__',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: const Color(0xFFD4AF37),
                      fontSize: 13.0,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onStopPressed(TurnosRecord turno) async {
    if (_shiftBusy) {
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
      _showShiftSnack(tr('home.stopError'));
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
        // Return an empty Container when the item does not exist.
        if (snapshot.data!.isEmpty) {
          return Container();
        }
        final homepageMotoristasRecord = homepageMotoristasRecordList.isNotEmpty
            ? homepageMotoristasRecordList.first
            : null;

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
                  Stack(
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Stack(
                          children: [
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            shadows: [
                                              Shadow(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              )
                                            ],
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
                                        context.goNamed(
                                            HistoricopageWidget.routeName);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                              shadows: [
                                                Shadow(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  offset: Offset(2.0, 2.0),
                                                  blurRadius: 2.0,
                                                )
                                              ],
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
                                        context.goNamed(
                                            RelatoriospageWidget.routeName);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                              shadows: [
                                                Shadow(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  offset: Offset(2.0, 2.0),
                                                  blurRadius: 2.0,
                                                )
                                              ],
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.settings_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 30.0,
                                            ),
                                            Text(
                                              tr('nav.settings'),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                                shadows: [
                                                  Shadow(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 2.0,
                                                  )
                                                ],
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
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: StreamBuilder<List<TurnosRecord>>(
                                  stream: queryTurnosRecord(
                                    queryBuilder: (turnosRecord) => turnosRecord
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
                                    List<TurnosRecord>
                                        containerTurnosRecordList =
                                        snapshot.data!;
                                    final containerTurnosRecord =
                                        containerTurnosRecordList.isNotEmpty
                                            ? containerTurnosRecordList.first
                                            : null;

                                    return Material(
                                      color: Colors.transparent,
                                      elevation: 16.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 291.8,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 2.0,
                                              color: Color(0xFFD4AF37),
                                              offset: Offset(
                                                2.0,
                                                2.0,
                                              ),
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  valueOrDefault<String>(
                                                    _model
                                                        .veiculodoc?.matricula,
                                                    '__-__-__',
                                                  ),
                                                  textAlign: TextAlign.center,
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
                                                    color: Color(0xFFD4AF37),
                                                    fontSize: 18.0,
                                                    letterSpacing: 1.2,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    shadows: [
                                                      Shadow(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        offset:
                                                            Offset(2.0, 2.0),
                                                        blurRadius: 2.0,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'Horas Trabalhadas Hoje',
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
                                                      shadows: [
                                                        Shadow(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          offset:
                                                              Offset(2.0, 2.0),
                                                          blurRadius: 2.0,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Container(
                                                    width: 239.4,
                                                    height: 44.59,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: StreamBuilder<
                                                        List<TurnosRecord>>(
                                                      stream: queryTurnosRecord(
                                                        queryBuilder:
                                                            (turnosRecord) =>
                                                                turnosRecord
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
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child: SizedBox(
                                                              width: 50.0,
                                                              height: 50.0,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        List<TurnosRecord>
                                                            containerTurnosRecordList =
                                                            snapshot.data!;

                                                        return Container(
                                                          width: 284.5,
                                                          height: 67.8,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: StreamBuilder<
                                                                List<
                                                                    PausasRecord>>(
                                                              stream:
                                                                  queryPausasRecord(
                                                                queryBuilder:
                                                                    (pausasRecord) =>
                                                                        pausasRecord
                                                                            .where(
                                                                              'email',
                                                                              isEqualTo: currentUserEmail,
                                                                            )
                                                                            .where(
                                                                              'ativo',
                                                                              isEqualTo: true,
                                                                            ),
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                List<PausasRecord>
                                                                    textPausasRecordList =
                                                                    snapshot
                                                                        .data!;

                                                                return Text(
                                                                  functions.calculahorashoje(
                                                                      containerTurnosRecordList
                                                                          .toList(),
                                                                      textPausasRecordList
                                                                          .toList()),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            20.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
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

                                                      return Padding(
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
                                                              shadows: [
                                                                Shadow(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  offset: Offset(
                                                                    2.0,
                                                                    2.0,
                                                                  ),
                                                                  blurRadius:
                                                                      2.0,
                                                                )
                                                              ],
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
                                                  StreamBuilder<
                                                      List<PausasRecord>>(
                                                    stream: queryPausasRecord(
                                                      queryBuilder: (q) => q
                                                          .where(
                                                            'email',
                                                            isEqualTo:
                                                                currentUserEmail,
                                                          )
                                                          .where(
                                                            'turno_ref',
                                                            isEqualTo:
                                                                containerTurnosRecord
                                                                    .reference,
                                                          )
                                                          .where(
                                                            'ativo',
                                                            isEqualTo: true,
                                                          ),
                                                    ),
                                                    builder: (context,
                                                        pausaSnap) {
                                                      final activePausas =
                                                          pausaSnap.data ?? [];
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
                                                              shadows: [
                                                                Shadow(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  offset: Offset(
                                                                    2.0,
                                                                    2.0,
                                                                  ),
                                                                  blurRadius:
                                                                      2.0,
                                                                )
                                                              ],
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
                                                                    0.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
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
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFF7E1F25),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                          shadows: [
                                                            Shadow(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
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
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, -0.97),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 8.0, 16.0, 8.0),
                                child: _buildDriverHeader(
                                  context,
                                  driverName:
                                      homepageMotoristasRecord!.nome,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, -0.66),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 16.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2.0,
                                          color: Color(0xFFD4AF37),
                                          offset: Offset(
                                            2.0,
                                            2.0,
                                          ),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Align(
                                          alignment: AlignmentDirectional(
                                              -0.03, -0.75),
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
                                              shadows: [
                                                Shadow(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  offset: Offset(2.0, 2.0),
                                                  blurRadius: 2.0,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(
                                              -0.04, -0.63),
                                          child: Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Text(
                                              dateTimeFormat("MMMMEEEEd",
                                                  getCurrentTimestamp),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                shadows: [
                                                  Shadow(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
