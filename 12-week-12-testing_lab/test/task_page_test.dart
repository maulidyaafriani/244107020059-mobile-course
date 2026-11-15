import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/main.dart';

Widget buildApp() => const MaterialApp(home: TaskPage());

void main() {
  testWidgets('menampilkan keadaan kosong di awal', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Daftar tugas'), findsOneWidget);
    expect(find.text('Belum ada tugas'), findsOneWidget);
  });

  testWidgets('menambahkan tugas ke daftar', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Baca materi',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Baca materi'), findsOneWidget);
    expect(find.text('Belum ada tugas'), findsNothing);
  });

  testWidgets('menampilkan error jika judul kosong', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      '   ',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
    expect(find.text('Belum ada tugas'), findsOneWidget);
  });
}
