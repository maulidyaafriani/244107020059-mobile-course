# Verifikasi Usulan AI

## Checklist

| No | Pertanyaan | Hasil | Bukti / Catatan |
|----|------------|-------|-----------------|
| 1 | Interface repository di `domain`, implementasi di `data`? | Ya | Usulan AI menaruh `auth_repository.dart` di `domain/repositories/` dan `auth_repository_impl.dart` di `data/repositories/`. Sama dengan hasil refactor saya. |
| 2 | `domain` bebas import Flutter/Dio/SQLite/Firebase? | Ya | Grep 1: kosong. |
| 3 | Apakah AI membuat use case untuk tiap CRUD satu-baris? | Tidak | AI hanya mempertahankan `login.dart`. Untuk announcements, AI tidak membuat use case dan menyarankan provider membaca repository langsung. |
| 4 | Entity bebas mapping (`toMap/fromMap/toJson`)? | Ya | `AuthSession` hanya dua string. AI menaruh mapping di `models/` (`auth_session_model.dart`, `announcement_model.dart`). |
| 5 | DI terpusat di provider, widget tidak membuat repository sendiri? | Ya | `auth_providers.dart`. Grep 3: (isi hasilnya). |
| 6 | Keputusan final dan alasan | Lihat tabel di bawah | |

## Hasil grep

| Grep | Hasil |
|------|-------|
| 1. Domain steril dari framework | kosong |
| 2. Presentation steril dari data mentah | kosong |
| 3. Instansiasi manual di pages/providers | (isi hasilnya) |

## Usulan AI vs Keputusan Final

| Topik | Usulan AI | Keputusan final | Alasan |
|-------|-----------|-----------------|--------|
| Struktur feature-first | `features/auth` dan `features/announcements`, masing-masing domain/data/presentation | Diterima untuk `auth` | Sudah diterapkan dan berjalan. |
| Use case login | Boleh dipertahankan, atau repository langsung | Dipertahankan | Sebagai contoh pola, dan mudah ditambah validasi. |
| Fitur announcements | Entity, repository, data source, model | Ditunda | Halaman saat ini hanya menampilkan ID, belum ada alur data. Membuat lapisan penuh sekarang adalah over-engineering. |
| Data source terpisah (`datasources/`) | Ditambahkan di auth dan announcements | Ditolak untuk saat ini | Login masih mock, belum ada sumber data nyata. Ditambah saat backend tersedia. |
| `token_store.dart` | Pindah ke `features/auth/data/datasources/` | Ditunda | Masih dipakai `api_client.dart`. Memindahkannya perlu mengubah banyak import dan berisiko merusak aplikasi yang sudah jalan. |
| `api_client.dart` | Pindah ke `core/network/`, jangan bergantung pada `AuthRepository` | Ditunda, catat sebagai perbaikan | Saat ini bergantung pada interface `AuthRepository` (domain), bukan implementasi. Saran AI soal risiko siklus DI dicatat. |
| `providers/auth_provider.dart` | Satukan ke `features/auth/presentation/providers/` | Diterima sebagai perbaikan lanjutan | Sekarang ada dua file provider auth. Idealnya dijadikan satu. |
| Folder `messaging` | Pindah/ganti nama jadi `notifications/` | Ditolak | Hanya ganti nama, tidak mengubah ketergantungan layer, dan banyak import harus diubah. |
| Struktur `app/router` | Pindah `routes.dart` dan `router/` ke `app/` | Ditolak | Tidak menyelesaikan masalah dependensi, hanya kosmetik. |

## Arah dependensi

```
Presentation  ──►  Domain  ◄──  Data
```

Presentation dan Data sama-sama bergantung pada Domain. Domain tidak bergantung pada apa pun.