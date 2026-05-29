import 'package:beesports/models/chat_message_entity.dart';
import 'package:beesports/core/result.dart';

abstract class ChatRepository {
  Future<Result<List<ChatMessageEntity>>> getMessages(String lobbyId);

  Future<Result<void>> sendMessage({
    required String lobbyId,
    required String senderId,
    required String content,
  });

  Stream<ChatMessageEntity> subscribeToMessages(String lobbyId);

  void unsubscribe(String lobbyId);
}
