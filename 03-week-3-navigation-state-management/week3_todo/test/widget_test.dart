import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_todo/stats_page.dart';

void main() {
  testWidgets(
    'StatsPage dapat ditampilkan',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StatsPage(),
          ),
        ),
      );

      // Menunggu proses async selama 2 detik.
      await tester.pump(
        const Duration(seconds: 2),
      );

      // Statistics muncul 2 kali:
      // 1. Judul AppBar
      // 2. Label NavigationBar
      expect(
        find.text('Statistics'),
        findsNWidgets(2),
      );
    },
  );
}