import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'browser_notifications_stub.dart'
    if (dart.library.html) 'browser_notifications_web.dart'
    as browser_notifications;
import 'firebase_web_config.dart';
import '../routes.dart';

const campusAnnouncementsTopic = 'pengumuman-kampus';
const _notificationChannelId = 'campus_announcements';
const _notificationChannelName = 'Pengumuman kampus';

final fcmTokenForDebug = ValueNotifier<String?>(null);

final _backgroundLocalNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: initialize Firebase here; do not use BuildContext,
  // Riverpod, GoRouter, or other foreground-only application state.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Notification payloads are shown by the operating system in background.
  // Show a local notification here only for data-only messages.
  if (message.notification != null || kIsWeb) return;

  final title = message.data['title']?.toString();
  final body = message.data['body']?.toString();
  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }

  await _initializeLocalNotifications(
    _backgroundLocalNotifications,
    onResponse: (_) {},
  );
  await _showLocalNotification(
    _backgroundLocalNotifications,
    message,
    title: title,
    body: body,
  );
}

class PushService {
  PushService({
    required this._router,
    required this._dio,
    required String? apiBaseUrl,
    this.vapidKey,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _apiBaseUrl = _validatedBaseUrl(apiBaseUrl),
       _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final GoRouter _router;
  final Dio _dio;
  final Uri? _apiBaseUrl;
  final String? vapidKey;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  bool _initialized = false;
  bool _listenersInitialized = false;
  Future<void>? _initializing;

  static Uri? _validatedBaseUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      throw ArgumentError.value(value, 'apiBaseUrl', 'Must be an HTTP(S) URL.');
    }
    return uri;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return _isAuthorized(settings.authorizationStatus);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android 13+ (API 33) needs POST_NOTIFICATIONS at runtime.
      // On older Android versions the plugin treats this as a no-op.
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS requires explicit alert, badge, and sound authorization.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return _isAuthorized(settings.authorizationStatus);
    }

    return false;
  }

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    if (!kIsWeb) {
      await _initializeLocalNotifications(
        _localNotifications,
        onResponse: (response) => _openRouteFromPayload(response.payload),
      );
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _openRouteFromPayload(launchDetails?.notificationResponse?.payload);
      }
    }

    final permitted = await requestPermission();
    if (!permitted) {
      debugPrint('Push notifications were not authorized.');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // Prevent duplicate iOS banners; foreground FCM messages use local alerts.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    if (!_listenersInitialized) {
      _tokenSubscription = _messaging.onTokenRefresh.listen(
        (token) => unawaited(_registerRefreshedToken(token)),
        onError: (Object error, StackTrace stackTrace) {
          _reportError(error, stackTrace, 'FCM token refresh listener');
        },
      );
      _messageSubscription = FirebaseMessaging.onMessage.listen(
        (message) => unawaited(_handleForegroundMessageSafely(message)),
        onError: (Object error, StackTrace stackTrace) {
          _reportError(error, stackTrace, 'foreground FCM message listener');
        },
      );
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _navigateFromMessage(message),
        onError: (Object error, StackTrace stackTrace) {
          _reportError(error, stackTrace, 'FCM notification tap listener');
        },
      );
      _listenersInitialized = true;
    }

    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _navigateFromMessage(initialMessage);
      await _getAndRegisterToken();
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _getAndRegisterToken() async {
    final token = await _messaging.getToken(
      vapidKey: kIsWeb ? vapidKey ?? firebaseWebVapidKey : null,
      serviceWorkerScriptPath: kIsWeb ? '/firebase-messaging-sw.js' : null,
    );
    if (token != null) await _registerTokenSafely(token);
  }

  Future<void> _registerTokenSafely(String token) async {
    fcmTokenForDebug.value = token;
    if (_apiBaseUrl == null) {
      debugPrint(
        'FCM token was not sent: configure API_BASE_URL to POST /devices.',
      );
      return;
    }

    await _dio.postUri(
      _apiBaseUrl.resolve('/devices'),
      data: {
        'fcm_token': token,
        'platform': kIsWeb
            ? 'web'
            : defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      },
    );
  }

  Future<void> _registerRefreshedToken(String token) async {
    try {
      await _registerTokenSafely(token);
    } catch (error, stackTrace) {
      _reportError(error, stackTrace, 'registering refreshed FCM token');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    if (kIsWeb) {
      final shown = await browser_notifications.showBrowserNotification(
        title: title ?? 'Campus Notify',
        body: body ?? '',
      );
      if (!shown) debugPrint('Foreground browser notification was not shown.');
      return;
    }

    await _showLocalNotification(
      _localNotifications,
      message,
      title: title,
      body: body,
    );
  }

  Future<void> _handleForegroundMessageSafely(RemoteMessage message) async {
    try {
      await _handleForegroundMessage(message);
    } catch (error, stackTrace) {
      _reportError(error, stackTrace, 'displaying foreground notification');
    }
  }

  Future<void> subscribeToAnnouncements() async {
    _ensureNativeTopicMessaging();
    await _messaging.subscribeToTopic(campusAnnouncementsTopic);
  }

  Future<void> unsubscribeFromAnnouncements() async {
    _ensureNativeTopicMessaging();
    await _messaging.unsubscribeFromTopic(campusAnnouncementsTopic);
  }

  void _ensureNativeTopicMessaging() {
    if (kIsWeb) {
      throw UnsupportedError(
        'FCM topic subscribe/unsubscribe is not supported in the web client.',
      );
    }
  }

  void _navigateFromMessage(RemoteMessage message) {
    _router.go(routeFromMessage(message.data));
  }

  void _openRouteFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _router.go(routeFromMessage(decoded));
      }
    } on FormatException catch (error, stackTrace) {
      _reportError(error, stackTrace, 'notification route payload');
    }
  }

  void _reportError(Object error, StackTrace stackTrace, String context) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'PushService',
        context: ErrorDescription(context),
      ),
    );
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}

bool _isAuthorized(AuthorizationStatus status) =>
    status == AuthorizationStatus.authorized ||
    status == AuthorizationStatus.provisional;

Future<void> _initializeLocalNotifications(
  FlutterLocalNotificationsPlugin plugin, {
  required DidReceiveNotificationResponseCallback onResponse,
}) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  await plugin.initialize(
    settings: const InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    ),
    onDidReceiveNotificationResponse: onResponse,
  );

  final android = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Notifikasi pengumuman kampus',
      importance: Importance.high,
    ),
  );
}

Future<void> _showLocalNotification(
  FlutterLocalNotificationsPlugin plugin,
  RemoteMessage message, {
  required String? title,
  required String? body,
}) async {
  final route = message.data['route']?.toString();
  final payload = route == null
      ? null
      : jsonEncode({'route': routeFromMessage(message.data)});
  await plugin.show(
    id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
    title: title ?? 'Campus Notify',
    body: body ?? '',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: 'Notifikasi pengumuman kampus',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: payload,
  );
}
