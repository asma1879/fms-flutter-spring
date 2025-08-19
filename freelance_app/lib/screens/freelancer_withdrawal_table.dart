import 'package:flutter/material.dart';
import 'package:freelance_app/models/withdrawal_request.dart';
import 'package:freelance_app/services/withdrawal_service.dart';
import 'package:intl/intl.dart';

class FreelancerWithdrawalTableScreen extends StatefulWidget {
  final int freelancerId;

  const FreelancerWithdrawalTableScreen({super.key, required this.freelancerId});

  @override
  State<FreelancerWithdrawalTableScreen> createState() =>
      _FreelancerWithdrawalTableScreenState();
}

class _FreelancerWithdrawalTableScreenState
    extends State<FreelancerWithdrawalTableScreen> {
  List<WithdrawalRequest> withdrawals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
    try {
      final result = await WithdrawalService()
          .getWithdrawalsByFreelancer(widget.freelancerId);
      setState(() {
        withdrawals = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load records: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdrawal History")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : withdrawals.isEmpty
              ? const Center(child: Text("No withdrawal records yet."))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Method")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Status")),
                    ],
                    rows: withdrawals.map((w) {
                      return DataRow(cells: [
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(w.requestDate))),
                        DataCell(Text(w.method)),
                        DataCell(Text("\$${w.amount.toStringAsFixed(2)}")),
                        DataCell(Text(
                          w.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: w.status == "COMPLETED"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}
