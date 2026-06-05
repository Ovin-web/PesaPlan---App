import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pesaplan_new/models/expense.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<List<Expense>>(context);
    final incomes = Provider.of<List<Expense>>(context);

    // Merge & sort (most recent first)
    List<Expense> allTransactions = [...expenses, ...incomes]
      ..sort((a, b) => b.date.compareTo(a.date));

    // Apply filters
    List<Expense> filtered = allTransactions.where((t) {
      final matchQuery =
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchDate = _dateRange == null ||
          (t.date.isAtSameMomentAs(_dateRange!.start) ||
              t.date.isAfter(_dateRange!.start)) &&
              (t.date.isAtSameMomentAs(_dateRange!.end) ||
                  t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));

      return matchQuery && matchDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Clear Filters",
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _dateRange = null;
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // 📅 DATE RANGE PICKER BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _dateRange == null
                    ? 'Select Date Range'
                    : "${DateFormat('dd MMM').format(_dateRange!.start)}  →  ${DateFormat('dd MMM').format(_dateRange!.end)}",
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // LIST OF TRANSACTIONS
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      "No transactions found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final t = filtered[i];
                      final bool isIncome = incomes.any((x) => x.id == t.id);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isIncome ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            t.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "${t.category} • ${DateFormat('dd MMM yyyy').format(t.date)}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Text(
                            "${isIncome ? "+" : "-"} TZS ${t.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
