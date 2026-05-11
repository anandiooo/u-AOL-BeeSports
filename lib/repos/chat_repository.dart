import 'package:beesports/models/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String lobbyId);

  Future<void> sendMessage({
    required String lobbyId,
    required String senderId,
    required String content,
  });

  Stream<ChatMessageEntity> subscribeToMessages(String lobbyId);

  void unsubscribe(String lobbyId);
}
