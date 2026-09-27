## AI Verification Checklist

Sebelum rekomendasi AI (lihat `docs/ai-output.md`) diterima, berikut verifikasi
saya terhadap tiap poin:

**1. Apakah AI menempatkan daftar catatan di SharedPreferences?**
Tidak. AI merekomendasikan sqflite untuk catatan, SharedPreferences hanya
untuk preferensi tema. Rekomendasi ini diterima karena sesuai dengan
kebutuhan: catatan adalah koleksi yang akan bertumbuh dan butuh query
(sort, filter dirty), sementara SharedPreferences memang rapuh untuk
menyimpan koleksi -- cocoknya untuk 1-2 nilai sederhana saja.

**2. Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau
hanya CRUD polos?**
Mendukung. Skema yang diusulkan AI menyertakan kolom `dirty` dan
`updated_at`, sama dengan skema yang sudah dipakai project ini sejak
Praktikum 2 (`lib/data/local/db.dart`). AI tidak mengusulkan skema baru
yang berbeda dari yang sudah berjalan.

**3. Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya
asumsi?**
Didukung untuk Drift/Hive, tapi AI secara eksplisit menyatakan **sqflite
TIDAK reaktif secara bawaan** -- perlu StreamController manual. Ini
konsisten dengan implementasi project: `NotesNotifier` melakukan refresh
state secara manual (`state = await AsyncValue.guard(repo.fetchNotes)`)
setelah tiap operasi tulis, bukan lewat stream otomatis dari database.

**4. Apakah estimasi boilerplate AI masuk akal setelah dicoba instalasinya
(`flutter pub add` + migrasi skema)?**
Untuk sqflite: masuk akal. Instalasi hanya `flutter pub add sqflite path`,
skema dibuat sekali di `onCreate`, model `Note` butuh `toMap`/`fromMap`
manual (~20 baris) -- sesuai perkiraan "sedang" dari AI.
Untuk Drift: klaim "boilerplate besar di awal karena code-gen" TIDAK
diverifikasi langsung pada project ini (di luar scope waktu tugas) --
diterima sebagai asumsi berdasar pengalaman umum, bukan hasil uji coba
sendiri.

**5. Keputusan final dan alasan**
Kombinasi **SharedPreferences (preferensi) + sqflite (catatan)** diterima
sesuai rekomendasi AI, dengan alasan tambahan:
- Scope tugas ini kecil (1 tabel utama + 1 tabel cache), sehingga
  keuntungan type-safety Drift belum sebanding dengan biaya setup
  code-gen-nya.
- sqflite sudah terbukti jalan dan teruji (lihat `docs/hasil-testing.md`),
  migrasi ke Drift di tengah jalan berisiko menambah bug baru tanpa
  manfaat langsung.
- Reaktivitas otomatis (keunggulan utama Drift) belum dibutuhkan karena
  UI sudah cukup ter-update lewat Riverpod state management manual
  setelah tiap operasi tulis.




  # Hasil Testing

## Perintah yang dijalankan
```
flutter analyze
flutter test
```

## Hasil `flutter analyze`
```
Analyzing week5_offline_notes...
No issues found!
```

## Hasil `flutter test`
```
00:0X +4: All tests passed!
```

File: `test/note_test.dart` -- 4 test:
1. `fromMap aman terhadap field yang hilang` -- lulus
2. `flag dirty bertahan pada serialisasi` -- lulus
3. `provider sukses dengan repository palsu` -- lulus
4. `provider error dengan repository palsu` -- lulus (setelah downgrade
   `flutter_riverpod` dari `^3.4.3` ke `^2.6.1` karena versi 3 sempat
   menyebabkan test ini timeout -- provider yang gagal saat loading state
   di-dispose sebelum error ter-propagate dengan benar ke `expectLater`)

Test provider (#3 dan #4) menggunakan `FakeNoteRepository` -- tidak
menyentuh database SQLite sungguhan sama sekali, sesuai kebutuhan
kecepatan dan isolasi unit test.



Draf Refleksi

1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?

SharedPreferences dirancang untuk pasangan key-value sederhana (misal 1 boolean tema, 1 string timestamp) — bukan untuk koleksi data yang bertumbuh. Kalau daftar catatan dipaksa disimpan di sana (misalnya di-encode jadi 1 string JSON besar), yang rusak:

Tidak bisa query — untuk cari 1 catatan, filter yang dirty, atau sort by updated_at, seluruh JSON harus di-decode dulu ke memory, baru difilter manual di Dart. Tidak efisien untuk data besar.
Rawan korup — kalau proses nulis file terputus (app crash di tengah setString()), seluruh koleksi bisa rusak sekaligus, karena semuanya 1 blob string, bukan baris-baris terpisah seperti SQLite.
Tidak scalable — makin banyak catatan, makin besar 1 string itu harus di-parse ulang tiap baca/tulis walau cuma nambah 1 catatan baru.

2. Kapan cache-first cukup, dan kapan butuh strategi lain (misal network-first untuk data harga real-time)?

Cache-first cocok untuk data yang toleran terhadap "agak basi" — seperti daftar post artikel di project ini: kalaupun user lihat versi 1 menit lalu, tidak masalah, yang penting UI tidak blank/lambat.

Network-first (atau bahkan "network-only, cache cuma fallback") dibutuhkan untuk data yang berubah cepat dan salah-nya mahal — contoh harga saham, stok barang real-time, saldo rekening. Di kasus itu, menampilkan data lama seolah-olah terbaru bisa bikin user salah ambil keputusan (misal checkout dengan harga yang sudah berubah).

3. Bagaimana dirty flag berubah jadi antrean sync tanpa blocking UI? Kapan tabel outbox terpisah jadi perlu?

Di project ini, dirty = true ditulis langsung saat user simpan catatan (addNote()), dan UI tidak menunggu proses sync — user bisa terus nambah/hapus catatan lain sambil dirtyCountProvider cuma nampilin badge angka. Proses sync (syncNotes()) jalan terpisah, dipicu manual (tombol) atau bisa juga dijadwalkan di background, tanpa nge-block interaksi user sama sekali — inilah kenapa async/Future dipakai, bukan operasi sinkron yang nunggu network.

Tabel outbox terpisah (bukan cuma kolom dirty di tabel yang sama) jadi perlu ketika:

Perlu urutan pengiriman yang dijamin (misal edit lalu hapus harus terkirim berurutan, bukan sembarang)
Ada beberapa jenis operasi berbeda per baris (create/update/delete) yang perlu ditangani beda-beda saat sync, bukan cuma "kirim ulang seluruh row"
Perlu retry logic dengan status per-item (pending/sending/failed/retry-count), yang kalau ditumpuk di kolom dirty boolean saja jadi tidak cukup informatif

4. Bagian mana dari rekomendasi AI yang ditolak, dan mengapa?

Tabel perbandingan AI sendiri menempatkan Drift lebih unggul dari sqflite di hampir semua kriteria teknis (type-safety, reaktivitas otomatis via .watch()). Secara implisit AI mengarah ke Drift sebagai pilihan "lebih baik". Bagian ini saya tolak — saya tetap pakai sqflite murni, bukan karena Drift teknis lebih lemah, tapi karena trade-off praktis: Drift butuh setup build_runner/code generation yang menambah waktu build dan kompleksitas untuk scope tugas sekecil ini (1 tabel utama), sementara reaktivitas otomatisnya belum benar-benar dibutuhkan karena Riverpod sudah menangani refresh state secara manual dengan cukup baik. Keunggulan teknis Drift di atas kertas tidak sepadan dengan biaya adopsinya untuk kasus ini.