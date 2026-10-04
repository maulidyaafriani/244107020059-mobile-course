import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/main.dart';
import 'package:campus_notify/providers/auth_provider.dart';

class _MemoryTokenStore extends TokenStore {
  @override
  Future<String?> readAccess() async => null;
}

void main() {
  testWidgets('unauthenticated users are redirected to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(_MemoryTokenStore())],
        child: const CampusNotifyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
