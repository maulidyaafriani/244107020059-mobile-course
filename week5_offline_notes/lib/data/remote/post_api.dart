import 'package:dio/dio.dart';
import 'post.dart';

class PostApi {
  PostApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final res = await _dio.get('/posts');
    final data = res.data as List<dynamic>;
    return data
        .map((e) => Post.fromJson(e as Map<String, Object?>))
        .toList();
  }
}