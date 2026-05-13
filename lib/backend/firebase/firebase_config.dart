import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBYqrbzbj-yEDsobQy24JJnswr8nnUTYEU",
            authDomain: "drive-time-da85f.firebaseapp.com",
            projectId: "drive-time-da85f",
            storageBucket: "drive-time-da85f.firebasestorage.app",
            messagingSenderId: "481957119633",
            appId: "1:481957119633:web:cfa84092f80ff8885ea130",
            measurementId: "G-R75SB2MM5H"));
  } else {
    await Firebase.initializeApp();
  }
}
