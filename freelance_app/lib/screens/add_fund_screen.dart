import 'package:flutter/material.dart';
import 'package:freelance_app/services/fund_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFundScreen extends StatefulWidget {
  const AddFundScreen({super.key});

  @override
  State<AddFundScreen> createState() => _AddFundScreenState();
}

class _AddFundScreenState extends State<AddFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController transactionCodeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  String? selectedMethod;
  bool submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final success = await FundService().addFund({
      'clientId': userId,
      'amount': double.parse(amountController.text),
      'paymentMethod': selectedMethod,
      'transactionCode': transactionCodeController.text,
      'paymentNumber': numberController.text,
    });

    setState(() => submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Funds added successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add funds.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Funds")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['Bkash', 'Nagad', 'Rocket', 'Card']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a payment method'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: transactionCodeController,
                decoration: const InputDecoration(labelText: 'Transaction Code'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter transaction code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Payment Number'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter payment number' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitting ? null : _submit,
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
