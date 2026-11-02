import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

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
  final _imagePicker = ImagePicker();
  final List<ChatTurn> _conversation = [];
  Uint8List? _pendingImage;
  String? _pendingImageMimeType;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _recordingSubscription;
  final _recordedAudio = BytesBuilder(copy: false);
  String _streamingText = '';
  String? _error;
  bool _isSending = false;
  bool _isRecording = false;
  bool _recordingTooLarge = false;
  static const _maxMediaBytes = 5 * 1024 * 1024;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    unawaited(_recordingSubscription?.cancel());
    unawaited(_recorder?.dispose());
    super.dispose();
  }

  Future<void> _sendMessage({
    String? prompt,
    Uint8List? mediaBytes,
    String? mediaMimeType,
  }) async {
    final question = _inputController.text.trim();
    final message = question.isEmpty ? (prompt ?? '') : question;
    final attachment = mediaBytes ?? _pendingImage;
    final mimeType = mediaMimeType ?? _pendingImageMimeType;
    if ((message.isEmpty && attachment == null) || _isSending) return;

    _inputController.clear();
    setState(() {
      _error = null;
      _isSending = true;
      _streamingText = '';
      _pendingImage = null;
      _pendingImageMimeType = null;
      _conversation.add(
        ChatTurn(
          role: ChatRole.user,
          text: message,
          mediaBytes: attachment,
          mediaMimeType: mimeType,
        ),
      );
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
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Permintaan gagal diproses: $error');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source, {required String prompt}) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > _maxMediaBytes) {
        _showMessage('Gambar terlalu besar. Batas ukuran adalah 5 MB.');
        return;
      }
      final mimeType = switch (image.mimeType) {
        'image/png' => 'image/png',
        'image/webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      setState(() {
        _pendingImage = bytes;
        _pendingImageMimeType = mimeType;
        if (_inputController.text.trim().isEmpty) {
          _inputController.text = prompt;
        }
      });
    } on Exception catch (error) {
      if (mounted) _showMessage('Gambar tidak dapat dipilih: $error');
    }
  }

  Future<void> _showImageActions() async {
    final action = await showModalBottomSheet<_ImageAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              key: const ValueKey('scan-image-ocr'),
              leading: const Icon(Icons.document_scanner),
              title: const Text('Baca teks dari gambar (OCR)'),
              onTap: () => Navigator.pop(context, _ImageAction.galleryOcr),
            ),
            ListTile(
              key: const ValueKey('describe-image'),
              leading: const Icon(Icons.image_search),
              title: const Text('Deskripsikan gambar'),
              onTap: () =>
                  Navigator.pop(context, _ImageAction.galleryDescribe),
            ),
            ListTile(
              key: const ValueKey('capture-image'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil gambar dengan kamera'),
              onTap: () => Navigator.pop(context, _ImageAction.cameraOcr),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final useCamera = action == _ImageAction.cameraOcr;
    final prompt = switch (action) {
      _ImageAction.galleryOcr || _ImageAction.cameraOcr =>
        'Baca semua teks yang terlihat pada gambar ini. Pertahankan bahasa '
            'dan susunan baris sebisa mungkin. Jika tidak ada teks, katakan.',
      _ImageAction.galleryDescribe =>
        'Jelaskan isi gambar ini secara ringkas dan objektif.',
    };
    await _pickImage(
      useCamera ? ImageSource.camera : ImageSource.gallery,
      prompt: prompt,
    );
  }

  Future<void> _toggleRecording() async {
    if (_isSending) return;
    if (_isRecording) {
      try {
        await _recorder?.stop();
        await _recordingSubscription?.asFuture<void>().timeout(
          const Duration(seconds: 3),
          onTimeout: () {},
        );
        final bytes = _recordedAudio.takeBytes();
        final recorder = _recorder;
        _recorder = null;
        await recorder?.dispose();
        if (!mounted) return;
        setState(() => _isRecording = false);
        if (_recordingTooLarge) {
          setState(() => _recordingTooLarge = false);
          _showMessage('Rekaman terlalu besar. Batas ukuran adalah 5 MB.');
          return;
        }
        if (bytes.isEmpty) {
          _showMessage('Rekaman kosong. Coba rekam lagi.');
          return;
        }
        await _sendMessage(
          prompt: 'Transkripsikan ucapan dalam audio ini dengan akurat. '
              'Keluarkan teks transkripsi saja.',
          mediaBytes: bytes,
          mediaMimeType: 'audio/pcm;rate=16000',
        );
      } on Exception catch (error) {
        if (mounted) {
          setState(() => _isRecording = false);
          _showMessage('Rekaman tidak dapat diproses: $error');
        }
      }
      return;
    }

    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        await recorder.dispose();
        _showMessage('Izin mikrofon belum diberikan.');
        return;
      }
      _recordedAudio.clear();
      _recordingTooLarge = false;
      final audioStream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _recordingSubscription = audioStream.listen(
        (chunk) {
          if (_recordedAudio.length + chunk.length > _maxMediaBytes) {
            _recordingTooLarge = true;
            return;
          }
          _recordedAudio.add(chunk);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (mounted) _showMessage('Perekaman gagal: $error');
        },
      );
      _recorder = recorder;
      if (mounted) setState(() => _isRecording = true);
    } on Exception catch (error) {
      await recorder.dispose();
      if (mounted) _showMessage('Mikrofon tidak dapat digunakan: $error');
    }
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
          if (_pendingImage case final image?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.memory(
                    image,
                    key: const ValueKey('pending-image-preview'),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Gambar siap dikirim ke Gemini')),
                  IconButton(
                    key: const ValueKey('remove-pending-image'),
                    tooltip: 'Hapus gambar',
                    onPressed: () => setState(() {
                      _pendingImage = null;
                      _pendingImageMimeType = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          if (_isRecording)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('Merekam audio… tekan tombol berhenti jika selesai.'),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('attach-ai-image'),
                    tooltip: 'Pilih gambar untuk OCR atau deskripsi',
                    onPressed:
                        _isSending || _isRecording ? null : _showImageActions,
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    key: const ValueKey('record-ai-audio'),
                    tooltip: _isRecording ? 'Berhenti merekam' : 'Rekam audio',
                    onPressed: _isSending ? null : _toggleRecording,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (turn.mediaBytes != null &&
                turn.mediaMimeType?.startsWith('image/') == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.memory(
                  turn.mediaBytes!,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
            if (turn.mediaMimeType?.startsWith('audio/') == true)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.mic, size: 18),
              ),
            Text(turn.text),
          ],
        ),
      ),
    );
  }
}

enum _ImageAction { galleryOcr, galleryDescribe, cameraOcr }

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
