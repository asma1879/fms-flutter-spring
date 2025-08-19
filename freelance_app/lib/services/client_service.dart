import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

class ClientService {
  final String baseUrl = 'http://localhost:8080/api/clients';

  Future<Client> getClientById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load client');
    }
  }
}
