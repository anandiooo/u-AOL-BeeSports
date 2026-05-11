class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'] ?? 'general',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: map['data'] is Map ? Map<String, dynamic>.from(map['data']) : null,
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
