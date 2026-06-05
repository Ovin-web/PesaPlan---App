import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesaplan_new/services/income_service.dart';

class AddIncomeScreen extends StatefulWidget {
  final IncomeService incomeService;

  const AddIncomeScreen({
    super.key,
    required this.incomeService,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _sourceController =
  TextEditingController();
  final TextEditingController _amountController =
  TextEditingController();

  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await widget.incomeService.addIncome(
        source: _sourceController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("✅ Income Saved"),
          content: const Text(
              "Your income has been added successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMMd().format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Income")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Income Details",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: "Source",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter source" : null,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (TZS)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter amount";
                  if (double.tryParse(v) == null) {
                    return "Invalid number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey)),
                leading: const Icon(Icons.date_range),
                title: const Text("Income Date"),
                subtitle: Text(dateText),
                onTap: _pickDate,
              ),

              const SizedBox(height: 26),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSaving ? null : _saveIncome,
                child: _isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.white),
                )
                    : const Text(
                  "Save Income",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
