# Week 9 — AI Challenge: review search

## Prompt

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Konteks tambahan yang diberikan: implementasi pencarian ada di
`lib/pages/notes_page.dart`, aturan filter murni di
`lib/domain/use_cases/filter_notes_by_title.dart`, dan tes di
`test/search_filter_test.dart`. Repository memuat daftar secara asinkron; fitur
ini hanya mencari judul dari daftar yang sudah dimuat, bukan melakukan query
database atau mencari isi catatan.

## Output review AI

1. **Blocker — draf awal pencarian peka kapitalisasi.** Implementasi awal
   memakai `note.title.contains(query)`, sehingga query `BELANJA` tidak cocok
   dengan judul `Belanja Bulanan`. Draf itu juga tidak memperlakukan query
   whitespace sebagai kosong. Ini temuan pada draf awal, bukan bug pada versi
   final.
2. **Saran — tampilkan kolom search walaupun daftar awal kosong.** Dengan
   begitu, field tetap terlihat sebelum pengguna menambahkan catatan.
3. **Saran — buat use case menerima `Note` langsung, bukan callback
   `titleOf`.** Tipe konkret dapat membuat signature lebih eksplisit dan
   lebih mudah dipahami oleh pemanggil.

## Usulan AI vs keputusan final

| Temuan | Keputusan | Bukti dan alasan teknis |
|---|---|---|
| Draf awal gagal mencari tanpa membedakan kapitalisasi dan query whitespace tidak dinormalisasi. | **Terima, sudah diperbaiki.** | Draf memakai `contains` langsung. Tes dengan `BELANJA` terhadap `Belanja Bulanan` dan tes whitespace membuktikan perilaku yang salah; implementasi final menormalisasi query dan judul memakai `trim().toLowerCase()`. |
| Search harus selalu terlihat ketika daftar belum berisi catatan. | **Tolak.** | Belum ada judul yang dapat dicari ketika daftar kosong. Empty state `Belum ada catatan` dan tombol tambah tetap menjelaskan tindakan yang tersedia; search tampil setelah ada data. Ini keputusan UX sesuai lingkup fitur, bukan kegagalan pencarian. |
| Use case harus bergantung langsung pada model `Note`. | **Tolak; pertahankan versi generik.** | Model `Note` berada di `data/local` dan sekaligus memiliki serialisasi. Mengimpor model data ke domain membalik arah dependency. `titleOf` mempertahankan fungsi murni tanpa dependency Flutter, Riverpod, repository, atau model data. Widget meneruskan `note.title`. |

## Keputusan per file

| File | Keputusan | Alasan |
|---|---|---|
| `lib/domain/use_cases/filter_notes_by_title.dart` | Terima + refactor | Menjaga aturan pencarian terisolasi dan pure; API generik mencegah domain bergantung pada model data. |
| `lib/pages/notes_page.dart` | Terima | Hanya menghubungkan query dan UI; empty state pencarian dibedakan dari daftar kosong dan jalur loading/error dipertahankan. |
| `lib/providers/notes_provider.dart` | Terima | Provider tetap mengelola state/repository; filter UI tidak dicampur ke operasi penyimpanan atau sync. |
| `test/search_filter_test.dart` | Terima | Menguji kapitalisasi, query kosong, query tak cocok, whitespace, empty state awal dan hasil search, tombol clear, dan fetch error. |

## Bukti verifikasi

Perintah yang dijalankan dari folder `week5_offline_notes/`:

```powershell
flutter test test\search_filter_test.dart
flutter analyze
```

Hasil terbaru: seluruh 6 tes pencarian lulus dan `flutter analyze` melaporkan
`No issues found!`. Regresi draf awal tercatat di
[`ai-log.md`](./ai-log.md); pengujian setelah perbaikan mengonfirmasi kasus
kapitalisasi dan whitespace lulus.
