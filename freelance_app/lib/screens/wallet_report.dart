import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WalletReportScreen extends StatefulWidget {
  const WalletReportScreen({Key? key}) : super(key: key);

  @override
  State<WalletReportScreen> createState() => _WalletReportScreenState();
}

class _WalletReportScreenState extends State<WalletReportScreen> {
  double walletBalance = 0.0;
  List<WalletTransaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchWalletReport();
  }

  Future<void> _fetchWalletReport() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        setState(() {
          error = "User not logged in.";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/auth/wallet/$userId/report'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
       // print('Raw wallet report JSON: $data');

        final transactionsJson = data['transactions'] as List;
       // print('Transactions JSON list length: ${transactionsJson.length}');
        for (var tx in transactionsJson) {
          //print('Transaction: $tx');
        }

        setState(() {
          walletBalance = (data['walletBalance'] ?? 0).toDouble();
          transactions = transactionsJson
              .map((tx) => WalletTransaction.fromJson(tx))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load wallet report: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getAmountColor(String type) {
    switch (type) {
      case 'DEPOSIT':
      case 'FREELANCER_RECEIVED':
        return Colors.green;
      case 'WITHDRAWAL':
      case 'RELEASE':
      case 'RELEASE_PAYMENT': // added RELEASE_PAYMENT here
      case 'HOLD_FUNDS':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatAmount(double amount, String type) {
    String sign = (type == 'WITHDRAWAL' || type == 'RELEASE' || type == 'RELEASE_PAYMENT') ? "-" : "+";
    return "$sign\$${amount.toStringAsFixed(2)}";
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'DEPOSIT':
        return Icons.account_balance_wallet;
        case 'HOLD_FUNDS':
      return Icons.lock;
      case 'WITHDRAWAL':
        return Icons.money_off;
      case 'RELEASE':
      case 'RELEASE_PAYMENT': // added RELEASE_PAYMENT here
        return Icons.payment;
      case 'FREELANCER_RECEIVED':
        return Icons.attach_money;
      default:
        return Icons.account_balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet Report"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 156, 134, 147),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWalletReport,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchWalletReport,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: Colors.deepPurple.shade50,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                "Current Wallet Balance",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "\$${walletBalance.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Transactions",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...transactions.map((tx) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getAmountColor(tx.type).withOpacity(0.15),
                                child: Icon(_getIconForType(tx.type), color: _getAmountColor(tx.type)),
                              ),
                              title: Text(
                                tx.type.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _getAmountColor(tx.type),
                                ),
                              ),
                              subtitle: Text(tx.description),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatAmount(tx.amount, tx.type),
                                    style: TextStyle(
                                      color: _getAmountColor(tx.type),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(tx.transactionDate),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              "No transactions found.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class WalletTransaction {
  final int id;
  final double amount;
  final String type;
  final String description;
  final String transactionDate;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.transactionDate,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      description: json['description'] ?? '',
      transactionDate: json['transactionDate'],
    );
  }
}
