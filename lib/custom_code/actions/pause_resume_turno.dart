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

void _showSnack(String message) {
  debugPrint('pauseResumeTurno: $message');
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

bool _estadoIndicaPausa(String? estado) {
  final e = (estado ?? '').trim().toLowerCase();
  return e == 'pausa' || e == 'em_pausa' || e == 'empausa';
}

/// PAUSA / RETOMAR
/// Parâmetro FlutterFlow: [turno] = Document (Turnos Record), ex. containerTurnosRecord
Future<void> pauseResumeTurno(TurnosRecord? turno) async {
  if (turno == null) {
    _showSnack(tr('shift.noActive'));
    return;
  }
  if (currentUserEmail.isEmpty) {
    _showSnack(tr('shift.notAuthenticated'));
    return;
  }

  final turnoRef = turno.reference;

  try {
    final fresh = await TurnosRecord.getDocumentOnce(turnoRef);
    if (!fresh.ativo) {
      _showSnack(tr('home.shiftInactive'));
      return;
    }
    if (fresh.email.isNotEmpty && fresh.email != currentUserEmail) {
      _showSnack(tr('shift.notOwner'));
      return;
    }

    final openPausas = await _activePausasForTurno(turnoRef);
    final shouldResume =
        openPausas.isNotEmpty || _estadoIndicaPausa(fresh.estado);

    if (!shouldResume) {
      final pausaRef = PausasRecord.collection.doc();
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        pausaRef,
        createPausasRecordData(
          email: currentUserEmail,
          turnoRef: turnoRef,
          dataDia: valueOrDefault<String>(
            dateTimeFormat('yyyy-MM-dd', getCurrentTimestamp),
            'yyyy-MM-dd',
          ),
          inicioPausa: getCurrentTimestamp,
          ativo: true,
        ),
      );
      batch.update(
        turnoRef,
        createTurnosRecordData(estado: 'pausa', ativo: true),
      );
      await batch.commit();
      await NotificationsService.instance.pauseShiftAlerts();
      _showSnack(tr('shift.pauseStarted'));
      return;
    }

    final now = getCurrentTimestamp;
    final batch = FirebaseFirestore.instance.batch();
    for (final pausa in openPausas) {
      batch.update(
        pausa.reference,
        createPausasRecordData(fimPausa: now, ativo: false),
      );
    }
    batch.update(
      turnoRef,
      createTurnosRecordData(estado: 'ativo', ativo: true),
    );
    await batch.commit();
    await NotificationsService.instance.resumeShiftAlerts();
    _showSnack(tr('shift.resumed'));
  } catch (e, st) {
    debugPrint('pauseResumeTurno error: $e\n$st');
    _showSnack(tr('shift.pauseResumeFailed'));
  }
}
