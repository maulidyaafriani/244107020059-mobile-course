# AI review vs keputusan final

## Konteks review

Perubahan yang direview adalah branch `feat/auth-validation` dibandingkan
dengan `develop`: use case validasi email/password, wiring validator pada form
login, dan unit test-nya. Review berfokus pada kebenaran, arsitektur, dan test;
masalah style ditangani formatter.

## Prompt

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Output awal review AI

1. **Saran — domain email yang cacat tetap lolos.** Regex hanya mensyaratkan
   karakter di kedua sisi titik terakhir; `user@example..com` cocok walaupun
   memiliki label domain kosong. Pertimbangkan memvalidasi setiap label domain
   dan menolak label yang diawali/diakhiri tanda hubung:

   ```dart
   final emailPattern = RegExp(
     r'^[^\s@]+@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+'
     r'[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$',
   );
   ```

2. **Saran — tes password pendek terlalu longgar.** `isNotNull` tetap lulus
   jika validator mengembalikan pesan yang salah. Periksa pesan yang diwajibkan:

   ```dart
   expect(
     validate.password('12345'),
     'Password minimal ${ValidateLoginInput.minPasswordLength} karakter',
   );
   ```

3. **Saran — kasus password `null` belum dites.** Implementasi menerima input
   nullable, tetapi tes hanya menguji string kosong. Tambahkan:

   ```dart
   expect(validate.password(null), 'Password tidak boleh kosong');
   ```

4. **Saran — password whitespace-only diterima.** Enam spasi memenuhi panjang
   minimum; AI menyarankan memangkas input sebelum validasi:

   ```dart
   final v = value?.trim() ?? '';
   ```

5. **Saran — pesan presentasi berada di domain.** Validator mengembalikan
   kalimat bahasa Indonesia. Jika aplikasi mendukung lokalisasi, kembalikan
   kode hasil validasi dan petakan ke teks di presentation:

   ```dart
   enum LoginInputError { emailEmpty, emailInvalid, passwordEmpty, passwordShort }
   ```

## Verifikasi dan keputusan

| # | Temuan | Bukti verifikasi | Keputusan final |
|---|---|---|---|
| 1 | Regex menerima label domain email yang cacat | Tes regresi `user@example..com` gagal sebelum perbaikan: hasil aktual `null`, padahal diharapkan `Format email tidak valid`. Pola domain diperketat; kedua kasus domain cacat sekarang ditolak. Ini validasi sintaks dasar, bukan klaim implementasi parser email RFC lengkap. | **Diterima dan diperbaiki.** |
| 2 | Tes password pendek hanya memeriksa non-null | Sebelum perubahan, assertion hanya `isNotNull` dan tidak membuktikan pesan validasi benar. Assertion kini memeriksa pesan minimum enam karakter. | **Diterima dan diperbaiki.** |
| 3 | Password `null` belum memiliki tes | `password` menerima `String?` dan cabang `value ?? ''` menangani null. Tes null ditambahkan dan memastikan pesan yang tepat. | **Diterima; coverage ditambahkan.** |
| 4 | Password yang seluruhnya spasi dianggap kosong | Ini observasi atas perilaku, tetapi bukan bug yang dapat disimpulkan dari kontrak saat ini: password diperlakukan sebagai nilai mentah dan bisa saja mengandung spasi. Memangkas password sebelum autentikasi dapat mengubah kredensial yang dikirim ke server. Tidak ada persyaratan produk yang menyatakan whitespace tidak valid. | **Ditolak.** Jangan trim password tanpa aturan backend/produk; validasi panjang tetap memeriksa nilai asli. |
| 5 | Domain mengembalikan kalimat UI dan AI menyarankan enum error | Temuan ini merupakan pertimbangan lokalisasi, bukan kegagalan perilaku atau pelanggaran arah dependensi (domain tidak mengimpor Flutter/Dio). Aplikasi belum memiliki persyaratan multi-bahasa; enum dan pemetaan tambahan menambah abstraksi untuk form kecil. | **Ditolak untuk scope ini.** Evaluasi ulang bila lokalisasi atau penggunaan lintas UI diperlukan. |

## Perubahan yang diterapkan

- Pola validasi email sekarang menolak label domain kosong atau yang dimulai/
  diakhiri tanda hubung.
- Tes password pendek memeriksa pesan spesifik, bukan sekadar hasil non-null.
- Tes input password null memastikan pesan kosong yang tepat.
- Tes email valid yang sudah ada tetap memastikan `user@mail.com` diterima.

## Bukti verifikasi

Tes regresi email yang ditambahkan dijalankan **sebelum** perbaikan dan gagal
dengan `Expected: 'Format email tidak valid'; Actual: <null>`. Setelah
perbaikan, perintah berikut berhasil dijalankan dari
`06-week-6-authentication/`:

```powershell
flutter test test\validate_login_input_test.dart
flutter analyze
dart format --set-exit-if-changed lib test
flutter test
```

Hasil akhir: format check pada `lib test` bersih (27 file), `flutter analyze`
tanpa temuan, dan seluruh 19 tes lulus. Format command dibatasi ke sumber Dart
karena pemindaian `.` di workspace lokal dapat menemui path generated yang
sudah tidak ada di dalam `build/`.
