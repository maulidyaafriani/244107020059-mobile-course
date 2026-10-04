import 'package:firebase_core/firebase_core.dart';

const firebaseWebApiKey = 'AIzaSyBna3QDMRiEMLxTG4g0fG4caZXEegu9IZs';
const firebaseWebAppId = '1:214757259024:web:7af9669e364a7b799f1795';
const firebaseWebMessagingSenderId = '214757259024';
const firebaseWebProjectId = 'campus-notify-db837';
const firebaseWebAuthDomain = 'campus-notify-db837.firebaseapp.com';
const firebaseWebStorageBucket = 'campus-notify-db837.firebasestorage.app';
const firebaseWebVapidKey =
    'BL4jDc-yrW2RjRq5F0qmUNOXp2OxaxIWKlBgkXP7rqJNI1GWSivWHyCH_FJWiTPuFhRhVHc7P4uEgGEkRPI7sO4';

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
