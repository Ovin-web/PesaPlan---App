import 'package:flutter/material.dart';
import 'package:pesaplan_new/models/expense.dart';
import 'package:pesaplan_new/services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const AddExpenseScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
  TextEditingController();
  final TextEditingController _amountController =
  TextEditingController();
  final TextEditingController _categoryController =
  TextEditingController();

  bool _isSaving = false;
  bool _isRecurring = false;
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final expense = Expense(
        id: '',
        title: _titleController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        isRecurring: _isRecurring,
      );

      await widget.expenseService.addExpense(expense);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Expense saved successfully"),
        ),
      );

      Navigator.pop(context, true); // return success to refresh dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration:
                const InputDecoration(labelText: "Title"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Amount (TZS)"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter amount";
                  if (double.tryParse(v) == null) {
                    return "Invalid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration:
                const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                      "Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Change"),
                  )
                ],
              ),
              SwitchListTile(
                value: _isRecurring,
                onChanged: (v) =>
                    setState(() => _isRecurring = v),
                title: const Text("Recurring Expense"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Save Expense"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
