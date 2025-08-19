// file: freelancer_job_report_screen.dart
import 'package:flutter/material.dart';
import 'package:freelance_app/models/bid_model.dart';  // adjust path as needed

class FreelancerJobReportScreen extends StatelessWidget {
  final Bid bid;

  const FreelancerJobReportScreen({Key? key, required this.bid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final job = bid.job;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Delivery Report"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: job == null
            ? const Center(child: Text("No job data available"))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Client ID: ${job.clientId ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Divider(height: 24, thickness: 1),
                    Text(
                      job.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    _infoRow("Budget", "\$${job.budget.toStringAsFixed(2)}"),
                    _infoRow("Deadline", job.deadline),
                    _infoRow("Bid Amount", "\$${bid.amount.toStringAsFixed(2)}"),
                    _infoRow("Bid Status", bid.status ?? "Unknown"),
                    _infoRow("Delivery Status", bid.deliveryStatus ?? "Unknown"),
                    _infoRow("Delivery Time", bid.deliveryTime ?? "Not Delivered"),
                    const SizedBox(height: 16),
                    if (bid.deliveryLink != null && bid.deliveryLink!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery Link / File:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              // Implement link opening or file preview if desired
                            },
                            child: Text(
                              bid.deliveryLink!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    Text(
                      "Proposal Message:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(bid.proposalMessage),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Thank you for your professionalism and hard work!",
                        style: TextStyle(color: Colors.teal.shade700, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value),
        ],
      ),
    );
  }
}
