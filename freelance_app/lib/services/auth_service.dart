import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080/api/auth';

  Future<User> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200 && response.body.isNotEmpty) {
    final body = jsonDecode(response.body);

    // Create User object from flat JSON (not from body['user'])
    return User.fromJson(body); // body has id, name, email, role
  } else if (response.statusCode == 401) {
    throw Exception("Invalid email or password");
  } else {
    throw Exception("Login failed: ${response.statusCode}");
  }
}

  Future<User> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }
}
