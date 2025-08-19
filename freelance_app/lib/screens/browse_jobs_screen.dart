import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/job_service.dart';
import '../models/job_model.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';
import 'freelancer_apply_screen.dart';
import 'package:intl/intl.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  List<Job> jobs = [];
  List<Job> filteredJobs = [];
  bool loading = true;
  bool hasError = false;
  int? userId;
  String searchQuery = "";
  Set<int> savedJobs = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
    loadJobs();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  Future<void> loadJobs() async {
    setState(() {
      loading = true;
      hasError = false;
    });
    try {
      final jobList = await JobService().getAllJobs();

      // Sort by id descending (newest first)
      jobList.sort((a, b) => b.id!.compareTo(a.id!));

      setState(() {
        jobs = jobList;
        filteredJobs = jobList;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        hasError = true;
      });
    }
  }

  void _searchJobs(String query) {
    setState(() {
      searchQuery = query;
      filteredJobs = jobs
          .where((job) =>
              job.title.toLowerCase().contains(query.toLowerCase()) ||
              job.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _toggleWishlist(Job job) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to save jobs.")),
      );
      return;
    }

    if (savedJobs.contains(job.id)) {
      // Just remove locally for now
      setState(() {
        savedJobs.remove(job.id);
      });
      return;
    }

    final wishlistItem = Wishlist(job: job, userId: userId!);

    try {
      await WishlistService().addToWishlist(wishlistItem);
      setState(() {
        savedJobs.add(job.id!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job saved to wishlist"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save job"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Jobs"),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: loadJobs,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _searchJobs,
                decoration: InputDecoration(
                  hintText: "Search jobs...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Job list
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(
                          child: Text(
                            "Error loading jobs. Pull down to refresh.",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : filteredJobs.isEmpty
                          ? const Center(
                              child: Text("No jobs found"),
                            )
                          : ListView.builder(
                              itemCount: filteredJobs.length,
                              itemBuilder: (context, index) {
                                final job = filteredJobs[index];
                                final skillsList = job.skills.isNotEmpty
                                    ? job.skills
                                        .split(',')
                                        .map((s) => s.trim())
                                        .toList()
                                    : <String>[];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title + Wishlist icon
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                job.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                savedJobs.contains(job.id)
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_outlined,
                                                color: savedJobs
                                                        .contains(job.id)
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  _toggleWishlist(job),
                                            )
                                          ],
                                        ),

                                        const SizedBox(height: 4),
                                        Text(
                                          job.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),

                                        const SizedBox(height: 8),
                                        if (skillsList.isNotEmpty)
                                          Wrap(
                                            spacing: 6,
                                            children: skillsList
                                                .map((skill) => Chip(
                                                      label: Text(skill),
                                                      backgroundColor:
                                                          Colors.teal.shade50,
                                                    ))
                                                .toList(),
                                          ),

                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Budget: \$${job.budget}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Due: ${job.deadline != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(job.deadline)) : 'N/A'}",
                                              style: const TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                            ),
                                            child: const Text("Apply"),
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final freelancerId =
                                                  prefs.getInt('userId') ?? 0;

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FreelancerApplyScreen(
                                                    jobId: job.id!,
                                                    jobTitle: job.title,
                                                    freelancerId: freelancerId,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
