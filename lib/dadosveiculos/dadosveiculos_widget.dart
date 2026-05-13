import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'dadosveiculos_model.dart';
export 'dadosveiculos_model.dart';

class DadosveiculosWidget extends StatefulWidget {
  const DadosveiculosWidget({super.key});

  static String routeName = 'dadosveiculos';
  static String routePath = '/dadosveiculos';

  @override
  State<DadosveiculosWidget> createState() => _DadosveiculosWidgetState();
}

class _DadosveiculosWidgetState extends State<DadosveiculosWidget> {
  late DadosveiculosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Path of the `veiculos` document whose fields were seeded into the
  /// text controllers. Seeding runs at most once per path so later stream
  /// rebuilds do not overwrite user edits.
  String? _vehicleControllersSeededForPath;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DadosveiculosModel());

    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textFieldFocusNode5 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VeiculosRecord>>(
      stream: queryVeiculosRecord(
        queryBuilder: (veiculosRecord) => veiculosRecord
            .where('email', isEqualTo: currentUserEmail)
            .where('ativo', isEqualTo: true),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
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
        List<VeiculosRecord> dadosveiculosVeiculosRecordList = snapshot.data!;
        final VeiculosRecord? vehicleRecord =
            dadosveiculosVeiculosRecordList.isNotEmpty
            ? dadosveiculosVeiculosRecordList.first
            : null;

        if (vehicleRecord != null) {
          final docPath = vehicleRecord.reference.path;
          if (_vehicleControllersSeededForPath != docPath) {
            _model.textController1 ??= TextEditingController();
            _model.textController2 ??= TextEditingController();
            _model.textController3 ??= TextEditingController();
            _model.textController4 ??= TextEditingController();
            _model.textController5 ??= TextEditingController();
            _model.textController1!.text = vehicleRecord.matricula;
            _model.textController2!.text = vehicleRecord.marca;
            _model.textController3!.text = vehicleRecord.ano;
            _model.textController4!.text = vehicleRecord.cor;
            _model.textController5!.text = vehicleRecord.licencaoperador;
            _vehicleControllersSeededForPath = docPath;
          }
        } else {
          _vehicleControllersSeededForPath = null;
          _model.textController1 ??= TextEditingController();
          _model.textController2 ??= TextEditingController();
          _model.textController3 ??= TextEditingController();
          _model.textController4 ??= TextEditingController();
          _model.textController5 ??= TextEditingController();
        }

        return _buildVehicleForm(context, vehicleRecord);
      },
    );
  }

  Widget _buildVehicleForm(
    BuildContext context,
    VeiculosRecord? vehicleRecord,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.all(22.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/ChatGPT_Image_24_04_2026,_12_09_37.png',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  GradientText(
                    'Dados do Veiculo',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).success,
                      fontSize: 30.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodyMedium.fontStyle,
                    ),
                    colors: [
                      FlutterFlowTheme.of(context).primaryBackground,
                      Color(0xFFC9A227),
                    ],
                    gradientDirection: GradientDirection.ltr,
                    gradientType: GradientType.linear,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          [
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    key: ValueKey('nome'),
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Matricula',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontStyle,
                                            ),
                                            color: Color(0xFFC9A227),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                      alignLabelWithHint: false,
                                      hintText: 'Introduz a Matricula',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w100,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w100,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    keyboardType: TextInputType.name,
                                    cursorColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textController1Validator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    key: ValueKey('email'),
                                    controller: _model.textController2,
                                    focusNode: _model.textFieldFocusNode2,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Marca',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            color: Color(0xFFC9A227),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                      hintText: 'intruduzir Marca do veiculo',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w100,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w100,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textController2Validator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    key: ValueKey('telefone'),
                                    controller: _model.textController3,
                                    focusNode: _model.textFieldFocusNode3,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Ano',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            color: Color(0xFFC9A227),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                      hintText: '2025',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w100,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w100,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textController3Validator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    key: ValueKey('certificado'),
                                    controller: _model.textController4,
                                    focusNode: _model.textFieldFocusNode4,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Cor',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            color: Color(0xFFC9A227),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                      hintText: 'Número do certificado',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w100,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w100,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textController4Validator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    key: ValueKey('nif'),
                                    controller: _model.textController5,
                                    focusNode: _model.textFieldFocusNode5,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Licença do Operador',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            color: Color(0xFFC9A227),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                      hintText: 'Adicionar licença do Operador',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w100,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w100,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textController5Validator
                                        .asValidator(context),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      if (vehicleRecord != null) {
                                        await vehicleRecord.reference.update(
                                          createVeiculosRecordData(
                                            matricula:
                                                _model.textController1.text,
                                            marca: _model.textController2.text,
                                            ano: _model.textController3.text,
                                            cor: _model.textController4.text,
                                            licencaoperador:
                                                _model.textController5.text,
                                            email: currentUserEmail,
                                            ativo: true,
                                          ),
                                        );
                                      } else {
                                        await VeiculosRecord.collection
                                            .doc()
                                            .set(
                                              createVeiculosRecordData(
                                                matricula:
                                                    _model.textController1.text,
                                                marca:
                                                    _model.textController2.text,
                                                ano:
                                                    _model.textController3.text,
                                                cor:
                                                    _model.textController4.text,
                                                licencaoperador:
                                                    _model.textController5.text,
                                                email: currentUserEmail,
                                                ativo: true,
                                                createdTime:
                                                    getCurrentTimestamp,
                                              ),
                                            );
                                      }
                                    },
                                    text: 'Guardar',
                                    options: FFButtonOptions(
                                      width: 153.0,
                                      height: 45.54,
                                      padding: EdgeInsets.all(12.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                          ),
                                      color: Color(0xFFC9A227),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryBackground,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      context.pushNamed(
                                        HomepageWidget.routeName,
                                      );
                                    },
                                    text: 'Menu principal',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 50.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0,
                                        0.0,
                                        16.0,
                                        0.0,
                                      ),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                          ),
                                      color: Color(0xFFC9A227),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).titleSmall.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).titleSmall.fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).titleSmall.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).titleSmall.fontStyle,
                                            shadows: [
                                              Shadow(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ]
                              .divide(SizedBox(height: 12.0))
                              .around(SizedBox(height: 12.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
