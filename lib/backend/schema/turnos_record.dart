import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TurnosRecord extends FirestoreRecord {
  TurnosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "estado" field.
  String? _estado;
  String get estado => _estado ?? '';
  bool hasEstado() => _estado != null;

  // "inicio_turno" field.
  DateTime? _inicioTurno;
  DateTime? get inicioTurno => _inicioTurno;
  bool hasInicioTurno() => _inicioTurno != null;

  // "ativo" field.
  bool? _ativo;
  bool get ativo => _ativo ?? false;
  bool hasAtivo() => _ativo != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "fim_turno" field.
  DateTime? _fimTurno;
  DateTime? get fimTurno => _fimTurno;
  bool hasFimTurno() => _fimTurno != null;

  // "data_dia" field.
  String? _dataDia;
  String get dataDia => _dataDia ?? '';
  bool hasDataDia() => _dataDia != null;

  // "nome_motorista" field.
  String? _nomeMotorista;
  String get nomeMotorista => _nomeMotorista ?? '';
  bool hasNomeMotorista() => _nomeMotorista != null;

  // "certificado_cmtvde" field.
  String? _certificadoCmtvde;
  String get certificadoCmtvde => _certificadoCmtvde ?? '';
  bool hasCertificadoCmtvde() => _certificadoCmtvde != null;

  // "matricula" field.
  String? _matricula;
  String get matricula => _matricula ?? '';
  bool hasMatricula() => _matricula != null;

  // "licenca_operador" field.
  String? _licencaOperador;
  String get licencaOperador => _licencaOperador ?? '';
  bool hasLicencaOperador() => _licencaOperador != null;

  // "duracao_segundos" field.
  int? _duracaoSegundos;
  int get duracaoSegundos => _duracaoSegundos ?? 0;
  bool hasDuracaoSegundos() => _duracaoSegundos != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _estado = snapshotData['estado'] as String?;
    _inicioTurno = snapshotData['inicio_turno'] as DateTime?;
    _ativo = snapshotData['ativo'] as bool?;
    _data = snapshotData['data'] as DateTime?;
    _fimTurno = snapshotData['fim_turno'] as DateTime?;
    _dataDia = snapshotData['data_dia'] as String?;
    _nomeMotorista = snapshotData['nome_motorista'] as String?;
    _certificadoCmtvde = snapshotData['certificado_cmtvde'] as String?;
    _matricula = snapshotData['matricula'] as String?;
    _licencaOperador = snapshotData['licenca_operador'] as String?;
    _duracaoSegundos = castToType<int>(snapshotData['duracao_segundos']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('turnos');

  static Stream<TurnosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TurnosRecord.fromSnapshot(s));

  static Future<TurnosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TurnosRecord.fromSnapshot(s));

  static TurnosRecord fromSnapshot(DocumentSnapshot snapshot) => TurnosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TurnosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TurnosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TurnosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TurnosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTurnosRecordData({
  String? email,
  String? estado,
  DateTime? inicioTurno,
  bool? ativo,
  DateTime? data,
  DateTime? fimTurno,
  String? dataDia,
  String? nomeMotorista,
  String? certificadoCmtvde,
  String? matricula,
  String? licencaOperador,
  int? duracaoSegundos,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'estado': estado,
      'inicio_turno': inicioTurno,
      'ativo': ativo,
      'data': data,
      'fim_turno': fimTurno,
      'data_dia': dataDia,
      'nome_motorista': nomeMotorista,
      'certificado_cmtvde': certificadoCmtvde,
      'matricula': matricula,
      'licenca_operador': licencaOperador,
      'duracao_segundos': duracaoSegundos,
    }.withoutNulls,
  );

  return firestoreData;
}

class TurnosRecordDocumentEquality implements Equality<TurnosRecord> {
  const TurnosRecordDocumentEquality();

  @override
  bool equals(TurnosRecord? e1, TurnosRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.estado == e2?.estado &&
        e1?.inicioTurno == e2?.inicioTurno &&
        e1?.ativo == e2?.ativo &&
        e1?.data == e2?.data &&
        e1?.fimTurno == e2?.fimTurno &&
        e1?.dataDia == e2?.dataDia &&
        e1?.nomeMotorista == e2?.nomeMotorista &&
        e1?.certificadoCmtvde == e2?.certificadoCmtvde &&
        e1?.matricula == e2?.matricula &&
        e1?.licencaOperador == e2?.licencaOperador &&
        e1?.duracaoSegundos == e2?.duracaoSegundos;
  }

  @override
  int hash(TurnosRecord? e) => const ListEquality().hash([
        e?.email,
        e?.estado,
        e?.inicioTurno,
        e?.ativo,
        e?.data,
        e?.fimTurno,
        e?.dataDia,
        e?.nomeMotorista,
        e?.certificadoCmtvde,
        e?.matricula,
        e?.licencaOperador,
        e?.duracaoSegundos
      ]);

  @override
  bool isValidKey(Object? o) => o is TurnosRecord;
}
