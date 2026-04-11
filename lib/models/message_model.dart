class Message {
  final int id;
  final int senderId;
  final String senderRole; // 'parent', 'educateur', 'admin'
  final int receiverId;
  final String receiverRole;
  final int? childId;
  final String message;
  final String createdAt;
  final String? readAt;
  final String? senderAvatar;

  Message({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    this.childId,
    required this.message,
    required this.createdAt,
    this.readAt,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      senderId: json['sender_id'] is int ? json['sender_id'] : int.parse(json['sender_id'].toString()),
      senderRole: json['sender_role'] ?? 'parent',
      receiverId: json['receiver_id'] is int ? json['receiver_id'] : int.parse(json['receiver_id'].toString()),
      receiverRole: json['receiver_role'] ?? 'parent',
      childId: json['child_id'] != null ? (json['child_id'] is int ? json['child_id'] : int.parse(json['child_id'].toString())) : null,
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      readAt: json['read_at'],
      senderAvatar: json['sender_avatar'],
    );
  }
}
