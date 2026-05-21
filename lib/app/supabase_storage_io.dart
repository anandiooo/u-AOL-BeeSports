import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileLocalStorage extends LocalStorage {
  FileLocalStorage({required this.persistSessionKey});

  final String persistSessionKey;
  final _store = _SupabaseFileStore('supabase_auth');

  @override
  Future<void> initialize() => _store.initialize();

  @override
  Future<bool> hasAccessToken() async {
    return _store.exists(persistSessionKey);
  }

  @override
  Future<String?> accessToken() {
    return _store.read(persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() {
    return _store.delete(persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _store.write(persistSessionKey, persistSessionString);
  }
}

class FileGotrueAsyncStorage implements GotrueAsyncStorage {
  FileGotrueAsyncStorage() {
    _initialize();
  }

  final _store = _SupabaseFileStore('supabase_pkce');
  final Completer<void> _initializationCompleter = Completer<void>();

  Future<void> _initialize() async {
    await _store.initialize();
    _initializationCompleter.complete();
  }

  @override
  Future<String?> getItem({required String key}) async {
    await _initializationCompleter.future;
    return _store.read(key);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await _initializationCompleter.future;
    await _store.delete(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await _initializationCompleter.future;
    await _store.write(key, value);
  }
}

class _SupabaseFileStore {
  _SupabaseFileStore(this.subdirectoryName);

  final String subdirectoryName;
  Directory? _directory;

  Future<void> initialize() async {
    _directory = await _resolveDirectory();
  }

  Future<Directory> _resolveDirectory() async {
    final baseDirectory = await getApplicationSupportDirectory();
    final directory = Directory('${baseDirectory.path}/$subdirectoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _fileForKey(String key) async {
    final directory = _directory ??= await _resolveDirectory();
    final fileName = Uri.encodeComponent(key);
    return File('${directory.path}/$fileName.json');
  }

  Future<bool> exists(String key) async {
    final file = await _fileForKey(key);
    return file.exists();
  }

  Future<String?> read(String key) async {
    final file = await _fileForKey(key);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  Future<void> write(String key, String value) async {
    final file = await _fileForKey(key);
    await file.writeAsString(value, flush: true);
  }

  Future<void> delete(String key) async {
    final file = await _fileForKey(key);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
