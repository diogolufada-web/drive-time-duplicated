import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loginpage_model.dart';
export 'loginpage_model.dart';

class LoginpageWidget extends StatefulWidget {
  const LoginpageWidget({super.key});

  static String routeName = 'Loginpage';
  static String routePath = '/loginpage';

  @override
  State<LoginpageWidget> createState() => _LoginpageWidgetState();
}

class _LoginpageWidgetState extends State<LoginpageWidget> {
  late LoginpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginpageModel());

    _model.emailTextController ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _onForgotPassword() async {
    final email = _model.emailTextController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('auth.enterEmailForReset'))),
      );
      return;
    }
    try {
      await authManager.resetPassword(email: email, context: context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('auth.resetPasswordSent'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('auth.resetPasswordError'))),
      );
    }
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
              Form(
                key: _model.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _model.emailTextController,
                        focusNode: _model.textFieldFocusNode1,
                        decoration: dtInputDecoration(
                          context,
                          labelText: tr('auth.email'),
                          hintText: tr('auth.emailHint'),
                        ),
                        validator: _model.emailTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _model.passwordTextController,
                        focusNode: _model.textFieldFocusNode2,
                        obscureText: !_model.passwordVisibility,
                        decoration: dtInputDecoration(
                          context,
                          labelText: tr('auth.password'),
                          hintText: tr('auth.passwordHint'),
                        ).copyWith(
                          suffixIcon: InkWell(
                            onTap: () => safeSetState(
                              () => _model.passwordVisibility =
                                  !_model.passwordVisibility,
                            ),
                            child: Icon(
                              _model.passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 22,
                            ),
                          ),
                        ),
                        validator: _model.passwordTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        if (_model.formKey.currentState == null ||
                            !_model.formKey.currentState!.validate()) {
                          return;
                        }

                        final user = await authManager.signInWithEmail(
                          context,
                          _model.emailTextController.text,
                          _model.passwordTextController.text,
                        );
                        if (user == null) {
                          return;
                        }

                        context.goNamedAuth(
                          HomepageWidget.routeName,
                          context.mounted,
                        );
                      },
                      text: tr('auth.signIn'),
                      options: FFButtonOptions(
                        width: 280,
                        height: 48,
                        color: kDtGold,
                        textStyle: theme.titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: theme.primaryBackground,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _onForgotPassword,
                child: Text(
                  tr('auth.forgotPassword'),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    color: kDtGold,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FFButtonWidget(
                onPressed: () =>
                    context.pushNamed(RegisterpageWidget.routeName),
                text: tr('login.createAccount'),
                options: FFButtonOptions(
                  width: 280,
                  height: 48,
                  color: kDtGold,
                  textStyle: theme.titleSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: theme.primaryBackground,
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
    );
  }
}
