import 'dart:convert';
import 'dart:typed_data';

enum ChatRole { user, model }

class ChatTurn {
  const ChatTurn({
    required this.role,
    required this.text,
    this.mediaBytes,
    this.mediaMimeType,
  }) : assert((mediaBytes == null) == (mediaMimeType == null));

  final ChatRole role;
  final String text;
  final Uint8List? mediaBytes;
  final String? mediaMimeType;

  Map<String, Object> toGeminiContent() {
    final bytes = mediaBytes;
    return {
      'role': role.name,
      'parts': [
        {'text': text},
        if (bytes != null)
          {
            'inlineData': {
              'mimeType': mediaMimeType!,
              'data': base64Encode(bytes),
            },
          },
      ],
    };
  }
}
