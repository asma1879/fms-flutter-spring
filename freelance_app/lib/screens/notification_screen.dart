import 'package:flutter/material.dart';
import 'package:freelance_app/models/notification_item.dart';
//import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;

  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.fetchNotifications(widget.userId);
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _notificationService.fetchNotifications(widget.userId);
    });
  }

  void _markAsRead(NotificationModel notification) async {
    bool success = await _notificationService.markNotificationRead(notification.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification marked as read')),
      );
      _refreshNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          final notifications = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  subtitle: Text(notification.timestamp.toLocal().toString()),
                  trailing: notification.read
                      ? const Icon(Icons.done, color: Colors.green)
                      : TextButton(
                          onPressed: () => _markAsRead(notification),
                          child: const Text('Mark as read'),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
