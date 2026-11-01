# Week 9 — AI-Assisted Development

## Fitur

Pencarian lokal judul catatan yang tidak membedakan kapitalisasi, tombol
clear, serta empty state berbeda untuk daftar kosong dan hasil pencarian
kosong. Domain filter murni berada di
[`week5_offline_notes/lib/domain/use_cases/filter_notes_by_title.dart`](../week5_offline_notes/lib/domain/use_cases/filter_notes_by_title.dart);
implementasi UI dan state berada di project tersebut.

## Prompt dan keputusan AI

- Prompt, konteks, output awal, debug, dan verifikasi:
  [`week5_offline_notes/docs/ai-log.md`](../week5_offline_notes/docs/ai-log.md)
- Prompt review, temuan, keputusan terima/tolak:
  [`week5_offline_notes/docs/ai-review-vs-keputusan.md`](../week5_offline_notes/docs/ai-review-vs-keputusan.md)
- Ringkasan dokumentasi submission: [`docs/`](docs/)

## Stack

Flutter/Dart, Riverpod, sqflite (native), SharedPreferences (web). Search
memfilter daftar yang sudah dimuat; database, repository, dan sync tidak
diubah.

## Cara menjalankan dan hasil verifikasi

Dari folder `week5_offline_notes/`:

```powershell
flutter pub get
dart format --set-exit-if-changed lib/domain/use_cases/filter_notes_by_title.dart lib/pages/notes_page.dart lib/providers/notes_provider.dart test/search_filter_test.dart
flutter analyze
flutter test
flutter run -d chrome
```

Hasil terakhir: `flutter analyze` bersih, 10/10 tes lulus, dan formatter pada
file terkait bersih. Tes mencakup query `BELANJA`, query kosong/whitespace,
hasil tak cocok, daftar awal kosong, empty state pencarian, clear, dan fetch
error. Screenshot hasil query perlu ditangkap dan disimpan manual di
[`screenshots/`](screenshots/); sesi browser lama tidak merespons input saat
upaya screenshot.
