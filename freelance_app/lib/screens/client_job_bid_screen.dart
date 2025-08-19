import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import 'package:freelance_app/models/bid_model.dart';
import 'package:freelance_app/providers/bid_provider.dart';
import 'package:freelance_app/screens/send_message_screen.dart';
import 'package:freelance_app/screens/freelancer_profile_screen.dart';

class ClientJobBidsScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const ClientJobBidsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<ClientJobBidsScreen> createState() => _ClientJobBidsScreenState();
}

class _ClientJobBidsScreenState extends State<ClientJobBidsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<BidProvider>(context, listen: false).loadBids(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bids for "${widget.jobTitle}"'),
        centerTitle:true,
        backgroundColor: Colors.teal,
      ),
      body: Consumer<BidProvider>(
        builder: (context, bidProvider, _) {
          final bids = bidProvider.bids;
          if (bids.isEmpty) {
            return const Center(child: Text("No bids for this job yet."));
          }
          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Freelancer Name
                      if (bid.freelancerName != null && bid.freelancerName!.isNotEmpty)
                        Text(
                          bid.freelancerName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple,
                          ),
                        ),
                      const SizedBox(height: 6),

                      // Bid Amount
                      Text(
                        'Bid Amount: \$${bid.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      

                      // Proposal
                      Text('Proposal: ${bid.proposalMessage}'),
                      const SizedBox(height: 4),

                      // Status
                      Text(
                        'Status: ${bid.status ?? 'PENDING'}',
                        style: TextStyle(
                          color: bid.status == 'ACCEPTED'
                              ? Colors.green
                              : bid.status == 'REJECTED'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person),
                            label: const Text("View Profile"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FreelancerProfileScreen(
                                    userId: bid.freelancerId,
                                    readOnly: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                tooltip: 'Accept',
                                color: Colors.green,
                                onPressed: bid.status == 'ACCEPTED'
                                    ? null
                                    : () => _changeBidStatus(bid, 'ACCEPTED'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Reject',
                                color: Colors.red,
                                onPressed: bid.status == 'REJECTED'
                                    ? null
                                    : () => _changeBidStatus(bid, 'REJECTED'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                tooltip: 'Message',
                                color: Colors.blue,
                                onPressed: () => _sendMessage(bid.freelancerId),
                              ),
                              if (bid.status == 'ACCEPTED' &&
                                  !bid.isPaidToFreelancer)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.lock),
                                  label: const Text("Accept & Hold"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 58, 183, 177),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _acceptBidAndHold(bid),
                                ),
                              if (bid.status == 'DELIVERED' &&
                                  !bid.isPaidToFreelancer)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.payment),
                                  label: const Text("Release Payment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _releasePayment(bid),
                                ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _changeBidStatus(Bid bid, String status) async {
    final provider = Provider.of<BidProvider>(context, listen: false);
    final success = await provider.changeBidStatus(bid.id!, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Bid ${status.toLowerCase()} successfully'
            : 'Failed to update bid status'),
      ),
    );
  }

  void _acceptBidAndHold(Bid bid) async {
    final provider = Provider.of<BidProvider>(context, listen: false);
    final success = await provider.acceptBidAndHoldFunds(bid.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Bid accepted and funds moved to system.'
            : 'Failed to accept bid.'),
      ),
    );
  }

  void _releasePayment(Bid bid) async {
    final provider = Provider.of<BidProvider>(context, listen: false);
    final success = await provider.confirmBidPayment(bid.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Payment released to freelancer.'
            : 'Failed to release payment.'),
      ),
    );

    if (success) {
      setState(() {
        bid.isPaidToFreelancer = true;
      });
    }
  }

  void _sendMessage(int freelancerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendMessageScreen(
          receiverId: freelancerId,
        ),
      ),
    );
  }
}
