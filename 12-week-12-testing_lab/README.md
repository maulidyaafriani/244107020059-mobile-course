# Praktikum Pengujian Fitur Tugas

Project Flutter ini menyediakan form sederhana untuk menambahkan tugas. Test
mencakup validasi judul, service/repository, tampilan form, dan alur integrasi.

## Skenario pengujian

| Jenis | Skenario | Hasil yang diperiksa |
|---|---|---|
| Unit | Judul berisi teks, kosong, atau hanya spasi | Judul valid diterima; judul kosong/spasi ditolak |
| Unit | Repository memberi data, daftar kosong, atau error | Data diteruskan, daftar kosong tetap kosong, dan error diteruskan |
| Widget | Halaman dibuka pertama kali | Judul halaman dan keadaan kosong terlihat |
| Widget | Pengguna menyimpan judul tugas | Tugas tampil di daftar dan keadaan kosong hilang |
| Widget | Pengguna menyimpan judul kosong/spasi | Pesan validasi terlihat dan daftar tetap kosong |
| Integrasi | Pengguna menambahkan tugas melalui aplikasi | Tugas yang disimpan tampil di layar |

## Hasil pengujian dan analisis

- `flutter test --coverage` — berhasil; **8 test lulus** (`All tests passed!`).
- `flutter analyze` — berhasil; **No issues found!**
- Coverage unit dan widget (`coverage/lcov.info`):
  - `lib/task_repository.dart`: 3 dari 3 baris executable (100%).
  - `lib/is_valid_task_title.dart`: 2 dari 2 baris executable (100%).
  - `lib/main.dart`: 32 dari 34 baris executable (94,1%).
  - Total: 37 dari 39 baris executable (94,9%).

Coverage menunjukkan baris yang dijalankan, bukan jaminan semua perilaku
teruji. Baris yang belum tercakup di `main.dart` terkait entry point aplikasi;
alur halaman dan validasi form sudah diuji oleh widget test.

## Integration test dan kendala

Integration test tersedia di `integration_test/app_test.dart`. Perangkat yang
terdeteksi dengan `flutter devices` adalah Windows, Chrome, dan Edge; tidak ada
emulator atau perangkat Android.

Perintah yang dicoba:

```shell
flutter test integration_test/app_test.dart -d windows
```

Test belum dapat dijalankan karena Flutter tidak menemukan toolchain Visual
Studio yang dibutuhkan untuk membangun aplikasi Windows. Chrome tidak dicoba
karena perintah tersebut memerlukan setup ChromeDriver untuk integration test.
Temuan yang belum terselesaikan adalah menjalankan integration test pada
perangkat yang didukung setelah toolchain Visual Studio Desktop dengan C++
tersedia, atau setelah emulator/perangkat Android tersambung.

## Refleksi

- Tanpa test, bug yang mungkin terlewat antara lain judul yang hanya berisi
  spasi dianggap valid, tugas tidak muncul setelah disimpan, atau error dari
  repository tertelan dan terlihat seperti daftar kosong.
- Fake repository memungkinkan test memberikan data, daftar kosong, dan error
  secara langsung tanpa jaringan atau penyimpanan eksternal. Hasilnya konsisten
  dan error bisa diuji tanpa bergantung pada layanan lain.
- Widget test memeriksa tampilan serta interaksi form dalam lingkungan
  terisolasi. Integration test memeriksa alur utama melalui aplikasi yang
  berjalan, sehingga dapat menemukan masalah pada gabungan komponen yang tidak
  terlihat dari widget test saja.
