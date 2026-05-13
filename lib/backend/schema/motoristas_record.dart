import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MotoristasRecord extends FirestoreRecord {
  MotoristasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "telefone" field.
  String? _telefone;
  String get telefone => _telefone ?? '';
  bool hasTelefone() => _telefone != null;

  // "certeficadocmtvde" field.
  String? _certeficadocmtvde;
  String get certeficadocmtvde => _certeficadocmtvde ?? '';
  bool hasCerteficadocmtvde() => _certeficadocmtvde != null;

  // "cartadeconducao" field.
  String? _cartadeconducao;
  String get cartadeconducao => _cartadeconducao ?? '';
  bool hasCartadeconducao() => _cartadeconducao != null;

  // "nif" field.
  String? _nif;
  String get nif => _nif ?? '';
  bool hasNif() => _nif != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _nome = snapshotData['nome'] as String?;
    _telefone = snapshotData['telefone'] as String?;
    _certeficadocmtvde = snapshotData['certeficadocmtvde'] as String?;
    _cartadeconducao = snapshotData['cartadeconducao'] as String?;
    _nif = snapshotData['nif'] as String?;
    _email = snapshotData['email'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('motoristas');

  static Stream<MotoristasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MotoristasRecord.fromSnapshot(s));

  static Future<MotoristasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MotoristasRecord.fromSnapshot(s));

  static MotoristasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MotoristasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MotoristasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MotoristasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MotoristasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MotoristasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMotoristasRecordData({
  String? nome,
  String? telefone,
  String? certeficadocmtvde,
  String? cartadeconducao,
  String? nif,
  String? email,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nome': nome,
      'telefone': telefone,
      'certeficadocmtvde': certeficadocmtvde,
      'cartadeconducao': cartadeconducao,
      'nif': nif,
      'email': email,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class MotoristasRecordDocumentEquality implements Equality<MotoristasRecord> {
  const MotoristasRecordDocumentEquality();

  @override
  bool equals(MotoristasRecord? e1, MotoristasRecord? e2) {
    return e1?.nome == e2?.nome &&
        e1?.telefone == e2?.telefone &&
        e1?.certeficadocmtvde == e2?.certeficadocmtvde &&
        e1?.cartadeconducao == e2?.cartadeconducao &&
        e1?.nif == e2?.nif &&
        e1?.email == e2?.email &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(MotoristasRecord? e) => const ListEquality().hash([
        e?.nome,
        e?.telefone,
        e?.certeficadocmtvde,
        e?.cartadeconducao,
        e?.nif,
        e?.email,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is MotoristasRecord;
}
