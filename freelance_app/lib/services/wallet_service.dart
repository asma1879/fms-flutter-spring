//import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;

class WalletService {
  final String baseUrl = 'http://localhost:8080/api/auth/wallet';

  Future<double> getUserWallet(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    //print('Wallet API response status: ${response.statusCode}');
    //print('Wallet API response body: ${response.body}');
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to load user wallet');
    }
  }

  Future<double> getFreelancerWallet(int freelancerId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$freelancerId'));
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to load freelancer wallet');
    }
  }
  Future<List<dynamic>> getWalletTransactions(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/wallet-transactions/user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load wallet transactions');
  }
}
