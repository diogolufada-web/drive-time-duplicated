import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

String calculahorashoje(
  List<TurnosRecord> turnos,
  List<PausasRecord> pausas,
) {
  Duration totalTurno = Duration.zero;
  Duration totalPausa = Duration.zero;

  for (final turno in turnos) {
    final DateTime? inicio = turno.inicioTurno;
    final DateTime fim = turno.fimTurno ?? DateTime.now();

    if (inicio != null) {
      totalTurno += fim.difference(inicio);
    }
  }

  for (final pausa in pausas) {
    final DateTime? inicio = pausa.inicioPausa;
    final DateTime fim = pausa.fimPausa ?? DateTime.now();

    if (inicio != null) {
      totalPausa += fim.difference(inicio);
    }
  }

  Duration total = totalTurno - totalPausa;

  if (total.isNegative) {
    total = Duration.zero;
  }

  final horas = total.inHours.toString().padLeft(2, '0');
  final minutos = total.inMinutes.remainder(60).toString().padLeft(2, '0');
  final segundos = total.inSeconds.remainder(60).toString().padLeft(2, '0');

  return '$horas:$minutos:$segundos';
}
