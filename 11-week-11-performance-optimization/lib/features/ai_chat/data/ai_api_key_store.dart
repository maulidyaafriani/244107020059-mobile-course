import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AiApiKeyStore {
  Future<String?> read();
  Future<void> write(String key);
  Future<void> delete();
}

class SecureAiApiKeyStore implements AiApiKeyStore {
  SecureAiApiKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _storageKey = 'gemini_api_key';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _storageKey);
    } on PlatformException {
      throw const AiApiKeyStorageException();
    }
  }

  @override
  Future<void> write(String key) async {
    try {
      await _storage.write(key: _storageKey, value: key);
    } on PlatformException {
      throw const AiApiKeyStorageException();
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: _storageKey);
    } on PlatformException {
      throw const AiApiKeyStorageException();
    }
  }
}

class AiApiKeyStorageException implements Exception {
  const AiApiKeyStorageException();
}
