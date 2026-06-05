// lib/helpers/storage_helper.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_item.dart';

class StorageHelper {
  static const String _incomeKey = 'income_items';
  static const String _expenseKey = 'expense_items';

  // Save income items
  static Future<void> saveIncome(List<BudgetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_incomeKey, encoded);
  }

  // Load income items
  static Future<List<BudgetItem>> loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_incomeKey);
    if (jsonString == null) return [];
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded.map((e) => BudgetItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Save expense items
  static Future<void> saveExpenses(List<BudgetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_expenseKey, encoded);
  }

  // Load expense items
  static Future<List<BudgetItem>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expenseKey);
    if (jsonString == null) return [];
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded.map((e) => BudgetItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
