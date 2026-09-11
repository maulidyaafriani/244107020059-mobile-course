# Week 3 - Navigation & State Management

## Mini Project

Pada minggu ini saya membuat aplikasi ToDo menggunakan Flutter dengan
GoRouter dan Riverpod sebagai state management.

### Fitur Aplikasi

- Menambahkan tugas.
- Menandai tugas sebagai selesai.
- Menghapus tugas.
- Filter tugas yang belum selesai.
- Navigasi halaman menggunakan GoRouter.
- Halaman Statistics.
- NavigationBar untuk berpindah halaman.
- Simulasi data asynchronous menggunakan AsyncNotifier.
- Menampilkan kondisi loading, error, dan success.
- Widget test.

### Halaman Aplikasi

Aplikasi memiliki dua halaman utama:

- `/` untuk halaman ToDo.
- `/stats` untuk halaman Statistics.

### Teknologi yang Digunakan

- Flutter
- Dart
- Riverpod
- flutter_riverpod
- GoRouter
- Flutter Test

### State Management

State daftar Todo dikelola menggunakan Riverpod dengan `Notifier`.

Data statistik menggunakan `AsyncNotifier` dan `AsyncValue` untuk menangani
proses asynchronous dengan kondisi loading, error, dan success.

### Cara Menjalankan

Jalankan perintah:

```bash
flutter pub get
flutter run -d chrome

Untuk mengecek kode:

flutter analyze

Untuk menjalankan test:

flutter test
Hasil Pengujian

Hasil flutter analyze:

No issues found!

Hasil flutter test:

All tests passed!


Refleksi
1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?

setState masih cukup digunakan ketika state hanya digunakan pada satu
widget atau satu halaman. Contohnya untuk perubahan tampilan yang sederhana.

Riverpod lebih cocok digunakan ketika state digunakan oleh beberapa widget
atau halaman dan membutuhkan pengelolaan state yang lebih terstruktur.

Pada project ini Riverpod digunakan untuk mengelola daftar Todo dan data
statistik.

2. Apa perbedaan context.go dan context.push?

context.go() digunakan untuk berpindah ke route tertentu.

Sedangkan context.push() digunakan untuk menambahkan halaman baru ke
navigation stack.

Pada project ini context.go() digunakan untuk berpindah antara halaman
Todo dan Statistics.

3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

AsyncValue menggabungkan kondisi asynchronous seperti loading, error, dan
success dalam satu state.

Hal ini lebih aman dibanding menggunakan beberapa boolean terpisah karena
dapat mengurangi kemungkinan kondisi state yang tidak konsisten.

Pada project ini AsyncValue digunakan untuk menangani proses pengambilan
data statistik.

4. Bagian mana dari hasil AI yang diperbaiki dan mengapa?

AI digunakan sebagai bantuan dalam membuat kode awal untuk halaman
Statistics, AsyncNotifier, handling loading/error/success, dan widget test.

Hasil dari AI kemudian diperiksa menggunakan flutter analyze dan
flutter test.

Beberapa bagian diperbaiki agar sesuai dengan struktur project, termasuk
widget test yang disesuaikan setelah NavigationBar ditambahkan.

Widget Todo juga dipisahkan menjadi TodoTile agar kode menjadi lebih
terstruktur dan mudah diuji.

Setelah dilakukan perbaikan, hasil verifikasi menunjukkan:

flutter analyze
No issues found!

flutter test
All tests passed!
Dokumentasi

Dokumentasi AI Challenge disimpan pada folder:

docs/tugas/AI-challege.md

Screenshot hasil aplikasi dan pengujian disimpan pada folder: tugas itu semua ada ss an nya  