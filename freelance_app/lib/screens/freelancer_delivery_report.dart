import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:freelance_app/models/bid_model.dart';

class FreelancerDeliveryReportScreen extends StatelessWidget {
  final Bid bid;

  const FreelancerDeliveryReportScreen({super.key, required this.bid});

  String formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat.yMMMMd().add_jm().format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double systemFee = bid.amount * 0.10;
    final double freelancerEarnings = bid.amount * 0.90;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Delivery Report'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Delivery Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.deepPurple.shade100, thickness: 2),
                    const SizedBox(height: 20),

                    // Job Title
                    _infoRow(
                      icon: Icons.work_outline,
                      title: 'Job Title',
                      value: bid.job?.title ?? 'N/A',
                    ),

                    // Proposal Message
                    _infoRow(
                      icon: Icons.message_outlined,
                      title: 'Proposal',
                      value: bid.proposalMessage,
                    ),

                    // Bid Amount
                    _infoRow(
                      icon: Icons.attach_money_outlined,
                      title: 'Bid Amount',
                      value: '\$${bid.amount.toStringAsFixed(2)}',
                      valueColor: Colors.green.shade700,
                    ),

                    // Freelancer Earnings (90%)
                    _infoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Your Earnings (90%)',
                      value: '\$${freelancerEarnings.toStringAsFixed(2)}',
                      valueColor: Colors.teal.shade700,
                    ),

                    // Payment status
                    _infoRow(
                      icon: Icons.payment,
                      title: 'Payment Status',
                      value: bid.isPaidToFreelancer ? 'Paid' : 'Pending',
                      valueColor: bid.isPaidToFreelancer ? Colors.green : Colors.orange,
                    ),

                    // Delivery Status
                    _infoRow(
                      icon: Icons.delivery_dining,
                      title: 'Delivery Status',
                      value: bid.deliveryStatus ?? 'Not Delivered',
                      valueColor: (bid.deliveryStatus ?? '').toLowerCase() == 'delivered'
                          ? Colors.green
                          : Colors.redAccent,
                    ),

                    // Delivery Date
                    _infoRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Delivery Date',
                      value: formatDate(bid.deliveryTime),
                    ),

                    // Delivery Link (if any)
                    if (bid.deliveryLink != null && bid.deliveryLink!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.link_outlined, color: Colors.deepPurple),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                bid.deliveryLink!,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Share / Export button
                    // Center(
                    //   child: ElevatedButton.icon(
                    //     icon: const Icon(Icons.share),
                    //     label: const Text('Share Delivery Report'),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color.fromARGB(255, 62, 183, 58),
                    //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       elevation: 5,
                    //     ),
                    //     onPressed: () {
                    //       // TODO: Implement share functionality (e.g. using share_plus)
                    //     },
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 26),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
