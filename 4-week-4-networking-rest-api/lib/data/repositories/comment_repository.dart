import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Loads comments from the JSONPlaceholder comments endpoint.
class CommentRepository {
  /// Creates a repository that uses the supplied Dio client.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Fetches all comments belonging to [postId] with a ten-second timeout.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data ?? <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
