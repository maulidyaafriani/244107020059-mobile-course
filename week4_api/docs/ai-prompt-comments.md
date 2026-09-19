AI Prompt Challenge - Comment Repository
Prompt yang digunakan

Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id} dari JSONPlaceholder menggunakan Dio + flutter_riverpod. Requirements:

Model Comment dengan fromJson aman null (postId, id, name, email, body).
CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
AsyncNotifierProvider dengan penanganan error otomatis (AsyncError) dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
Satu unit test untuk fromJson dengan field yang hilang. Jelaskan setiap bagian kode dalam komentar.
Output awal AI

Model Comment yang dihasilkan AI:

dart
class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

Provider yang dihasilkan AI (memakai pola Riverpod 2.x):

dart
class CommentNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
  @override
  Future<List<Comment>> build(int arg) async {
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final commentProvider =
    AsyncNotifierProviderFamily<CommentNotifier, List<Comment>, int>(
  CommentNotifier.new,
);

Saat dijalankan (flutter run -d chrome), muncul compile error:

lib/data/providers.dart:24:31: Error: Type 'FamilyAsyncNotifier' not found.
lib/data/providers.dart:45:5: Error: Method not found: 'AsyncNotifierProviderFamily'.
lib/data/providers.dart:27:24: Error: The getter 'ref' isn't defined for the type 'CommentNotifier'.
lib/data/providers.dart:33:5: Error: The setter 'state' isn't defined for the type 'CommentNotifier'.
lib/data/providers.dart:36:56: Error: The getter 'arg' isn't defined for the type 'CommentNotifier'.
Verifikasi & temuan
 UI tidak memanggil Dio langsung — sudah lewat repository & provider.
 fromJson aman null — sudah pakai as num?, as String? ?? ''.
 Semua DioExceptionType dipetakan — memakai fungsi friendlyErrorMessage yang sudah ada, jadi otomatis tercakup.
 baseUrl/timeout terpusat — CommentRepository pakai dioProvider yang sama dengan PostRepository.
 Test AI awalnya hanya menguji happy path — saya tambahkan test untuk field yang hilang.
 flutter analyze & flutter test lolos tanpa warning (setelah perbaikan).
Masalah yang ditemukan & perbaikan

Kode dari AI memakai FamilyAsyncNotifier dan AsyncNotifierProviderFamily, yang merupakan API Riverpod versi 2.x. Project ini memakai flutter_riverpod: ^3.4.3 (Riverpod 3), di mana class tersebut sudah dihapus. Ini menyebabkan beberapa compile error: Type 'FamilyAsyncNotifier' not found, Method not found: 'AsyncNotifierProviderFamily', dan error terkait ref/state/arg yang tidak dikenali di dalam notifier.

Perbaikan: mengganti pola menjadi cara Riverpod 3 untuk notifier dengan parameter (family) — menggunakan AsyncNotifierProvider.autoDispose.family dan menyimpan argumen (postId) lewat constructor + field pada class CommentNotifier, bukan lewat this.arg seperti versi lama:

dart
final commentListProvider = AsyncNotifierProvider.autoDispose
    .family<CommentNotifier, List<Comment>, int>(
  CommentNotifier.new,
);

class CommentNotifier extends AsyncNotifier<List<Comment>> {
  CommentNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

Pelajaran: AI coding assistant bisa menghasilkan kode berdasarkan versi package yang lebih lama dari yang ter-install di project. Penting untuk selalu memverifikasi versi package sebelum menerima kode dari AI mentah-mentah.