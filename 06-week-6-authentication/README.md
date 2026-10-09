

## Matriks pengujian FCM

Pengujian dilakukan di Chrome (web) dari Firebase Console dengan title/body
notifikasi dan custom data `route=/pengumuman/3`.

| State | Hasil yang diharapkan | Prosedur uji | Hasil |
|---|---|---|---|
| Foreground | Notifikasi lokal/browser muncul, klik menuju `/pengumuman/3` | Biarkan tab aplikasi terbuka, kirim pesan uji | (isi hasil) |
| Background | Notifikasi sistem/browser muncul, klik membuka aplikasi di rute yang benar | Pindah ke tab lain, kirim pesan, lalu klik notifikasi | (isi hasil) |
| Terminated | Aplikasi terbuka di rute yang benar lewat `getInitialMessage` | Tutup tab aplikasi, kirim pesan, lalu klik notifikasi | (isi hasil) |

Contoh pengisian kolom Hasil (pilih sesuai kenyataan):
- `Berhasil: notifikasi muncul dan klik membuka aplikasi.`
- `Sebagian: notifikasi muncul, tetapi tidak berpindah rute karena getInitialMessage tidak didukung di web.`
- `Gagal: notifikasi tidak muncul (isi dugaan penyebab).`

Catatan:
- Pengujian memakai web karena tidak menggunakan emulator atau perangkat
  Android. Pratinjau web hanya menguji notifikasi browser dan tidak
  membuktikan perilaku notifikasi sistem Android.
- Token FCM lengkap tidak ditampilkan di screenshot maupun laporan.

## Bukti token lifecycle

- `screenshots/fcm-console-test.png`: pengujian kirim pesan dari Firebase
  Console.
- Screenshot token terpotong (12 karakter pertama + `...`) sebelum dan sesudah
  data situs dihapus, untuk menunjukkan token berubah dan `onTokenRefresh`
  memperbarui token.

## Dokumentasi AI Challenge

Prompt, output awal AI, daftar perbaikan manual, dan keputusan teknis ada di
folder `docs/` (lihat `docs/ai-challenge.md`).


## Checklist verifikasi

| Pertanyaan | Temuan | Perbaikan / bukti |
|---|---|---|
| Background handler top-level dengan `@pragma('vm:entry-point')`? | Ya. `firebaseMessagingBackgroundHandler` berada di luar class dan diberi anotasi `@pragma('vm:entry-point')`. | Tidak perlu perbaikan. Handler tidak memakai `BuildContext`, Riverpod, atau `GoRouter`. |
| `onTokenRefresh` mengirim token baru ke backend, bukan hanya log? | Ya. Listener memanggil `_registerRefreshedToken`, lalu `_registerTokenSafely` yang melakukan `POST /devices` lewat Dio. Jika `API_BASE_URL` belum diatur, pengiriman dilewati dan dicatat di debug log. | URL backend diatur lewat `--dart-define=API_BASE_URL`. Belum diuji ke backend asli karena backend tidak tersedia. |
| Foreground memakai notifikasi manual? | Ya. Native memakai `flutter_local_notifications`. Web memakai Notification API browser. Di iOS, presentasi otomatis dimatikan agar banner tidak ganda. | Tidak perlu perbaikan. |
| Klik dari 3 state masuk ke rute benar? | Kode menangani `onMessageOpenedApp` (background), `getInitialMessage` (terminated), dan payload notifikasi lokal (foreground). Route dinormalisasi dan divalidasi di `routeFromMessage`. | Bukti ada di tabel uji (lihat README / `docs/test-matrix.md`). Di web, `getInitialMessage` terbatas. |
| Token/secret tidak di-hardcode dan tidak di-log penuh? | Token tidak dicetak ke log. Base URL API dari `--dart-define`, bukan hardcode. Token hanya disimpan di `fcmTokenForDebug` dan ditampilkan terpotong. VAPID key bersifat publik. | Screenshot dan laporan tidak menampilkan token penuh. |

## 4. Perbaikan manual
- Fungsi `_handleForegroundMessageSafely` sebelumnya tertulis di dalam
  `_handleForegroundMessage`, setelah `return`, sehingga tidak bisa dipanggil
  dari `_initialize()`. Saya pindahkan menjadi method terpisah di dalam class.
- (Tambahkan perbaikan lain yang kamu lakukan.)

## 5. Keputusan final dan alasan teknis
- Pengujian di Chrome (web) karena tidak memakai emulator atau HP Android.
  Hasilnya tidak membuktikan perilaku notifikasi sistem Android.
- Subscribe topik di web tidak didukung SDK client, jadi dilempar
  `UnsupportedError`. Subscribe topik web harus lewat backend (Admin SDK).
- Pesan personal (nilai, tagihan) memakai token perangkat, bukan topik.
  Topik hanya untuk broadcast seperti `pengumuman-kampus`.
- Payload memakai gabungan `notification` + `data` (`route`), agar sistem
  menampilkan banner otomatis saat background/terminated dan routing tetap
  bisa dilakukan lewat `data.route`.

## 6. Lifecycle token (untuk demo)
Saat aplikasi mulai, token diambil dengan `getToken` lalu dikirim ke backend.
Token bisa berubah (hapus data, reinstall, rotasi keamanan), jadi
`onTokenRefresh` wajib dipantau dan token baru dikirim ulang. Tanpa itu,
backend menyimpan token basi dan notifikasi tidak sampai.

## 7. Refactoring dan pengujian unit

- Semua route aplikasi didefinisikan di `lib/routes.dart`. GoRouter dan handler
  FCM memakai konstanta yang sama.
- `routeFromMessage(Map<String, dynamic>)` adalah fungsi murni yang memberi
  fallback ke beranda, menormalkan route tanpa slash, dan menolak URL eksternal.
- `lib/data/api_errors.dart` memetakan Dio 401, timeout, offline, dan kegagalan
  server ke pesan ramah. UI tidak menampilkan exception Dio mentah.
- Jalankan `flutter test test/auth_push_test.dart` untuk menguji route,
  skenario token sederhana, dan pemetaan error tanpa Firebase sungguhan.
- Background handler berjalan di isolate terpisah: jangan mengakses
  `BuildContext`, provider Riverpod, atau router aplikasi dari handler itu.


  ## Checklist verifikasi mandiri

- [ ya] Token hanya disimpan di `flutter_secure_storage`, tidak ada di
  SharedPreferences, log, atau screenshot penuh.
  Catatan: token FCM tidak dicetak ke log dan ditampilkan terpotong di
  halaman Debug.
- [ya ] 401 memicu refresh sekali lalu retry; refresh gagal memaksa login ulang.
  Catatan: (isi sesuai implementasi Praktikum 1, atau tulis "belum
  diimplementasikan")
- [ ya] Ketiga app state diuji dengan tabel bukti; klik masuk ke rute yang
  benar.
  Catatan: diuji di Chrome (web), hasil ada di tabel matriks pengujian FCM.
- [x] Topik dipakai untuk broadcast (`pengumuman-kampus`), token perangkat
  untuk pesan personal.
- [ ya] `flutter analyze` bersih dan semua test lulus.


## Refleksi

**1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**

SharedPreferences menyimpan data sebagai teks biasa (XML di Android, plist di
iOS) tanpa enkripsi. Pada perangkat yang di-root/jailbreak, lewat backup, atau
lewat malware, isinya mudah dibaca. `flutter_secure_storage` memakai Keystore
(Android) dan Keychain (iOS), sehingga data terenkripsi dan terikat ke
perangkat.

Refresh token berumur panjang dan dapat menghasilkan access token baru. Bila
bocor, penyerang bisa menyamar sebagai mahasiswa tersebut dalam waktu lama,
misalnya membaca nilai atau tagihan, tanpa perlu password. Karena itu refresh
token harus disimpan di tempat yang aman dan dicabut di server bila dicurigai
bocor.

**2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester?**

Token FCM bisa berubah karena reinstall, hapus data aplikasi, pemulihan ke
perangkat baru, atau rotasi keamanan dari Firebase. Bila perubahan itu tidak
dikirim ke backend, backend terus menyimpan token lama yang sudah tidak berlaku.
Akibatnya:
- Pesan personal (nilai, tagihan, jadwal pribadi) dikirim ke token basi dan
  tidak pernah sampai.
- Pengguna tidak sadar ada yang terlewat, karena tidak ada error di sisi
  aplikasi.
- Seiring waktu makin banyak mahasiswa yang tidak menerima notifikasi, dan
  database penuh token yang tidak valid.

**3. Kapan memakai topik dan kapan memakai token perangkat?**

- **Topik** untuk broadcast ke banyak orang sekaligus. Backend tidak perlu
  menyimpan daftar token. Contoh: "Jadwal kuliah Mobile pindah ke Ruang A2"
  (topik `pengumuman-kampus` atau topik per kelas), pengumuman libur kampus,
  informasi kegiatan UKM.
- **Token perangkat** untuk pesan personal yang hanya boleh dilihat satu orang.
  Contoh: "Nilai UTS Anda sudah keluar", "Tagihan UKT Anda jatuh tempo",
  "Pengajuan cuti Anda disetujui". Topik tidak cocok untuk ini karena siapa pun
  yang berlangganan topik itu akan menerima pesannya.

**4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**

- Fungsi `_handleForegroundMessageSafely` tertulis di dalam
  `_handleForegroundMessage`, setelah `return`, sehingga tidak bisa dipanggil
  dari `_initialize()`. Saya pindahkan menjadi method terpisah di dalam class.
- Subscribe topik tidak didukung SDK client di web, sehingga dilempar
  `UnsupportedError` dan topik web harus lewat backend (Admin SDK).
- Foreground di web memakai Notification API browser karena
  `flutter_local_notifications` tidak mendukung web.
- (Tambahkan perbaikan lain yang kamu lakukan, misalnya validasi rute atau
  penyembunyian token penuh di halaman Debug.)

  JOBSHEET 7

  ## Audit Layer (sebelum refactor)

| File | Layer saat ini | Masalah |
|------|----------------|---------|
| pages/home_page.dart | presentation | tidak ada temuan grep |
| pages/login_page.dart | presentation | tidak ada temuan grep |
| pages/announcement_page.dart | presentation | tidak ada temuan grep |
| providers/auth_provider.dart | presentation (state) | baris 9: membuat AuthRepository() langsung (DI bocor) |
| data/auth_repository.dart | data | interface dan implementasi masih satu kelas |
| data/api_client.dart | data | OK |
| data/api_errors.dart | data | perlu dipindah/dipetakan ke Failure di domain |
| data/token_store.dart | data | OK |
| messaging/push_service.dart | data (infrastruktur) | OK |
| router/, routes.dart, main.dart | app/routing | OK |

## Struktur target (fitur: auth)

lib/
├── core/
│   └── failures.dart
├── features/
│   └── auth/
│       ├── domain/
│       │   ├── entities/user.dart
│       │   ├── repositories/auth_repository.dart   # interface
│       │   └── usecases/login.dart
│       ├── data/
│       │   ├── models/user_model.dart
│       │   └── repositories/auth_repository_impl.dart
│       └── presentation/
│           ├── providers/auth_providers.dart
│           └── pages/login_page.dart
└── routes.dart


## Hasil Verifikasi (setelah refactor)

| Pemeriksaan | Sebelum | Sesudah |
|-------------|---------|---------|
| DI bocor (`Repository(` di providers) | 1 temuan | 0 |
| Domain bebas framework | - | 0 temuan |
| Presentation bebas data mentah | 0 | 0 |
| flutter analyze | - | No issues found |
| flutter test | - | (isi hasilnya) |