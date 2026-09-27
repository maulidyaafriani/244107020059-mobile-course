import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkModeAsync.when(
            data: (isDark) => SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: const Text('Ganti tampilan aplikasi jadi gelap/terang'),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
            loading: () => const ListTile(
              title: Text('Mode Gelap'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => ListTile(title: Text('Gagal memuat: $e')),
          ),
          const Divider(),
          lastOpenedAsync.when(
            data: (value) => ListTile(
              title: const Text('Terakhir dibuka'),
              subtitle: Text(value ?? 'Belum pernah tercatat'),
            ),
            loading: () => const ListTile(title: Text('Memuat...')),
            error: (e, _) => ListTile(title: Text('Gagal memuat: $e')),
          ),
        ],
      ),
    );
  }
}