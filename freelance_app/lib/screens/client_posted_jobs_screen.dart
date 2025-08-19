import 'package:flutter/material.dart';
import 'package:freelance_app/models/job_model.dart';
import 'package:freelance_app/screens/client_job_bid_screen.dart';
import 'package:freelance_app/services/job_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientPostedJobsScreen extends StatefulWidget {
  const ClientPostedJobsScreen({super.key});

  @override
  State<ClientPostedJobsScreen> createState() => _ClientPostedJobsScreenState();
}

class _ClientPostedJobsScreenState extends State<ClientPostedJobsScreen> {
  List<Job> jobs = [];
  bool loading = true;
  int? clientId;
  Job? _selectedJob; // for dropdown

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getInt('userId');

    if (clientId != null) {
      try {
        List<Job> fetchedJobs = await JobService().getJobsByClient(clientId!);
        setState(() {
          jobs = fetchedJobs;
          loading = false;
        });
      } catch (e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load jobs.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Posted Jobs")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? const Center(child: Text("No jobs posted yet."))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<Job>(
                        isExpanded: true,
                        value: _selectedJob,
                        hint: const Text("Select a job to view bids"),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Posted Job Titles",
                        ),
                        items: jobs.map((job) {
                          return DropdownMenuItem(
                            value: job,
                            child: Text(job.title),
                          );
                        }).toList(),
                        onChanged: (job) {
                          if (job != null) {
                            setState(() => _selectedJob = job);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientJobBidsScreen(
                                  jobId: job.id!,
                                  jobTitle: job.title,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return _buildJobCard(job);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientJobBidsScreen(
                jobId: job.id!,
                jobTitle: job.title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(job.description),
              const SizedBox(height: 6),
              Text("Skills: ${job.skills}",
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 6),
              Text("Budget: \$${job.budget.toStringAsFixed(2)}"),
              Text("Deadline: ${job.deadline}"),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text("View Bids"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(218, 226, 174, 213),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientJobBidsScreen(
                          jobId: job.id!,
                          jobTitle: job.title,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
