import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> showBrowserNotification({
  required String title,
  required String body,
}) async {
  var permission = web.Notification.permission;
  if (permission == 'default') {
    permission = (await web.Notification.requestPermission().toDart).toDart;
  }
  if (permission != 'granted') return false;

  web.Notification(title, web.NotificationOptions(body: body));
   return true;
}
