Saya akan meninjau struktur `lib/` dan prompt yang ada, lalu menyusun usulan yang memetakan setiap file lama ke tujuan barunya beserta trade-off dan contoh wiring Riverpod.

Find files matching `lib/**/*`

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\docs\\ai-challenge.md"
}

Find files matching `**/pubspec.yaml`

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\features\\auth\\domain\\repositories\\auth_repository.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\features\\auth\\domain\\entities\\auth_session.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\features\\auth\\domain\\usecases\\login.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\features\\auth\\data\\repositories\\auth_repository_impl.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\features\\auth\\presentation\\providers\\auth_providers.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\providers\\auth_provider.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\data\\api_client.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\data\\token_store.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\pages\\announcement_page.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\pages\\login_page.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\pages\\home_page.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\messaging\\push_service.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\providers\\push_service_provider.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\router\\app_router.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\main.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\routes.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\core\\failures.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\data\\api_errors.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\messaging\\firebase_web_config.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\messaging\\browser_notifications_web.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\messaging\\browser_notifications_stub.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\widgets\\browser_notification_test_button.dart"
}

Read 
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\pubspec.yaml"
}

Read , lines 1 to 230
Completed with input: {
  "path": "C:\\Users\\LENOVO\\Documents\\SEMESTER 5\\PemMob\\244107020059-mobile-course\\06-week-6-authentication\\lib\\messaging\\push_service.dart",
  "view_range": [
    1,
    230
  ]
}

## Ringkasan kondisi saat ini

Di workspace yang saya periksa, auth sudah memiliki sebagian struktur feature-first, tetapi implementasi login masih mock. Fitur announcements belum memiliki alur CRUD—`announcement_page.dart` hanya menampilkan ID. Saya juga tidak menemukan widget yang memanggil Dio langsung; pemanggilan Dio yang ada berada di `push_service.dart` untuk mendaftarkan token FCM.

## Struktur yang diusulkan

```text
lib/
  app/
    router/
      app_router.dart
      routes.dart

  core/
    network/
      dio_provider.dart
      api_client.dart
    errors/
      api_exception.dart
      failure.dart

  features/
    auth/
      domain/
        entities/auth_session.dart
        repositories/auth_repository.dart
        usecases/login.dart
      data/
        datasources/auth_remote_data_source.dart
        datasources/token_local_data_source.dart
        models/auth_session_model.dart
        repositories/auth_repository_impl.dart
      presentation/
        pages/login_page.dart
        providers/auth_providers.dart

    announcements/
      domain/
        entities/announcement.dart
        repositories/announcement_repository.dart
      data/
        datasources/announcement_remote_data_source.dart
        models/announcement_model.dart
        repositories/announcement_repository_impl.dart
      presentation/
        pages/announcement_list_page.dart
        pages/announcement_detail_page.dart
        providers/announcement_providers.dart

  notifications/
    push_service.dart
    push_service_provider.dart
    firebase_web_config.dart
    browser_notifications_web.dart
    browser_notifications_stub.dart

  pages/
    home_page.dart
  widgets/
    browser_notification_test_button.dart
  main.dart
```

`announcements` cukup dimulai dengan `list` dan detail jika hanya menampilkan pengumuman. Tambahkan operasi `create`, `update`, dan `delete` hanya bila memang dibutuhkan. Pemisahan `notifications` menjaga FCM sebagai integrasi lintas fitur, bukan mencampurnya ke repository auth atau announcements.

## Pemetaan file saat ini

| File sekarang | Tujuan |
|---|---|
| `data/api_client.dart` | Pindah ke `core/network/`. Pertahankan satu konfigurasi Dio bersama. Hindari membuat client bergantung langsung pada `AuthRepository`; itu berisiko membentuk siklus DI. Refresh token sebaiknya memakai jalur yang tidak memicu interceptor refresh berulang. |
| `data/api_errors.dart` | Pecah: exception jaringan ke `core/network` atau `core/errors`, sedangkan pemetaan pesan untuk UI ke presentation. Repository menerjemahkan error transport menjadi hasil domain yang sesuai. |
| `data/token_store.dart` | Pindah ke `features/auth/data/datasources/token_local_data_source.dart`; secure storage adalah detail data auth, bukan domain. |
| `core/failures.dart` | Pertahankan hanya jika beberapa fitur memang berbagi tipe failure. Pastikan file ini tidak bergantung pada Dio atau Flutter. Untuk awal yang sederhana, error spesifik fitur juga boleh tinggal dekat fiturnya. |
| `features/auth/domain/entities/auth_session.dart` | Tetap di lokasi; sudah sesuai. |
| `features/auth/domain/repositories/auth_repository.dart` | Tetap sebagai kontrak domain. |
| `features/auth/domain/usecases/login.dart` | Pertahankan jika login memang menjadi batas operasi bisnis. Untuk login yang hanya meneruskan parameter ke repository, pemanggilan repository langsung juga masuk akal. |
| `features/auth/data/repositories/auth_repository_impl.dart` | Tetap di data, tetapi ganti implementasi mock dengan remote data source dan token local data source saat backend tersedia. |
| `features/auth/presentation/providers/auth_providers.dart` | Tetap sebagai tempat provider fitur auth. Lengkapi wiring-nya agar implementasi repository menerima dependensi melalui constructor. |
| `providers/auth_provider.dart` | Pindahkan notifier dan state auth ke `features/auth/presentation/providers/`. Satukan dengan provider auth yang sudah ada agar tidak ada dua tempat DI/state untuk auth. |
| `pages/login_page.dart` | Pindah ke `features/auth/presentation/pages/`. Widget hanya validasi input, membaca state, dan menampilkan hasil—bukan mengakses Dio. |
| `pages/announcement_page.dart` | Pindah ke `features/announcements/presentation/pages/`; pecah menjadi daftar dan detail saat alur datanya tersedia. Buat entity, repository, data source, dan model announcements yang saat ini belum ada. |
| `pages/home_page.dart` | Tetap sebagai halaman app-shell atau pindah ke `features/home/presentation/` jika Home berkembang menjadi fitur tersendiri. UI tombol FCM bisa dipisah dari konten pengumuman. |
| `messaging/push_service.dart` | Pindah ke `notifications/` atau `features/notifications/`. Ini mengelola FCM dan routing notifikasi; endpoint pendaftaran token bisa dipisah ke data source bila mulai diuji atau digunakan lintas tempat. |
| `providers/push_service_provider.dart` | Pindah berdampingan dengan PushService, misalnya `notifications/push_service_provider.dart`. |
| `messaging/firebase_web_config.dart` | Pindah ke konfigurasi/integrasi Firebase. Pertahankan pemisahan konfigurasi platform, bukan masukkan ke domain fitur. |
| `messaging/browser_notifications_web.dart` dan `messaging/browser_notifications_stub.dart` | Pindah bersama implementasi notifikasi browser. Stub tetap diperlukan untuk conditional import non-web. |
| `widgets/browser_notification_test_button.dart` | Tetap di `widgets/` bila hanya widget demo yang dipakai lintas halaman; hapus bila tombol tes tidak lagi menjadi bagian aplikasi. |
| `routes.dart` | Pindah ke `app/router/`. Fungsi parsing route dari payload notifikasi bisa dipisah ke helper routing notifikasi jika kebutuhannya tumbuh. |
| `router/app_router.dart` | Pindah ke `app/router/`. Router menghubungkan fitur, tetapi tidak seharusnya berisi aturan bisnis fitur. |
| `main.dart` | Tetap sebagai composition root: inisialisasi Flutter/Firebase, `ProviderScope`, dan aplikasi. Hindari menaruh wiring semua fitur di sini. |

## Use case atau repository langsung?

**Repository langsung dari provider/notifier** cukup untuk operasi CRUD sederhana: memuat daftar, membaca detail, atau menyimpan perubahan yang hanya meneruskan input ke API. Ini mengurangi file dan lapisan yang tidak menambah perilaku.

**Use case berguna** ketika suatu operasi mewakili aturan bisnis yang jelas atau koordinasi beberapa hal—misalnya login yang harus menyimpan sesi, memuat profil, lalu menentukan alur navigasi; atau publikasi pengumuman yang perlu validasi aturan, upload lampiran, dan penanganan hak akses. Use case juga membantu jika operasi yang sama dipakai dari beberapa UI atau perlu diuji terpisah.

Hindari membuat satu use case, interface, dan wrapper hasil baru untuk setiap metode CRUD tanpa kebutuhan nyata. DTO-to-entity mapping juga tidak harus dipaksakan jika bentuk API dan kebutuhan aplikasi masih identik; pisahkan saat model API memang berbeda atau membawa detail transport yang tak boleh bocor ke UI.

## Contoh wiring Riverpod tanpa package DI tambahan

Provider menjadi composition root kecil: buat objek konkret di layer provider, lalu berikan ke konstruktor dependensinya.

```dart
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_BASE_URL')));
});

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    remoteDataSource: AnnouncementRemoteDataSource(ref.watch(dioProvider)),
  );
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) {
  return ref.watch(announcementRepositoryProvider).list();
});
```

Di halaman, provider dibaca dengan `ref.watch(...)` untuk state dan `ref.read(...)` untuk aksi. Halaman tidak mengetahui Dio maupun implementasi repository. Untuk announcements sederhana, `announcementsProvider` dapat membaca repository langsung; tambahkan use case di antaranya hanya jika ada aturan bisnis yang membenarkannya.

**Trade-off utamanya:** struktur feature-first membuat batas kepemilikan fitur dan pengujian lebih jelas, tetapi menambah file serta perpindahan antar-layer. Terapkan batas tersebut pada dependensi yang nyata—UI tidak bergantung pada Dio, domain tidak mengenal Flutter—tanpa membuat setiap operasi CRUD menjadi arsitektur berlapis yang berlebihan.