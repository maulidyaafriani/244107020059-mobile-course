import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

import 'gemini_stream_transport_types.dart';

GeminiStreamTransport createGeminiStreamTransport() =>
    WebGeminiStreamTransport();

class WebGeminiStreamTransport implements GeminiStreamTransport {
  @override
  Future<GeminiStreamResponse> post({
    required Uri uri,
    required String apiKey,
    required Map<String, Object?> body,
  }) async {
    final headers = web.Headers()
      ..append('Content-Type', 'application/json')
      ..append('x-goog-api-key', apiKey);
    final request = web.Request(
      uri.toString().toJS,
      web.RequestInit(
        method: 'POST',
        headers: headers,
        body: jsonEncode(body).toJS,
      ),
    );
    final web.Response response;
    try {
      response = await web.window.fetch(request).toDart;
    } on Object catch (error, stackTrace) {
      if (error is! Exception && error is! Error) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw DioException(
        requestOptions: RequestOptions(path: uri.path),
        type: DioExceptionType.connectionError,
      );
    }

    final responseBody = response.body;
    if (responseBody == null) {
      return GeminiStreamResponse(
        statusCode: response.status,
        body: const Stream.empty(),
      );
    }
    return GeminiStreamResponse(
      statusCode: response.status,
      body: _readChunks(responseBody.getReader()),
    );
  }

  Stream<Uint8List> _readChunks(web.ReadableStreamReader reader) async* {
    final streamReader = _ReadableStreamDefaultReader(reader);
    while (true) {
      final result = await streamReader.read().toDart;
      if (result.done) return;
      final value = result.value;
      if (value != null && value.isA<JSUint8Array>()) {
        yield (value as JSUint8Array).toDart;
      }
    }
  }
}

extension type _ReadableStreamDefaultReader(JSObject _) implements JSObject {
  external JSPromise<web.ReadableStreamReadResult> read();
}
