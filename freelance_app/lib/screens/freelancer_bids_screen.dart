import 'package:flutter/material.dart';
import 'package:freelance_app/screens/job_details_screen.dart';
import '../models/bid_model.dart';
import '../services/bid_service.dart';

class FreelancerBidsScreen extends StatefulWidget {
  final int freelancerId;
  const FreelancerBidsScreen({Key? key, required this.freelancerId}) : super(key: key);

  @override
  State<FreelancerBidsScreen> createState() => _FreelancerBidsScreenState();
}

class _FreelancerBidsScreenState extends State<FreelancerBidsScreen> {
  late Future<List<Bid>> _bids;

  @override
  void initState() {
    super.initState();
    _bids = BidService().getBidsByFreelancer(widget.freelancerId);
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade400;
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getDeliveryStatusColor(String? deliveryStatus) {
    if (deliveryStatus == null) return Colors.grey.shade400;
    switch (deliveryStatus.toUpperCase()) {
      case 'DELIVERED':
        return Colors.green.shade600;
      case 'NOT DELIVERED':
      case 'PENDING':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildBidCard(Bid bid) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title and Bid Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    bid.job?.title ?? bid.jobTitle ?? 'Unknown Job',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bid.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bid.status ?? 'N/A',
                    style: TextStyle(
                      color: _getStatusColor(bid.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Proposal Message
            Text(
              bid.proposalMessage,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // Divider
            const Divider(height: 1, thickness: 1),

            const SizedBox(height: 12),

            // Bid Amount, Bid Time, Delivery Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Bid Amount: ',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: '\$${bid.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Bid Time: ',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: bid.bidTime ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDeliveryStatusColor(bid.deliveryStatus).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bid.deliveryStatus ?? 'N/A',
                    style: TextStyle(
                      color: _getDeliveryStatusColor(bid.deliveryStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Delivery Link (if available)
            if (bid.deliveryLink != null && bid.deliveryLink!.isNotEmpty)
              InkWell(
                onTap: () {
                  // TODO: open delivery link in browser or webview
                },
                child: Text(
                  "Delivery Link: ${bid.deliveryLink}",
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 15),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
  onPressed: () {
    if (bid.job != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobDetailsScreen(job: bid.job!),
        ),
      );
    } else {
      // If no job object, just show a SnackBar or optional modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job details not available for "${bid.jobTitle ?? 'Unknown Job'}"'),
        ),
      );
    }
  },
  icon: const Icon(Icons.work_outline, size: 20),
  label: const Text("View Job"),
),


                const SizedBox(width: 16),
                if (bid.status?.toLowerCase() == 'accepted' && bid.deliveryStatus != 'DELIVERED')
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Show delivery dialog
                    },
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: const Text("Deliver Work"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bids"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Bid>>(
        future: _bids,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading bids: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You haven't placed any bids yet."));
          }
          //final bids = snapshot.data!;
          final bids = snapshot.data!..sort((a, b) => b.id!.compareTo(a.id!));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              return _buildBidCard(bid);
            },
          );
        },
      ),
    );
  }
}
