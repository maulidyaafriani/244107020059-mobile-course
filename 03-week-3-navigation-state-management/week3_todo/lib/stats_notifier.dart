import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data statistik yang akan ditampilkan pada halaman StatsPage.
class StatItem {
  final String title;
  final int value;

  const StatItem({
    required this.title,
    required this.value,
  });
}

/// Provider untuk mengatur data statistik secara asynchronous.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);

/// Notifier yang bertugas mengambil data statistik.
///
/// Data dibuat secara simulasi dengan delay 2 detik.
/// Terdapat kemungkinan 30% terjadi error.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    return _getStats();
  }

  /// Mengambil data statistik secara simulasi.
  Future<List<StatItem>> _getStats() async {
    // Simulasi proses mengambil data selama 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi error sebesar 30%.
    final random = Random();

    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik.');
    }

    // Data statistik berhasil diambil.
    return const [
      StatItem(title: 'Total Pengguna', value: 120),
      StatItem(title: 'Total Pesanan', value: 75),
      StatItem(title: 'Total Produk', value: 45),
    ];
  }

  /// Memuat ulang data statistik ketika tombol Retry ditekan.
  Future<void> retry() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _getStats();
    });
  }
}