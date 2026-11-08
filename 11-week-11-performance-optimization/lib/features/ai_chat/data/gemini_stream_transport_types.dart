import 'dart:typed_data';

class GeminiStreamResponse {
  const GeminiStreamResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Stream<Uint8List> body;
}

abstract interface class GeminiStreamTransport {
  Future<GeminiStreamResponse> post({
    required Uri uri,
    required String apiKey,
    required Map<String, Object?> body,
  });
}
