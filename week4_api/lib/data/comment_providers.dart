import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

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