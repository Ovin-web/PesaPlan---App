import '../models/expense.dart';

// Sum up a list of expenses or incomes
double totalAmount(List<Expense> items) {
  return items.fold(0.0, (sum, item) => sum + item.amount);
}
