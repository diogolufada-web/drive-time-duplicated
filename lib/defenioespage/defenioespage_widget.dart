import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'defenioespage_model.dart';
export 'defenioespage_model.dart';

class DefenioespageWidget extends StatefulWidget {
  const DefenioespageWidget({super.key});

  static String routeName = 'defenioespage';
  static String routePath = '/defenioespage';

  @override
  State<DefenioespageWidget> createState() => _DefenioespageWidgetState();
}

class _DefenioespageWidgetState extends State<DefenioespageWidget> {
  late DefenioespageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _accent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DefenioespageModel());
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(theme),
                      const SizedBox(height: 20),
                      _sectionLabel(theme, tr('settings.theme')),
                      const SizedBox(height: 8),
                      _themeButtons(theme),
                      const SizedBox(height: 20),
                      _sectionLabel(theme, tr('settings.language')),
                      const SizedBox(height: 8),
                      _languageDropdown(theme),
                      const SizedBox(height: 24),
                      _sectionLabel(theme, tr('settings.account')),
                      const SizedBox(height: 8),
                      _navCard(
                        theme: theme,
                        icon: Icons.person,
                        label: tr('settings.driverData'),
                        onTap: () => context.pushNamed(
                          DadosmotoristaWidget.routeName,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _navCard(
                        theme: theme,
                        icon: Icons.directions_car_filled_outlined,
                        label: tr('settings.vehicleData'),
                        onTap: () => context.pushNamed(
                          DadosveiculosWidget.routeName,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FFButtonWidget(
                        onPressed: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.signOut();
                          GoRouter.of(context).clearRedirectLocation();
                          context.pushNamedAuth(
                            LoginpageWidget.routeName,
                            context.mounted,
                          );
                        },
                        text: 'LOGOUT',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 46,
                          color: _accent,
                          textStyle: theme.titleSmall.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.bold,
                            ),
                            color: Colors.white,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Column(
      children: [
        dtTextLogo(context),
        const SizedBox(height: 12),
        dtSectionTitle(context, tr('nav.settings'), fontSize: 32),
      ],
    );
  }

  Widget _sectionLabel(FlutterFlowTheme theme, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        label,
        style: theme.bodyMedium.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          color: theme.secondaryText,
          fontSize: 13,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _themeButtons(FlutterFlowTheme theme) {
    final isLight = FlutterFlowTheme.themeMode == ThemeMode.light;
    return Row(
      children: [
        Expanded(
          child: _themeChoice(
            theme,
            label: tr('settings.light'),
            icon: Icons.light_mode,
            selected: isLight,
            onTap: () {
              setDarkModeSetting(context, ThemeMode.light);
              safeSetState(() {});
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _themeChoice(
            theme,
            label: tr('settings.dark'),
            icon: Icons.dark_mode,
            selected: !isLight,
            onTap: () {
              setDarkModeSetting(context, ThemeMode.dark);
              safeSetState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _themeChoice(
    FlutterFlowTheme theme, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accent : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : _accent,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.titleSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                color: selected ? Colors.white : theme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageDropdown(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: FFLocalizations.languageCode,
          icon: const Icon(Icons.language, color: _accent),
          dropdownColor: theme.secondaryBackground,
          style: theme.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
            color: theme.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem(value: 'pt', child: Text(tr('lang.pt'))),
            DropdownMenuItem(value: 'en', child: Text(tr('lang.en'))),
          ],
          onChanged: (value) async {
            if (value == null) return;
            await setAppLanguage(context, value);
            safeSetState(() {});
          },
        ),
      ),
    );
  }

  Widget _navCard({
    required FlutterFlowTheme theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: dtCardDecoration(context),
        child: Row(
          children: [
            Icon(icon, color: _accent, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: theme.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _accent),
          ],
        ),
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
            onTap: () => context.goNamed(RelatoriospageWidget.routeName),
          ),
          _navItem(
            theme: theme,
            icon: Icons.settings_outlined,
            label: tr('nav.settings'),
            selected: true,
            onTap: () {},
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
