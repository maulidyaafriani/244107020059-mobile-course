import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/post.dart';
import '../data/repositories/post_repository.dart';
import 'connectivity_provider.dart';

final postRepositoryProvider = Provider((ref) => PostRepository());

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.watch(postRepositoryProvider);

    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    final cached = await repo.readCachedPosts();

    // 2. Refresh di background (tidak diawait) -- kecuali sedang
    //    mensimulasikan offline.
    if (!ref.read(forceOfflineProvider)) {
      _refreshInBackground();
    }
    return cached;
  }

  Future<void> _refreshInBackground() async {
    final repo = ref.read(postRepositoryProvider);
    try {
      final fresh = await repo.refreshFromNetwork();
      // Hanya update state bila notifier ini masih "hidup".
      state = AsyncData(fresh);
    } catch (_) {
      // Gagal refresh (offline sungguhan, timeout, dll): biarkan
      // cache lama tetap tampil, jangan lempar error ke UI.
    }
  }

  /// Refresh manual (mis. pull-to-refresh). Tetap menghormati
  /// simulasi offline.
  Future<void> refresh() async {
    if (ref.read(forceOfflineProvider)) return;
    final repo = ref.read(postRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(repo.refreshFromNetwork);
  }
}