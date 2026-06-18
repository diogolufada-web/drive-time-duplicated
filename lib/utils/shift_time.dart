import '/backend/backend.dart';

/// Computes the legally active shift duration in seconds for [turno],
/// subtracting any pause intervals that fall within the shift window.
///
/// - [allPausas] must include **all** pauses for the shift/day (open and closed).
///   If only `ativo: true` pauses are passed, closed breaks are not subtracted
///   and the timer will incorrectly include pause time after resume.
/// - Pauses are filtered by `turnoRef` (compared by document path).
/// - [referenceNow] is used as the end time when a shift (or an open pause) is
///   still active. Defaults to `DateTime.now()`.
int effectiveShiftSeconds(
  TurnosRecord turno,
  List<PausasRecord> allPausas, {
  DateTime? referenceNow,
}) {
  final start = turno.inicioTurno;
  if (start == null) return 0;

  final now = referenceNow ?? DateTime.now();
  final end = turno.fimTurno ?? now;
  if (!end.isAfter(start)) return 0;

  final grossSeconds = end.difference(start).inSeconds;
  if (grossSeconds <= 0) return 0;

  final turnoPath = turno.reference.path;
  int pauseSeconds = 0;

  for (final p in allPausas) {
    if (p.turnoRef?.path != turnoPath) continue;
    final pStartRaw = p.inicioPausa;
    if (pStartRaw == null) continue;
    // Open pause: count until now (timer freezes). Closed: use fim_pausa only.
    final pEndRaw = p.fimPausa ?? now;

    final pStart = pStartRaw.isBefore(start) ? start : pStartRaw;
    final pEnd = pEndRaw.isAfter(end) ? end : pEndRaw;

    if (pEnd.isAfter(pStart)) {
      pauseSeconds += pEnd.difference(pStart).inSeconds;
    }
  }

  final net = grossSeconds - pauseSeconds;
  return net > 0 ? net : 0;
}

/// Formats a duration in seconds as `Hh MMm`, e.g. `0h 03m` for 180 seconds.
String formatHM(int seconds) {
  if (seconds <= 0) return '0h 00m';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
