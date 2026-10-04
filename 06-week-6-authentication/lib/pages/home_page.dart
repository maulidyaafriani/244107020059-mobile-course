import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/api_errors.dart';
import '../messaging/firebase_web_config.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/push_service_provider.dart';
import '../routes.dart';
import '../widgets/browser_notification_test_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _enableWebNotifications(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final pushService = ref.read(pushServiceProvider);
      final permitted = await pushService.requestPermission();
      if (!permitted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin notifikasi belum diberikan.')),
          );
        }
        return;
      }

      await pushService.initialize();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'web push notification setup',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(error))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              FilledButton(
                onPressed: () =>
                    context.go(AppRoutes.announcement('contoh')),
                child: const Text('Lihat pengumuman contoh'),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 24),
                const Text(
                  'Demo notifikasi browser (bukan FCM)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Klik tombol ini dan izinkan notifikasi agar melihat '
                  'notifikasi muncul di komputer.',
                ),
                const SizedBox(height: 12),
                const BrowserNotificationTestButton(),
                const SizedBox(height: 24),
                const Text(
                  'Tes notifikasi Firebase Web',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  hasFirebaseWebConfig
                      ? 'Aktifkan notifikasi, lalu salin token ke Firebase Console.'
                      : 'Tambahkan konfigurasi Firebase Web dan VAPID key untuk '
                            'mengaktifkan tes notifikasi.',
                ),
                if (hasFirebaseWebConfig) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => _enableWebNotifications(context, ref),
                    child: const Text('Aktifkan notifikasi dan ambil token'),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String?>(
                    valueListenable: fcmTokenForDebug,
                    builder: (context, token, child) {
                      if (token == null) {
                        return const Text('Token belum tersedia.');
                      }
                      final preview = token.length <= 12
                          ? token
                          : '${token.substring(0, 12)}...';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Token FCM (disamarkan)'),
                        subtitle: Text(preview),
                        trailing: IconButton(
                          tooltip: 'Salin token lengkap',
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: token));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Token disalin. Jangan masukkan token '
                                    'penuh ke screenshot.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
