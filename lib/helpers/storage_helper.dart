import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageHelper {
  static const String _incomeKey = 'income_items';
  static const String _expenseKey = 'expense_items';

  static Future<void> saveIncome(List<Expense> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_incomeKey, jsonString);
  }

  static Future<void> saveExpenses(List<Expense> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_expenseKey, jsonString);
  }

  static Future<List<Expense>> loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_incomeKey);
    if (jsonString == null) return [];
    final List list = jsonDecode(jsonString);
    return list.map((e) => Expense.fromMap(e)).toList();
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expenseKey);
    if (jsonString == null) return [];
    final List list = jsonDecode(jsonString);
    return list.map((e) => Expense.fromMap(e)).toList();
  }
}
