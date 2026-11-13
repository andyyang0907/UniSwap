enum MessageType { text, intent, appointment }

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isMine;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    DateTime? createdAt,
    this.isMine = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ChatSession {
  final String id;
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  String lastMessage;
  DateTime lastMessageAt;
  int unreadCount;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    required this.lastMessage,
    DateTime? lastMessageAt,
    this.unreadCount = 0,
    this.messages = const [],
  }) : lastMessageAt = lastMessageAt ?? DateTime.now();
}
