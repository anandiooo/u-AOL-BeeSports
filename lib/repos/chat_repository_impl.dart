import 'dart:async';

import 'package:beesports/models/chat_message_entity.dart';
import 'package:beesports/repos/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};

  ChatRepositoryImpl(this._client);

  @override
  Future<Result<List<ChatMessageEntity>>> getMessages(String lobbyId) async {
    return withRetry(() async {
      final data = await _client
          .from('chat_messages')
          .select('*, profile:profiles!chat_messages_sender_id_fkey(full_name)')
          .eq('lobby_id', lobbyId)
          .order('created_at', ascending: true)
          .limit(100);

      return (data as List).map((e) => ChatMessageEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<void>> sendMessage({
    required String lobbyId,
    required String senderId,
    required String content,
  }) async {
    return withRetry(() async {
      await _client.from('chat_messages').insert({
        'lobby_id': lobbyId,
        'sender_id': senderId,
        'content': content,
        'is_system': false,
      });
    });
  }

  @override
  Stream<ChatMessageEntity> subscribeToMessages(String lobbyId) {
    final controller = StreamController<ChatMessageEntity>.broadcast();

    final channel = _client
        .channel('lobby-chat-$lobbyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'lobby_id',
            value: lobbyId,
          ),
          callback: (payload) async {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty) {
              final profileData = await _client
                  .from('profiles')
                  .select('full_name')
                  .eq('id', newRow['sender_id'])
                  .maybeSingle();
              newRow['sender_name'] = profileData?['full_name'];
              controller.add(ChatMessageEntity.fromMap(newRow));
            }
          },
        )
        .subscribe();

    _channels[lobbyId] = channel;

    controller.onCancel = () {
      unsubscribe(lobbyId);
    };

    return controller.stream;
  }

  @override
  void unsubscribe(String lobbyId) {
    final channel = _channels.remove(lobbyId);
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }
}
