import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '/flutter_flow/flutter_flow_util.dart';

/// Mensagem amigável para erros de autenticação Firebase (PT/EN via [tr]).
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return tr('errors.auth.emailInUse');
    case 'invalid-email':
      return tr('errors.auth.invalidEmail');
    case 'weak-password':
      return tr('errors.auth.weakPassword');
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
    case 'INVALID_LOGIN_CREDENTIALS':
      return tr('errors.auth.invalidCredentials');
    case 'too-many-requests':
      return tr('errors.auth.tooManyRequests');
    case 'requires-recent-login':
      return tr('errors.auth.requiresRecentLogin');
    case 'network-request-failed':
      return tr('errors.network');
    default:
      return tr('errors.auth.generic');
  }
}

/// Mensagem amigável para erros Firestore/rede.
String firestoreErrorMessage(Object? error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return tr('errors.firestore.permissionDenied');
      case 'unavailable':
        return tr('errors.firestore.unavailable');
      case 'failed-precondition':
        return tr('errors.firestore.failedPrecondition');
    }
  }
  return tr('errors.generic');
}
