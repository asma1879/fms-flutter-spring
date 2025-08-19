import 'dart:convert';
import 'package:freelance_app/models/message.dart';
import 'package:http/http.dart' as http;
//import '../models/message_model.dart';

class MessageService {
  final String baseUrl = 'http://localhost:8080/api/auth/messages';

  Future<bool> sendMessage(Message message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<List<Message>> getMessagesBetweenUsers(int userId1, int userId2) async {
    final response = await http.get(
      Uri.parse('$baseUrl/between?userId1=$userId1&userId2=$userId2'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
