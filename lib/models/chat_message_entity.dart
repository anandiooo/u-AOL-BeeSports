class ChatMessageEntity {
  final String id;
  final String lobbyId;
  final String senderId;
  final String? senderName;
  final String content;
  final bool isSystem;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.lobbyId,
    required this.senderId,
    this.senderName,
    required this.content,
    this.isSystem = false,
    required this.createdAt,
  });

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map) {
    final profile = map['profile'] as Map<String, dynamic>?;
    return ChatMessageEntity(
      id: map['id'],
      lobbyId: map['lobby_id'],
      senderId: map['sender_id'],
      senderName: profile?['full_name'] ?? map['sender_name'],
      content: map['content'],
      isSystem: map['is_system'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
