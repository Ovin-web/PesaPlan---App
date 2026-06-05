import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/savings_goal.dart';

class SavingsGoalService {
  final String uid;

  SavingsGoalService({required this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference: users/{uid}/savings_goals
  CollectionReference<Map<String, dynamic>> get _goalRef {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('savings_goals');
  }

  // --------------------------------------------------
  // CREATE SAVINGS GOAL
  // --------------------------------------------------
  Future<void> addGoal(SavingsGoal goal) async {
    await _goalRef.add(goal.toMap());
  }

  // --------------------------------------------------
  // UPDATE SAVINGS GOAL
  // --------------------------------------------------
  Future<void> updateGoal(SavingsGoal goal) async {
    await _goalRef.doc(goal.id).update(goal.toMap());
  }

  // --------------------------------------------------
  // DELETE SAVINGS GOAL
  // --------------------------------------------------
  Future<void> deleteGoal(String goalId) async {
    await _goalRef.doc(goalId).delete();
  }

  // --------------------------------------------------
  // ADD MONEY TO A GOAL
  // --------------------------------------------------
  Future<void> addToGoal({
    required String goalId,
    required double amount,
  }) async {
    final doc = _goalRef.doc(goalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);

      if (!snapshot.exists) return;

      final current =
          (snapshot.data()!['savedAmount'] as num).toDouble();

      transaction.update(doc, {
        'savedAmount': current + amount,
      });
    });
  }

  // --------------------------------------------------
  // STREAM SAVINGS GOALS (REAL-TIME)
  // --------------------------------------------------
  Stream<List<SavingsGoal>> streamGoals() {
    return _goalRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SavingsGoal.fromFirestore(doc))
          .toList();
    });
  }

  // --------------------------------------------------
  // FETCH GOALS ONCE (FOR AI COACHING)
  // --------------------------------------------------
  Future<List<SavingsGoal>> fetchGoalsOnce() async {
    final snapshot = await _goalRef.get();

    return snapshot.docs
        .map((doc) => SavingsGoal.fromFirestore(doc))
        .toList();
  }
}
