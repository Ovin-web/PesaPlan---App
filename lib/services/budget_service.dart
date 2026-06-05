import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/budget.dart';

class BudgetService {
  final String uid;
  BudgetService({required this.uid});

  final CollectionReference budgetCollection = FirebaseFirestore.instance.collection('budgets');

  Future<void> setBudget(String category, double amount) async {
    return await budgetCollection.doc(uid).collection('userBudgets').doc(category).set({'amount': amount, 'category': category});
  }

  Stream<List<Budget>> get budgets {
    return budgetCollection
        .doc(uid)
        .collection('userBudgets')
        .snapshots()
        .map(_budgetListFromSnapshot);
  }

  List<Budget> _budgetListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Budget.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
