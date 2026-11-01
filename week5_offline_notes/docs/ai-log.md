# Week 9 — Prompt dan context engineering

## Status

Praktikum 1 selesai: prompt inti dan konteks proyek sudah disiapkan.
Praktikum 2 selesai: fitur pencarian judul sudah dibuat, diuji otomatis, dan
di-smoke-test pada aplikasi web di browser.

## Lima slot prompt

- **Peran:** senior Flutter developer yang memahami Riverpod dan repository
  pattern.
- **Konteks:** aplikasi catatan offline, Riverpod 2.6.1, model `Note`, daftar
  dimuat melalui `notesProvider`; penyimpanan native memakai sqflite dan web
  memakai SharedPreferences.
- **Tugas:** pencarian judul tanpa membedakan kapitalisasi, termasuk empty
  state untuk hasil pencarian yang kosong.
- **Batas:** perubahan kecil, jangan mengubah skema/database, proses sync,
  repository, dependensi, atau arsitektur yang ada; jangan menaruh query
  SQLite di widget; jangan mencari isi body.
- **Output:** implementasi, sekurangnya tiga kasus tes, dan cara menjalankan
  verifikasi.

## Konteks proyek yang diberikan

Struktur terkait:

```text
lib/
  data/
    local/note.dart
    repositories/note_repository.dart
    repositories/note_repository_native.dart
    repositories/note_repository_web.dart
  pages/notes_page.dart
  providers/notes_provider.dart
test/note_test.dart
```

Versi dependency dari `pubspec.yaml`:

```text
flutter_riverpod: ^2.6.1
sqflite: ^2.4.4
sqflite_common_ffi: ^2.3.4+2
shared_preferences: ^2.5.5
path: ^1.9.1
```

Model yang harus tetap kompatibel:

```dart
class Note {
  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
```

Provider saat ini memuat daftar dan melakukan perubahan lewat repository:

```dart
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();
}
```

Kontrak repository yang sudah dipakai UI/provider:

```dart
Future<List<Note>> fetchNotes();
Future<Note> addNote({required String title, String body = ''});
Future<void> deleteNote(int id);
```

Repository dipilih secara conditional export untuk native dan web. `NotesPage`
menampilkan `notesProvider` dalam state loading/data/error, dengan teks
`Belum ada catatan` ketika koleksi benar-benar kosong. Ini proyek sederhana
dengan provider/repository, bukan feature-first Clean Architecture penuh;
jangan mengklaim struktur yang tidak ada.

## Prompt mentah

```text
Peran: Bertindak sebagai senior Flutter developer yang teliti pada Riverpod,
repository pattern, aksesibilitas, dan testing.

Konteks: Tambahkan fitur kecil di project week5_offline_notes yang sudah ada.
Gunakan struktur berikut:
- UI: lib/pages/notes_page.dart
- state: lib/providers/notes_provider.dart
- model: lib/data/local/note.dart (id, title, body, updatedAt, dirty)
- repository: lib/data/repositories/note_repository.dart, dengan implementasi
  native sqflite dan web SharedPreferences melalui conditional export.
Dependency relevan: flutter_riverpod ^2.6.1, sqflite ^2.4.4,
sqflite_common_ffi ^2.3.4+2, shared_preferences ^2.5.5, path ^1.9.1.
Daftar catatan saat ini tersedia melalui notesProvider sebagai
AsyncValue<List<Note>>. Pertahankan urutan hasil fetchNotes.

Tugas: Tambahkan pencarian lokal berdasarkan judul catatan. Pencarian tidak
case-sensitive dan query yang dikosongkan kembali menampilkan seluruh daftar.
Bedakan empty state daftar yang memang kosong ("Belum ada catatan") dengan
empty state hasil pencarian ("Tidak ada catatan yang cocok"). Sediakan kontrol
untuk menghapus query.

Batasan:
- Jangan akses SQLite/SharedPreferences langsung dari widget.
- Jangan mengubah repository, skema, model, logika sync, platform behavior,
  atau dependency; filter daftar yang sudah dimuat saja.
- Jangan mencari di body.
- Pertahankan loading/error state yang ada dan jangan menyembunyikan error
  fetch.
- Jaga perubahan kode produksi tetap kecil (maksimal sekitar 80 baris) dan
  ikuti gaya formatter proyek.
- Jangan menambahkan package baru atau mengarang API.
- Jangan menyertakan credential, token, API key, atau data pribadi.

Output:
1. Tunjukkan file yang perlu diubah dan patch yang ringkas.
2. Berikan minimal tiga kasus tes: pencarian tidak sensitif kapitalisasi,
   query kosong menampilkan semua catatan, dan tidak ada hasil menampilkan
   empty state pencarian. Sertakan kasus daftar awal kosong bila sesuai.
3. Jelaskan cara menjalankan dart format, flutter analyze, flutter test, dan
   tes manual singkat.
4. Sebelum menulis kode, sebutkan asumsi atau API yang perlu diverifikasi.
```

## Hasil tahap

| Tahap | Hasil |
|---|---|
| Prompt 5 slot | Selesai |
| Konteks kode relevan dan versi package | Selesai |
| Pemeriksaan secret | Tidak menempel token, API key, password, atau konfigurasi Firebase |
| Output awal AI | Draf awal di bawah; cacat case-sensitive dan whitespace ditemukan lewat tes |
| Implementasi dan tes search | Selesai; 4 tes filter dan 2 tes UI ditambahkan |
| Smoke test web | Lulus: query `BELANJA` menampilkan empty state; `OKE` menemukan judul `oke baik`; tombol clear dan query whitespace mengembalikan daftar |

## Output awal AI

Implementasi awal yang dihasilkan mengikuti repository/state yang sudah ada,
tanpa mengubah repository atau skema:

```dart
List<Note> filterNotesByTitle(List<Note> notes, String query) {
  if (query.isEmpty) return notes;
  return notes.where((note) => note.title.contains(query)).toList();
}
```

UI menambahkan field pencarian hanya saat daftar memuat catatan, memfilter
daftar yang sudah dimuat, mempertahankan urutan hasil, dan membedakan teks
empty state daftar awal dari empty state hasil pencarian. Query dapat dihapus
melalui tombol clear.

## Verifikasi, bug, dan keputusan

Tes awal gagal sebelum perbaikan:

- `BELANJA` tidak menemukan `Belanja Bulanan` dan `Daftar Belanja`, karena
  `String.contains` pada draf awal case-sensitive.
- Query `'   '` menghasilkan daftar kosong, bukan menganggap input hanya
  whitespace sebagai query kosong.

Filter diperbaiki dengan `trim().toLowerCase()` pada query dan
`toLowerCase()` pada judul. Repository, database, model, sync, dan dependencies
tidak diubah. Hasil dibuktikan oleh tes pencarian case-insensitive, query
kosong, query tak cocok, dan whitespace; widget test membuktikan empty state
awal, empty state pencarian, menghapus query untuk memulihkan daftar, dan
mempertahankan pesan error fetch.

## Praktikum 3 — Debug dan refactor

Langkah reproduksi bug draf: jalankan tes case-insensitive dengan query
`BELANJA` terhadap judul `Belanja Bulanan`, lalu jalankan tes whitespace
dengan query `'   '`. Keduanya gagal pada draf awal karena memakai
`contains` langsung dan hanya memeriksa `query.isEmpty`. Perbaikannya
diverifikasi oleh tes regresi yang sama setelah normalisasi query dan judul.

Aturan pencarian dipindahkan ke fungsi murni di
`lib/domain/use_cases/filter_notes_by_title.dart`. Fungsi menerima pemilih
judul agar layer domain tidak mengimpor Flutter, Riverpod, ataupun model data
yang juga menangani serialisasi. Widget hanya meneruskan daftar, query, dan
judul; provider tetap mengelola state serta repository. Tidak ada akses
database dari widget, dan jalur loading/error daftar tetap dipertahankan.

Verifikasi setelah refactor: `flutter analyze` lulus tanpa temuan dan
`flutter test` lulus dengan 10 tes. `dart format --set-exit-if-changed` lulus
untuk seluruh file Dart yang diubah. Pemeriksaan format ke seluruh project
menemukan 15 file lama lain yang belum terformat; file-file itu tidak diubah
agar PR pencarian tetap fokus. Hot restart pada app web yang sedang berjalan
gagal di Chrome DevTools, tetapi hot reload berhasil.

## Perintah verifikasi

Jalankan dari folder `week5_offline_notes/`:

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Hasil terakhir:

- `flutter analyze`: bersih.
- `flutter test`: 10 tes lulus.
- `dart format --set-exit-if-changed` pada file fitur/tes: bersih.
- Smoke test manual dilakukan pada Chrome web dengan data sementara `oke baik`.
- Hot restart melalui DTD gagal pada Chrome DevTools; aplikasi kemudian
  dijalankan ulang, smoke test dilakukan, dan hot reload berikutnya berhasil.
