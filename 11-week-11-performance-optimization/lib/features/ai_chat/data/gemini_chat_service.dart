import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/chat_turn.dart';
import 'ai_api_key_store.dart';
import 'gemini_stream_transport.dart';

class GeminiChatService {
  GeminiChatService({
    required this.transport,
    required this.keyStore,
    this.model = 'gemini-3.6-flash',
  });

  final GeminiStreamTransport transport;
  final AiApiKeyStore keyStore;
  final String model;

  Future<void> saveApiKey(String key) async {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      throw const AiChatException('API key tidak boleh kosong.');
    }
    try {
      await keyStore.write(trimmedKey);
    } on AiApiKeyStorageException {
      throw const AiChatException('API key tidak dapat disimpan dengan aman.');
    }
  }

  Future<void> deleteApiKey() async {
    try {
      await keyStore.delete();
    } on AiApiKeyStorageException {
      throw const AiChatException('API key tidak dapat dihapus.');
    }
  }

  Stream<String> streamReply(List<ChatTurn> conversation) async* {
    if (conversation.isEmpty) {
      throw const AiChatException('Tulis pertanyaan sebelum mengirim.');
    }

    final String? apiKey;
    try {
      apiKey = await keyStore.read();
    } on AiApiKeyStorageException {
      throw const AiChatException(
        'API key tidak dapat dibaca dari storage aman.',
      );
    }
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiChatException(
        'API key belum diatur. Tambahkan API key Gemini melalui menu kunci.',
      );
    }

    final GeminiStreamResponse response;
    try {
      response = await transport.post(
        uri: Uri.https(
          'generativelanguage.googleapis.com',
          '/v1beta/models/$model:streamGenerateContent',
          const {'alt': 'sse'},
        ),
        apiKey: apiKey,
        body: {
          'contents': conversation
              .map((turn) => turn.toGeminiContent())
              .toList(),
        },
      );
    } on DioException catch (error) {
      throw AiChatException(_messageForDioError(error));
    }

    if (response.statusCode != 200) {
      throw AiChatException(
        'Gemini menolak permintaan (HTTP ${response.statusCode}). '
        'Periksa API key, kuota, dan koneksi.',
      );
    }

    var receivedText = false;
    try {
      await for (final line
          in response.body
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final data = line.substring(5).trim();
        if (data.isEmpty || data == '[DONE]') continue;
        final text = parseGeminiSseData(data);
        if (text.isEmpty) continue;
        receivedText = true;
        yield text;
      }
    } on FormatException {
      throw const AiChatException('Respons Gemini tidak dapat dibaca.');
    } on DioException catch (error) {
      throw AiChatException(_messageForDioError(error));
    }

    if (!receivedText) {
      throw const AiChatException(
        'Gemini tidak mengirim teks. Coba ubah pertanyaan atau periksa batasan keamanan.',
      );
    }
  }
}

String parseGeminiSseData(String data) {
  final decoded = jsonDecode(data);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Gemini event must be a JSON object.');
  }
  final candidates = decoded['candidates'];
  if (candidates is! List || candidates.isEmpty) return '';
  final firstCandidate = candidates.first;
  if (firstCandidate is! Map<String, dynamic>) return '';
  final content = firstCandidate['content'];
  if (content is! Map<String, dynamic>) return '';
  final parts = content['parts'];
  if (parts is! List) return '';

  return parts
      .whereType<Map<String, dynamic>>()
      .map((part) => part['text'])
      .whereType<String>()
      .join();
}

String _messageForDioError(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout =>
    'Koneksi ke Gemini terlalu lama. Coba lagi.',
  DioExceptionType.connectionError =>
    'Tidak dapat terhubung ke Gemini. Periksa koneksi internet.',
  _ => 'Permintaan ke Gemini gagal. Coba lagi.',
};

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}
