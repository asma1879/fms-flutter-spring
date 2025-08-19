class NotificationModel {
  final int id;
  final int userId;
  final String message;
  final DateTime timestamp;
  final bool read;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
    );
  }
}
