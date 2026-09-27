import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';
import '../providers/posts_provider.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (Cache-first)'),
        actions: [
          IconButton(
            tooltip: forceOffline ? 'Simulasi: Offline' : 'Simulasi: Online',
            icon: Icon(forceOffline ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () => ref.read(forceOfflineProvider.notifier).state =
                !forceOffline,
          ),
          IconButton(
            tooltip: 'Refresh dari jaringan',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(postsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) => posts.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada cache.\nTekan refresh sekali saat online untuk mengisi cache.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${post.id}')),
                    title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
    );
  }
}