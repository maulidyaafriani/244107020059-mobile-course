import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/firebase_web_config.dart';
import 'messaging/push_service.dart';
import 'providers/push_service_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    if (hasFirebaseWebAppConfig) {
      await Firebase.initializeApp(options: firebaseWebOptions);
    }
  } else {
    await Firebase.initializeApp();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }
  runApp(const ProviderScope(child: CampusNotifyApp()));
  if (kIsWeb) {
    if (!hasFirebaseWebAppConfig) {
      debugPrint(
        'Web preview: Firebase Web config is missing; Firebase Cloud '
        'Messaging is unavailable.',
      );
    } else if (!hasFirebaseWebConfig) {
      debugPrint(
        'Firebase Web is initialized. Add FIREBASE_VAPID_KEY to enable '
        'browser push notifications.',
      );
    }
  }
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePushService();
      });
    }
  }

  Future<void> _initializePushService() async {
    try {
      await ref.read(pushServiceProvider).initialize();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'push notification initialization',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
