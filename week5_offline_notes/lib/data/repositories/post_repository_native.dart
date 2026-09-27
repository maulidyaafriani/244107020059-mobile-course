import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../remote/post.dart';
import '../remote/post_api.dart';

class PostRepository {
  PostRepository({
    Future<Database> Function()? openDb,
    PostApi? api,
  })  : _openDb = openDb ?? openNotesDb,
        _api = api ?? PostApi();

  final Future<Database> Function() _openDb;
  final PostApi _api;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((row) => Post.fromJson(
            jsonDecode(row['payload'] as String) as Map<String, Object?>))
        .toList();
  }

  Future<void> _writeCache(List<Post> posts) async {
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    batch.delete('cached_posts');
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Post>> refreshFromNetwork() async {
    final posts = await _api.fetchPosts();
    await _writeCache(posts);
    return posts;
  }
}
