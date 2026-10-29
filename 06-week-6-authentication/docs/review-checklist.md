# Review Checklist

## 0. Temuan Audit Riwayat

| Temuan | Bukti | Tindakan |
|--------|-------|----------|
| Commit langsung ke `main` | `git log`: semua commit di `main`, tidak ada `develop` | Buat `develop`, kerja lewat branch |
| Pesan commit tanpa scope | `refactor:`, `docs:`, `test:` | Format `tipe(scope): deskripsi` |
| Satu commit memuat banyak hal | `5ec95b6` (refactor + README + tests) | Pecah per perubahan logis |
| File sampah Windows terlacak | `secrenshoot/desktop.ini` modified | `.gitignore` + `git rm --cached` |
| Screenshot belum di-commit | 5 file `.png` untracked | Commit lewat branch chore |
| Nama folder/file tidak konsisten | `secrenshoot`, `jonsheet7.2.png` | Dicatat, rename di PR terpisah |

## 1. Perbaikan Pesan Commit

| # | Sebelum | Sesudah | Alasan |
|---|---------|---------|--------|
| 1 | `docs: add verification results` | `docs(arch): tambah hasil verifikasi dependency rule` | Menyebut modul dan jenis verifikasi |
| 2 | `refactor: wire auth provider to clean architecture use case` | `refactor(auth): hubungkan authProvider ke LoginUseCase` | Ada scope dan target jelas |
| 3 | `docs: finish clean architecture refactor, README, and tests` | Dipecah: `docs(readme): lengkapi status arsitektur` dan `test(auth): tambah test LoginUseCase` | Satu commit satu perubahan logis |
