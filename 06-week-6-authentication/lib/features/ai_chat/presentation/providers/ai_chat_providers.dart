import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_api_key_store.dart';
import '../../data/gemini_chat_service.dart';
import '../../data/gemini_stream_transport.dart';

final geminiChatServiceProvider = Provider<GeminiChatService>((ref) {
  return GeminiChatService(
    transport: createGeminiStreamTransport(),
    keyStore: SecureAiApiKeyStore(),
  );
});
