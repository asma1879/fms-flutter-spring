import 'package:flutter/material.dart';
import 'package:freelance_app/models/job_model.dart';

class HomeJobsScreen extends StatelessWidget {
  final List<Job> jobs;
  const HomeJobsScreen({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return jobs.isEmpty
        ? const Center(child: Text("No jobs available."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Budget: \$${job.budget.toStringAsFixed(2)}\nDeadline: ${job.deadline}"),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text("Apply"),
                  ),
                ),
              );
            },
          );
  }
}
