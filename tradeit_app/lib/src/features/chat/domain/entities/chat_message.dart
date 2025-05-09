class ChatMessage {
  final String text;
  final String sender;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
  });
}