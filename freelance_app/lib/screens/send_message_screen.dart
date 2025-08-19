import 'package:flutter/material.dart';
import 'package:freelance_app/models/message.dart';
//import '../models/message_model.dart';
import '../services/message_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendMessageScreen extends StatefulWidget {
  final int receiverId;

  const SendMessageScreen({super.key, required this.receiverId});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final MessageService _messageService = MessageService();

  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }

  void _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final senderId = await _getCurrentUserId();

    final message = Message(
      content: content,
      senderId: senderId,
      receiverId: widget.receiverId,
      timestamp: DateTime.now().toIso8601String(),

    );

    final success = await _messageService.sendMessage(message);

    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Message')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Send your message below',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _send,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
