import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import 'connectivity_provider.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> add(String title, {String body = ''}) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(title: title, body: body);
    state = await AsyncValue.guard(repo.fetchNotes);
  }

  Future<void> remove(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    state = await AsyncValue.guard(repo.fetchNotes);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
        () => ref.read(noteRepositoryProvider).fetchNotes());
  }
}

/// Jumlah catatan yang belum tersinkron -- dipakai untuk badge di AppBar.
/// Ikut watch notesProvider supaya rebuild tiap kali daftar catatan berubah
/// (tambah/hapus/sync).
final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

/// State: jumlah catatan yang barusan berhasil disinkronkan (0 = idle/tidak
/// ada yang perlu disync). AsyncLoading = sedang proses sync.
final syncStatusProvider =
    AsyncNotifierProvider<SyncNotifier, int>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async => 0;

  Future<void> syncNow() async {
    if (ref.read(forceOfflineProvider)) {
      state = AsyncError('Sedang offline (simulasi)', StackTrace.current);
      return;
    }
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _syncNotes(repo));
    ref.invalidate(dirtyCountProvider);
    ref.invalidate(notesProvider);
  }

  /// Simulasi upload catatan dirty ke server.
  ///
  /// Aturan konflik (dokumentasikan ini di laporan): LAST-WRITE-WINS
  /// berdasarkan `updated_at`. Artinya versi dengan `updated_at` paling baru
  /// -- lokal atau server -- yang menang dan menimpa versi lain. Pada
  /// project nyata, kirim `updated_at` lokal bersama tiap catatan; jika
  /// server punya versi lebih baru untuk id yang sama, ambil versi server,
  /// bukan menimpa membabi buta.
  Future<int> _syncNotes(NoteRepository repo) async {
    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;
    // Simulasi upload: pada project nyata, kirim tiap catatan dirty
    // ke REST API di sini, lalu tandai bersih hanya bila server
    // menjawab 2xx.
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();
    return dirtyCount;
  }
}