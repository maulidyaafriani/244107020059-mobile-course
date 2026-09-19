## Refleksi

### 1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
UI dilarang memanggil Dio langsung karena akan mencampur logika presentasi
dengan logika jaringan. Kalau dilanggar:
- Konfigurasi (base URL, timeout, header) jadi tersebar di banyak widget,
  sehingga sulit diubah secara konsisten (misalnya saat ganti environment
  dev/production).
- Widget jadi sulit di-unit-test karena tidak bisa di-mock tanpa jaringan
  sungguhan — di project ini, test provider dengan `FakePostRepository`
  hanya mungkin karena Dio disembunyikan di balik interface repository.
- Penanganan error jadi tidak konsisten, karena setiap widget bisa menangani
  DioException dengan cara berbeda-beda, alih-alih terpusat di satu fungsi
  seperti `friendlyErrorMessage`.
- Kode jadi lebih sulit di-refactor: mengganti Dio dengan http client lain
  akan menyentuh banyak file UI, bukan cuma satu file repository.

### 2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?
Pagination client-side cukup ketika seluruh dataset sudah kecil dan bisa
dimuat sekaligus ke memori (misalnya < 100-200 item), lalu ditampilkan
bertahap hanya untuk kebutuhan UX (mengurangi jumlah widget yang di-render
sekaligus). Pagination server-side (`_page`/`_limit`) wajib dipakai ketika:
- Dataset besar atau tidak diketahui ukurannya di awal.
- Data berasal dari sumber yang mahal untuk diambil sekaligus (bandwidth,
  waktu respons, biaya API).
- Data bisa berubah antar page (misal data real-time), sehingga memuat
  semuanya sekaligus berisiko data basi.
Di project ini, JSONPlaceholder /posts sebenarnya kecil (100 item), tapi
pagination server tetap dipakai untuk mensimulasikan pola yang akan
dipakai di API produksi sungguhan dengan data jauh lebih besar.

### 3. Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
Riverpod's `AsyncNotifier.build()` secara otomatis membungkus seluruh
eksekusi method `build()` dalam mekanisme try/catch internal. Jika
`repository.fetchPosts()` melempar exception (misalnya DioException karena
timeout), Riverpod menangkapnya dan mengubah state provider menjadi
`AsyncError` tanpa perlu try/catch manual di dalam `build()` maupun di
widget yang meng-`watch` provider tersebut — widget cukup menangani lewat
`.when(error: ...)`.
Try/catch eksplisit tetap dibutuhkan di method custom seperti `refresh()`
pada `PostListNotifier`, karena method ini dipanggil dari luar siklus
`build()` (misalnya dari `onPressed` tombol refresh) sehingga tidak
otomatis dibungkus oleh mekanisme Riverpod — exception di dalamnya harus
ditangkap manual dan diset ke `state = AsyncError(e, st)` supaya UI tetap
tahu ada error, bukan crash diam-diam.

### 4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
AI (dalam AI Prompt Challenge, fitur Comment) menghasilkan kode
`CommentNotifier` menggunakan `FamilyAsyncNotifier` dan
`AsyncNotifierProviderFamily`, yang merupakan API Riverpod versi 2.x.
Project ini memakai `flutter_riverpod: ^3.4.3` (Riverpod 3), di mana
kedua class tersebut sudah dihapus, sehingga muncul beberapa compile
error (`Type 'FamilyAsyncNotifier' not found`, dst).
Saya memperbaikinya dengan mengganti ke pola Riverpod 3 untuk notifier
dengan parameter: menggunakan `AsyncNotifierProvider.autoDispose.family`
dan menyimpan argumen (`postId`) lewat constructor + field pada class
notifier, bukan lewat `this.arg` seperti pola lama. Detail lengkap ada
di `docs/ai-prompt-comments.md`.