import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.createdAt,
  });

  // --------------------------------------------------
  // Convert SavingsGoal → Firestore Map
  // --------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // --------------------------------------------------
  // Convert Firestore → SavingsGoal
  // --------------------------------------------------
  factory SavingsGoal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return SavingsGoal(
      id: doc.id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] as num).toDouble(),
      savedAmount: (data['savedAmount'] as num).toDouble(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // --------------------------------------------------
  // Progress (0 → 1)
  // --------------------------------------------------
  double get progress {
    if (targetAmount == 0) return 0;
    return (savedAmount / targetAmount).clamp(0, 1);
  }

  // --------------------------------------------------
  // Days remaining
  // --------------------------------------------------
  int get daysRemaining {
    return deadline.difference(DateTime.now()).inDays;
  }
}
