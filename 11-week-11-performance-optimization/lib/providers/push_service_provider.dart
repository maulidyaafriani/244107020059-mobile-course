import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging/firebase_web_config.dart';
import '../messaging/push_service.dart';
import '../router/app_router.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(
    router: ref.watch(appRouterProvider),
    dio: Dio(),
    apiBaseUrl: _apiBaseUrl,
    vapidKey: firebaseWebVapidKey,
  );
  ref.onDispose(service.dispose);
  return service;
});
