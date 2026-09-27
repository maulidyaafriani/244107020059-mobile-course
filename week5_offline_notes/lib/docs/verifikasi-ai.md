# Verifikasi Rekomendasi AI

## Checklist

1. **Apakah AI menempatkan daftar catatan di SharedPreferences?**
   Tidak. AI merekomendasikan sqflite untuk catatan, SharedPreferences hanya
   untuk preferensi tema. Ini sesuai dengan implementasi project
   (`lib/data/prefs.dart` untuk tema, `lib/data/repositories/note_repository.dart`
   untuk catatan) -- jadi rekomendasi AI diterima di titik ini.

2. **Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau
   hanya CRUD polos?**
   Ya, mendukung. Skema yang diusulkan AI menyertakan kolom `dirty` dan
   `updated_at`, sama persis dengan skema yang sudah dipakai di
   `lib/data/local/db.dart` sejak Praktikum 2. AI tidak mengusulkan skema baru
   yang berbeda dari yang sudah berjalan.

3. **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya
   asumsi?**
   Didukung, tapi hanya untuk Drift dan Hive -- AI secara eksplisit menyatakan
   sqflite TIDAK reaktif secara bawaan (perlu StreamController manual). Ini
   konsisten dengan implementasi project: `NotesNotifier` di
   `lib/providers/notes_provider.dart` melakukan refresh state secara manual
   (`state = await AsyncValue.guard(repo.fetchNotes)`) setelah setiap operasi
   tulis, bukan lewat stream otomatis dari database.

4. **Apakah estimasi boilerplate AI masuk akal setelah dicoba instalasinya
   (`flutter pub add` + migrasi skema)?**
   Untuk sqflite: masuk akal. Instalasi hanya `flutter pub add sqflite path`,
   dan skema dibuat sekali di `onCreate`. Model `Note` butuh `toMap`/`fromMap`
   manual (~20 baris), sesuai perkiraan "sedang" dari AI.
   Drift tidak dicoba instalasinya langsung pada project ini (di luar scope
   waktu tugas), sehingga klaim "boilerplate besar di awal karena code-gen"
   untuk Drift belum diverifikasi langsung -- ini asumsi yang diterima
   berdasarkan pengalaman umum, bukan hasil uji coba sendiri.

5. **Keputusan final dan alasan**
   Kombinasi **SharedPreferences (preferensi) + sqflite (catatan)** diterima
   sesuai rekomendasi AI, dengan alasan tambahan dari saya:
   - Scope tugas ini kecil (1 tabel utama + 1 tabel cache), sehingga
     keuntungan type-safety Drift belum sebanding dengan biaya setup
     code-gen-nya.
   - sqflite sudah terbukti jalan di project (lihat Praktikum 2 & 3),
     migrasi ke Drift di tengah jalan berisiko menambah bug baru tanpa
     manfaat langsung untuk kebutuhan saat ini.
   - Reaktivitas otomatis (yang jadi keunggulan utama Drift) belum
     dibutuhkan karena UI di project ini sudah cukup ter-update lewat
     Riverpod state management secara manual setelah tiap operasi tulis.

## Kesimpulan

Rekomendasi AI diterima secara keseluruhan tanpa perubahan skema, karena
sudah konsisten dengan kebutuhan project (dirty flag, updated_at, tanpa
relasi antar tabel). Bagian yang saya tambahkan sendiri adalah justifikasi
kenapa Drift TIDAK dipakai meski secara teori lebih unggul -- yaitu
pertimbangan biaya setup vs manfaat untuk scope tugas ini.