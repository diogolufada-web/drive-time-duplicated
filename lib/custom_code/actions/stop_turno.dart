// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/internationalization.dart';
import '/services/notifications_service.dart';
import '/utils/shift_time.dart';

void _showSnack(String message) {
  debugPrint('stopTurno: $message');
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) {
    return;
  }
  ScaffoldMessenger.of(ctx).clearSnackBars();
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
  );
}

Future<List<PausasRecord>> _activePausasForTurno(
  DocumentReference turnoRef,
) async {
  if (currentUserEmail.isEmpty) {
    return [];
  }
  return queryPausasRecordOnce(
    queryBuilder: (q) => q
        .where('email', isEqualTo: currentUserEmail)
        .where('turno_ref', isEqualTo: turnoRef)
        .where('ativo', isEqualTo: true),
  );
}

Future<List<PausasRecord>> _allPausasForTurno(
  DocumentReference turnoRef,
) async {
  if (currentUserEmail.isEmpty) {
    return [];
  }
  return queryPausasRecordOnce(
    queryBuilder: (q) => q
        .where('email', isEqualTo: currentUserEmail)
        .where('turno_ref', isEqualTo: turnoRef),
  );
}

Future<void> _safeShiftNotification(Future<void> Function() action) async {
  try {
    await action();
  } catch (e, st) {
    debugPrint('stopTurno: notificação ignorada ($e)\n$st');
  }
}

Future<bool> _finalizeTurno(
  TurnosRecord turno, {
  required DateTime endTime,
  required String successMessage,
}) async {
  if (currentUserEmail.isEmpty) {
    _showSnack(tr('shift.notAuthenticated'));
    return false;
  }

  final turnoRef = turno.reference;

  try {
    final fresh = await TurnosRecord.getDocumentOnce(turnoRef);
    if (!fresh.ativo) {
      return false;
    }
    if (fresh.email.isNotEmpty && fresh.email != currentUserEmail) {
      _showSnack(tr('shift.notOwner'));
      return false;
    }

    final openPausas = await _activePausasForTurno(turnoRef);
    final allPausas = await _allPausasForTurno(turnoRef);

    final activeSeconds = effectiveShiftSeconds(
      fresh,
      allPausas,
      referenceNow: endTime,
    );

    final batch = FirebaseFirestore.instance.batch();

    for (final pausa in openPausas) {
      batch.update(
        pausa.reference,
        createPausasRecordData(fimPausa: endTime, ativo: false),
      );
    }
    batch.update(
      turnoRef,
      createTurnosRecordData(
        fimTurno: endTime,
        estado: 'terminado',
        ativo: false,
        duracaoSegundos: activeSeconds,
      ),
    );
    await batch.commit();
    await _safeShiftNotification(
      () => NotificationsService.instance.cancelShiftAlerts(),
    );
    _showSnack(successMessage);
    return true;
  } catch (e, st) {
    debugPrint('stopTurno error: $e\n$st');
    _showSnack(tr('shift.stopFailed'));
    return false;
  }
}

/// STOP
/// Parâmetro FlutterFlow: [turno] = Document (Turnos Record), ex. containerTurnosRecord
Future<void> stopTurno(TurnosRecord? turno) async {
  if (turno == null) {
    _showSnack(tr('shift.noActive'));
    return;
  }
  await _finalizeTurno(
    turno,
    endTime: getCurrentTimestamp,
    successMessage: tr('shift.stopped'),
  );
}

/// Termina automaticamente turnos activos há mais de 24 horas.
Future<bool> autoStopTurnoIfExpired(TurnosRecord? turno) async {
  if (turno == null || !isShiftExpired(turno)) {
    return false;
  }
  final autoEnd = shiftAutoEndTime(turno);
  if (autoEnd == null) {
    return false;
  }
  return _finalizeTurno(
    turno,
    endTime: autoEnd,
    successMessage: tr('shift.autoStopped24h'),
  );
}
