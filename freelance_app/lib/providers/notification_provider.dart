import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freelance_app/models/notification_item.dart';
//import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Timer? _pollingTimer;

  void startPolling(int userId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchNotifications(userId);
    });
    // Also fetch immediately
    fetchNotifications(userId);
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchNotifications(int userId) async {
    try {
      final list = await _service.fetchNotifications(userId);
      _notifications = list;
      _unreadCount = list.where((n) => !n.read).length;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch notifications: $e");
    }
  }

  Future<void> markAsRead(int notificationId) async {
    bool success = await _service.markNotificationRead(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          read: true,
        );
        _unreadCount = _notifications.where((n) => !n.read).length;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
