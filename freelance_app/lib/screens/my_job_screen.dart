import 'package:flutter/material.dart';
import 'package:freelance_app/screens/freelancer_delivery_report.dart';
import 'package:freelance_app/screens/review_screen.dart';
import 'package:provider/provider.dart';
import '../providers/bid_provider.dart';

class MyJobsScreen extends StatefulWidget {
  final int freelancerId;
  const MyJobsScreen({Key? key, required this.freelancerId}) : super(key: key);

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    await Provider.of<BidProvider>(context, listen: false)
        .loadAcceptedBids(widget.freelancerId);
    setState(() => _isLoading = false);
  }

  Future<void> _showDeliveryLinkDialog(int bidId) async {
    final TextEditingController _linkController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Deliver Job"),
        content: TextField(
          controller: _linkController,
          decoration: const InputDecoration(
            labelText: "Delivery Link",
            hintText: "Enter the link to your completed work",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_linkController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Delivery link cannot be empty.")),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text("Deliver"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deliveryLink = _linkController.text.trim();
      final bidProvider = Provider.of<BidProvider>(context, listen: false);

      final success = await bidProvider.deliverJob(bidId, deliveryLink: deliveryLink);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Job marked as delivered."
              : "Failed to deliver job."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bidProvider = Provider.of<BidProvider>(context);
    final acceptedJobs = bidProvider.acceptedBids;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Jobs"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : acceptedJobs.isEmpty
              ? const Center(child: Text("No accepted jobs yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: acceptedJobs.length,
                  itemBuilder: (ctx, i) {
                    final bid = acceptedJobs[i];
                    final job = bid.job!;
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job Title
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Job Description
                            Text(
                              job.description,
                              style: const TextStyle(color: Colors.black87),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),

                            // Deadline + Budget
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Deadline: ${job.deadline}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const Spacer(),
                                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                Text(
                                  job.budget.toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Your Bid & Status
                            Row(
                              children: [
                                Text(
                                  "Your Bid: \$${bid.amount}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Chip(
                                  label: Text(
                                    bid.deliveryStatus == 'DELIVERED'
                                        ? "Delivered"
                                        : "Not Delivered",
                                    style: TextStyle(
                                      color: bid.deliveryStatus == 'DELIVERED'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  backgroundColor: bid.deliveryStatus == 'DELIVERED'
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                ),
                              ],
                            ),

                            // Delivery Link (if delivered)
                            if (bid.deliveryStatus == 'DELIVERED' &&
                                bid.deliveryLink != null &&
                                bid.deliveryLink!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    // Open link logic
                                  },
                                  child: Text(
                                    "Delivery Link: ${bid.deliveryLink}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),

                            const Divider(height: 20),

                            // Action Buttons Row
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (bid.deliveryStatus != 'DELIVERED')
                                  ElevatedButton.icon(
                                    onPressed: () => _showDeliveryLinkDialog(bid.id!),
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text("Deliver"),
                                  ),
                                if (bid.deliveryStatus == 'DELIVERED')
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.rate_review),
                                    label: const Text("Leave Review"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SubmitReviewScreen(
                                            reviewerId: widget.freelancerId,
                                            revieweeId: job.clientId ?? 0,
                                            jobId: job.id ?? 0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                TextButton.icon(
                                  icon: const Icon(Icons.assessment),
                                  label: const Text("View Report"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FreelancerDeliveryReportScreen(
                                          bid: bid,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
