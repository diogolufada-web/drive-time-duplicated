import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'homepage_widget.dart' show HomepageWidget;
import 'package:flutter/material.dart';

class HomepageModel extends FlutterFlowModel<HomepageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  MotoristasRecord? motoristadoc;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  VeiculosRecord? veiculodoc;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  PausasRecord? pausadoc;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  PausasRecord? pausastopdoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
