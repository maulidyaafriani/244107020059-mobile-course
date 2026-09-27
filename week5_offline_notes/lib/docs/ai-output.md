# Output AI (belum diverifikasi)

## Perbandingan 4 opsi storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada query -- cuma key-value get/set | Query sederhana (filter manual di Dart, tidak ada SQL) | Full SQL (WHERE, JOIN, GROUP BY, dll) | Full SQL + type-safe query builder Dart |
| Kebutuhan relasi | Tidak mendukung relasi sama sekali | Tidak mendukung relasi native (harus manual) | Mendukung (foreign key, JOIN) | Mendukung, plus validasi relasi saat compile-time |
| Reaktivitas (stream) | Tidak ada bawaan | Ada (`box.watch()`) | Tidak bawaan -- perlu dibungkus manual pakai StreamController | Ada bawaan (`.watch()` per query, auto-update saat data berubah) |
| Type-safety | Lemah -- semua manual cast (`getString`, `getBool`, dst) | Sedang -- butuh `TypeAdapter` manual/generated | Lemah -- `Map<String, Object?>` mentah dari `query()` | Kuat -- kode Dart digenerate dari skema, error ketahuan saat compile |
| Ukuran boilerplate | Sangat kecil | Sedang (butuh adapter per model) | Sedang (manual `toMap`/`fromMap`) | Besar di awal (setup builder, code-gen), kecil setelahnya |
| Kemudahan testing | Mudah (bisa di-mock/in-memory) | Sedang (butuh `Hive.init` di test) | Mudah -- bisa pakai `sqflite_common_ffi` in-memory | Mudah -- mendukung in-memory database bawaan |

## Rekomendasi final AI

| Kebutuhan | Rekomendasi | Alasan |
|---|---|---|
| Preferensi tema | SharedPreferences | Cuma 2 key-value sederhana, tidak butuh query/relasi |
| Catatan (koleksi, dirty flag, 1000+ baris) | sqflite (SQLite) | Perlu query terstruktur, performa stabil, sudah jalan di project |

## Skema tabel untuk 1000+ catatan (usulan AI)

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_dirty ON notes(dirty);
CREATE INDEX idx_notes_updated ON notes(updated_at);
```

## Trade-off (ringkasan AI)

- SharedPreferences: ringan, tapi rapuh untuk koleksi data.
- Hive: cepat, reaktif, tapi butuh TypeAdapter manual.
- sqflite: SQL penuh, tapi mapping manual, tidak type-safe.
- Drift: paling type-safe dan reaktif otomatis, tapi setup code-gen lebih berat.