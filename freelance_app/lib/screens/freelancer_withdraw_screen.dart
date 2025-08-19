import 'package:flutter/material.dart';
import 'package:freelance_app/models/withdrawal_request.dart';
import 'package:freelance_app/services/withdrawal_service.dart';
import 'package:intl/intl.dart';

class FreelancerWithdrawScreen extends StatefulWidget {
  final int freelancerId;

  const FreelancerWithdrawScreen({super.key, required this.freelancerId});

  @override
  State<FreelancerWithdrawScreen> createState() => _FreelancerWithdrawScreenState();
}

class _FreelancerWithdrawScreenState extends State<FreelancerWithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();

  String _selectedMethod = 'PayPal';
  final List<String> _methods = ['PayPal', 'Bank Transfer', 'Payoneer'];

  bool _loading = false;
  bool _tableLoading = true;
  List<WithdrawalRequest> _withdrawals = [];

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _submitWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await WithdrawalService().submitWithdrawal(
      widget.freelancerId,
      _selectedMethod,
      _accountController.text,
      amount,
    );

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Withdrawal submitted' : 'Withdrawal failed')),
    );

    if (success) {
      _amountController.clear();
      _accountController.clear();
      _loadWithdrawals();
    }
  }

  Future<void> _loadWithdrawals() async {
    setState(() => _tableLoading = true);
    try {
      final data = await WithdrawalService().getWithdrawalsByFreelancer(widget.freelancerId);
      setState(() {
        _withdrawals = data;
        _tableLoading = false;
      });
    } catch (e) {
      setState(() => _tableLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load withdrawal history')),
      );
    }
  }

  Widget _buildAccountFieldInfo() {
    switch (_selectedMethod) {
      case 'PayPal':
        return const Text('Enter your PayPal Email');
      case 'Bank Transfer':
        return const Text('Enter your Bank Account Number / IFSC');
      case 'Payoneer':
        return const Text('Enter your Payoneer Email');
      default:
        return const Text('Enter Account Information');
    }
  }

  Widget _buildWithdrawalTable() {
    if (_tableLoading) return const Center(child: CircularProgressIndicator());
    if (_withdrawals.isEmpty) return const Text("No withdrawal history yet.");

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Method")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Status")),
        ],
        rows: _withdrawals.map((w) {
          return DataRow(cells: [
            DataCell(Text(DateFormat('yyyy-MM-dd').format(w.requestDate))),
            DataCell(Text(w.method)),
            DataCell(Text("\$${w.amount.toStringAsFixed(2)}")),
            DataCell(Text(
              w.status,
              style: TextStyle(
                color: w.status == "COMPLETED" ? Colors.green : Colors.orange,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }


  void _onSelectOverflow(String choice) {
  switch (choice) {
    case 'Wallet':
      Navigator.pushNamed(context, '/freelancersWallet');
      break;
    case 'Withdraw':
      // Current screen, maybe do nothing or refresh
      _loadWithdrawals();
      break;
    case 'History':
      Navigator.pushNamed(context, '/freelancerWithdrawalTable', arguments: widget.freelancerId);
      break;
    case 'Reports':
      Navigator.pushNamed(context, '/freelancerReports', arguments: widget.freelancerId);
      break;
    case 'Wallet Report':
      Navigator.pushNamed(context, '/walletReport');
      break;
    case 'Wishlist':
      Navigator.pushNamed(context, '/wishlist', arguments: widget.freelancerId);
      break;
    case 'Reviews':
      Navigator.pushNamed(context, '/freelancerReviews', arguments: widget.freelancerId);
      break;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(213, 148, 151, 132),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onSelectOverflow,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Wallet', child: Text('Wallet')),
              PopupMenuItem(value: 'Withdraw', child: Text('Withdraw')),
              PopupMenuItem(value: 'History', child: Text('Withdrawal History')),
              PopupMenuItem(value: 'Reports', child: Text('Reports')),
              PopupMenuItem(value: 'Wallet Report', child: Text('Wallet Report')),
              PopupMenuItem(value: 'Wishlist', child: Text('Wishlist')),
              PopupMenuItem(value: 'Reviews', child: Text('Reviews')),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                    border: OutlineInputBorder(),
                  ),
                  items: _methods
                      .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMethod = val);
                  },
                ),
                const SizedBox(height: 12),
                _buildAccountFieldInfo(),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: "Account Info",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter account info' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter amount' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _submitWithdraw,
                  icon: const Icon(Icons.send),
                  label: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Submit Withdrawal"),
                ),
                const SizedBox(height: 30),
                const Text("Withdrawal History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildWithdrawalTable(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
