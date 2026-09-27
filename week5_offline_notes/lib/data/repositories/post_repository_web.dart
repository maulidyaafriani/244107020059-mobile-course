import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../remote/post.dart';
import '../remote/post_api.dart';

class PostRepository {
  PostRepository({PostApi? api}) : _api = api ?? PostApi();

  static const _cacheKey = 'cached_posts';
  final PostApi _api;

  Future<List<Post>> readCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];

    final values = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    return values.map(Post.fromJson).toList();
  }

  Future<void> _writeCache(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(posts.map((post) => post.toJson()).toList()),
    );
  }

  Future<List<Post>> refreshFromNetwork() async {
    final posts = await _api.fetchPosts();
    await _writeCache(posts);
    return posts;
  }
}
