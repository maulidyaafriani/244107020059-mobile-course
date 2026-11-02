import 'package:dio/dio.dart';

import 'gemini_stream_transport_types.dart';

GeminiStreamTransport createGeminiStreamTransport() =>
    NativeGeminiStreamTransport();

class NativeGeminiStreamTransport implements GeminiStreamTransport {
  NativeGeminiStreamTransport({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(minutes: 2),
              sendTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  @override
  Future<GeminiStreamResponse> post({
    required Uri uri,
    required String apiKey,
    required Map<String, Object?> body,
  }) async {
    final response = await _dio.post<ResponseBody>(
      uri.toString(),
      data: body,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
        validateStatus: (_) => true,
      ),
    );
    final stream = response.data?.stream;
    if (stream == null) {
      return GeminiStreamResponse(
        statusCode: response.statusCode ?? 0,
        body: const Stream.empty(),
      );
    }
    return GeminiStreamResponse(
      statusCode: response.statusCode ?? 0,
      body: stream,
    );
  }
}
