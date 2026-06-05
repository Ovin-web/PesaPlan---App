// lib/models/budget_item.dart
class BudgetItem {
  String name;
  double amount;

  BudgetItem({required this.name, required this.amount});

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }

  // Create object from JSON
  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
