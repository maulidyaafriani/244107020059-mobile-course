import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/gemini_chat_service.dart';
import '../../domain/chat_turn.dart';
import '../providers/ai_chat_providers.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatTurn> _conversation = [];
  String _streamingText = '';
  String? _error;
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _inputController.text.trim();
    if (question.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() {
      _error = null;
      _isSending = true;
      _streamingText = '';
      _conversation.add(ChatTurn(role: ChatRole.user, text: question));
    });

    try {
      await for (final chunk
          in ref
              .read(geminiChatServiceProvider)
              .streamReply(List.unmodifiable(_conversation))) {
        if (!mounted) return;
        setState(() => _streamingText += chunk);
        _scrollToBottom();
      }
      if (!mounted) return;
      setState(() {
        _conversation.add(ChatTurn(role: ChatRole.model, text: _streamingText));
        _streamingText = '';
      });
    } on AiChatException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
    _scrollToBottom();
  }

  Future<void> _manageApiKey() async {
    final keyController = TextEditingController();
    final service = ref.read(geminiChatServiceProvider);
    final action = await showDialog<_KeyAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('API key Gemini'),
        content: TextField(
          key: const ValueKey('gemini-api-key-field'),
          controller: keyController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'API key',
            helperText: 'Disimpan lokal melalui secure storage.',
          ),
        ),
        actions: [
          TextButton(
            key: const ValueKey('delete-gemini-api-key'),
            onPressed: () => Navigator.pop(dialogContext, _KeyAction.delete),
            child: const Text('Hapus tersimpan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const ValueKey('save-gemini-api-key'),
            onPressed: () => Navigator.pop(
              dialogContext,
              _KeyAction.save(keyController.text),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    keyController.dispose();
    if (!mounted || action == null) return;

    try {
      switch (action) {
        case _SaveKey(:final key):
          await service.saveApiKey(key);
          if (mounted) _showMessage('API key tersimpan dengan aman.');
        case _DeleteKey():
          await service.deleteApiKey();
          if (mounted) _showMessage('API key tersimpan telah dihapus.');
      }
    } on AiChatException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
        actions: [
          IconButton(
            key: const ValueKey('manage-gemini-api-key'),
            tooltip: 'Atur API key',
            onPressed: _manageApiKey,
            icon: const Icon(Icons.key),
          ),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            content: const Text(
              'Jangan kirim NIK, nomor telepon, alamat, data login, atau '
              'informasi sensitif. Pesan dikirim ke Gemini dan tidak disimpan '
              'oleh aplikasi ini.',
            ),
            leading: const Icon(Icons.privacy_tip_outlined),
            actions: const [SizedBox.shrink()],
          ),
          Expanded(
            child: ListView.builder(
              key: const ValueKey('ai-chat-messages'),
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  _conversation.length +
                  (_streamingText.isNotEmpty ? 1 : 0) +
                  (_isSending && _streamingText.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _conversation.length) {
                  return _MessageBubble(turn: _conversation[index]);
                }
                if (_streamingText.isNotEmpty) {
                  return _MessageBubble(
                    turn: ChatTurn(role: ChatRole.model, text: _streamingText),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          if (_conversation.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Tanyakan hal umum. Jangan masukkan data pribadi.'),
            ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                error,
                key: const ValueKey('ai-chat-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('ai-chat-input'),
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pertanyaan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const ValueKey('send-ai-message'),
                    tooltip: 'Kirim',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == ChatRole.user;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? colors.primaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(turn.text),
      ),
    );
  }
}

sealed class _KeyAction {
  const _KeyAction();

  factory _KeyAction.save(String key) = _SaveKey;
  factory _KeyAction.delete() = _DeleteKey;
}

final class _SaveKey extends _KeyAction {
  const _SaveKey(this.key);

  final String key;
}

final class _DeleteKey extends _KeyAction {
  const _DeleteKey();
}
