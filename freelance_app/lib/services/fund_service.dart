import 'dart:convert';
import 'package:http/http.dart' as http;

class FundService {
  final String baseUrl = 'http://localhost:8080/api/auth/funds';

  Future<bool> addFund(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}
