import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/expense.dart';

class ExpenseService {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExpenseService({required this.uid});

  // --------------------------------------------------
  // FIRESTORE REFERENCE
  // users/{uid}/expenses
  // --------------------------------------------------
  CollectionReference<Map<String, dynamic>> get _expenseRef {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses');
  }

  // --------------------------------------------------
  // ADD EXPENSE (🔥 FIXED: SAFE + FAST)
  // --------------------------------------------------
  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseRef.add({
        ...expense.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ❗ Never freeze UI
      rethrow;
    }
  }

  // --------------------------------------------------
  // UPDATE EXPENSE
  // --------------------------------------------------
  Future<void> updateExpense(Expense expense) async {
    if (expense.id.isEmpty) return;

    try {
      await _expenseRef.doc(expense.id).update(expense.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------
  // DELETE EXPENSE
  // --------------------------------------------------
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenseRef.doc(expenseId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------
  // STREAM ALL EXPENSES (REAL-TIME)
  // --------------------------------------------------
  Stream<List<Expense>> streamExpenses() {
    return _expenseRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
    });
  }

  // --------------------------------------------------
  // FETCH EXPENSES ONCE (AI / ANALYTICS SAFE)
  // --------------------------------------------------
  Future<List<Expense>> fetchExpensesOnce() async {
    try {
      final snapshot = await _expenseRef.get();

      return snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
    } catch (e) {
      // ❗ AI must never crash
      return [];
    }
  }
}
