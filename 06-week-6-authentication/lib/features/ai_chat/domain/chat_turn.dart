enum ChatRole { user, model }

class ChatTurn {
  const ChatTurn({required this.role, required this.text});

  final ChatRole role;
  final String text;

  Map<String, Object> toGeminiContent() => {
    'role': role.name,
    'parts': [
      {'text': text},
    ],
  };
}
