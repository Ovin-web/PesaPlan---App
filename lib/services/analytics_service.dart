import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnalyticsService({required this.uid});

  // --------------------------------------------------
  // CURRENT MONTH SPENDING
  // --------------------------------------------------
  Future<double> getCurrentMonthSpending() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
      )
          .get();

      double total = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];

        if (amount is num) {
          total += amount.toDouble();
        }
      }

      return total;
    } catch (e) {
      // ❗ NEVER crash UI or AI
      return 0.0;
    }
  }

  // --------------------------------------------------
  // AVERAGE MONTHLY SPENDING (🔥 FIXED)
  // --------------------------------------------------
  Future<double> getAverageMonthlySpending() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final Map<String, double> monthlyTotals = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final amount = data['amount'];
        final rawDate = data['date'];

        if (amount is! num || rawDate == null) continue;

        DateTime date;

        // ✅ SAFELY HANDLE FIRESTORE DATE TYPES
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is DateTime) {
          date = rawDate;
        } else {
          // ❌ Ignore corrupted / unexpected date formats
          continue;
        }

        final key = '${date.year}-${date.month}';

        monthlyTotals[key] =
            (monthlyTotals[key] ?? 0) + amount.toDouble();
      }

      if (monthlyTotals.isEmpty) return 0.0;

      final total =
      monthlyTotals.values.fold(0.0, (a, b) => a + b);

      return total / monthlyTotals.length;
    } catch (e) {
      // ❗ NEVER crash UI or AI
      return 0.0;
    }
  }
}
