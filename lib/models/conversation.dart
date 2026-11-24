import '../models/user.dart';

class Conversation {
  final int id;
  final User? otherUser;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  Conversation({
    required this.id,
    this.otherUser,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      otherUser: json['other_user'] != null
          ? User.fromJson(json['other_user'] as Map<String, dynamic>)
          : null,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final String text;
  final DateTime sentAt;
  final bool isMe;
  final User? sender;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isMe,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isMe: json['is_me'] as bool? ?? false,
      sender: json['sender'] != null
          ? User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }
}
