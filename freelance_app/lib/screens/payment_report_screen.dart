import 'package:flutter/material.dart';
import 'package:freelance_app/models/bid_model.dart';

class PaymentReportScreen extends StatelessWidget {
  final Bid bid;

  const PaymentReportScreen({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final double systemFee = bid.amount * 0.10;
    final double freelancerReceives = bid.amount * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Report'),
        backgroundColor: const Color.fromARGB(209, 113, 110, 117),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Payment Receipt',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color.fromARGB(255, 106, 104, 110),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(thickness: 1.5, height: 30),
                _buildRow("Job Title", bid.job?.title ?? 'N/A'),
                _buildRow("Job ID", bid.jobId.toString()),
                _buildRow("Freelancer ID", bid.freelancerId.toString()),
                _buildRow("Total Amount", "\$${bid.amount.toStringAsFixed(2)}"),
                _buildRow("System Fee (10%)", "\$${systemFee.toStringAsFixed(2)}"),
                _buildRow("Paid to Freelancer (90%)", "\$${freelancerReceives.toStringAsFixed(2)}"),
                const SizedBox(height: 20),
                // Center(
                //   child: ElevatedButton.icon(
                //     icon: const Icon(Icons.share),
                //     label: const Text("Share Report"),
                //     onPressed: () {
                //       // TODO: implement share/download/report export
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.teal,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
