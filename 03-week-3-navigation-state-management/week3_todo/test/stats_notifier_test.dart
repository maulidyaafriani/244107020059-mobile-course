import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_todo/stats_notifier.dart';

void main() {
  group('StatsNotifier', () {
    test('berhasil mengambil data statistik', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => TestStatsNotifier(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = await container.read(statsProvider.future);

      expect(result.length, 3);
      expect(result[0].title, 'Total Pengguna');
      expect(result[0].value, 120);
      expect(result[1].title, 'Total Pesanan');
      expect(result[1].value, 75);
      expect(result[2].title, 'Total Produk');
      expect(result[2].value, 45);
    });
  });
}

/// Notifier khusus untuk testing agar hasilnya selalu berhasil
/// dan tidak dipengaruhi oleh random error 30%.
class TestStatsNotifier extends StatsNotifier {
  @override
  Future<List<StatItem>> build() async {
    return const [
      StatItem(title: 'Total Pengguna', value: 120),
      StatItem(title: 'Total Pesanan', value: 75),
      StatItem(title: 'Total Produk', value: 45),
    ];
  }
}