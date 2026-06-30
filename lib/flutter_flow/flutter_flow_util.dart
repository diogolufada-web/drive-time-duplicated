import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:from_css_color/from_css_color.dart';
import 'dart:math' show pow, pi, sin;
import 'package:intl/intl.dart';
import 'package:json_path/json_path.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'flutter_flow_theme.dart';
import 'internationalization.dart';


export 'lat_lng.dart';
export 'place.dart';
export 'uploaded_file.dart';
export 'flutter_flow_model.dart';
export 'dart:math' show min, max;
export 'dart:typed_data' show Uint8List;
export 'dart:convert' show jsonEncode, jsonDecode;
export 'package:intl/intl.dart';
export 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseFirestore;
export 'package:page_transition/page_transition.dart';
export 'nav/nav.dart';
export 'internationalization.dart';

T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;

String dateTimeFormat(String format, DateTime? dateTime, {String? locale}) {
  if (dateTime == null) {
    return '';
  }
  final effectiveLocale = locale ?? FFLocalizations.languageCode;
  if (format == 'relative') {
    return timeago.format(dateTime, locale: effectiveLocale, allowFromNow: true);
  }
  return DateFormat(format, effectiveLocale).format(dateTime);
}

Future launchURL(String url) async {
  var uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (e) {
    throw 'Could not launch $uri: $e';
  }
}

Color colorFromCssString(String color, {Color? defaultColor}) {
  try {
    return fromCssColor(color);
  } catch (_) {}
  return defaultColor ?? Colors.black;
}

enum FormatType {
  decimal,
  percent,
  scientific,
  compact,
  compactLong,
  custom,
}

enum DecimalType {
  automatic,
  periodDecimal,
  commaDecimal,
}

String formatNumber(
  num? value, {
  required FormatType formatType,
  DecimalType? decimalType,
  String? currency,
  bool toLowerCase = false,
  String? format,
  String? locale,
}) {
  if (value == null) {
    return '';
  }
  var formattedValue = '';
  switch (formatType) {
    case FormatType.decimal:
      switch (decimalType!) {
        case DecimalType.automatic:
          formattedValue = NumberFormat.decimalPattern().format(value);
          break;
        case DecimalType.periodDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'en_US').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('en_US').format(value);
          }
          break;
        case DecimalType.commaDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'es_PA').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('es_PA').format(value);
          }
          break;
      }
      break;
    case FormatType.percent:
      formattedValue = NumberFormat.percentPattern().format(value);
      break;
    case FormatType.scientific:
      formattedValue = NumberFormat.scientificPattern().format(value);
      if (toLowerCase) {
        formattedValue = formattedValue.toLowerCase();
      }
      break;
    case FormatType.compact:
      formattedValue = NumberFormat.compact().format(value);
      break;
    case FormatType.compactLong:
      formattedValue = NumberFormat.compactLong().format(value);
      break;
    case FormatType.custom:
      final hasLocale = locale != null && locale.isNotEmpty;
      formattedValue =
          NumberFormat(format, hasLocale ? locale : null).format(value);
  }

  if (formattedValue.isEmpty) {
    return value.toString();
  }

  if (currency != null) {
    final currencySymbol = currency.isNotEmpty
        ? currency
        : NumberFormat.simpleCurrency().format(0.0).substring(0, 1);
    formattedValue = '$currencySymbol$formattedValue';
  }

  return formattedValue;
}

DateTime get getCurrentTimestamp => DateTime.now();
DateTime dateTimeFromSecondsSinceEpoch(int seconds) {
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

extension DateTimeConversionExtension on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}

extension DateTimeComparisonOperators on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

T? castToType<T>(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (T) {
    case double:
      // Doubles may be stored as ints in some cases.
      return value.toDouble() as T;
    case int:
      // Likewise, ints may be stored as doubles. If this is the case
      // (i.e. no decimal value), return the value as an int.
      if (value is num && value.toInt() == value) {
        return value.toInt() as T;
      }
      break;
    default:
      break;
  }
  return value as T;
}

dynamic getJsonField(
  dynamic response,
  String jsonPath, [
  bool isForList = false,
]) {
  final field = JsonPath(jsonPath).read(response);
  if (field.isEmpty) {
    return null;
  }
  if (field.length > 1) {
    return field.map((f) => f.value).toList();
  }
  final value = field.first.value;
  if (isForList) {
    return value is! Iterable
        ? [value]
        : (value is List ? value : value.toList());
  }
  return value;
}

Rect? getWidgetBoundingBox(BuildContext context) {
  try {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox!.localToGlobal(Offset.zero) & renderBox.size;
  } catch (_) {
    return null;
  }
}

bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isiOS => !kIsWeb && Platform.isIOS;
bool get isWeb => kIsWeb;

const kBreakpointSmall = 479.0;
const kBreakpointMedium = 767.0;
const kBreakpointLarge = 991.0;
bool isMobileWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kBreakpointSmall;
bool responsiveVisibility({
  required BuildContext context,
  bool phone = true,
  bool tablet = true,
  bool tabletLandscape = true,
  bool desktop = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kBreakpointSmall) {
    return phone;
  } else if (width < kBreakpointMedium) {
    return tablet;
  } else if (width < kBreakpointLarge) {
    return tabletLandscape;
  } else {
    return desktop;
  }
}

const kTextValidatorUsernameRegex = r'^[a-zA-Z][a-zA-Z0-9_-]{2,16}$';
// https://stackoverflow.com/a/201378
const kTextValidatorEmailRegex =
    "^(?:[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])\$";
const kTextValidatorWebsiteRegex =
    r'(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

extension FFTextEditingControllerExt on TextEditingController? {
  String get text => this == null ? '' : this!.text;
  set text(String newText) => this?.text = newText;
}

extension IterableExt<T> on Iterable<T> {
  List<T> sortedList<S extends Comparable>(
      {S Function(T)? keyOf, bool desc = false}) {
    final sortedAscending = toList()
      ..sort(keyOf == null ? null : ((a, b) => keyOf(a).compareTo(keyOf(b))));
    if (desc) {
      return sortedAscending.reversed.toList();
    }
    return sortedAscending;
  }

  List<S> mapIndexed<S>(S Function(int, T) func) => toList()
      .asMap()
      .map((index, value) => MapEntry(index, func(index, value)))
      .values
      .toList();
}

extension StringDocRef on String {
  DocumentReference get ref => FirebaseFirestore.instance.doc(this);
}

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    MyApp.of(context).setThemeMode(themeMode);

Future<void> setAppLanguage(BuildContext context, String languageCode) =>
    MyApp.of(context).setLocale(Locale(languageCode));

/// Caminho do logotipo COMPLETO (com tagline "TEMPO. FOCO. RESULTADOS.")
/// adequado ao tema actual. Usar apenas no Login / Register.
String driveTimeLogoAsset(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? 'assets/images/drive_time_logo_dark.png'
      : 'assets/images/drive_time_logo_light.png';
}

/// Versao SO texto "DRIVE TIME" (sem tagline), para cabecalhos de paginas
/// internas (Definicoes, Historico, Relatorios, Dados...).
String driveTimeTextLogoAsset(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? 'assets/images/drive_time_text_dark.png'
      : 'assets/images/drive_time_text_light.png';
}

/// Apenas o simbolo DT dourado (sem texto). Universal entre temas.
const String driveTimeMarkAsset = 'assets/images/drive_time_mark.png';

/// Logotipo completo (DRIVE TIME + tagline) para login, registo e splash.
Widget dtFullLogo(
  BuildContext context, {
  double maxWidth = 340.0,
  double maxHeight = 200.0,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: Image.asset(
        driveTimeLogoAsset(context),
        fit: BoxFit.contain,
      ),
    ),
  );
}

/// Corpo scrollavel para ecras de autenticacao (teclado nao tapa campos).
Widget dtAuthScrollBody({
  required BuildContext context,
  required List<Widget> children,
  bool centerContent = true,
  bool showFullLogo = true,
  double logoScale = 1.0,
}) {
  final logoMaxWidth = 340.0 * logoScale;
  final logoMaxHeight = 200.0 * logoScale;
  return LayoutBuilder(
    builder: (context, constraints) {
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0 + bottomInset),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: centerContent ? constraints.maxHeight - 24.0 : 0,
          ),
          child: Column(
            mainAxisAlignment: centerContent
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showFullLogo) ...[
                dtFullLogo(
                  context,
                  maxWidth: logoMaxWidth,
                  maxHeight: logoMaxHeight,
                ),
                SizedBox(height: 20.0 * logoScale),
              ],
              ...children,
            ],
          ),
        ),
      );
    },
  );
}

/// Logotipo completo no topo da Home (icone + DRIVE TIME + tagline).
/// Usa [driveTimeLogoAsset] — dark/light conforme o tema activo.
Widget dtHomeHeaderLogo(BuildContext context) => dtFullLogo(
      context,
      maxWidth: 260,
      maxHeight: 96,
    );

/// Logotipo "DRIVE TIME" so texto, com tamanho normalizado para todas as
/// paginas. Imagem tem aspect ratio ~10:1 (texto largo e baixo); por isso
/// limitamos largura maxima e usamos uma altura modesta.
Widget dtTextLogo(BuildContext context, {double height = 32.0, double maxWidth = 220.0}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Image.asset(
        driveTimeTextLogoAsset(context),
        height: height,
        fit: BoxFit.contain,
      ),
    ),
  );
}

/// InputDecoration partilhada para todos os formularios. Garante que os
/// campos tem:
/// - fundo a contrastar com o card-pai (primaryBackground -> mais claro/escuro
///   que o card branco/cinza)
/// - borda cinzenta sempre visivel e borda dourada quando o campo esta focado.
InputDecoration dtInputDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
}) {
  final theme = FlutterFlowTheme.of(context);
  return InputDecoration(
    isDense: true,
    labelText: labelText,
    labelStyle: theme.labelMedium.override(
      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
      color: kDtGold,
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: hintText,
    hintStyle: theme.labelMedium.override(
      font: GoogleFonts.inter(fontWeight: FontWeight.w400),
      color: theme.secondaryText,
      fontSize: 14.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme.alternate, width: 1.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: kDtGold, width: 1.8),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme.error, width: 1.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme.error, width: 1.8),
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: theme.primaryBackground,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
  );
}

// ---------------------------------------------------------------------------
// Design system Drive Time - tokens partilhados
// ---------------------------------------------------------------------------

/// Fundo escuro da marca (splash e ecrãs escuros).
const Color kDtBackground = Color(0xFF050505);

/// Tamanho do logotipo no splash Flutter (centrado).
const double kDtSplashLogoMaxWidth = 360.0;
const double kDtSplashLogoMaxHeight = 180.0;

/// Cor de acento principal (dourado).
const Color kDtGold = Color(0xFFD4AF37);

/// Cor de acento secundario (dourado escuro).
const Color kDtGoldDark = Color(0xFFB8860B);

/// Gradiente dourado claro -> escuro usado em cards e botoes destacados.
const LinearGradient kDtGoldGradient = LinearGradient(
  colors: [kDtGold, kDtGoldDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Container "card" partilhado entre todas as paginas. Borda dourada fina,
/// raio uniforme e leve sombra para destacar em ambos os temas.
BoxDecoration dtCardDecoration(BuildContext context, {double radius = 16.0}) {
  return BoxDecoration(
    color: FlutterFlowTheme.of(context).secondaryBackground,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: kDtGold, width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

/// Decoracao com fundo em gradiente dourado, util para cards de destaque
/// (ex.: "Total da semana").
BoxDecoration dtGoldCardDecoration({double radius = 16.0}) {
  return BoxDecoration(
    gradient: kDtGoldGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: Color(0x55000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

/// Titulo de seccao com gradiente que vai da cor do texto (preto no light,
/// branco no dark) ate ao dourado. Usado como cabecalho das paginas.
Widget dtSectionTitle(
  BuildContext context,
  String text, {
  double fontSize = 32.0,
  TextAlign textAlign = TextAlign.center,
}) {
  final theme = FlutterFlowTheme.of(context);
  return ShaderMask(
    shaderCallback: (rect) => LinearGradient(
      colors: [theme.primaryText, kDtGold],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect),
    blendMode: BlendMode.srcIn,
    child: Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'InterTight',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: Colors.white,
      ),
    ),
  );
}

void showSnackbar(
  BuildContext context,
  String message, {
  bool loading = false,
  int duration = 4,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (loading)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 10.0),
              child: Container(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Text(message),
        ],
      ),
      duration: Duration(seconds: duration),
    ),
  );
}

extension FFStringExt on String {
  String maybeHandleOverflow({int? maxChars, String replacement = ''}) =>
      maxChars != null && length > maxChars
          ? replaceRange(maxChars, null, replacement)
          : this;

  String toCapitalization(TextCapitalization textCapitalization) {
    switch (textCapitalization) {
      case TextCapitalization.none:
        return this;
      case TextCapitalization.words:
        return split(' ').map(toBeginningOfSentenceCase).join(' ');
      case TextCapitalization.sentences:
        return toBeginningOfSentenceCase(this);
      case TextCapitalization.characters:
        return toUpperCase();
    }
  }
}

extension ListFilterExt<T> on Iterable<T?> {
  List<T> get withoutNulls => where((s) => s != null).map((e) => e!).toList();
}

extension MapFilterExtensions<T> on Map<String, T?> {
  Map<String, T> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value as T)),
      );
}

extension MapListContainsExt on List<dynamic> {
  bool containsMap(dynamic map) => map is Map
      ? any((e) => e is Map && const DeepCollectionEquality().equals(e, map))
      : contains(map);
}

extension ListDivideExt<T extends Widget> on Iterable<T> {
  Iterable<MapEntry<int, Widget>> get enumerate => toList().asMap().entries;

  List<Widget> divide(Widget t, {bool Function(int)? filterFn}) => isEmpty
      ? []
      : (enumerate
          .map((e) => [e.value, if (filterFn == null || filterFn(e.key)) t])
          .expand((i) => i)
          .toList()
        ..removeLast());

  List<Widget> around(Widget t) => addToStart(t).addToEnd(t);

  List<Widget> addToStart(Widget t) =>
      enumerate.map((e) => e.value).toList()..insert(0, t);

  List<Widget> addToEnd(Widget t) =>
      enumerate.map((e) => e.value).toList()..add(t);

  List<Padding> paddingTopEach(double val) =>
      map((w) => Padding(padding: EdgeInsets.only(top: val), child: w))
          .toList();
}

extension StatefulWidgetExtensions on State<StatefulWidget> {
  /// Check if the widget exist before safely setting state.
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}

// For iOS 16 and below, set the status bar color to match the app's theme.
// https://github.com/flutter/flutter/issues/41067
Brightness? _lastBrightness;
void fixStatusBarOniOS16AndBelow(BuildContext context) {
  if (!isiOS) {
    return;
  }
  final brightness = Theme.of(context).brightness;
  if (_lastBrightness != brightness) {
    _lastBrightness = brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        systemStatusBarContrastEnforced: true,
      ),
    );
  }
}

extension ColorOpacityExt on Color {
  Color applyAlpha(double val) => withValues(alpha: val);
}

String roundTo(double value, int decimalPoints) {
  final power = pow(10, decimalPoints);
  return ((value * power).round() / power).toString();
}

double computeGradientAlignmentX(double evaluatedAngle) {
  evaluatedAngle %= 360;
  final rads = evaluatedAngle * pi / 180;
  double x;
  if (evaluatedAngle < 45 || evaluatedAngle > 315) {
    x = sin(2 * rads);
  } else if (45 <= evaluatedAngle && evaluatedAngle <= 135) {
    x = 1;
  } else if (135 <= evaluatedAngle && evaluatedAngle <= 225) {
    x = sin(-2 * rads);
  } else {
    x = -1;
  }
  return double.parse(roundTo(x, 2));
}

double computeGradientAlignmentY(double evaluatedAngle) {
  evaluatedAngle %= 360;
  final rads = evaluatedAngle * pi / 180;
  double y;
  if (evaluatedAngle < 45 || evaluatedAngle > 315) {
    y = -1;
  } else if (45 <= evaluatedAngle && evaluatedAngle <= 135) {
    y = sin(-2 * rads);
  } else if (135 <= evaluatedAngle && evaluatedAngle <= 225) {
    y = 1;
  } else {
    y = sin(2 * rads);
  }
  return double.parse(roundTo(y, 2));
}

extension ListUniqueExt<T> on Iterable<T> {
  List<T> unique(dynamic Function(T) getKey) {
    var distinctSet = <dynamic>{};
    var distinctList = <T>[];
    for (var item in this) {
      if (distinctSet.add(getKey(item))) {
        distinctList.add(item);
      }
    }
    return distinctList;
  }
}

String getCurrentRoute(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRoute() : '';
List<String> getCurrentRouteStack(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRouteStack() : [];
