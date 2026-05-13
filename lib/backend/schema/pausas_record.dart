import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PausasRecord extends FirestoreRecord {
  PausasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "turno_ref" field.
  DocumentReference? _turnoRef;
  DocumentReference? get turnoRef => _turnoRef;
  bool hasTurnoRef() => _turnoRef != null;

  // "data_dia" field.
  String? _dataDia;
  String get dataDia => _dataDia ?? '';
  bool hasDataDia() => _dataDia != null;

  // "inicio_pausa" field.
  DateTime? _inicioPausa;
  DateTime? get inicioPausa => _inicioPausa;
  bool hasInicioPausa() => _inicioPausa != null;

  // "fim_pausa" field.
  DateTime? _fimPausa;
  DateTime? get fimPausa => _fimPausa;
  bool hasFimPausa() => _fimPausa != null;

  // "ativo" field.
  bool? _ativo;
  bool get ativo => _ativo ?? false;
  bool hasAtivo() => _ativo != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _turnoRef = snapshotData['turno_ref'] as DocumentReference?;
    _dataDia = snapshotData['data_dia'] as String?;
    _inicioPausa = snapshotData['inicio_pausa'] as DateTime?;
    _fimPausa = snapshotData['fim_pausa'] as DateTime?;
    _ativo = snapshotData['ativo'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('pausas');

  static Stream<PausasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PausasRecord.fromSnapshot(s));

  static Future<PausasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PausasRecord.fromSnapshot(s));

  static PausasRecord fromSnapshot(DocumentSnapshot snapshot) => PausasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PausasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PausasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PausasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PausasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPausasRecordData({
  String? email,
  DocumentReference? turnoRef,
  String? dataDia,
  DateTime? inicioPausa,
  DateTime? fimPausa,
  bool? ativo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'turno_ref': turnoRef,
      'data_dia': dataDia,
      'inicio_pausa': inicioPausa,
      'fim_pausa': fimPausa,
      'ativo': ativo,
    }.withoutNulls,
  );

  return firestoreData;
}

class PausasRecordDocumentEquality implements Equality<PausasRecord> {
  const PausasRecordDocumentEquality();

  @override
  bool equals(PausasRecord? e1, PausasRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.turnoRef == e2?.turnoRef &&
        e1?.dataDia == e2?.dataDia &&
        e1?.inicioPausa == e2?.inicioPausa &&
        e1?.fimPausa == e2?.fimPausa &&
        e1?.ativo == e2?.ativo;
  }

  @override
  int hash(PausasRecord? e) => const ListEquality().hash([
        e?.email,
        e?.turnoRef,
        e?.dataDia,
        e?.inicioPausa,
        e?.fimPausa,
        e?.ativo
      ]);

  @override
  bool isValidKey(Object? o) => o is PausasRecord;
}
