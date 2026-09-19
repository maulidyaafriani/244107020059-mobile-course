import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';
import '../data/comment_providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Post #$postId')),
      body: postsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(friendlyErrorMessage(err)),
        ),
        data: (posts) {
          Post? post;
          for (final p in posts) {
            if (p.id == postId) {
              post = p;
              break;
            }
          }

          if (post == null) {
            return const Center(
              child: Text('Post tidak ditemukan di data yang sudah dimuat.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text('Komentar',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final commentsAsync =
                        ref.watch(commentListProvider(postId));
                    return commentsAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (err, _) =>
                          Text(friendlyErrorMessage(err)),
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const Text('Belum ada komentar.');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: comments
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                        Text(c.body),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}