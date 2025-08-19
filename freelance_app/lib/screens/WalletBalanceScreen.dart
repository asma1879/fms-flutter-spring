//import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:freelance_app/services/wallet_service.dart';

//import '../services/wallet_service.dart';

class WalletBalance extends StatefulWidget {
  final int userId;
  final String role; // "client" or "freelancer"

  const WalletBalance({super.key, required this.userId, required this.role});

  @override
  State<WalletBalance> createState() => _WalletBalanceState();
}

class _WalletBalanceState extends State<WalletBalance> {
  double balance = 0.0;
  bool loading = true;

  final walletService = WalletService();

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  void loadWallet() async {
  try {
    double b = await walletService.getUserWallet(widget.userId);
    print('Fetched wallet balance: $b');
    setState(() {
      balance = b;
      loading = false;
    });
  } catch (e) {
    setState(() {
      balance = 0.0;
      loading = false;
    });
    print('Failed to load wallet: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return loading
        ? const CircularProgressIndicator()
        : Text(
            "Wallet Balance: \$${balance.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
  }
}
