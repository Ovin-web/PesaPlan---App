import 'package:cloud_firestore/cloud_firestore.dart';

class SpendingPredictionService {
  final String uid;

  SpendingPredictionService({required this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --------------------------------------------------
  // Predict next month's spending using monthly trend
  // --------------------------------------------------
  Future<double> predictNextMonthSpending() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final Map<String, double> monthlyTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        final dateField = data['date'];

        if (amount is! num || dateField == null) continue;

        DateTime date;

        if (dateField is Timestamp) {
          date = dateField.toDate();
        } else if (dateField is DateTime) {
          date = dateField;
        } else {
          continue;
        }

        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        monthlyTotals[key] =
            (monthlyTotals[key] ?? 0) + amount.toDouble();
      }

      if (monthlyTotals.length < 2) {
        return monthlyTotals.values.first;
      }

      // ✅ Sort months chronologically
      final sortedKeys = monthlyTotals.keys.toList()
        ..sort((a, b) {
          final aParts = a.split('-');
          final bParts = b.split('-');

          final aDate =
          DateTime(int.parse(aParts[0]), int.parse(aParts[1]));
          final bDate =
          DateTime(int.parse(bParts[0]), int.parse(bParts[1]));

          return aDate.compareTo(bDate);
        });

      final months =
      sortedKeys.map((k) => monthlyTotals[k]!).toList();

      // 📈 Growth-based prediction
      double growthSum = 0;
      for (int i = 1; i < months.length; i++) {
        growthSum += (months[i] - months[i - 1]);
      }

      final avgGrowth = growthSum / (months.length - 1);
      final prediction = months.last + avgGrowth;

      return prediction < 0 ? months.last : prediction;
    } catch (e) {
      return 0;
    }
  }
}
