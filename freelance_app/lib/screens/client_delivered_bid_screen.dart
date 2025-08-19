import 'package:flutter/material.dart';
import 'package:freelance_app/screens/review_screen.dart';
import 'package:provider/provider.dart';
import '../providers/bid_provider.dart';
import '../models/bid_model.dart';
import 'payment_report_screen.dart';
//import 'submit_review_screen.dart'; // ⭐ NEW

class ClientDeliveredBidsScreen extends StatefulWidget {
  final int clientId;
  final VoidCallback onPaymentConfirmed;

  const ClientDeliveredBidsScreen({
    super.key,
    required this.clientId,
    required this.onPaymentConfirmed,
  });

  @override
  State<ClientDeliveredBidsScreen> createState() => _ClientDeliveredBidsScreenState();
}

class _ClientDeliveredBidsScreenState extends State<ClientDeliveredBidsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveredBids();
  }

  Future<void> _loadDeliveredBids() async {
    final bidProvider = Provider.of<BidProvider>(context, listen: false);
    await bidProvider.loadDeliveredBids(widget.clientId);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _confirmPayment(Bid bid) async {
    final bidProvider = Provider.of<BidProvider>(context, listen: false);
    final success = await bidProvider.confirmBidPayment(bid.id!);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment confirmed and sent")),
      );
      widget.onPaymentConfirmed();
      await _loadDeliveredBids();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveredBids = Provider.of<BidProvider>(context).deliveredBids;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivered Jobs'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveredBids.isEmpty
              ? const Center(child: Text('No delivered jobs yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: deliveredBids.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final bid = deliveredBids[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bid.job?.title ?? "Untitled Job",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
  "Freelancer's Name: ${bid.freelancerName ?? "Unknown"}",
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(height: 8),

                            Text(
                              "Proposal Message: ${bid.proposalMessage}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            if (bid.deliveryLink != null)
                              Text(
                                "Delivery Link: ${bid.deliveryLink}",
                                style: const TextStyle(color: Colors.blue),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              "Bid Amount: \$${bid.amount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                bid.status == "PAID" ? "PAID" : "Awaiting Payment",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  bid.status == "PAID" ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(height: 12),

                            // View Payment Report button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentReportScreen(bid: bid),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text("View Report"),
                              ),
                            ),

                            // Confirm & Pay (if not paid yet)
                            if (bid.status != "PAID")
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => _confirmPayment(bid),
                                  icon: const Icon(Icons.payment),
                                  label: const Text("Confirm & Pay"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),

                            // ⭐ NEW: Leave a Review (if paid)
                            if (bid.status == "PAID")
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SubmitReviewScreen(
                                          reviewerId: widget.clientId,                 // Client
                                          revieweeId: bid.freelancerId ?? 0,           // Freelancer
                                          jobId: bid.job?.id ?? 0,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.rate_review),
                                  label: const Text("Leave a Review"),
                                ),
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
