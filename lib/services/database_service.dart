// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/expense.dart';
import 'package:pesaplan_new/models/budget.dart';
import 'package:pesaplan_new/models/category.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference expenseCollection =
      FirebaseFirestore.instance.collection('expenses');
  final CollectionReference incomeCollection =
      FirebaseFirestore.instance.collection('incomes');
  final CollectionReference budgetCollection =
      FirebaseFirestore.instance.collection('budgets');
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await expenseCollection.doc(uid).collection('userExpenses').add(expense.toMap());
  }

  // Add income (same model)
  Future<void> addIncome(Expense income) async {
    await incomeCollection.doc(uid).collection('userIncomes').add(income.toMap());
  }

  // Budgets
  Future<void> addBudget(Budget budget) async {
    await budgetCollection.doc(uid).collection('userBudgets').add(budget.toMap());
  }

  // Categories
  Future<void> addCategory(Category category) async {
    await categoryCollection.doc(uid).collection('userCategories').add(category.toMap());
  }

  // Streams with doc id mapping
  Stream<List<Expense>> get expenses {
    return expenseCollection
        .doc(uid)
        .collection('userExpenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<Expense>> get incomes {
    return incomeCollection
        .doc(uid)
        .collection('userIncomes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<Budget>> get budgets {
    return budgetCollection
        .doc(uid)
        .collection('userBudgets')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Budget.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<Category>> get categories {
    return categoryCollection
        .doc(uid)
        .collection('userCategories')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Category.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // Monthly totals - careful with month boundaries
  Future<double> getMonthlyExpenseTotal(int month, int year) async {
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final snapshot = await expenseCollection.doc(uid).collection('userExpenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    double sum = 0.0;
    for (final d in snapshot.docs) {
      final data = d.data() as Map<String, dynamic>;
      sum += (data['amount'] ?? 0).toDouble();
    }
    return sum;
  }

  Future<double> getMonthlyIncomeTotal(int month, int year) async {
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final snapshot = await incomeCollection.doc(uid).collection('userIncomes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    double sum = 0.0;
    for (final d in snapshot.docs) {
      final data = d.data() as Map<String, dynamic>;
      sum += (data['amount'] ?? 0).toDouble();
    }
    return sum;
  }

  // Predictive suggestion: simple average of last N months
  Future<bool> willOverspendNextMonth({int months = 3}) async {
    final now = DateTime.now();
    double totalExpenses = 0.0;
    double totalIncome = 0.0;

    for (int i = 1; i <= months; i++) {
      var date = DateTime(now.year, now.month - i + 1, 1);
      int m = date.month;
      int y = date.year;
      totalExpenses += await getMonthlyExpenseTotal(m, y);
      totalIncome += await getMonthlyIncomeTotal(m, y);
    }

    final avgExpense = totalExpenses / months;
    final avgIncome = totalIncome / months;

    return avgExpense > avgIncome;
  }
}
