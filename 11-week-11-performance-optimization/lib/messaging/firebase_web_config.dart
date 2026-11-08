import 'package:firebase_core/firebase_core.dart';

const firebaseWebApiKey = '';
const firebaseWebAppId = '';
const firebaseWebMessagingSenderId = '';
const firebaseWebProjectId = '';
const firebaseWebAuthDomain = '';
const firebaseWebStorageBucket = '';
const firebaseWebVapidKey =
    '';

bool get hasFirebaseWebAppConfig =>
    firebaseWebApiKey.isNotEmpty &&
    firebaseWebAppId.isNotEmpty &&
    firebaseWebMessagingSenderId.isNotEmpty &&
    firebaseWebProjectId.isNotEmpty;

bool get hasFirebaseWebConfig =>
    hasFirebaseWebAppConfig && firebaseWebVapidKey.isNotEmpty;

FirebaseOptions get firebaseWebOptions => FirebaseOptions(
  apiKey: firebaseWebApiKey,
  appId: firebaseWebAppId,
  messagingSenderId: firebaseWebMessagingSenderId,
  projectId: firebaseWebProjectId,
  authDomain: firebaseWebAuthDomain.isEmpty
      ? '$firebaseWebProjectId.firebaseapp.com'
      : firebaseWebAuthDomain,
  storageBucket: firebaseWebStorageBucket.isEmpty
      ? '$firebaseWebProjectId.firebasestorage.app'
      : firebaseWebStorageBucket,
);
