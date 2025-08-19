class Message {
  final int? id;
  final String content;
  final String? timestamp; // ISO-8601 format as String
  final int senderId;
  final int receiverId;

  Message({
    this.id,
    required this.content,
    this.timestamp,
    required this.senderId,
    required this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      timestamp: json['timestamp'],
      senderId: json['sender']['id'],
      receiverId: json['receiver']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': {'id': senderId},
      'receiver': {'id': receiverId},
    };
  }
}
