import 'dart:convert';
import 'package:http/http.dart' as http;

class ChartService {
  final String baseUrl = "http://localhost:8080/api/auth/charts";

  Future<List<dynamic>> getJobsPerMonth() async {
    final response = await http.get(Uri.parse('$baseUrl/jobs-per-month'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chart data');
    }
  }

  Future<List<dynamic>> getBidsByStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/bids-by-status'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chart data');
    }
  }
}
