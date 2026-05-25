import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '/flutter_flow/internationalization.dart';

/// Serviço de notificações locais para alertas de turno.
///
/// Fluxo:
/// - Ao iniciar turno -> [scheduleShiftAlerts] agenda:
///   - Aviso de 9h de trabalho (descontando pausas via reagendamento)
///   - Lembrete de fim-de-dia (23:00 do dia do turno) se ainda não passou
/// - Ao pausar -> [pauseShiftAlerts] cancela e guarda o instante de pausa
/// - Ao retomar -> [resumeShiftAlerts] reagenda somando a duração da pausa
/// - Ao terminar -> [cancelShiftAlerts] limpa tudo
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  static const String _channelId = 'drive_time_shift_alerts';
  static const String _channelName = 'Alertas de Turno';
  static const String _channelDescription =
      'Notificações sobre limite de horas e fim de turno';

  // IDs fixos para as duas notificações ativas em cada momento.
  static const int _nineHourAlertId = 9001;
  static const int _endOfDayAlertId = 9002;

  // Chaves de SharedPreferences para persistir estado entre reinícios da app.
  static const String _prefNineHourTargetMs = 'shift_nine_hour_target_ms';
  static const String _prefPauseStartMs = 'shift_pause_started_ms';
  static const String _prefEndOfDayTargetMs = 'shift_end_of_day_target_ms';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa o plugin e o pacote `timezone`.
  /// Deve ser chamado uma vez no arranque da app (`main.dart`).
  Future<void> init() async {
    if (_initialized || kIsWeb) {
      _initialized = true;
      return;
    }
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  /// Pede permissão de notificações ao utilizador (Android 13+ / iOS).
  Future<void> requestPermissionsIfNeeded() async {
    if (kIsWeb || !_initialized) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  NotificationDetails _details({
    required String title,
    required String body,
  }) {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// Agenda os dois alertas relativos a um turno que começa em [inicioTurno].
  Future<void> scheduleShiftAlerts({required DateTime inicioTurno}) async {
    if (kIsWeb || !_initialized) return;

    final nineHourTarget = inicioTurno.add(const Duration(hours: 9));
    final endOfDayTarget = DateTime(
      inicioTurno.year,
      inicioTurno.month,
      inicioTurno.day,
      23,
      0,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _prefNineHourTargetMs,
      nineHourTarget.millisecondsSinceEpoch,
    );
    await prefs.setInt(
      _prefEndOfDayTargetMs,
      endOfDayTarget.millisecondsSinceEpoch,
    );
    await prefs.remove(_prefPauseStartMs);

    await _scheduleAt(
      id: _nineHourAlertId,
      when: nineHourTarget,
      title: tr('notif.nineHours.title'),
      body: tr('notif.nineHours.body'),
    );

    await _scheduleAt(
      id: _endOfDayAlertId,
      when: endOfDayTarget,
      title: tr('notif.endOfDay.title'),
      body: tr('notif.endOfDay.body'),
    );
  }

  /// Pausa: cancela os alertas e guarda o instante em que a pausa começou,
  /// para que possamos somar essa duração quando retomar.
  Future<void> pauseShiftAlerts() async {
    if (kIsWeb || !_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _prefPauseStartMs,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _plugin.cancel(_nineHourAlertId);
  }

  /// Retoma: estende o alvo das 9h pela duração da pausa e reagenda.
  /// O alerta de fim-de-dia continua agendado (relógio de parede).
  Future<void> resumeShiftAlerts() async {
    if (kIsWeb || !_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final pauseStartMs = prefs.getInt(_prefPauseStartMs);
    final nineTargetMs = prefs.getInt(_prefNineHourTargetMs);
    if (pauseStartMs == null || nineTargetMs == null) return;

    final pausedFor = DateTime.now().millisecondsSinceEpoch - pauseStartMs;
    final newTargetMs = nineTargetMs + (pausedFor > 0 ? pausedFor : 0);
    final newTarget = DateTime.fromMillisecondsSinceEpoch(newTargetMs);

    await prefs.setInt(_prefNineHourTargetMs, newTargetMs);
    await prefs.remove(_prefPauseStartMs);

    await _scheduleAt(
      id: _nineHourAlertId,
      when: newTarget,
      title: tr('notif.nineHours.title'),
      body: tr('notif.nineHours.body'),
    );
  }

  /// Cancela ambos os alertas e limpa o estado persistido.
  Future<void> cancelShiftAlerts() async {
    if (kIsWeb || !_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefNineHourTargetMs);
    await prefs.remove(_prefEndOfDayTargetMs);
    await prefs.remove(_prefPauseStartMs);
    await _plugin.cancel(_nineHourAlertId);
    await _plugin.cancel(_endOfDayAlertId);
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    // Se o instante já passou (ex: turno iniciado depois das 23:00),
    // não agendamos esse alerta — sem som, sem ruído.
    if (!when.isAfter(now)) return;

    final tzWhen = tz.TZDateTime.from(when, tz.local);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        _details(title: title, body: body),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Em emuladores sem permissão de alarme exato, faz fallback para inexato.
      debugPrint('NotificationsService: falha alarme exato ($e). A tentar inexato.');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzWhen,
          _details(title: title, body: body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e2) {
        debugPrint('NotificationsService: agendamento falhou: $e2');
      }
    }
  }
}
