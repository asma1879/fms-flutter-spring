import 'package:flutter/material.dart';
import 'package:freelance_app/models/bid_model.dart';
import 'package:freelance_app/providers/bid_provider.dart';
import 'package:provider/provider.dart';

class FreelancerApplyScreen extends StatefulWidget {
  final int jobId;
  final int freelancerId;
  final String jobTitle;

  const FreelancerApplyScreen({
    super.key,
    required this.jobId,
    required this.freelancerId,
    required this.jobTitle,
  });

  @override
  State<FreelancerApplyScreen> createState() => _FreelancerApplyScreenState();
}

class _FreelancerApplyScreenState extends State<FreelancerApplyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply to ${widget.jobTitle}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Bid Amount"),
            ),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Proposal Message"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final bid = Bid(
                  amount: double.parse(_amountController.text),
                  proposalMessage: _messageController.text,
                  freelancerId: widget.freelancerId,
                  jobId: widget.jobId,
                );

                final provider = Provider.of<BidProvider>(context, listen: false);
                final success = await provider.submitBid(bid);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Bid submitted successfully!'
                        : 'Failed to submit bid'),
                  ),
                );
              },
              child: const Text("Submit Bid"),
            )
          ],
        ),
      ),
    );
  }
}
