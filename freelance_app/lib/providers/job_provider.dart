// providers/job_provider.dart
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];

  List<Job> get jobs => _jobs;

  Future<void> fetchJobs() async {
    _jobs = await JobService().getAllJobs();
    notifyListeners();
  }
}
