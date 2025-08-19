import 'package:flutter/material.dart';
import 'package:freelance_app/screens/add_fund_screen.dart';
import 'package:freelance_app/screens/client_delivered_bid_screen.dart';
import 'package:freelance_app/screens/client_post_job_screen.dart';
import 'package:freelance_app/screens/client_posted_jobs_screen.dart';
import 'package:freelance_app/screens/client_review_screen.dart';
import 'package:freelance_app/screens/wallet_report.dart';

class OverviewPage extends StatelessWidget {
  final String username;
  final double walletBalance;
  final bool loading;
  final int? clientId;
  final Future<void> Function() loadWalletCallback;
  final VoidCallback logoutCallback;

  const OverviewPage({
    super.key,
    required this.username,
    required this.walletBalance,
    required this.loading,
    required this.clientId,
    required this.loadWalletCallback,
    required this.logoutCallback,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadWalletCallback,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Wallet Balance",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          "\$${walletBalance.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddFundScreen()),
                            );
                            await loadWalletCallback();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Funds"),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _quickActions(context),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _actionButton(context, Icons.post_add, "Post Job", () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPostJobScreen()));
        }),
        _actionButton(context, Icons.list_alt, "My Jobs", () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPostedJobsScreen()));
        }),
        _actionButton(context, Icons.delivery_dining, "Delivered", () {
          if (clientId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientDeliveredBidsScreen(
                  clientId: clientId!,
                  onPaymentConfirmed: loadWalletCallback,
                ),
              ),
            );
          }
        }),
        _actionButton(context, Icons.account_balance_wallet, "Wallet Report", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletReportScreen()),
          );
        }),
        _actionButton(context, Icons.rate_review, "Reviews", () {
          if (clientId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClientReviewsScreen(clientId: clientId!)),
            );
          }
        }),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
