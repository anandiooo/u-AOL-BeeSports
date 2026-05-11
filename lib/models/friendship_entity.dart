class FriendshipEntity {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status;
  final String? requesterName;
  final String? addresseeName;
  final String? requesterAvatar;
  final String? addresseeAvatar;
  final DateTime createdAt;

  const FriendshipEntity({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    this.requesterName,
    this.addresseeName,
    this.requesterAvatar,
    this.addresseeAvatar,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';

  factory FriendshipEntity.fromMap(Map<String, dynamic> map) {
    final requester = map['requester'] as Map<String, dynamic>?;
    final addressee = map['addressee'] as Map<String, dynamic>?;
    return FriendshipEntity(
      id: map['id'],
      requesterId: map['requester_id'],
      addresseeId: map['addressee_id'],
      status: map['status'] ?? 'pending',
      requesterName: requester?['full_name'] ?? map['requester_name'],
      addresseeName: addressee?['full_name'] ?? map['addressee_name'],
      requesterAvatar: requester?['avatar_url'],
      addresseeAvatar: addressee?['avatar_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
