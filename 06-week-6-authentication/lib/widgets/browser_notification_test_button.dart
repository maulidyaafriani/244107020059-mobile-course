import 'package:flutter/material.dart';

import '../messaging/browser_notifications_stub.dart'
    if (dart.library.html) '../messaging/browser_notifications_web.dart'
    as browser_notifications;

class BrowserNotificationTestButton extends StatelessWidget {
  const BrowserNotificationTestButton({super.key});

  Future<void> _showNotification(BuildContext context) async {
    try {
      final shown = await browser_notifications.showBrowserNotification(
        title: 'Campus Notify - Tes Notifikasi',
        body: 'Notifikasi demo berhasil ditampilkan di browser.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              shown
                  ? 'Notifikasi demo sudah dikirim ke browser.'
                  : 'Izin notifikasi browser tidak diberikan.',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'browser notification demo',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifikasi browser gagal: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showNotification(context),
      icon: const Icon(Icons.notifications_active_outlined),
      label: const Text('Tampilkan notifikasi demo'),
    );
  }
}
