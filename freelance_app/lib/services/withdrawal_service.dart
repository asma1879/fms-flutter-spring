import 'dart:convert';
import 'package:freelance_app/models/withdrawal_request.dart';
import 'package:http/http.dart' as http;

class WithdrawalService {
  final String baseUrl = 'http://localhost:8080/api/auth/withdraw';

  Future<bool> submitWithdrawal(int freelancerId, String method, String accountInfo, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/freelancer/$freelancerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'method': method,
        'accountInfo': accountInfo,
        'amount': amount,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<WithdrawalRequest>> getWithdrawalsByFreelancer(int freelancerId) async {
    final response = await http.get(Uri.parse('$baseUrl/freelancer/$freelancerId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => WithdrawalRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load withdrawals');
    }
  }
}
