import 'package:flutter/material.dart';
import 'package:freelance_app/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreelancerWalletScreen extends StatefulWidget {
  const FreelancerWalletScreen({super.key});

  @override
  State<FreelancerWalletScreen> createState() => _FreelancerWalletScreenState();
}

class _FreelancerWalletScreenState extends State<FreelancerWalletScreen> {
  double _walletBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final freelancerId = prefs.getInt('userId');
    if (freelancerId != null) {
      try {
        final balance = await WalletService().getUserWallet(freelancerId);
        setState(() {
          _walletBalance = balance;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load wallet balance")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallet"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Colors.teal),
                      const SizedBox(height: 20),
                      const Text("Available Balance", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                        "\$${_walletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
