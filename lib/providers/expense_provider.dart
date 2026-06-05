import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../helpers/storage_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _incomeItems = [];
  List<Expense> _expenseItems = [];

  List<Expense> get incomeItems => _incomeItems;
  List<Expense> get expenseItems => _expenseItems;

  Future<void> loadItems() async {
    _incomeItems = await StorageHelper.loadIncome();
    _expenseItems = await StorageHelper.loadExpenses();
    notifyListeners();
  }

  void addIncome(Expense item) {
    _incomeItems.add(item);
    StorageHelper.saveIncome(_incomeItems);
    notifyListeners();
  }

  void addExpense(Expense item) {
    _expenseItems.add(item);
    StorageHelper.saveExpenses(_expenseItems);
    notifyListeners();
  }

  void removeIncome(int index) {
    _incomeItems.removeAt(index);
    StorageHelper.saveIncome(_incomeItems);
    notifyListeners();
  }

  void removeExpense(int index) {
    _expenseItems.removeAt(index);
    StorageHelper.saveExpenses(_expenseItems);
    notifyListeners();
  }
}
