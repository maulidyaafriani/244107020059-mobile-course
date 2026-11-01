import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/domain/use_cases/filter_notes_by_title.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/providers/notes_provider.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository(this.notes, {this.throwOnFetch = false})
    : super(openDb: () => throw UnimplementedError());

  final List<Note> notes;
  final bool throwOnFetch;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwOnFetch) throw Exception('fetch failed');
    return notes;
  }

  @override
  Future<int> countDirty() async => notes.where((note) => note.dirty).length;
}

void main() {
  final notes = [
    Note(title: 'Belanja Bulanan', updatedAt: DateTime(2026, 1, 2)),
    Note(title: 'Jadwal Kuliah', updatedAt: DateTime(2026, 1, 1)),
    Note(title: 'Daftar Belanja', updatedAt: DateTime(2025, 12, 31)),
  ];

  test('pencarian judul mengabaikan huruf besar dan kecil', () {
    final result = filterNotesByTitle(
      notes,
      'BELANJA',
      titleOf: (note) => note.title,
    );

    expect(result.map((note) => note.title), [
      'Belanja Bulanan',
      'Daftar Belanja',
    ]);
  });

  test('query kosong mengembalikan semua catatan sesuai urutan', () {
    expect(
      filterNotesByTitle(
        notes,
        '',
        titleOf: (note) => note.title,
      ).map((note) => note.title),
      ['Belanja Bulanan', 'Jadwal Kuliah', 'Daftar Belanja'],
    );
  });

  test('query yang tidak cocok menghasilkan daftar kosong', () {
    expect(
      filterNotesByTitle(notes, 'zzz-tak-ada', titleOf: (note) => note.title),
      isEmpty,
    );
  });

  test('whitespace query dianggap kosong', () {
    expect(
      filterNotesByTitle(notes, '   ', titleOf: (note) => note.title),
      hasLength(notes.length),
    );
  });

  testWidgets('empty state membedakan daftar kosong dan hasil pencarian', (
    tester,
  ) async {
    await tester.pumpWidget(_notesApp(const []));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada catatan'), findsOneWidget);
    expect(find.byKey(const ValueKey('notes-search-field')), findsNothing);

    await tester.pumpWidget(_notesApp(notes));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('notes-search-field')),
      'tidak ada',
    );
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear-note-search')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('notes-search-field')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.text('Belanja Bulanan'), findsOneWidget);
    expect(find.text('Jadwal Kuliah'), findsOneWidget);
    expect(find.text('Daftar Belanja'), findsOneWidget);
  });

  testWidgets('fetch error tetap ditampilkan', (tester) async {
    await tester.pumpWidget(_notesApp(const [], throwOnFetch: true));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat: Exception: fetch failed'), findsOneWidget);
  });
}

Widget _notesApp(List<Note> notes, {bool throwOnFetch = false}) {
  return ProviderScope(
    overrides: [
      noteRepositoryProvider.overrideWithValue(
        FakeNoteRepository(notes, throwOnFetch: throwOnFetch),
      ),
    ],
    child: const MaterialApp(home: NotesPage()),
  );
}
