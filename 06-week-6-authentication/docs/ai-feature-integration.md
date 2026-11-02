# Praktikum Week 10 — Chat Interface dengan AI

## Fitur dan implementasi

- Home menautkan ke `/ai-chat`.
- `features/ai_chat/domain/chat_turn.dart` memodelkan percakapan tanpa
  ketergantungan Flutter.
- `features/ai_chat/data/gemini_chat_service.dart` memanggil Gemini REST
  `streamGenerateContent` dan memproses Server-Sent Events secara bertahap.
- Transport native menggunakan Dio; Flutter Web memakai Fetch
  `ReadableStream`, karena adapter Dio berbasis XHR menunggu respons selesai
  sebelum menyerahkan body.
- API key diminta dari pengguna dan disimpan/dihapus secara terpisah memakai
  `flutter_secure_storage`; `TokenStore.clear()` dan `deleteAll()` tidak
  dipakai.
- Provider Riverpod membuat Dio client; UI menampilkan loader, potongan
  jawaban streaming, dan pesan error yang ramah.
- Tombol gambar mendukung pemilihan galeri untuk OCR/deskripsi dan kamera
  untuk OCR. Gambar dikompresi oleh picker dan dibatasi maksimum 5 MB.
- Tombol mikrofon merekam PCM 16 kHz mono dan meminta Gemini mentranskripsikan
  audio. Data media dikirim sebagai `inlineData` base64 bersama prompt.
- Android dan iOS mendeklarasikan izin kamera/mikrofon/galeri yang diperlukan.

## Privasi, biaya, dan batas keamanan

- Tidak ada kunci API di source code, `--dart-define`, log, atau screenshot.
  Masukkan kunci milik sendiri lewat ikon kunci dalam layar Chat AI.
- Jangan mengirim NIK, nomor telepon, alamat, data login, token FCM, nilai,
  tagihan, atau data pribadi. Seluruh riwayat percakapan sesi yang sedang
  berjalan, termasuk lampiran gambar/audio, dikirim kembali ke Gemini pada
  setiap permintaan untuk mempertahankan konteks; aplikasi tidak menyimpan
  riwayat ke disk.
- Lampiran gambar dan audio dibatasi 5 MB; data dikirim ke Gemini dan dapat
  memakai kuota/biaya. Hindari gambar dokumen identitas atau rekaman berisi
  informasi pribadi.
- API key dikirim ke Gemini melalui HTTPS dalam header `x-goog-api-key`.
  `flutter_secure_storage` melindungi penyimpanan lokal, tetapi tidak membuat
  kunci client-side aman dari ekstraksi pada aplikasi yang didistribusikan.
  Produksi sebaiknya memanggil backend tepercaya dengan autentikasi, rate
  limit, batas biaya, dan kebijakan retensi.
- Pemanggilan model dapat memakai kuota atau berbayar. Gunakan hanya key yang
  berhak Anda pakai dan pantau limit di AI Studio/Google Cloud.
- Tidak ada fallback jawaban buatan saat API gagal karena itu akan terlihat
  seperti jawaban AI yang berhasil. UI menunjukkan error koneksi, timeout,
  API key/kuota, atau respons kosong; pengguna dapat mencoba lagi atau
  menghapus key.

## Cara verifikasi

```powershell
flutter test test\ai_chat_test.dart
flutter analyze
```

Tes memeriksa API key wajib sebelum request, penyimpanan key trim/tidak
kosong, parsing event SSE valid/malformed, serialisasi lampiran gambar/audio,
serta alur UI mengirim pertanyaan dan merender jawaban yang datang sebagai
beberapa chunk. Tidak ada tes yang mengirim request jaringan atau memakai API
key sungguhan.

Untuk tes manual: jalankan `flutter run -d chrome`, buka Chat AI dari Home,
atur key sendiri, kirim pertanyaan umum tanpa data pribadi, amati teks
streaming dan coba mode offline. Dari tombol gambar, pilih OCR atau deskripsi,
lalu ambil gambar dari galeri; dari tombol mikrofon rekam ucapan singkat dan
tekan berhenti untuk meminta transkripsi. Izin kamera/mikrofon perlu diuji di
perangkat/emulator yang mendukungnya. Hapus key melalui tombol kunci setelah
demonstrasi bila tidak ingin menyimpannya.

Hasil verifikasi setelah penambahan fitur media: `flutter test` lulus (17 tes),
`flutter analyze` tanpa temuan, formatter bersih, dan
`flutter build web --no-wasm-dry-run` berhasil. Tes otomatis tidak menghubungi
layanan eksternal. Kamera/mikrofon dan request sungguhan ke Gemini belum diuji
di perangkat dengan izin serta API key aktif.
