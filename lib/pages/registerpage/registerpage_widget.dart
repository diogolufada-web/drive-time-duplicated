import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registerpage_model.dart';
export 'registerpage_model.dart';

class RegisterpageWidget extends StatefulWidget {
  const RegisterpageWidget({super.key});

  static String routeName = 'Registerpage';
  static String routePath = '/registerpage';

  @override
  State<RegisterpageWidget> createState() => _RegisterpageWidgetState();
}

class _RegisterpageWidgetState extends State<RegisterpageWidget> {
  late RegisterpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegisterpageModel());

    _model.emailTextController ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.confirmPasswordTextController ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _registerField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required String? Function(BuildContext, String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    String? fieldKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: 280,
        child: TextFormField(
          key: fieldKey != null ? ValueKey(fieldKey) : null,
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: dtInputDecoration(
            context,
            labelText: labelText,
            hintText: hintText,
          ).copyWith(suffixIcon: suffixIcon),
          validator: validator?.asValidator(context),
        ),
      ),
    );
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: dtAuthScrollBody(
            context: context,
            centerContent: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    context.pushNamed(LoginpageWidget.routeName);
                  },
                  text: tr('register.backToLogin'),
                  options: FFButtonOptions(
                    width: 280,
                    height: 40.0,
                    color: kDtGold,
                    textStyle: theme.titleSmall.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Form(
                key: _model.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _registerField(
                      fieldKey: 'email',
                      controller: _model.emailTextController!,
                      focusNode: _model.textFieldFocusNode1!,
                      labelText: tr('auth.email'),
                      hintText: tr('auth.emailHint'),
                      validator: _model.emailTextControllerValidator,
                    ),
                    _registerField(
                      fieldKey: 'password',
                      controller: _model.passwordTextController!,
                      focusNode: _model.textFieldFocusNode2!,
                      labelText: tr('auth.password'),
                      hintText: tr('auth.passwordHint'),
                      obscureText: !_model.passwordVisibility1,
                      validator: _model.passwordTextControllerValidator,
                      suffixIcon: InkWell(
                        onTap: () => safeSetState(
                          () => _model.passwordVisibility1 =
                              !_model.passwordVisibility1,
                        ),
                        focusNode: FocusNode(skipTraversal: true),
                        child: Icon(
                          _model.passwordVisibility1
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 22,
                        ),
                      ),
                    ),
                    _registerField(
                      controller: _model.confirmPasswordTextController!,
                      focusNode: _model.textFieldFocusNode3!,
                      labelText: tr('register.confirmPassword'),
                      hintText: tr('register.confirmPasswordHint'),
                      obscureText: !_model.passwordVisibility2,
                      validator: _model.confirmPasswordTextControllerValidator,
                      suffixIcon: InkWell(
                        onTap: () => safeSetState(
                          () => _model.passwordVisibility2 =
                              !_model.passwordVisibility2,
                        ),
                        focusNode: FocusNode(skipTraversal: true),
                        child: Icon(
                          _model.passwordVisibility2
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 22,
                        ),
                      ),
                    ),
                    _registerField(
                      fieldKey: 'nome',
                      controller: _model.textController2!,
                      focusNode: _model.textFieldFocusNode4!,
                      labelText: tr('register.fullName'),
                      hintText: tr('register.fullNameHint'),
                      validator: _model.textController2Validator,
                    ),
                    _registerField(
                      fieldKey: 'nif',
                      controller: _model.textController3!,
                      focusNode: _model.textFieldFocusNode5!,
                      labelText: tr('form.nif'),
                      hintText: tr('form.nifHint'),
                      validator: _model.textController3Validator,
                    ),
                    _registerField(
                      fieldKey: 'telefone',
                      controller: _model.textController4!,
                      focusNode: _model.textFieldFocusNode6!,
                      labelText: 'Télemovel',
                      hintText: 'Número de telemóvel',
                      validator: _model.textController4Validator,
                    ),
                    _registerField(
                      fieldKey: 'certificadocmtvde',
                      controller: _model.textController5!,
                      focusNode: _model.textFieldFocusNode7!,
                      labelText: tr('register.cmtvde'),
                      hintText: tr('register.cmtvdeHint'),
                      validator: _model.textController5Validator,
                    ),
                    const SizedBox(height: 8),
                    FFButtonWidget(
                      onPressed: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        if (_model.formKey.currentState == null ||
                            !_model.formKey.currentState!.validate()) {
                          return;
                        }
                        if (_model.passwordTextController.text !=
                            _model.confirmPasswordTextController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('validation.passwordMatch')),
                            ),
                          );
                          return;
                        }

                        final user = await authManager.createAccountWithEmail(
                          context,
                          _model.emailTextController.text,
                          _model.passwordTextController.text,
                        );
                        if (user == null) {
                          return;
                        }

                        final driverEmail = currentUserEmail.isNotEmpty
                            ? currentUserEmail
                            : _model.emailTextController.text.trim();
                        await MotoristasRecord.collection.doc().set(
                              createMotoristasRecordData(
                                nome: _model.textController2.text.trim(),
                                email: driverEmail,
                                telefone: _model.textController4.text.trim(),
                                certeficadocmtvde:
                                    _model.textController5.text.trim(),
                                createdTime: getCurrentTimestamp,
                                nif: _model.textController3.text.trim(),
                              ),
                            );

                        context.goNamedAuth(
                          DadosveiculosWidget.routeName,
                          context.mounted,
                        );
                      },
                      text: tr('register.createAccount'),
                      options: FFButtonOptions(
                        width: 280,
                        height: 48,
                        color: kDtGold,
                        textStyle: theme.titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
