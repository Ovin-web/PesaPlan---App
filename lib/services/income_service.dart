import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/income.dart';

class IncomeService {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  IncomeService({required this.uid});

  CollectionReference<Map<String, dynamic>> get _incomeRef {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('income');
  }

  // --------------------------------------------------
  // ADD INCOME (FIXED — uses Timestamp)
  // --------------------------------------------------
  Future<void> addIncome({
    required String source,
    required double amount,
    required DateTime date,
  }) async {
    await _incomeRef.add({
      'source': source,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    });
  }

  // --------------------------------------------------
  // STREAM ALL INCOME
  // --------------------------------------------------
  Stream<List<Income>> get incomeStream {
    return _incomeRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList());
  }

  // --------------------------------------------------
  // TOTAL MONTHLY INCOME
  // --------------------------------------------------
  Future<double> getCurrentMonthIncome() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);

      final snapshot = await _incomeRef
          .where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();

      double total = 0;

      for (final doc in snapshot.docs) {
        final amount = doc['amount'];
        if (amount is num) total += amount.toDouble();
      }

      return total;
    } catch (_) {
      return 0;
    }
  }

  // --------------------------------------------------
  // AVERAGE MONTHLY INCOME
  // --------------------------------------------------
  Future<double> getAverageMonthlyIncome() async {
    try {
      final snapshot = await _incomeRef.get();
      if (snapshot.docs.isEmpty) return 0;

      final Map<String, double> monthlyTotals = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        final dateField = data['date'];

        if (amount is! num || dateField == null) continue;

        DateTime date =
        (dateField as Timestamp).toDate();

        final key = '${date.year}-${date.month}';

        monthlyTotals[key] =
            (monthlyTotals[key] ?? 0) + amount.toDouble();
      }

      final total =
      monthlyTotals.values.reduce((a, b) => a + b);

      return total / monthlyTotals.length;
    } catch (_) {
      return 0;
    }
  }
}
