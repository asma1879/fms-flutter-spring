import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class JobService {
  final String baseUrl = 'http://localhost:8080/api/auth/jobs';

  Future<bool> postJob(Map<String, dynamic> jobData) async {
  // Wrap clientId as client: { id: clientId }
  final modifiedJobData = Map<String, dynamic>.from(jobData);
  
  if (jobData['clientId'] != null) {
    modifiedJobData['client'] = {'id': jobData['clientId']};
    modifiedJobData.remove('clientId');
  }
  
  final response = await http.post(
    Uri.parse('$baseUrl/post'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(modifiedJobData),
  );
  return response.statusCode == 200;
}


  Future<List<Job>> getJobsByClient(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/client/$clientId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((job) => Job.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load client jobs');
    }
  }

  Future<List<Job>> getAllJobs() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((job) => Job.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load all jobs');
    }
  }
}
