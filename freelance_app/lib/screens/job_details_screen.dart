import 'package:flutter/material.dart';
import '../models/job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  List<Widget> _buildSkillsChips(String skills) {
    final skillList = skills.split(',').map((e) => e.trim()).toList();
    return skillList.map((skill) {
      return Chip(
        label: Text(skill),
        backgroundColor: Colors.deepPurple.shade100,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Budget: \$${job.budget.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "Deadline: ${job.deadline}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _buildSkillsChips(job.skills),
            ),
            const SizedBox(height: 20),
            const Text(
              "Job Description",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
