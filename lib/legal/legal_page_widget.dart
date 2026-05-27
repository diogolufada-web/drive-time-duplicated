import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalPageWidget extends StatelessWidget {
  const LegalPageWidget({
    super.key,
    required this.titleKey,
    required this.bodyKey,
  });

  final String titleKey;
  final String bodyKey;

  static const String privacyRouteName = 'privacyPolicy';
  static const String privacyRoutePath = '/privacy-policy';
  static const String termsRouteName = 'termsOfUse';
  static const String termsRoutePath = '/terms-of-use';

  static LegalPageWidget privacy() => const LegalPageWidget(
        titleKey: 'legal.privacy.title',
        bodyKey: 'legal.privacy.body',
      );

  static LegalPageWidget terms() => const LegalPageWidget(
        titleKey: 'legal.terms.title',
        bodyKey: 'legal.terms.body',
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryText),
        title: Text(
          tr(titleKey),
          style: theme.titleMedium.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: dtCardDecoration(context),
            child: Text(
              tr(bodyKey),
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                color: theme.primaryText,
                fontSize: 14,
              ).copyWith(height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
