import 'dart:async';
import 'dart:html' as html;

import 'package:supabase_flutter/supabase_flutter.dart';

class FileLocalStorage extends LocalStorage {
  FileLocalStorage({required this.persistSessionKey});

  final String persistSessionKey;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return html.window.localStorage.containsKey(persistSessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return html.window.localStorage[persistSessionKey];
  }

  @override
  Future<void> removePersistedSession() async {
    html.window.localStorage.remove(persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    html.window.localStorage[persistSessionKey] = persistSessionString;
  }
}

class FileGotrueAsyncStorage implements GotrueAsyncStorage {
  FileGotrueAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> removeItem({required String key}) async {
    html.window.localStorage.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    html.window.localStorage[key] = value;
  }
}
