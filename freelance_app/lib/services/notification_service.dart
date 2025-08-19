import 'dart:convert';
import 'package:freelance_app/models/notification_item.dart';
import 'package:http/http.dart' as http;
//import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8080/api/auth/notifications';  // Change to your backend URL

  Future<List<NotificationModel>> fetchNotifications(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<bool> markNotificationRead(int notificationId) async {
    final response = await http.put(Uri.parse('$baseUrl/$notificationId/read'));
    return response.statusCode == 200;
  }
}
