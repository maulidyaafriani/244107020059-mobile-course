# Laporan optimasi performa

## Ruang lingkup

Workspace yang tersedia adalah `06-week-6-authentication` pada branch fitur
week 10, bukan project Minggu 7–10 yang disebut dalam jobsheet. Karena folder
`11-week-11-performance-optimization/` tidak tersedia, perubahan dan laporan
ini berada di project tersebut. Temuan berikut berasal dari inspeksi kode;
baseline dan hasil sesudah optimasi belum direkam dengan DevTools.

## Metrik profiling

| Metrik | Baseline | Setelah optimasi |
|---|---|---|
| Rata-rata frame time | Belum diukur | Belum diukur |
| Frame jank (merah/kuning) | Belum dihitung | Belum dihitung |
| Heap/memori | Snapshot belum diambil | Snapshot belum diambil |
| Flame Chart sebelum/sesudah | Belum direkam | Belum direkam |

Screenshot `screenshots/before-profile.png` dan
`screenshots/after-profile.png` belum tersedia. Tidak ada angka atau bukti
profiling yang diasumsikan sebagai hasil pengukuran.

## Temuan dan optimasi

1. **Decode gambar chat tidak dibatasi ukuran tampil.** Gambar lampiran
   ditampilkan pada lebar 220 logical pixel, atau 64 pada preview, tetapi
   sebelumnya didekode dari dimensi sumber. `cacheWidth` kini mengikuti lebar
   tampilan dikalikan device-pixel ratio. Ini mengurangi ukuran decode/cache
   untuk layar kecil; dampak aktual perlu diukur pada Raster thread.
2. **Scroll berulang selama streaming.** Setiap chunk jawaban meminta animasi
   gulir 180 ms baru. Permintaan kini dikoaleskan per frame dan streaming
   memakai `jumpTo`; setelah respons selesai, aplikasi tetap melakukan satu
   animasi gulir halus.
3. **Daftar chat menggunakan lazy builder.** Riwayat ditampilkan dengan
   `ListView.builder`, sehingga widget untuk item di luar layar tidak dibangun
   sekaligus. Pola ini sudah ada dan dipertahankan; ia tidak membatasi memori
   data riwayat yang tetap disimpan di state.

## Verifikasi

Perintah yang dijalankan pada project ini:

```powershell
flutter analyze
flutter test
```

Hasil terakhir: `flutter analyze` tidak menemukan masalah dan seluruh 18 test
lulus. Ini memverifikasi analisis statis dan perilaku yang dicakup tes, bukan
peningkatan frame time atau penggunaan memori.

Untuk melengkapi pengukuran, jalankan `flutter run --profile`, rekam skenario
interaksi yang sama sebelum dan sesudah perubahan di DevTools Performance, dan
catat frame time, jank, serta aktivitas decode gambar. Ambil heap snapshot pada
halaman chat dan setelah navigasi berulang. Simpan screenshot Flame Chart
sebagai `screenshots/before-profile.png` dan `screenshots/after-profile.png`.

## Refleksi

- **Dampak terbesar yang diharapkan:** pembatasan decode gambar dapat
  mengurangi biaya decode dan memori gambar beresolusi tinggi yang tampil
  kecil. Dampak terbesar belum dapat dipastikan tanpa profil Raster thread.
- **Cara memverifikasi:** bandingkan rekaman DevTools dengan perangkat,
  skenario, dan durasi yang sama; jangan simpulkan dari kelancaran yang terasa
  saja. Tes otomatis dan analyzer adalah pemeriksaan regresi, bukan benchmark.
- **Trade-off:** scroll streaming yang langsung melompat menghindari animasi
  yang terus dimulai ulang, tetapi gerakannya kurang halus selama teks masuk.
  Satu animasi tetap dipakai setelah respons selesai. Decode yang lebih kecil
  menghemat sumber daya namun dapat menurunkan ketajaman jika ukuran target
  salah.
- **Menghindari premature optimization:** ukur lebih dulu dan fokus pada
  bottleneck yang teramati. Hindari menambah cache, pagination, atau kompleksitas
  state sebelum ada kebutuhan dan bukti bahwa biaya tersebut dominan.
