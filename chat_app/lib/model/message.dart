class Message {
  final String from;
  final String to;
  final String content;
  final DateTime timestamp;

  Message({
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp,
  });
}
