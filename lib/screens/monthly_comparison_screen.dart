import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pesaplan_new/models/expense.dart';
import 'package:intl/intl.dart';

class MonthlyComparisonScreen extends StatelessWidget {
  const MonthlyComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<List<Expense>>(context);
    final incomes = Provider.of<List<Expense>>(context);

    if (expenses.isEmpty && incomes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Monthly Income vs Expense")),
        body: const Center(
          child: Text("No data available yet."),
        ),
      );
    }

    final monthlyData = _calculateMonthlyTotals(incomes, expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Income vs Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: _getMaxY(monthlyData),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(
                              monthlyData[value.toInt()].month,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(monthlyData),
                ),
                swapAnimationDuration: const Duration(milliseconds: 900),
                swapAnimationCurve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // DATA PROCESSING
  // ───────────────────────────────────────────────────────────────

  List<_MonthlyTotals> _calculateMonthlyTotals(
      List<Expense> incomes, List<Expense> expenses) {
    final Map<String, _MonthlyTotals> map = {};

    for (var income in incomes) {
      final key = DateFormat('yyyy-MM').format(income.date);
      map.putIfAbsent(key, () => _MonthlyTotals.empty(key));
      map[key]!.income += income.amount;
    }

    for (var exp in expenses) {
      final key = DateFormat('yyyy-MM').format(exp.date);
      map.putIfAbsent(key, () => _MonthlyTotals.empty(key));
      map[key]!.expense += exp.amount;
    }

    // Convert to sorted list
    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => map[k]!).toList();
  }

  double _getMaxY(List<_MonthlyTotals> data) {
    double max = 0.0;
    for (var m in data) {
      if (m.income > max) max = m.income;
      if (m.expense > max) max = m.expense;
    }
    return max * 1.25;
  }

  // ───────────────────────────────────────────────────────────────
  // BAR GROUP BUILDER
  // ───────────────────────────────────────────────────────────────

  List<BarChartGroupData> _buildBarGroups(List<_MonthlyTotals> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barsSpace: 12,
        barRods: [
          BarChartRodData(
            toY: data[index].income,
            color: Colors.green.shade600,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data[index].expense,
            color: Colors.red.shade600,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // ───────────────────────────────────────────────────────────────
  // LEGEND WIDGET
  // ───────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.green.shade600, "Income"),
        const SizedBox(width: 20),
        _legendItem(Colors.red.shade600, "Expenses"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────
// MONTHLY MODEL FOR CHART
// ───────────────────────────────────────────────────────────────

class _MonthlyTotals {
  final String month; // MMM
  double income;
  double expense;

  _MonthlyTotals({required this.month, required this.income, required this.expense});

  factory _MonthlyTotals.empty(String key) {
    final date = DateFormat('yyyy-MM').parse('$key-01');
    return _MonthlyTotals(
      month: DateFormat('MMM').format(date),
      income: 0,
      expense: 0,
    );
  }
}
