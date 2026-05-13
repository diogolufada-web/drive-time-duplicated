import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VeiculosRecord extends FirestoreRecord {
  VeiculosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "matricula" field.
  String? _matricula;
  String get matricula => _matricula ?? '';
  bool hasMatricula() => _matricula != null;

  // "marca" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "ano" field.
  String? _ano;
  String get ano => _ano ?? '';
  bool hasAno() => _ano != null;

  // "cor" field.
  String? _cor;
  String get cor => _cor ?? '';
  bool hasCor() => _cor != null;

  // "licencaoperador" field.
  String? _licencaoperador;
  String get licencaoperador => _licencaoperador ?? '';
  bool hasLicencaoperador() => _licencaoperador != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "ativo" field.
  bool? _ativo;
  bool get ativo => _ativo ?? false;
  bool hasAtivo() => _ativo != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _matricula = snapshotData['matricula'] as String?;
    _marca = snapshotData['marca'] as String?;
    _ano = snapshotData['ano'] as String?;
    _cor = snapshotData['cor'] as String?;
    _licencaoperador = snapshotData['licencaoperador'] as String?;
    _email = snapshotData['email'] as String?;
    _ativo = snapshotData['ativo'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('veiculos');

  static Stream<VeiculosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VeiculosRecord.fromSnapshot(s));

  static Future<VeiculosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VeiculosRecord.fromSnapshot(s));

  static VeiculosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VeiculosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VeiculosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VeiculosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VeiculosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VeiculosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVeiculosRecordData({
  String? matricula,
  String? marca,
  String? ano,
  String? cor,
  String? licencaoperador,
  String? email,
  bool? ativo,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'matricula': matricula,
      'marca': marca,
      'ano': ano,
      'cor': cor,
      'licencaoperador': licencaoperador,
      'email': email,
      'ativo': ativo,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class VeiculosRecordDocumentEquality implements Equality<VeiculosRecord> {
  const VeiculosRecordDocumentEquality();

  @override
  bool equals(VeiculosRecord? e1, VeiculosRecord? e2) {
    return e1?.matricula == e2?.matricula &&
        e1?.marca == e2?.marca &&
        e1?.ano == e2?.ano &&
        e1?.cor == e2?.cor &&
        e1?.licencaoperador == e2?.licencaoperador &&
        e1?.email == e2?.email &&
        e1?.ativo == e2?.ativo &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(VeiculosRecord? e) => const ListEquality().hash([
        e?.matricula,
        e?.marca,
        e?.ano,
        e?.cor,
        e?.licencaoperador,
        e?.email,
        e?.ativo,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is VeiculosRecord;
}
