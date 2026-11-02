import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_notify/features/ai_chat/data/ai_api_key_store.dart';
import 'package:campus_notify/features/ai_chat/data/gemini_chat_service.dart';
import 'package:campus_notify/features/ai_chat/data/gemini_stream_transport.dart';
import 'package:campus_notify/features/ai_chat/domain/chat_turn.dart';
import 'package:campus_notify/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:campus_notify/features/ai_chat/presentation/providers/ai_chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGeminiStreamTransport implements GeminiStreamTransport {
  FakeGeminiStreamTransport({
    this.responseBody = const Stream<Uint8List>.empty(),
  });

  final Stream<Uint8List> responseBody;
  Map<String, Object?>? sentBody;

  @override
  Future<GeminiStreamResponse> post({
    required Uri uri,
    required String apiKey,
    required Map<String, Object?> body,
  }) async {
    sentBody = body;
    return GeminiStreamResponse(statusCode: 200, body: responseBody);
  }
}

class MemoryApiKeyStore implements AiApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async {
    value = key;
  }

  @override
  Future<void> delete() async => value = null;
}

class FakeGeminiChatService extends GeminiChatService {
  FakeGeminiChatService()
    : super(
        transport: FakeGeminiStreamTransport(),
        keyStore: MemoryApiKeyStore(),
      );

  @override
  Stream<String> streamReply(List<ChatTurn> conversation) async* {
    yield 'Halo, ';
    yield 'kampus!';
  }
}

void main() {
  group('Gemini chat service', () {
    test('requires an API key before making a request', () async {
      final service = GeminiChatService(
        transport: FakeGeminiStreamTransport(),
        keyStore: MemoryApiKeyStore(),
      );

      await expectLater(
        service.streamReply([
          const ChatTurn(role: ChatRole.user, text: 'Hai'),
        ]).toList(),
        throwsA(isA<AiChatException>()),
      );
    });

    test('stores trimmed API keys and rejects empty values', () async {
      final store = MemoryApiKeyStore();
      final service = GeminiChatService(
        transport: FakeGeminiStreamTransport(),
        keyStore: store,
      );

      await service.saveApiKey('  demo-key  ');
      expect(store.value, 'demo-key');
      await expectLater(
        service.saveApiKey('  '),
        throwsA(isA<AiChatException>()),
      );
    });

    test('parses text from a Gemini SSE event', () {
      expect(
        parseGeminiSseData(
          '{"candidates":[{"content":{"parts":[{"text":"Halo"}]}}]}',
        ),
        'Halo',
      );
    });

    test('streams text from chunked SSE events', () async {
      final transport = FakeGeminiStreamTransport(
        responseBody: Stream.fromIterable([
          Uint8List.fromList(
            utf8.encode(
              'data: {"candidates":[{"content":{"parts":[{"text":"Halo "}]}}]}\n',
            ),
          ),
          Uint8List.fromList(
            utf8.encode(
              '\ndata: {"candidates":[{"content":{"parts":[{"text":"kampus!"}]}}]}\n\n',
            ),
          ),
        ]),
      );
      final service = GeminiChatService(
        transport: transport,
        keyStore: MemoryApiKeyStore()..value = 'demo-key',
      );

      final chunks = await service.streamReply([
        const ChatTurn(role: ChatRole.user, text: 'Hai'),
      ]).toList();

      expect(chunks, ['Halo ', 'kampus!']);
      expect(transport.sentBody?['contents'], [
        {
          'role': 'user',
          'parts': [
            {'text': 'Hai'},
          ],
        },
      ]);
    });

    test('reports malformed Gemini SSE data', () {
      expect(
        () => parseGeminiSseData('not-json'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  testWidgets('sends a question and renders streamed reply', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          geminiChatServiceProvider.overrideWithValue(FakeGeminiChatService()),
        ],
        child: const MaterialApp(home: AiChatPage()),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('ai-chat-input')),
      'Apa kabar?',
    );
    await tester.tap(find.byKey(const ValueKey('send-ai-message')));
    await tester.pumpAndSettle();

    expect(find.text('Apa kabar?'), findsOneWidget);
    expect(find.text('Halo, kampus!'), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-chat-error')), findsNothing);
  });
}
