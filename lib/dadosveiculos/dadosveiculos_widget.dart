import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _saving = false;

  static const Color _gold = Color(0xFFD4AF37);

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

  Future<void> _save(VeiculosRecord? existing) async {
    if (_saving) return;
    _saving = true;
    try {
      final data = createVeiculosRecordData(
        matricula: _model.textController1?.text.trim(),
        marca: _model.textController2?.text.trim(),
        ano: _model.textController3?.text.trim(),
        cor: _model.textController4?.text.trim(),
        licencaoperador: _model.textController5?.text.trim(),
        email: currentUserEmail,
        ativo: true,
      );
      if (existing != null) {
        await existing.reference.update(data);
      } else {
        await VeiculosRecord.collection.doc().set({
          ...data,
          'created_time': getCurrentTimestamp,
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('form.saved'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('form.saveError'))),
      );
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VeiculosRecord>>(
      stream: queryVeiculosRecord(
        queryBuilder: (q) => q
            .where('email', isEqualTo: currentUserEmail)
            .where('ativo', isEqualTo: true),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        final theme = FlutterFlowTheme.of(context);
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
            ),
          );
        }
        final existing =
            snapshot.data!.isNotEmpty ? snapshot.data!.first : null;

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
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      dtTextLogo(context),
                      const SizedBox(height: 12),
                      dtSectionTitle(
                        context,
                        tr('form.vehicleTitle'),
                        fontSize: 32,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: dtCardDecoration(context),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _field(
                              theme,
                              key: 'matricula',
                              controller: _model.textController1 ??=
                                  TextEditingController(
                                      text: existing?.matricula),
                              focusNode: _model.textFieldFocusNode1,
                              label: tr('form.plate'),
                              hint: tr('form.plateHint'),
                              keyboard: TextInputType.text,
                              validator: _model.textController1Validator
                                  .asValidator(context),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              theme,
                              key: 'marca',
                              controller: _model.textController2 ??=
                                  TextEditingController(text: existing?.marca),
                              focusNode: _model.textFieldFocusNode2,
                              label: tr('form.brand'),
                              hint: tr('form.brandHint'),
                              keyboard: TextInputType.text,
                              validator: _model.textController2Validator
                                  .asValidator(context),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              theme,
                              key: 'ano',
                              controller: _model.textController3 ??=
                                  TextEditingController(text: existing?.ano),
                              focusNode: _model.textFieldFocusNode3,
                              label: tr('form.year'),
                              hint: tr('form.yearHint'),
                              keyboard: TextInputType.number,
                              validator: _model.textController3Validator
                                  .asValidator(context),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              theme,
                              key: 'cor',
                              controller: _model.textController4 ??=
                                  TextEditingController(text: existing?.cor),
                              focusNode: _model.textFieldFocusNode4,
                              label: tr('form.color'),
                              hint: tr('form.colorHint'),
                              keyboard: TextInputType.text,
                              validator: _model.textController4Validator
                                  .asValidator(context),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              theme,
                              key: 'licenca',
                              controller: _model.textController5 ??=
                                  TextEditingController(
                                      text: existing?.licencaoperador),
                              focusNode: _model.textFieldFocusNode5,
                              label: tr('form.operatorLicense'),
                              hint: tr('form.operatorLicenseHint'),
                              keyboard: TextInputType.text,
                              validator: _model.textController5Validator
                                  .asValidator(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: () => _save(existing),
                        text: tr('form.save'),
                        options: FFButtonOptions(
                          width: 180,
                          height: 46,
                          color: _gold,
                          textStyle: theme.bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: theme.primaryBackground,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FFButtonWidget(
                        onPressed: () =>
                            context.pushNamed(HomepageWidget.routeName),
                        text: tr('form.mainMenu'),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: _gold,
                          textStyle: theme.titleSmall.override(
                            font: GoogleFonts.interTight(),
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    FlutterFlowTheme theme, {
    required String key,
    required TextEditingController controller,
    required FocusNode? focusNode,
    required String label,
    required String hint,
    required TextInputType keyboard,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: ValueKey(key),
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: theme.bodyMedium.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
          color: _gold,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: theme.labelMedium.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.w300),
          fontWeight: FontWeight.w300,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _gold, width: 1.8),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 1.8),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: theme.primaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: theme.bodyMedium.override(
        font: GoogleFonts.inter(),
        color: theme.primaryText,
      ),
      keyboardType: keyboard,
      cursorColor: theme.primaryText,
      validator: validator,
    );
  }
}
