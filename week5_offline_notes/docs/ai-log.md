# Week 9 — Prompt dan context engineering

## Status

Praktikum 1 selesai: prompt inti dan konteks proyek sudah disiapkan untuk
fitur pencarian judul catatan. Implementasi fitur, output awal AI, verifikasi,
dan hasil tes dicatat setelah tahap generate dan review berikutnya; tidak ada
hasil yang diklaim sebelum dijalankan.

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
| Output awal AI | Menunggu tahap generate (Praktikum 2) |
| Implementasi dan tes search | Belum dikerjakan pada Praktikum 1 |
